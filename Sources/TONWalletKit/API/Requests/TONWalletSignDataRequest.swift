//
//  TONWalletSignDataRequest.swift
//  TONWalletKit
//
//  Created by Nikita Rodionov on 02.10.2025.
//

import Foundation

public class TONWalletSignDataRequest {
    let walletKit: any JSDynamicObject
    let event: SignDataRequestEvent
    
    public var dAppInfo: DAppInfo? { event.dAppInfo }
    public var walletAddress: String? { event.walletAddress }
    
    init(
        walletKit: any JSDynamicObject,
        event: SignDataRequestEvent
    ) {
        self.walletKit = walletKit
        self.event = event
    }
    
    public func approve() async throws {
        try await walletKit.approveSignDataRequest(event)
    }
    
    public func reject(reason: String? = nil) async throws {
        try await walletKit.rejectSignDataRequest(event)
    }
}

