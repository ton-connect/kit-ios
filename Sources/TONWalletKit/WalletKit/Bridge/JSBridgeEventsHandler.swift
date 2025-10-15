//
//  JSBridgeEventsHandler.swift
//  TONWalletKit
//
//  Created by Nikita Rodionov on 15.10.2025.
//

import Foundation
import JavaScriptCore

class JSBridgeEventsHandler {
    private var wrappers: [BridgeEventsHandlerWeakWrapper] = []
    
    var isEmpty: Bool { wrappers.isEmpty }
    
    func handle(eventType: String, eventData: JSValue, walletKit: any JSDynamicObject) throws {
        guard let data = eventData.toData() else {
            print("❌ Failed to parse event data")
            return
        }
        
        guard let eventType = JSWalletKitSwiftBridgeEventType(rawValue: eventType) else {
            print("⚠️ Unknown event type: \(eventType)")
            return
        }
        
        let bridgeEvent = JSWalletKitSwiftBridgeEvent(type: eventType, data: data)
        
        guard let event = TONWalletKitEvent(bridgeEvent: bridgeEvent, walletKit: walletKit) else {
            print("⚠️ Unknown event type: \(eventType)")
            return
        }
        
        clean()
        
        let handlers = wrappers.compactMap { $0.handler }
        
        if handlers.isEmpty {
            throw "No handlers was added to handle \(event)"
        }
        
        let errors: [Error] = handlers.compactMap {
            do {
                try $0.handle(event: event)
                return nil
            } catch {
                return error
            }
        }
        
        if errors.count == handlers.count, let error = errors.first {
            throw error
        }
    }
    
    func add(handler: any TONBridgeEventsHandler) {
        clean()
        
        if !wrappers.contains(where: { $0.handler === handler }) {
            wrappers.append(BridgeEventsHandlerWeakWrapper(handler: handler))
        }
    }
    
    func remove(handler: any TONBridgeEventsHandler) {
        clean()
        
        wrappers.removeAll(where: { $0.handler === handler })
    }
    
    private func clean() {
        wrappers.removeAll(where: { $0.handler == nil })
    }
}

private class BridgeEventsHandlerWeakWrapper {
    weak var handler: (any TONBridgeEventsHandler)?
    
    init(handler: (any TONBridgeEventsHandler)?) {
        self.handler = handler
    }
}

public struct JSWalletKitSwiftBridgeEvent {
    public let type: JSWalletKitSwiftBridgeEventType
    public let data: Data
}

public enum JSWalletKitSwiftBridgeEventType: String {
    case connectRequest
    case transactionRequest
    case signDataRequest
    case disconnect
}
