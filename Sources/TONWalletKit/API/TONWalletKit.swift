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
import Combine

public class TONWalletKit {
    private static let sharedPool = TONWalletKitReusableContextPool()
    
    let configuration: TONWalletKitConfiguration
    private let context: JSWalletKitContext
    
    private var walletKit: any JSDynamicObject { context.walletKit }
    private var eventHandlersAdapters: [TONBridgeEventsHandlerAdapter] = []
    
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
    
    public static func initialize(
        configuration: TONWalletKitConfiguration,
        storage: TONWalletKitStorageType
    ) async throws -> TONWalletKit {
        guard let context = sharedPool.fetch(configuration: configuration) else {
            let context = JSWalletKitContext()
            try await context.load(script: JSWalletKitScript())
            
            let storage = storage.jsStorage(context: context)
            
            try await context.initializeWalletKit(
                configuration: configuration,
                storage: AnyJSValueEncodable(storage)
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
        let signer = TONWalletSignerAdapter(context: context, signer: signer)
        let adapter = try await walletKit.createV4R2WalletAdapter(AnyJSValueEncodable(signer), parameters)
        return TONWalletAdapter(jsWalletAdapter: adapter, version: .v4r2)
    }
    
    public func walletV5R1Adapter(
        signer: any TONWalletSignerProtocol,
        parameters: TONV5R1WalletParameters
    ) async throws -> any TONWalletAdapterProtocol {
        let signer = TONWalletSignerAdapter(context: context, signer: signer)
        let adapter = try await walletKit.createV5R1WalletAdapter(AnyJSValueEncodable(signer), parameters)
        return TONWalletAdapter(jsWalletAdapter: adapter, version: .v5r1)
    }

    public func add(walletAdapter: any TONWalletAdapterProtocol) async throws -> any TONWalletProtocol {
        let version = walletAdapter.version
        let walletAdapter = TONWalletAdapterJSAdapter(context: context, wallet: walletAdapter)
        let wallet = try await walletKit.addWallet(AnyJSValueEncodable(walletAdapter))
        let address: String = try await wallet.getAddress()

        return TONWallet(jsWallet: wallet, address: address, version: version)
    }
    
    public func wallet(address: String) throws -> any TONWalletProtocol {
        let wallet: JSValue = try walletKit.getWallet(address)
        
        return TONWallet(
            jsWallet: wallet,
            address: address,
            version: TONWalletVersion(value: wallet.version)
        )
    }
    
    public func wallets() async throws -> [any TONWalletProtocol] {
        let value: JSValue = try await walletKit.getWallets()
        let jsWallets = value.toObjectsArray()
        
        var wallets: [TONWallet] = []
        
        for jsWallet in jsWallets {
            let wallet = TONWallet(
                jsWallet: jsWallet,
                address: try await jsWallet.getAddress(),
                version: TONWalletVersion(value: jsWallet.version)
            )
            wallets.append(wallet)
        }
        return wallets
    }

    public func send(transaction: TONConnectTransactionParamContent, from wallet: any TONWalletProtocol) async throws {
        try await walletKit.sendTransaction(AnyJSValueEncodable(wallet), transaction)
    }
        
    public func connect(url: String) async throws {
        try await walletKit.handleTonConnectUrl(url)
    }
      
    public func remove(walletAddress: String) async throws {
        try await walletKit.removeWallet(walletAddress)
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
    
    func injectableBridge() -> TONWalletKit.InjectableBridge {
        TONWalletKit.InjectableBridge(
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

    func jsStorage(context: JSContext) -> (any JSWalletKitStorage)? {
        switch self {
        case .memory: nil
        case .keychain:
            TONWalletKitStorageAdapter(
                context: context,
                storage: TONWalletKitKeychainStorage()
            )
        case .custom(let value):
            TONWalletKitStorageAdapter(
                context: context,
                storage: value
            )
        }
    }
}

extension TONWalletKit {
    
    class InjectableBridge {
        private let walletKit: any JSDynamicObject
        private let bridgeTransport: JSBridgeTransport
        
        init(
            walletKit: any JSDynamicObject,
            bridgeTransport: JSBridgeTransport
        ) {
            self.walletKit = walletKit
            self.bridgeTransport = bridgeTransport
        }
        
        func request(message: TONBridgeEventMessage, request: Any) async throws {
            try await walletKit.processInjectedBridgeRequest(message, AnyJSValueEncodable(request))
        }
        
        func waitForResponse() -> AnyPublisher<Response, Error> {
            bridgeTransport.waitForResponse()
                .map { response in
                    Response(
                        sessionID: response.sessionID,
                        messageID: response.messageID,
                        message: response.message
                    )
                }
                .eraseToAnyPublisher()
        }
    }
}

extension TONWalletKit.InjectableBridge {
    
    struct Response {
        let sessionID: String?
        let messageID: String?
        let message: AnyCodable?
    }
}
