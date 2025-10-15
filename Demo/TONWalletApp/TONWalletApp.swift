//
//  TONWalletApp.swift
//  TONWalletApp
//
//  Created by Nikita Rodionov on 11.09.2025.
//

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
                        let bridgeURL = "https://bridge.tonapi.io/bridge"
                        
                        let configuration = TONWalletKitConfiguration(
                            network: .mainnet,
                            walletManifest: TONWalletKitConfiguration.Manifest(
                                name: "TON Wallet Demo App",
                                appName: "Wallet",
                                imageUrl: "https://example.com/image.png",
                                aboutUrl: "https://example.com/about",
                                universalLink: "https://example.com/universal-link",
                                bridgeUrl: bridgeURL
                            ),
                            bridge: TONWalletKitConfiguration.Bridge(bridgeUrl: bridgeURL),
                            apiClient: TONWalletKitConfiguration.APIClient(key: "25a9b2326a34b39a5fa4b264fb78fb4709e1bd576fc5e6b176639f5b71e94b0d"),
                            features: [
                                TONWalletKitConfiguration.SendTransactionFeature(maxMessages: 1),
                                TONWalletKitConfiguration.SignDataFeature(types: [.text, .binary, .cell]),
                            ],
                            storage: .keychain
                        )
                        do {
                            let kit = try await TONWalletKit.initialize(configuration: configuration)
                            try await kit?.add(eventHandler: TONEventsHandler.shared)
                            initialized = true
                        } catch {
                            debugPrint(error.localizedDescription)
                        }
                    }
            }
        }
    }
}
