//
//  JSValue+Conversion.swift
//  TONWalletKit
//
//  Created by Nikita Rodionov on 22.10.2025.
//

import Foundation
import JavaScriptCore

extension JSValue {
    
    func decode<T>() throws -> T where T: JSValueDecodable {
        if T.self is JSValueDecodableOptional.Type {
            if self.isNull || self.isUndefined {
                return Optional<JSValueDecodable>.none as! T
            }
        } else {
            if self.isNull {
                throw JSValueConversionError.unableToConvertNullJSValue(type: T.self)
            }
            
            if self.isUndefined {
                throw JSValueConversionError.unableToConvertUndefinedJSValue(type: T.self)
            }
        }
        
        guard let value = try T.from(self) else {
            throw JSValueConversionError.unableToConvertJSValue(type: T.self)
        }
        return value
    }
}

private protocol JSValueDecodableOptional {}

extension Optional: JSValueDecodableOptional, JSValueDecodable where Wrapped: JSValueDecodable {
    
    static func from(_ value: JSValue) throws -> Optional<Wrapped>? {
        if let value = try Wrapped.from(value) {
            return value
        }
        return .none
    }
}
