//
//  TONBridgeEventsHandler.swift
//  TONWalletKit
//
//  Created by Nikita Rodionov on 09.10.2025.
//

import Foundation

public protocol TONBridgeEventsHandler {
    
    func handle(event: TONWalletKitEvent)
}
