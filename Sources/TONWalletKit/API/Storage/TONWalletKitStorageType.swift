//
//  TONWalletKitStorage.swift
//  TONWalletKit
//
//  Created by Nikita Rodionov on 16.10.2025.
//

import Foundation

public enum TONWalletKitStorageType {
    case memory
    case keychain
    case custom(TONWalletKitStorage)
}
