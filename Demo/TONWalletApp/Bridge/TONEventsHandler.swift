//
//  TONEventsHandler.swift
//  TONWalletApp
//
//  Created by Nikita Rodionov on 06.10.2025.
//

import Foundation
import Combine
import TONWalletKit

class TONEventsHandler: TONBridgeEventsHandler {
    let events = PassthroughSubject<TONWalletKitEvent, Never>()
    
    static let shared = TONEventsHandler()
    
    private init() {}
    
    func handle(event: TONWalletKitEvent) {
        events.send(event)
    }
}

