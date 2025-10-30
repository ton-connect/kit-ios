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
            
            try await context.initWalletKit(configuration, AnyJSValueEncodable(storage as Any))
            
            sharedPool.store(configuration: configuration, walletKitContext: context)
            return TONWalletKit(context: context)
        }
        
        return TONWalletKit(context: context)
    }
    
    private func add(_ walletAdapter: Any, _ version: TONWalletVersion) async throws -> TONWalletProtocol {
        let wallet = try await context.walletKit.addWallet(AnyJSValueEncodable(walletAdapter))
        let address: String = try await wallet.getAddress()

        return TONWallet(wallet: wallet, address: address, version: version)
    }
    
    public func addV4R2Wallet(mnemonic: TONMnemonic, parameters: TONV4R2WalletParameters) async throws -> any TONWalletProtocol {
        try await add(try await context.walletKit.createV4R2WalletUsingMnemonic(mnemonic.value, parameters), .v4r2)
    }
    
    public func addV4R2Wallet(secretKey: Data, parameters: TONV4R2WalletParameters) async throws -> any TONWalletProtocol {
        let data = [UInt8](secretKey)
        let wallet = try await context.walletKit.createV4R2WalletUsingSecretKey(AnyJSValueEncodable(data), parameters)
        return try await add(wallet, .v4r2)
    }
    
    public func addV4R2Wallet(signer: any TONWalletSigner, parameters: TONV4R2WalletParameters) async throws -> any TONWalletProtocol {
        let signer = TONWalletSignerAdapter(context: context, signer: signer)
        let wallet = try await context.walletKit.createV4R2WalletUsingSigner(AnyJSValueEncodable(signer), parameters)
        return try await add(wallet, .v4r2)
    }
    
    public func addV5R1Wallet(mnemonic: TONMnemonic, parameters: TONV5R1WalletParameters) async throws -> any TONWalletProtocol {
        try await add(try await context.walletKit.createV5R1WalletUsingMnemonic(mnemonic.value, parameters), .v5r1)
    }
    
    public func addV5R1Wallet(secretKey: Data, parameters: TONV5R1WalletParameters) async throws -> any TONWalletProtocol {
        let data = [UInt8](secretKey)
        let wallet = try await context.walletKit.createV5R1WalletUsingSecretKey(AnyJSValueEncodable(data), parameters)
        return try await add(try await context.walletKit.createV5R1WalletUsingSecretKey(wallet, parameters), .v5r1)
    }
    
    public func addV5R1Wallet(signer: any TONWalletSigner, parameters: TONV5R1WalletParameters) async throws -> any TONWalletProtocol {
        let signer = TONWalletSignerAdapter(context: context, signer: signer)
        let wallet = try await context.walletKit.createV5R1WalletUsingSigner(AnyJSValueEncodable(signer), parameters)
        return try await add(wallet, .v5r1)
    }
    
    public func add(walletAdapter: TONWalletAdapter) async throws -> TONWalletProtocol {
        let wallet = TONWalletJSAdapter(context: context, wallet: walletAdapter)
        return try await add(wallet, walletAdapter.version)
    }
    
    public func wallets() throws -> [any TONWalletProtocol] {
        let value: JSValue = try context.walletKit.getWallets()
        let jsWallets = value.toArray().compactMap { JSValue(object: $0, in: context) }
        
        var wallets: [TONWallet] = []
        
        for jsWallet in jsWallets {
            let wallet = TONWallet(
                wallet: jsWallet,
                address: try jsWallet.getAddress(),
                version: TONWalletVersion(value: jsWallet.version)
            )
            wallets.append(wallet)
        }
        return wallets
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
        if let adapter = eventHandlersAdapters.first(where: { $0 == eventsHandler }) {
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
