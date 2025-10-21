//
//  TONBase64.swift
//  TONWalletKit
//
//  Created by Nikita Rodionov on 20.10.2025.
//

import Foundation

public struct TONBase64: Codable {
    public let value: String
    public var data: Data? { Data(base64Encoded: value) }
    
    public init(base64Encoded: String) {
        self.value = base64Encoded
    }
    
    public init(data: Data) {
        self.init(base64Encoded: data.base64EncodedString())
    }
    
    public init(string: String) {
        self.init(data: Data(string.utf8))
    }
    
    public init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        self.value = try container.decode(String.self)
    }
    
    public func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()
        try container.encode(value)
    }
}
