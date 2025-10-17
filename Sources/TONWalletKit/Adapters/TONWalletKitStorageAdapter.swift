//
//  TONWalletKitStorageAdapter.swift
//  TONWalletKit
//
//  Created by Nikita Rodionov on 09.10.2025.
//

import Foundation

class TONWalletKitStorageAdapter: NSObject, JSWalletKitStorage {
    private weak var context: JSContext?
    private let storage: TONWalletKitStorage
    
    init(
        context: JSContext,
        storage: TONWalletKitStorage
    ) {
        self.context = context
        self.storage = storage
    }
    
    @objc(set::) func save(key: String, value: String) -> JSValue {
        do {
            try storage.save(key: key, value: value)
            return JSValue(newPromiseResolvedWithResult: JSValue(undefinedIn: context), in: context)
        } catch {
            return JSValue(newPromiseRejectedWithReason: error.localizedDescription, in: context)
        }
    }
    
    @objc(get:) func get(key: String) -> JSValue {
        do {
            if let value = try storage.get(key: key) {
                return JSValue(newPromiseResolvedWithResult: value, in: context)
            } else {
                return JSValue(newPromiseResolvedWithResult: JSValue(nullIn: context), in: context)
            }
        } catch {
            return JSValue(newPromiseRejectedWithReason: error.localizedDescription, in: context)
        }
    }
    
    @objc(remove:) func remove(key: String) -> JSValue {
        do {
            try storage.remove(key: key)
            return JSValue(newPromiseResolvedWithResult: JSValue(undefinedIn: context), in: context)
        } catch {
            return JSValue(newPromiseRejectedWithReason: error.localizedDescription, in: context)
        }
    }
    
    @objc(clear) func clear() -> JSValue {
        do {
            try storage.clear()
            return JSValue(newPromiseResolvedWithResult: JSValue(undefinedIn: context), in: context)
        } catch {
            return JSValue(newPromiseRejectedWithReason: error.localizedDescription, in: context)
        }
    }
}
