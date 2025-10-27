//
//  WeakValueWrapper.swift
//  TONWalletKit
//
//  Created by Nikita Rodionov on 16.10.2025.
//

import Foundation

class AnyWeakValueWrapper {
    weak var value: AnyObject?
    
    init(value: AnyObject) {
        self.value = value
    }
}

class WeakValueWrapper<T: AnyObject> {
    weak var value: T?
    
    init(value: T) {
        self.value = value
    }
}
