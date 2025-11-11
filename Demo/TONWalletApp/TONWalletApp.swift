//
//  TONWalletApp.swift
//  TONWalletApp
//
//  Created by Nikita Rodionov on 11.09.2025.
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
import SwiftUI
import TONWalletKit

@main
struct TONWalletApp: App {
    @State var initialized = false
    
    var body: some Scene {
        WindowGroup {
            if initialized {
                TONWalletAppView()
            } else {
                ProgressView()
                    .task {
                        do {
                            try await TONWalletKit.mainnet()
                            initialized = true
                        } catch {
                            debugPrint(error.localizedDescription)
                        }
                    }
            }
        }
    }
}

extension TONWalletKit {
    
    private static var _mainnet: TONWalletKit?
    
    @discardableResult
    static func mainnet() async throws -> TONWalletKit {
        if let _mainnet {
            return _mainnet
        }
        let bridgeURL = "https://bridge.tonapi.io/bridge"
        
        let configuration = TONWalletKitConfiguration(
            network: .mainnet,
            walletManifest: TONWalletKitConfiguration.Manifest(
                name: "WalletKitDemoWallet",
                appName: "wallet_kit_demo_wallet",
                imageUrl: "https://example.com/image.png",
                aboutUrl: "https://example.com/about",
                universalLink: "https://example.com/universal-link",
                bridgeUrl: bridgeURL
            ),
            bridge: TONWalletKitConfiguration.Bridge(bridgeUrl: bridgeURL, webViewInjectionKey: "walletKitDemoWallet"),
            apiClient: TONWalletKitConfiguration.APIClient(key: "25a9b2326a34b39a5fa4b264fb78fb4709e1bd576fc5e6b176639f5b71e94b0d"),
            features: [
                TONWalletKitConfiguration.SendTransactionFeature(maxMessages: 1),
                TONWalletKitConfiguration.SignDataFeature(types: [.text, .binary, .cell]),
            ]
        )
        let kit = try await TONWalletKit.initialize(configuration: configuration, storage: .keychain)
        _mainnet = kit
        return kit
    }
}
