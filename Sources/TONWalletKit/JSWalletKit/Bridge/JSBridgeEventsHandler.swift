//
//  JSBridgeEventsHandler.swift
//  TONWalletKit
//
//  Created by Nikita Rodionov on 17.10.2025.
//

import Foundation

protocol JSBridgeEventsHandler: AnyObject {
    var isValid: Bool { get }
    
    func handle(event: JSWalletKitSwiftBridgeEvent) throws
    func invalidate()
}
