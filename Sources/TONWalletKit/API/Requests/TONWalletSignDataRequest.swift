//
//  TONWalletSignDataRequest.swift
//  TONWalletKit
//
//  Created by Nikita Rodionov on 02.10.2025.
//

import Foundation

public class TONWalletSignDataRequest {
    let context: any JSDynamicObject
    let event: TONSignDataRequestEvent
    
    public var dAppInfo: TONDAppInfo? { event.dAppInfo }
    public var walletAddress: String? { event.walletAddress }
    
    init(
        context: any JSDynamicObject,
        event: TONSignDataRequestEvent
    ) {
        self.context = context
        self.event = event
    }
    
    public func approve() async throws {
        try await context.walletKit.approveSignDataRequest(event)
    }
    
    public func reject(reason: String? = nil) async throws {
        try await context.walletKit.rejectSignDataRequest(event)
    }
}

