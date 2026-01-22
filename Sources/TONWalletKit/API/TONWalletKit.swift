//
//  TONWalletKit.swift
//  TONWalletKit
//
//  Created by Nikita Rodionov on 12.09.2025.
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

public class TONWalletKit {
    private static let sharedPool = TONWalletKitReusableContextPool()
    
    let configuration: TONWalletKitConfiguration
    private let context: JSWalletKitContext
    
    private var walletKit: any JSDynamicObject { context.walletKit }
    private var eventHandlersAdapters: [TONBridgeEventsHandlerJSAdapter] = []
    
    deinit {
        eventHandlersAdapters.forEach { $0.invalidate() }
    }
    
    init(
        configuration: TONWalletKitConfiguration,
        context: JSWalletKitContext
    ) {
        self.configuration = configuration
        self.context = context
    }
    
    public static func initialize(configuration: TONWalletKitConfiguration) async throws -> TONWalletKit {
        guard let context = sharedPool.fetch(configuration: configuration) else {
            let context = JSWalletKitContext()
            try await context.load(script: JSWalletKitScript())
            
            let storage = configuration.storage.jsStorage(context: context)
            let sessionManager: any JSValueEncodable = configuration.sessionManager.map {
                TONConnectSessionsManagerJSAdapter(
                    context: context,
                    sessionsManager: $0
                )
            }
            let apiClients = configuration.networkConfigurations.compactMap { config -> TONAPIClientJSAdapter? in
                guard let apiClient = config.apiClient else { return nil }
                
                return TONAPIClientJSAdapter(
                    context: context,
                    apiClient: apiClient,
                    network: config.network
                )
            }
            
            try await context.initializeWalletKit(
                configuration: configuration,
                storage: AnyJSValueEncodable(storage),
                sessionManager: sessionManager,
                apiClients: apiClients,
            )
            
            sharedPool.store(configuration: configuration, walletKitContext: context)
            return TONWalletKit(configuration: configuration, context: context)
        }
        
        return TONWalletKit(configuration: configuration, context: context)
    }
    
    public func signer(mnemonic: TONMnemonic) async throws -> any TONWalletSignerProtocol {
        let signer = try await walletKit.createSignerFromMnemonic(mnemonic.value)
        
        return TONWalletSigner(jsWalletSigner: signer)
    }
    
    public func signer(privateKey: Data) async throws -> any TONWalletSignerProtocol {
        let data = [UInt8](privateKey)
        let signer = try await walletKit.createSignerFromPrivateKey(data)
        
        return TONWalletSigner(jsWalletSigner: signer)
    }
    
    public func walletV4R2Adapter(
        signer: any TONWalletSignerProtocol,
        parameters: TONV4R2WalletParameters
    ) async throws -> any TONWalletAdapterProtocol {
        let signer = TONEncodableWalletSigner(signer: signer)
        let adapter = try await walletKit.createV4R2WalletAdapter(signer, parameters)
        
        return TONWalletAdapter(jsWalletAdapter: adapter, version: .v4r2)
    }
    
    public func walletV5R1Adapter(
        signer: any TONWalletSignerProtocol,
        parameters: TONV5R1WalletParameters
    ) async throws -> any TONWalletAdapterProtocol {
        let signer = TONEncodableWalletSigner(signer: signer)
        let adapter = try await walletKit.createV5R1WalletAdapter(signer, parameters)
        
        return TONWalletAdapter(jsWalletAdapter: adapter, version: .v5r1)
    }

    public func add(walletAdapter: any TONWalletAdapterProtocol) async throws -> any TONWalletProtocol {
        let walletAdapter = TONEncodableWalletAdapter(walletAdapter: walletAdapter)
        let wallet = try await walletKit.addWallet(walletAdapter)
        let address: String = try await wallet.getAddress()
        let id: String = try await wallet.getWalletId()
        
        return TONWallet(
            jsWallet: wallet,
            id: id,
            address: try TONUserFriendlyAddress(value: address)
        )
    }
    
    public func wallet(id: TONWalletID) throws -> any TONWalletProtocol {
        let wallet: JSValue = try walletKit.getWallet(id)
        let address: String = try wallet.getAddress()
        
        return TONWallet(
            jsWallet: wallet,
            id: id,
            address: try TONUserFriendlyAddress(value: address),
        )
    }
    
    public func wallets() async throws -> [any TONWalletProtocol] {
        let value: JSValue = try await walletKit.getWallets()
        let jsWallets = value.toObjectsArray()
        
        return try jsWallets.map {
            let wallet: TONWallet = try $0.decode()
            return wallet
        }
    }

    public func send(transaction: TONTransactionRequest, from wallet: any TONWalletProtocol) async throws {
        try await walletKit.sendTransaction(TONEncodableWallet(wallet: wallet), transaction)
    }
        
    public func connect(url: String) async throws {
        try await walletKit.handleTonConnectUrl(url)
    }
      
    public func remove(walletId: TONWalletID) async throws {
        try await walletKit.removeWallet(walletId)
    }
    
    public func add(eventsHandler: TONBridgeEventsHandler) async throws {
        if eventHandlersAdapters.contains(where: { $0 == eventsHandler }) {
            return
        }
        
        let adapter = TONBridgeEventsHandlerJSAdapter(handler: eventsHandler, context: context)
        
        try await context.add(eventsHandler: adapter)
        
        eventHandlersAdapters.append(adapter)
    }
    
    public func remove(eventsHandler: TONBridgeEventsHandler) async throws {
        if let adapter = eventHandlersAdapters.first(where: { $0 == eventsHandler }) {
            try await context.remove(eventsHandler: adapter)
            
            eventHandlersAdapters.removeAll { $0 === adapter }
        }
    }
    
    func injectableBridge() -> TONWalletKitInjectableBridge {
        TONWalletKitInjectableBridge(
            walletKit: walletKit,
            bridgeTransport: context.bridgeTransport
        )
    }
}

private class TONWalletKitReusableContextPool {
    private var pool: [TONWalletKitConfiguration: WeakValueWrapper<JSWalletKitContext>] = [:]
    
    func fetch(configuration: TONWalletKitConfiguration) -> JSWalletKitContext? {
        pool[configuration]?.value
    }
    
    func store(configuration: TONWalletKitConfiguration, walletKitContext: JSWalletKitContext) {
        pool[configuration] = WeakValueWrapper(value: walletKitContext)
    }
}

private extension TONWalletKitStorageType {

    func jsStorage(context: JSContext) -> (any JSValueEncodable)? {
        switch self {
        case .memory: nil
        case .keychain:
            TONWalletKitStorageJSAdapter(
                context: context,
                storage: TONWalletKitKeychainStorage()
            )
        case .custom(let value):
            TONWalletKitStorageJSAdapter(
                context: context,
                storage: value
            )
        }
    }
}
