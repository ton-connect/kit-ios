//
//  JSValueConversionError.swift
//  TONWalletKit
//
//  Created by Nikita Rodionov on 22.10.2025.
//

import Foundation

enum JSValueConversionError: LocalizedError {
    case unableToConvertJSValue(type: Any.Type, description: String)
    case unableToConvertUndefinedJSValue(type: Any.Type)
    case unableToConvertNullJSValue(type: Any.Type)
    case decodingError(DecodingError)
    case encodingError(EncodingError)
    case unknown(message: String)
    
    var errorDescription: String? {
        switch self {
        case .unableToConvertJSValue(let type, let description):
            return "Unable to cast JS value \(description) to \(type)"
        case .unableToConvertUndefinedJSValue(let type):
            return "Unable to cast undefined JS value to \(type)"
        case .unableToConvertNullJSValue(let type):
            return "Unable to cast null JS value to \(type)"
        case .unknown(let message):
            return message
        case .decodingError(let error):
            return error.localizedDescription
        case .encodingError(let error):
            return error.localizedDescription
        }
    }
}
