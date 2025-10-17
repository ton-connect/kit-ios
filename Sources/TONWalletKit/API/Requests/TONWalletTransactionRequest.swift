//
//  TONWalletTransactionRequest.swift
//  TONWalletKit
//
//  Created by Nikita Rodionov on 02.10.2025.
//

import Foundation

public class TONWalletTransactionRequest {
    let context: any JSDynamicObject
    let event: TONTransactionRequestEvent
    
    public var dAppInfo: TONDAppInfo? { event.dAppInfo }
    
    init(
        context: any JSDynamicObject,
        event: TONTransactionRequestEvent
    ) {
        self.context = context
        self.event = event
    }
    
    public func approve() async throws {
        try await context.walletKit.approveTransactionRequest(event)
    }
    
    public func reject(reason: String? = nil) async throws {
        try await context.walletKit.rejectTransactionRequest(event)
    }
}
