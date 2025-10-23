//
//  JSValueCodable.swift
//  TONWalletKit
//
//  Created by Nikita Rodionov on 22.10.2025.
//

import Foundation
import JavaScriptCore

protocol JSValueEncodable {
    
    func encode(in context: JSContext) throws -> Any
}

extension JSValue: JSValueEncodable {
    
    func encode(in context: JSContext) throws -> Any { self }
}

extension String: JSValueEncodable {
    
    func encode(in context: JSContext) throws -> Any { self }
}

extension Int: JSValueEncodable {
    
    func encode(in context: JSContext) throws -> Any { self }
}

extension Int32: JSValueEncodable {
    
    func encode(in context: JSContext) throws -> Any { self }
}

extension Int64: JSValueEncodable {
    
    func encode(in context: JSContext) throws -> Any { self }
}

extension UInt: JSValueEncodable {
    
    func encode(in context: JSContext) throws -> Any { self }
}

extension UInt32: JSValueEncodable {
    
    func encode(in context: JSContext) throws -> Any { self }
}

extension UInt64: JSValueEncodable {
    
    func encode(in context: JSContext) throws -> Any { self }
}

extension Float: JSValueEncodable {
    
    func encode(in context: JSContext) throws -> Any { self }
}

extension Double: JSValueEncodable {
    
    func encode(in context: JSContext) throws -> Any { self }
}

extension Bool: JSValueEncodable {
    
    func encode(in context: JSContext) throws -> Any { self }
}

extension Date: JSValueEncodable {
    
    func encode(in context: JSContext) throws -> Any { self }
}

extension NSNull: JSValueEncodable {
    
    func encode(in context: JSContext) throws -> Any { self }
}

extension Array: JSValueEncodable where Element: JSValueEncodable {
    
    func encode(in context: JSContext) throws -> Any {
        try self.map { element in
            try element.encode(in: context)
        }
    }
}

extension JSValueEncodable where Self: Encodable {
    
    func encode(in context: JSContext) throws -> Any {
        let encoder = JSONEncoder()
        let data = try encoder.encode(self)
        let object = try JSONSerialization.jsonObject(with: data)
        
        guard let value = JSValue(object: object, in: context) else {
            throw "Unable to encode value: \(Self.self) to JSValue"
        }
        return value
    }
}

extension Optional: JSValueEncodable where Wrapped: JSValueEncodable {
    
    func encode(in context: JSContext) throws -> Any {
        switch self {
        case .none:
            return JSValue(nullIn: context) as Any
        case .some(let wrapped):
            return try wrapped.encode(in: context)
        }
    }
}


