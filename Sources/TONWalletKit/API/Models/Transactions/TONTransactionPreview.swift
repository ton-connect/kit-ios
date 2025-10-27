//  TONTransactionPreview.swift
//  TONWalletKit
//
//  Created by Nikita Rodionov on 13.10.2025.
//
//  Copyright (c) 2025 TON Connect
//
//  Permission is hereby granted, free of charge, to any person obtaining a copy
//  of this software and associated documentation files (the "Software"), to deal
//  in the Software without restriction, including without limitation the rights
//  to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
//  copies of the Software, and to permit persons to whom the Software is
//  furnished to do so, subject to the following conditions:
//  
//  The above copyright notice and this permission notice shall be included in all
//  copies or substantial portions of the Software.
//  
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
//  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
//  SOFTWARE.

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
