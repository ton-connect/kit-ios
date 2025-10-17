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
            let event = try decoder.decode(TONConnectRequestEvent.self, from: bridgeEvent.data)
            self = .connectRequest(TONWalletConnectionRequest(context: context, event: event))
        case .transactionRequest:
            let event = try decoder.decode(TONTransactionRequestEvent.self, from: bridgeEvent.data)
            self = .transactionRequest(TONWalletTransactionRequest(context: context, event: event))
        case .signDataRequest:
            let event = try decoder.decode(TONSignDataRequestEvent.self, from: bridgeEvent.data)
            self = .signDataRequest(TONWalletSignDataRequest(context: context, event: event))
        case .disconnect:
            self = .disconnect(try decoder.decode(TONDisconnectEvent.self, from: bridgeEvent.data))
        }
    }
}
