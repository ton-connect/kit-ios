//
//  TONBridgeEventsHandlerAdapter.swift
//  TONWalletKit
//
//  Created by Nikita Rodionov on 17.10.2025.
//

import Foundation

class TONBridgeEventsHandlerAdapter: JSBridgeEventsHandler {
    private weak var handler: TONBridgeEventsHandler?
    private weak var context: JSContext?
    
    var isValid: Bool {
        return handler != nil && context != nil
    }
    
    init(handler: TONBridgeEventsHandler, context: JSContext) {
        self.handler = handler
        self.context = context
    }
    
    func handle(event: JSWalletKitSwiftBridgeEvent) throws {
        guard let handler, let context else {
            throw "Unable to handle event: \(event.type)"
        }
        
        let event = try TONWalletKitEvent(bridgeEvent: event, context: context)
        
        try handler.handle(event: event)
    }
    
    func invalidate() {
        handler = nil
        context = nil
    }
    
    static func == (lhs: TONBridgeEventsHandlerAdapter, rhs: TONBridgeEventsHandler) -> Bool {
        guard let lhs = lhs.handler else {
            return false
        }
        return lhs === rhs
    }
}
