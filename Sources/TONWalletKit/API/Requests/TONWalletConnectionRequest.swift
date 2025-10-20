//
//  TONWalletConnectionRequest.swift
//  TONWalletKit
//
//  Created by Nikita Rodionov on 01.10.2025.
//

import Foundation

public class TONWalletConnectionRequest {
    let context: any JSDynamicObject
    let event: TONConnectRequestEvent
    
    public var dAppInfo: TONDAppInfo? { event.dAppInfo }
    public var permissions: [TONConnectRequestEvent.Preview.ConnectPermission] { event.preview?.permissions ?? [] }
    
    init(
        context: any JSDynamicObject,
        event: TONConnectRequestEvent
    ) {
        self.context = context
        self.event = event
    }
    
    public func approve(walletAddress: String) async throws {
        var event = self.event
        event.walletAddress = walletAddress
        try await context.walletKit.approveConnectRequest(event)
    }
    
    public func reject(reason: String? = nil) async throws {
        try await context.walletKit.rejectConnectRequest(event)
    }
}
