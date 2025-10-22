//
//  JSValueConvertible.swift
//  TONWalletKit
//
//  Created by Nikita Rodionov on 22.10.2025.
//

import Foundation
import JavaScriptCore

protocol JSValueDecodable {
    
    static func from(_ value: JSValue) throws -> Self?
}

extension String: JSValueDecodable {
    
    static func from(_ value: JSValue) throws -> String? {
        guard value.isString else { return nil }
        
        return value.toString()
    }
}

extension Int: JSValueDecodable {
    
    static func from(_ value: JSValue) throws -> Int? {
        guard value.isNumber, let number = value.toNumber() else { return nil }
        
        return number.intValue
    }
}

extension Int32: JSValueDecodable {
    
    static func from(_ value: JSValue) throws -> Int32? {
        guard value.isNumber, let number = value.toNumber() else { return nil }
        
        return number.int32Value
    }
}

extension Int64: JSValueDecodable {
    
    static func from(_ value: JSValue) throws -> Int64? {
        guard value.isNumber, let number = value.toNumber() else { return nil }
        
        return number.int64Value
    }
}

extension UInt: JSValueDecodable {
    
    static func from(_ value: JSValue) throws -> UInt? {
        guard value.isNumber, let number = value.toNumber() else { return nil }
        
        return number.uintValue
    }
}

extension UInt32: JSValueDecodable {
    
    static func from(_ value: JSValue) throws -> UInt32? {
        guard value.isNumber, let number = value.toNumber() else { return nil }
        
        return number.uint32Value
    }
}

extension UInt64: JSValueDecodable {
    
    static func from(_ value: JSValue) throws -> UInt64? {
        guard value.isNumber, let number = value.toNumber() else { return nil }
        
        return number.uint64Value
    }
}

extension Float: JSValueDecodable {
    
    static func from(_ value: JSValue) throws -> Float? {
        guard value.isNumber, let number = value.toNumber() else { return nil }
        
        return number.floatValue
    }
}

extension Double: JSValueDecodable {
    
    static func from(_ value: JSValue) throws -> Double? {
        guard value.isNumber, let number = value.toNumber() else { return nil }
        
        return number.doubleValue
    }
}

extension Bool: JSValueDecodable {
    
    static func from(_ value: JSValue) throws -> Bool? {
        guard value.isBoolean else { return nil }
        return value.toBool()
    }
}

extension Date: JSValueDecodable {
    
    static func from(_ value: JSValue) throws -> Date? {
        value.toDate()
    }
}

extension JSValue: JSValueDecodable {
    
    static func from(_ value: JSValue) throws -> Self? {
        if value.isObject && !value.isUndefined {
            return value as? Self
        }
        return nil
    }
}

extension Dictionary: JSValueDecodable where Key: Decodable, Value: Decodable {}
extension Array: JSValueDecodable where Element: Decodable {}

extension JSValueDecodable where Self: Decodable {
    
    static func from(_ value: JSValue) throws -> Self? {
        guard value.isObject && !value.isUndefined else {
            return nil
        }
            
        let object: Any
        
        if value.isArray {
            object = value.toArray()
        } else if let dictionary = value.toDictionary() {
            object = dictionary
        } else {
            return nil
        }
        
        let jsonData = try JSONSerialization.data(withJSONObject: object, options: [])
        let decoder = JSONDecoder()
        return try decoder.decode(Self.self, from: jsonData)
    }
}
