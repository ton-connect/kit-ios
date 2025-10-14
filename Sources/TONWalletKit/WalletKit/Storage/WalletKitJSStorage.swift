//
//  WalletKitStorage.swift
//  TONWalletKit
//
//  Created by Nikita Rodionov on 09.10.2025.
//

import Foundation
import JavaScriptCore

@objc protocol WalletKitJSStorage: JSExport {
    @objc(set::) func save(key: String, value: String) -> JSValue
    @objc(get:) func get(key: String) -> JSValue
    @objc(remove:) func remove(key: String) -> JSValue
    @objc(clear) func clear() -> JSValue
}
