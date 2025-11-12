//
//  TONWalletKitStorageAdapter.swift
//  TONWalletKit
//
//  Created by Nikita Rodionov on 09.10.2025.
//
//  Copyright (c) 2025 TON Connect
//
//  Permission is hereby granted, free of charge, to any person obtaining a copy
//  of this software and associated documentation files (the "Software"), to deal
//  in the Software without restriction, including without limitation the rights
//  to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
//  copies of the Software, and to permit persons to whom the Software is
//  furnished to do so, subject to the following conditions:
//  
//  The above copyright notice and this permission notice shall be included in all
//  copies or substantial portions of the Software.
//  
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
//  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
//  SOFTWARE.

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
    
    @objc func clear() -> JSValue {
        do {
            try storage.clear()
            return JSValue(newPromiseResolvedWithResult: JSValue(undefinedIn: context), in: context)
        } catch {
            return JSValue(newPromiseRejectedWithReason: error.localizedDescription, in: context)
        }
    }
}
