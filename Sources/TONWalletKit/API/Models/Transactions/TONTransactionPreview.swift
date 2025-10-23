//  TONTransactionPreview.swift
//  TONWalletKit
//
//  Created by Nikita Rodionov on 13.10.2025.
//

import Foundation

public enum TONTransactionPreview: Codable {
    case error(TONTransactionPreviewEmulationError)
    case success(TONTransactionPreviewEmulationResult)
    
    private enum CodingKeys: String, CodingKey {
        case result
        case emulationError
        case moneyFlow
        case emulationResult
    }
    
    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let result = try container.decode(TONResult.self, forKey: .result)
        
        switch result {
        case .error:
            let error = try TONTransactionPreviewEmulationError(from: decoder)
            self = .error(error)
        case .success:
            let success = try TONTransactionPreviewEmulationResult(from: decoder)
            self = .success(success)
        }
    }
    
    public func encode(to encoder: Encoder) throws {
        switch self {
        case .error(let error):
            try error.encode(to: encoder)
        case .success(let result):
            try result.encode(to: encoder)
        }
    }
}

public struct TONTransactionPreviewEmulationError: Codable {
    var result: TONResult = .error
    public let emulationError: TONError
    
    public init(emulationError: TONError) {
        self.emulationError = emulationError
    }
}

public struct TONTransactionPreviewEmulationResult: Codable {
    var result: TONResult = .success
    
    public let moneyFlow: TONMoneyFlow
    public let emulationResult: TONCenterEmulationResponse
    
    public init(
        moneyFlow: TONMoneyFlow,
        emulationResult: TONCenterEmulationResponse
    ) {
        self.moneyFlow = moneyFlow
        self.emulationResult = emulationResult
    }
}
