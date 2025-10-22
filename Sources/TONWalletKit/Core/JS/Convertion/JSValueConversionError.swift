//
//  JSValueConversionError.swift
//  TONWalletKit
//
//  Created by Nikita Rodionov on 22.10.2025.
//

import Foundation

enum JSValueConversionError: LocalizedError {
    case unableToConvertJSValue(type: Any.Type)
    case unableToConvertUndefinedJSValue(type: Any.Type)
    case unableToConvertNullJSValue(type: Any.Type)
    
    var errorDescription: String? {
        switch self {
        case .unableToConvertJSValue(let type):
            return "Unable to cast JS value to \(type)"
        case .unableToConvertUndefinedJSValue(let type):
            return "Unable to cast undefined JS value to \(type)"
        case .unableToConvertNullJSValue(let type):
            return "Unable to cast null JS value to \(type)"
        }
    }
}
