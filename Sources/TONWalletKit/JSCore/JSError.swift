//
//  JSError.swift
//  TONWalletKit
//
//  Created by Nikita Rodionov on 22.10.2025.
//

import Foundation
import JavaScriptCore

struct JSError: LocalizedError, JSValueDecodable {
    let message: String
    
    var errorDescription: String? { message }
    
    static func from(_ value: JSValue) throws -> JSError? {
        value.toJSError()
    }
}

extension JSValue {
    
    var isJSError: Bool {
        isInstance(of: context.objectForKeyedSubscript("Error"))
    }
    
    func toJSError() -> JSError? {
        if isJSError {
            return JSError(message: self.message ?? "Unknown JS error")
        }
        return nil
    }
}
