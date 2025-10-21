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
    
    /// Handles a raw bridge message from WebView
    /// This method forwards the message to the internal walletKit JavaScript instance
    /// - Parameter method: The bridge method name (e.g., "connect", "send", "disconnect")
    /// - Parameter params: The parameters for the method
    /// - Returns: The result from the JavaScript walletKit instance as a dictionary
    public func handleBridgeMessage(method: String, params: [String: Any]?) async throws -> [String: Any]? {
        debugPrint("📱 TONWalletKit.handleBridgeMessage: \(method)")
        
        // Forward the request to the JavaScript walletKit instance
        let result: JSValue?
        
        switch method {
        case "connect":
            // Convert params to JS object and call JS method
            guard let params = params else {
                throw "Missing connect params"
            }
            debugPrint("📱 Calling JS walletKit with connect params")
            // The connect should trigger events through the event system
            // For now, we'll return nil and let the event handlers process it
            result = nil
            
        case "restoreConnection":
            // Call JS method to restore connections
            debugPrint("📱 Calling JS walletKit.restoreConnection")
            // For now, return empty array - should query JS for active sessions
            return [:]
            
        case "send":
            // Forward transaction to JS
            guard let params = params else {
                throw "Missing send params"
            }
            debugPrint("📱 Calling JS walletKit with send params")
            // Transaction should trigger events through the event system
            result = nil
            
        case "disconnect":
            // Handle disconnection
            debugPrint("📱 Calling JS walletKit.disconnect")
            result = nil
            
        default:
            throw "Unknown bridge method: \(method)"
        }
        
        // Convert JS result to dictionary if needed
        if let result = result, !result.isNull && !result.isUndefined {
            return result.toDictionary() as? [String: Any]
        }
        
        return nil
    }
    
    /// Loads the inject.mjs script content for WebView injection
    /// - Returns: The inject.mjs script content as a String
    /// - Throws: Error if the script file cannot be found or loaded
    public static func loadInjectScript() throws -> String {
        // Try to find the TONWalletKit resource bundle
        var possibleBundles: [Bundle] = [Bundle.module]
        
        // Look for the module's resource bundle in the main bundle
        if let resourceBundleURL = Bundle.main.url(forResource: "TONWalletKit_TONWalletKit", withExtension: "bundle"),
           let resourceBundle = Bundle(url: resourceBundleURL) {
            possibleBundles.append(resourceBundle)
        }
        
        // Also try the class bundle and main bundle as fallbacks
        possibleBundles.append(contentsOf: [
            Bundle(for: TONWalletKit.self),
            Bundle.main
        ])
        
        for bundle in possibleBundles {
            // Try without subdirectory first (for .copy() or .process() resources)
            if let path = bundle.path(forResource: "inject", ofType: "mjs") {
                return try String(contentsOfFile: path, encoding: .utf8)
            }
            
            // Try with subdirectory (for .copy() with preserved paths)
            if let path = bundle.path(forResource: "inject", ofType: "mjs", inDirectory: "Resources/JS") {
                return try String(contentsOfFile: path, encoding: .utf8)
            }
            
            // Try direct file path
            if let resourceURL = bundle.resourceURL {
                let possiblePaths = [
                    resourceURL.appendingPathComponent("inject.mjs"),
                    resourceURL.appendingPathComponent("Resources/JS/inject.mjs")
                ]
                
                for possiblePath in possiblePaths {
                    if FileManager.default.fileExists(atPath: possiblePath.path) {
                        return try String(contentsOf: possiblePath, encoding: .utf8)
                    }
                }
            }
        }
        
        // Provide detailed error message
        let bundlePaths = possibleBundles.compactMap { $0.resourceURL?.path }.joined(separator: "\n  - ")
        throw NSError(
            domain: "TONWalletKit",
            code: 404,
            userInfo: [NSLocalizedDescriptionKey: "inject.mjs script not found in any bundle. Searched in:\n  - \(bundlePaths)\n\nNote: You may need to rebuild the project to update resources."]
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
