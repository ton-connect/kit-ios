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
import WebKit

public extension WKWebView {
    func inject(walletKit: TONWalletKit) throws {
        #if DEBUG
        if #available(iOS 16.4, *) {
            self.isInspectable = true
        }
        #endif
        
        let injectionScriptSource = """
            \(try JSWalletKitInjectionScript().load())
            window.injectWalletKit();
        """
        let injectionScript = WKUserScript(
            source: injectionScriptSource,
            injectionTime: .atDocumentStart,
            forMainFrameOnly: false,
        )
        
        configuration.userContentController.addUserScript(injectionScript)
        configuration.userContentController.addScriptMessageHandler(
            TONWalletKitInjectionMessagesHandler(walletKit: walletKit),
            contentWorld: .page,
            name: "tonConnectBridge"
        )
    }
}

private struct JSWalletKitInjectionScript: JSScript {

    func load() throws -> String {
        let jsFile = "inject"
        
        guard let path = Bundle.module.path(forResource: jsFile, ofType: "mjs") else {
            throw "Unable to find \(jsFile).mjs file"
        }
        
        var code = try String(contentsOfFile: path, encoding: .utf8)
        
        code = code.replacingOccurrences(
            of: "export {\n  A3 as main\n};",
            with: """
            var main = A3;
            main();
            """
        )
        
        return code
    }
}

private class TONWalletKitInjectionMessagesHandler: NSObject, WKScriptMessageHandlerWithReply {
    private let walletKit: TONWalletKit
    
    init(walletKit: TONWalletKit) {
        self.walletKit = walletKit
    }
    
    func userContentController(_ userContentController: WKUserContentController, didReceive message: WKScriptMessage) async -> (Any?, String?) {
        let domain = message.frameInfo.request.url.flatMap {
            let components = URLComponents(url: $0, resolvingAgainstBaseURL: false)
            return components?.host
        }
        
        let eventMessage = TONBridgeEventMessage(messageId: UUID().uuidString, tabId: "", domain: domain)
        
        do {
            let result = try await walletKit.processInjectedBridgeRequest(message: eventMessage, request: message.body)
            return (result, nil)
        } catch {
            return (nil, error.localizedDescription)
        }
    }
}
