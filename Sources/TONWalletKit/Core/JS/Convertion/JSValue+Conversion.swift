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
        return try to(T.self)
    }
    
    func to<T>(_ type: T.Type) throws -> T where T: JSValueDecodable {
        if self.isNull {
            throw JSValueConversionError.unableToConvertNullJSValue(type: T.self)
        }
        
        if self.isUndefined {
            throw JSValueConversionError.unableToConvertUndefinedJSValue(type: T.self)
        }
        
        guard let value = try T.from(self) else {
            throw JSValueConversionError.unableToConvertJSValue(type: T.self)
        }
        
        return value
    }
    
    func to<T, U>(_ type: T.Type) throws -> T where T == Optional<U>, U: JSValueDecodable {
        if self.isNull || self.isUndefined { return nil }
        return try to(U.self)
    }
}
