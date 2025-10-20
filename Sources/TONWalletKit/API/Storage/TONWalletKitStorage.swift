//
//  TONWalletKitStorage.swift
//  TONWalletKit
//
//  Created by Nikita Rodionov on 09.10.2025.
//

import Foundation

public protocol TONWalletKitStorage: AnyObject {
    func save(key: String, value: String) throws
    func get(key: String) throws -> String?
    func remove(key: String) throws
    func clear() throws
}
