//
//  TONError.swift
//  TONWalletKit
//
//  Created by Nikita Rodionov on 20.10.2025.
//

import Foundation

public struct TONError: Codable {
    public let code: Int?
    public let message: String?
    public let data: [String: AnyCodable]?
    
    public init(
        code: Int?,
        message: String?,
        data: [String : AnyCodable]?
    ) {
        self.code = code
        self.message = message
        self.data = data
    }
}
