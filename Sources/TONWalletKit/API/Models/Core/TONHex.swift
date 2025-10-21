//
//  TONHex.swift
//  TONWalletKit
//
//  Created by Nikita Rodionov on 21.10.2025.
//

import Foundation

public struct TONHex: Codable {
    public let value: String
    public var data: Data? { Data(hex: value) }
    
    public init(hexString: String) {
        self.value = hexString
    }
    
    public init(data: Data) {
        self.init(hexString: data.hex)
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
