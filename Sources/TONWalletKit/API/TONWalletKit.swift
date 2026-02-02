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
    let configuration: TONWalletKitConfiguration
    
    private let contextProvider = TONWalletKitContextProvider()
    private var context: JSWalletKitContext? {
        didSet {
            guard let context else { return }
            
            if context !== oldValue {
                addHandlers(to: context)
            }
        }
    }
    
    private var pendingEventHandlers: [any TONBridgeEventsHandler] = []
    private var eventHandlers: [TONBridgeEventsHandlerJSAdapter] = []
    
    public var isInitialized: Bool { context != nil }
    
    deinit {
        eventHandlers.forEach { $0.invalidate() }
    }
    
    public init(configuration: TONWalletKitConfiguration) {
        self.configuration = configuration
    }
    
    public func initialize() async throws {
        if isInitialized { return }
        
        self.context = try await contextProvider.context(for: configuration)
    }
    
    public func signer(mnemonic: TONMnemonic) async throws -> any TONWalletSignerProtocol {
        let signer = try await jsWalletKit().createSignerFromMnemonic(mnemonic.value)
        
        return TONWalletSigner(jsWalletSigner: signer)
    }
    
    public func signer(privateKey: Data) async throws -> any TONWalletSignerProtocol {
        let data = [UInt8](privateKey)
        let signer = try await jsWalletKit().createSignerFromPrivateKey(data)
        
        return TONWalletSigner(jsWalletSigner: signer)
    }
    
    public func walletV4R2Adapter(
        signer: any TONWalletSignerProtocol,
        parameters: TONV4R2WalletParameters
    ) async throws -> any TONWalletAdapterProtocol {
        let signer = TONEncodableWalletSigner(signer: signer)
        let adapter = try await jsWalletKit().createV4R2WalletAdapter(signer, parameters)
        
        return TONWalletAdapter(jsWalletAdapter: adapter)
    }
    
    public func walletV5R1Adapter(
        signer: any TONWalletSignerProtocol,
        parameters: TONV5R1WalletParameters
    ) async throws -> any TONWalletAdapterProtocol {
        let signer = TONEncodableWalletSigner(signer: signer)
        let adapter = try await jsWalletKit().createV5R1WalletAdapter(signer, parameters)
        
        return TONWalletAdapter(jsWalletAdapter: adapter)
    }

    public func add(walletAdapter: any TONWalletAdapterProtocol) async throws -> any TONWalletProtocol {
        let walletAdapter = TONEncodableWalletAdapter(walletAdapter: walletAdapter)
        let wallet = try await jsWalletKit().addWallet(walletAdapter)
        let address: String = try await wallet.getAddress()
        let id: String = try await wallet.getWalletId()
        
        return TONWallet(
            jsWallet: wallet,
            id: id,
            address: try TONUserFriendlyAddress(value: address)
        )
    }
    
    public func wallet(id: TONWalletID) async throws -> any TONWalletProtocol {
        let wallet: JSValue = try await jsWalletKit().getWallet(id)
        let address: String = try await wallet.getAddress()
        
        return TONWallet(
            jsWallet: wallet,
            id: id,
            address: try TONUserFriendlyAddress(value: address),
        )
    }
    
    public func wallets() async throws -> [any TONWalletProtocol] {
        let value: JSValue = try await jsWalletKit().getWallets()
        let jsWallets = value.toObjectsArray()
        
        return try jsWallets.map {
            let wallet: TONWallet = try $0.decode()
            return wallet
        }
    }

    public func send(
        transaction: TONTransactionRequest,
        from wallet: any TONWalletProtocol
    ) async throws {
        try await jsWalletKit().sendTransaction(TONEncodableWallet(wallet: wallet), transaction)
    }
        
    public func connect(url: String) async throws {
        var components = URLComponents(string: url)
        
        if components?.scheme == nil {
            components?.scheme = "tc"
        }
        try await jsWalletKit().handleTonConnectUrl(components?.url?.absoluteString ?? url)
    }
      
    public func remove(walletId: TONWalletID) async throws {
        try await jsWalletKit().removeWallet(walletId)
    }
    
    public func add(eventsHandler: any TONBridgeEventsHandler) throws {
        if pendingEventHandlers.contains(where: { $0 === eventsHandler }) {
            return
        }
        
        if eventHandlers.contains(where: { $0 == eventsHandler }) {
            return
        }
        
        guard let context else {
            pendingEventHandlers.append(eventsHandler)
            return
        }
        
        let adapter = TONBridgeEventsHandlerJSAdapter(handler: eventsHandler, context: context)
        
        try context.add(eventsHandler: adapter)
        
        eventHandlers.append(adapter)
    }
    
    public func remove(eventsHandler: any TONBridgeEventsHandler) throws {
        pendingEventHandlers.removeAll { $0 === eventsHandler }
        
        if let adapter = eventHandlers.first(where: { $0 == eventsHandler }) {
            try context?.remove(eventsHandler: adapter)
        }
        
        eventHandlers.removeAll { $0 == eventsHandler }
    }
    
    private func addHandlers(to context: JSWalletKitContext) {
        if pendingEventHandlers.isEmpty {
            return
        }
        
        for handler in pendingEventHandlers {
            let adapter = TONBridgeEventsHandlerJSAdapter(handler: handler, context: context)
            
            do {
                try context.add(eventsHandler: adapter)
                eventHandlers.append(adapter)
            } catch {
                debugPrint("Unable to add event handler: \(error)")
            }
        }
        
        pendingEventHandlers.removeAll()
    }
    
    func injectableBridge() throws -> TONWalletKitInjectableBridge {
        guard let context else {
            throw "Unable to resolve bridge for injection. WalletKit is not initialized"
        }
        
        return TONWalletKitInjectableBridge(
            jsWalletKit: context.walletKit,
            bridgeTransport: context.bridgeTransport
        )
    }
    
    func jsWalletKit() async throws -> JSDynamicObject {
        if let context {
            return context.walletKit
        }
        
        try await initialize()
        
        if let context {
            return context.walletKit
        } else {
            throw "Unable to resolve initialized Wallet Kit instance"
        }
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

private actor TONWalletKitContextProvider {
    private var result: Result<JSWalletKitContext, Error>?
    private var task: Task<JSWalletKitContext, Error>?
    
    func context(for configuration: TONWalletKitConfiguration) async throws -> JSWalletKitContext {
        if let result {
            switch result {
            case .success(let context):
                return context
            case .failure(let error):
                throw error
            }
        } else if let task {
            return try await task.value
        }
        
        let task = Task {
            do {
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
                
                self.result = .success(context)
                self.task = nil
                
                return context
            } catch {
                self.result = .failure(error)
                self.task = nil
                
                throw error
            }
        }
        return try await task.value
    }
}
