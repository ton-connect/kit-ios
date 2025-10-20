//
//  JSBridgeEventsHandler.swift
//  TONWalletKit
//
//  Created by Nikita Rodionov on 17.10.2025.
//

import Foundation

protocol JSBridgeEventsHandler: AnyObject {
    
    func handle(event: JSWalletKitSwiftBridgeEvent) throws
}
