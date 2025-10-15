//
//  TONWalletKit.swift
//  TONWalletKit
//
//  Created by Nikita Rodionov on 12.09.2025.
//

import Foundation

@dynamicMemberLookup
public struct TONWalletKit {
    static private(set) var engine: (any JSEngine)!
    static private(set) var bridgeEventsHandlers: JSBridgeEventsHandler?
    
    public static func initialize(
        configuration: TONWalletKitConfiguration
    ) async throws -> TONWalletKit? {
        // TODO: Make logic to cache WalletKits with configuration as a key for reuse
        guard engine == nil else {
            return TONWalletKit()
        }
        
        engine = WalletKitEngine(
            configuration: configuration
        )
        try await engine.start()
        return TONWalletKit()
    }
    
    public static subscript(dynamicMember member: String) -> JSFunction {
        engine[dynamicMember: member]
    }
    
    // TODO: Move this into separate class JSWalletKit that inherits JSContext to store all data while in memory
    public func add(eventHandler: any TONBridgeEventsHandler) async throws {
        let handler: JSBridgeEventsHandler
        
        if let bridgeEventsHandlers = Self.bridgeEventsHandlers {
            handler = bridgeEventsHandlers
            handler.add(handler: eventHandler)
        } else {
            handler = JSBridgeEventsHandler()
            Self.bridgeEventsHandlers = handler
            handler.add(handler: eventHandler)
            
            let eventsCallback: @convention(block) (String, JSValue) -> JSValue = {
                eventType,
                eventData in
                print("📨 Swift Bridge: Received event '\(eventType)'")
                
                do {
                    try Self.bridgeEventsHandlers?.handle(
                        eventType: eventType,
                        eventData: eventData,
                        walletKit: Self.engine
                    )
                    return JSValue(
                        newPromiseResolvedWithResult: JSValue(undefinedIn: Self.engine.context()),
                        in: Self.engine.context()
                    )
                } catch {
                    return JSValue(
                        newPromiseRejectedWithReason: error.localizedDescription,
                        in: Self.engine.context()
                    )
                }
            }
            
            try await Self.setEventsListeners(eventsCallback)
        }
    }
    
    public func remove(eventHandler: any TONBridgeEventsHandler) async throws {
        guard let bridgeEventsHandlers = Self.bridgeEventsHandlers else {
            return
        }
        bridgeEventsHandlers.remove(handler: eventHandler)
        
        if bridgeEventsHandlers.isEmpty {
            try await Self.removeEventListeners()
        }
    }
}

