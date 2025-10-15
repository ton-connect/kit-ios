//
//  WalletKitEngine.swift
//  TONWalletKit
//
//  Created by Nikita Rodionov on 11.09.2025.
//

import Foundation
import JavaScriptCore

public class WalletKitEngine: JSEngine {
    private let configuration: TONWalletKitConfiguration
    
    public private(set) var jsContext: JSContext?
    
    public init(configuration: TONWalletKitConfiguration) {
        self.configuration = configuration
    }
    
    public func loadJS(into context: JSContext) async throws {
        let js = try WalletKitJS.load()
        context.evaluateScript(js.code)
    }
    
    public func processJS(in context: JSContext) async throws {
        let storage: WalletKitJSStorage?
        
        switch configuration.storage {
        case .memory: storage = nil
        case .keychain:
            storage = WalletKitStorageWrapper(
                context: context,
                storage: WalletKitKeychainStorage()
            )
        case .custom(let value):
            storage = WalletKitStorageWrapper(
                context: context,
                storage: value
            )
        }
        
        try await context.initWalletKit(configuration, storage)
    }
    
    public func context() -> JSContext {
        if let jsContext {
            return jsContext
        }
        
        let context = JSContext()

        context?.polyfill(with: JSConsoleLogPolyfill())
        context?.polyfill(with: JSTimerPolyfill())
        context?.polyfill(with: JSFetchPolyfill())
        
        context?.polyfill(with: JSWalletKitInitialPolyfill())
        
        self.jsContext = context
        
        return context!
    }
    
    public func clearContext() {
        jsContext = nil
    }
}

extension WalletKitEngine: JSDynamicMember {
    
    public subscript(dynamicMember member: String) -> JSFunction {
        if let walletKit = try? object("walletKit") {
            return JSFunction(name: member, target: walletKit)
        }
        fatalError("WalletKitEngine not inited in JS")
    }
}

extension WalletKitEngine: JSDynamicObject {

    public func object(_ name: String) throws -> JSValue? {
        try jsContext?.object(name)
    }
}

