//
//  WKWebView+Injection.swift
//  TONWalletKit
//
//  Created by Nikita Rodionov on 07.11.2025.
//  
//  Copyright (c) 2025 TON Connect
//
//  Permission is hereby granted, free of charge, to any person obtaining a copy
//  of this software and associated documentation files (the "Software"), to deal
//  in the Software without restriction, including without limitation the rights
//  to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
//  copies of the Software, and to permit persons to whom the Software is
//  furnished to do so, subject to the following conditions:
//  
//  The above copyright notice and this permission notice shall be included in all
//  copies or substantial portions of the Software.
//  
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
//  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
//  SOFTWARE.

import Foundation
import Combine
import WebKit

public extension WKWebView {
    
    func inject(walletKit: TONWalletKit, key: String? = nil) throws {
        #if DEBUG
        if #available(iOS 16.4, *) {
            self.isInspectable = true
        }
        #endif
        
        let options = TONBridgeInjectOptions(
            deviceInfo: walletKit.configuration.deviceInfo,
            walletInfo: walletKit.configuration.walletManifest,
            jsBridgeKey: key,
            injectTonKey: nil,
            isWalletBrowser: true
        )
        
        let encoder = JSONEncoder()
        let jsonData = try encoder.encode(options)
        let jsonString = String(data: jsonData, encoding: .utf8)!
        
        let injectionScriptSource = """
            \(try JSWalletKitInjectionScript().load())
            window.injectWalletKit(\(jsonString));
        """
        let injectionScript = WKUserScript(
            source: injectionScriptSource,
            injectionTime: .atDocumentStart,
            forMainFrameOnly: false,
        )
        
        configuration.userContentController.addUserScript(injectionScript)
        configuration.userContentController.addScriptMessageHandler(
            TONWalletKitInjectionMessagesHandler(injectableBridge: walletKit.injectableBridge()),
            contentWorld: .page,
            name: "walletKitInjectionBridge"
        )
    }
}

private class TONWalletKitInjectionMessagesHandler: NSObject, WKScriptMessageHandlerWithReply {
    private let injectableBridge: TONWalletKit.InjectableBridge
    private var subscribers: [String: AnyCancellable] = [:]
    
    private let defaultTimeout: Int = 10000
    
    init(injectableBridge: TONWalletKit.InjectableBridge) {
        self.injectableBridge = injectableBridge
    }
    
    func userContentController(
        _ userContentController: WKUserContentController,
        didReceive message: WKScriptMessage,
        replyHandler: @escaping @MainActor (Any?, String?) -> Void
    ) {
        let domain = message.frameInfo.request.url.flatMap {
            let components = URLComponents(url: $0, resolvingAgainstBaseURL: false)
            return components?.host
        }
        
        let messageID = UUID().uuidString
        let messageDictionary = message.body as? [String: Any]
        
        let eventMessage = TONBridgeEventMessage(
            messageId: messageID,
            tabId: messageDictionary?["frameID"] as? String,
            domain: domain
        )
        
        let timeout = messageDictionary?["timeout"] as? Int
        
        subscribers[messageID] = injectableBridge.waitForResponse()
            .filter { $0.messageID == messageID }
            .prefix(1)
            .timeout(.milliseconds(timeout ?? defaultTimeout), scheduler: DispatchQueue.main) {
                "Timeout waiting for response for message with ID \(messageID)"
            }
            .sink(receiveCompletion: { [weak self] completion in
                if case .failure(let error) = completion {
                    replyHandler(nil, error.localizedDescription)
                }
                self?.subscribers.removeValue(forKey: messageID)
            }, receiveValue: { value in
                replyHandler(value.message?.value, nil)
            })

        Task { @MainActor [weak self] in
            do {
                try await injectableBridge.request(message: eventMessage, request: message.body)
            } catch {
                self?.subscribers.removeValue(forKey: messageID)
                replyHandler(nil, error.localizedDescription)
            }
        }
    }
}

