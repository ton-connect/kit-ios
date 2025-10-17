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
    
    init(handler: TONBridgeEventsHandler, context: JSContext) {
        self.handler = handler
        self.context = context
    }
    
    func handle(event: JSWalletKitSwiftBridgeEvent) throws {
        guard let context else { return }
        
        guard let handler else {
            throw "Unable to handle event: \(event.type)"
        }
        
        let event = try TONWalletKitEvent(bridgeEvent: event, context: context)
        
        try handler.handle(event: event)
    }
    
    static func == (lhs: TONBridgeEventsHandlerAdapter, rhs: TONBridgeEventsHandler) -> Bool {
        guard let lhs = lhs.handler else {
            return false
        }
        return lhs === rhs
    }
}
