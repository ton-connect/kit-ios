//
//  TONWalletKit.swift
//  TONWalletKit
//
//  Created by Nikita Rodionov on 12.09.2025.
//

import Foundation

public class TONWalletKit {
    private static let sharedPool = TONWalletKitReusableContextPool()
    
    private let context: JSWalletKitContext
    private var eventHandlersAdapters: [TONBridgeEventsHandlerAdapter] = []
    
    deinit {
        eventHandlersAdapters.forEach { $0.invalidate() }
    }
    
    init(context: JSWalletKitContext) {
        self.context = context
    }
    
    public static func initialize(
        configuration: TONWalletKitConfiguration,
        storage: TONWalletKitStorageType
    ) async throws -> TONWalletKit {
        guard let context = sharedPool.fetch(configuration: configuration) else {
            let context = JSWalletKitContext()
            try await context.load(script: JSWalletKitScript())
            
            let storage = storage.jsStorage(context: context)
            
            try await context.initWalletKit(configuration, storage)
            
            sharedPool.store(configuration: configuration, walletKitContext: context)
            return TONWalletKit(context: context)
        }
        
        return TONWalletKit(context: context)
    }
    
    private func add(_ walletAdapter: Any?, _ version: TONWalletVersion) async throws -> TONWalletProtocol {
        guard let walletAdapter, let wallet = try await context.walletKit.addWallet(walletAdapter) else {
            throw "No wallet added"
        }
        let address = try await wallet.getAddress()?.toString()

        return TONWallet(wallet: wallet, address: address, version: version)
    }
    
    public func addV4R2Wallet(mnemonic: TONMnemonic, parameters: TONV4R2WalletParameters) async throws -> any TONWalletProtocol {
        try await add(try await context.walletKit.createV4R2WalletUsingMnemonic(mnemonic.value, parameters), .v4r2)
    }
    
    public func addV4R2Wallet(secretKey: Data, parameters: TONV4R2WalletParameters) async throws -> any TONWalletProtocol {
        let data = [UInt8](secretKey)
        return try await add(try await context.walletKit.createV4R2WalletUsingSecretKey(data, parameters), .v4r2)
    }
    
    public func addV4R2Wallet(signer: any TONWalletSigner, parameters: TONV4R2WalletParameters) async throws -> any TONWalletProtocol {
        let signer = TONWalletSignerAdapter(context: context, signer: signer)
        return try await add(try await context.walletKit.createV4R2WalletUsingSigner(signer, parameters), .v4r2)
    }
    
    public func addV5R1Wallet(mnemonic: TONMnemonic, parameters: TONV5R1WalletParameters) async throws -> any TONWalletProtocol {
        try await add(try await context.walletKit.createV5R1WalletUsingMnemonic(mnemonic.value, parameters), .v5r1)
    }
    
    public func addV5R1Wallet(secretKey: Data, parameters: TONV5R1WalletParameters) async throws -> any TONWalletProtocol {
        let data = [UInt8](secretKey)
        return try await add(try await context.walletKit.createV5R1WalletUsingSecretKey(data, parameters), .v5r1)
    }
    
    public func addV5R1Wallet(signer: any TONWalletSigner, parameters: TONV5R1WalletParameters) async throws -> any TONWalletProtocol {
        let signer = TONWalletSignerAdapter(context: context, signer: signer)
        return try await add( try await context.walletKit.createV5R1WalletUsingSigner(signer, parameters), .v5r1)
    }
    
    public func add(walletAdapter: TONWalletAdapter) async throws -> TONWalletProtocol {
        let wallet = TONWalletJSAdapter(context: context, wallet: walletAdapter)
        return try await add(wallet, walletAdapter.version)
    }
        
    public func connect(url: String) async throws {
        try await context.walletKit.handleTonConnectUrl(url)
    }
      
    public func remove(walletAddress: String) async throws {
        try await context.walletKit.removeWallet(walletAddress)
    }
    
    public func add(eventsHandler: TONBridgeEventsHandler) async throws {
        if eventHandlersAdapters.contains(where: { $0 == eventsHandler }) {
            return
        }
        
        let adapter = TONBridgeEventsHandlerAdapter(handler: eventsHandler, context: context)
        
        try await context.add(eventsHandler: adapter)
        
        eventHandlersAdapters.append(adapter)
    }
    
    public func remove(eventsHandler: TONBridgeEventsHandler) async throws {
        if let adapter = eventHandlersAdapters.first { $0 == eventsHandler } {
            try await context.remove(eventsHandler: adapter)
            
            eventHandlersAdapters.removeAll { $0 === adapter }
        }
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

    func jsStorage(context: JSContext) -> (any JSWalletKitStorage)? {
        switch self {
        case .memory: nil
        case .keychain: TONWalletKitStorageAdapter(
            context: context,
            storage: TONWalletKitKeychainStorage()
        )
        case .custom(let value): TONWalletKitStorageAdapter(
            context: context,
            storage: value
        )
        }
    }
}
