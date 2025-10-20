//
//  JSWalletKitContext.swift
//  TONWalletKit
//
//  Created by Nikita Rodionov on 16.10.2025.
//

import Foundation
import JavaScriptCore

class JSWalletKitContext: JSContext {
    private var bridgeEventHandlers: JSBridgeRawEventsHandler?
    
    override init() {
        super.init()
        
        polyfill(with: JSConsoleLogPolyfill())
        polyfill(with: JSTimerPolyfill())
        polyfill(with: JSFetchPolyfill())
        polyfill(with: JSWalletKitInitialPolyfill())
    }
    
    override init!(virtualMachine: JSVirtualMachine!) {
        super.init(virtualMachine: virtualMachine)
    }
    
    func load(script: any JSScript) async throws {
        let code = try await script.load()
        self.evaluateScript(code)
    }
    
    func add(eventsHandler: any JSBridgeEventsHandler) async throws {
        if let bridgeEventHandlers {
            bridgeEventHandlers.add(handler: eventsHandler)
            return
        }
        
        bridgeEventHandlers = JSBridgeRawEventsHandler(handlers: [eventsHandler])
        
        let callback: @convention(block) (String, JSValue) -> JSValue? = { [weak self] eventType, eventData in
            guard let self else { return nil }
            
            debugPrint("Swift Bridge: Received event '\(eventType)'")
            
            do {
                try self.bridgeEventHandlers?.handle(eventType: eventType, eventData: eventData)
                
                return JSValue(
                    newPromiseResolvedWithResult: JSValue(undefinedIn: self),
                    in: self
                )
            } catch {
                return JSValue(
                    newPromiseRejectedWithReason: error.localizedDescription,
                    in: self
                )
            }
        }
        
        try await self.walletKit.setEventsListeners(callback)
    }
    
    func remove(eventsHandler: any JSBridgeEventsHandler) async throws {
        bridgeEventHandlers?.remove(handler: eventsHandler)
        
        if bridgeEventHandlers?.isEmpty != false {
            try await self.walletKit.removeEventListeners()
        }
    }
}
