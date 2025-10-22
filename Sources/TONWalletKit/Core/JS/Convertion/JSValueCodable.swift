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

extension Array: JSValueEncodable where Element: JSValueEncodable {
    
    func encode(in context: JSContext) throws -> Any {
        return try self.map { element in
            try element.encode(in: context)
        }
    }
}

extension JSValueEncodable where Self: Encodable {
    
    func encode(in context: JSContext) throws -> Any {
        let encoder = JSONEncoder()
        let data = try encoder.encode(self)
        let object = try JSONSerialization.jsonObject(with: data)
        
        return JSValue(object: object, in: context)
    }
}
