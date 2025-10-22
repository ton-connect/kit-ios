//
//  WalletKitEvent.swift
//  TONWalletKit
//
//  Created by Nikita Rodionov on 11.09.2025.
//

import Foundation

public enum TONWalletKitEvent {
    case connectRequest(TONWalletConnectionRequest)
    case transactionRequest(TONWalletTransactionRequest)
    case signDataRequest(TONWalletSignDataRequest)
    case disconnect(TONDisconnectEvent)
    
    init(bridgeEvent: JSWalletKitSwiftBridgeEvent, context: any JSDynamicObject) throws {
        let decoder = JSONDecoder()
        
        switch bridgeEvent.type {
        case .connectRequest:
            let event: TONConnectRequestEvent = try bridgeEvent.value.decode()
            self = .connectRequest(TONWalletConnectionRequest(context: context, event: event))
        case .transactionRequest:
            let event: TONTransactionRequestEvent = try bridgeEvent.value.decode()
            self = .transactionRequest(TONWalletTransactionRequest(context: context, event: event))
        case .signDataRequest:
            let event: TONSignDataRequestEvent = try bridgeEvent.value.decode()
            self = .signDataRequest(TONWalletSignDataRequest(context: context, event: event))
        case .disconnect:
            let event: TONDisconnectEvent = try bridgeEvent.value.decode()
            self = .disconnect(event)
        }
    }
}
