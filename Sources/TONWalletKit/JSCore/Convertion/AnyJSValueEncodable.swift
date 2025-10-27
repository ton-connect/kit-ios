//
//  AnyJSValueEncodable.swift
//  TONWalletKit
//
//  Created by Nikita Rodionov on 22.10.2025.
//

import Foundation
import JavaScriptCore

struct AnyJSValueEncodable: JSValueEncodable {
    let value: Any
    
    init(_ value: Any) {
        self.value = value
    }
    
    func encode(in context: JSContext) throws -> Any {
        if let value = value as? AnyJSValueEncodable {
            return try value.encode(in: context)
        }
        return value
    }
}
