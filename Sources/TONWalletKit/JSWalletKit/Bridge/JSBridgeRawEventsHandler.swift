//
//  JSBridgeRawEventsHandler.swift
//  TONWalletKit
//
//  Created by Nikita Rodionov on 15.10.2025.
//

import Foundation
import JavaScriptCore

class JSBridgeRawEventsHandler {
    private var handlers: [any JSBridgeEventsHandler] = []
    
    var isEmpty: Bool { handlers.isEmpty }
    
    init(handlers: [any JSBridgeEventsHandler]) {
        self.handlers = handlers
    }
    
    func handle(eventType: String, eventData: JSValue) throws {
        clean()
        
        guard let data = eventData.toData() else {
            throw "Failed to parse event data"
        }
        
        guard let eventType = JSWalletKitSwiftBridgeEventType(rawValue: eventType) else {
            throw "Unknown event type: \(eventType)"
        }
        
        let event = JSWalletKitSwiftBridgeEvent(type: eventType, data: data)
        
        if handlers.isEmpty {
            throw "No handlers was added to handle \(eventType)"
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
    
    func add(handler: any JSBridgeEventsHandler) {
        clean()
        
        if !handlers.contains(where: { $0 === handler }) {
            handlers.append(handler)
        }
    }
    
    func remove(handler: any JSBridgeEventsHandler) {
        clean()
        
        handlers.removeAll { $0 === handler }
    }
    
    private func clean() {
        handlers.removeAll { !$0.isValid }
    }
}

struct JSWalletKitSwiftBridgeEvent {
    let type: JSWalletKitSwiftBridgeEventType
    let data: Data
}

enum JSWalletKitSwiftBridgeEventType: String {
    case connectRequest
    case transactionRequest
    case signDataRequest
    case disconnect
}
