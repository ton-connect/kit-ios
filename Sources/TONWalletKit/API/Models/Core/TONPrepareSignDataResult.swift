//
//  TONPrepareSignDataResult.swift
//  TONWalletKit
//
//  Created by Nikita Rodionov on 16.10.2025.
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

public struct TONPrepareSignDataResult: Codable {
    public var address: String
    public var timestamp: Int
    public var domain: String
    public var payload: TONSignDataPayload
    public var hash: TONHex
    
    public init(
        address: String,
        timestamp: Int,
        domain: String,
        payload: TONSignDataPayload,
        hash: TONHex
    ) {
        self.address = address
        self.timestamp = timestamp
        self.domain = domain
        self.payload = payload
        self.hash = hash
    }
}

public enum TONSignDataPayload: Codable {
    case text(TONSignDataPayloadText)
    case binary(TONSignDataPayloadBinary)
    case cell(TONSignDataPayloadCell)

    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let type = try container.decode(String.self, forKey: .type)
        switch type {
        case "text":
            self = .text(try TONSignDataPayloadText(from: decoder))
        case "binary":
            self = .binary(try TONSignDataPayloadBinary(from: decoder))
        case "cell":
            self = .cell(try TONSignDataPayloadCell(from: decoder))
        default:
            throw DecodingError.dataCorruptedError(
                forKey: .type,
                in: container,
                debugDescription: "Unknown payload type"
            )
        }
    }

    public func encode(to encoder: Encoder) throws {
        switch self {
        case .text(let value):
            try value.encode(to: encoder)
        case .binary(let value):
            try value.encode(to: encoder)
        case .cell(let value):
            try value.encode(to: encoder)
        }
    }

    enum CodingKeys: String, CodingKey {
        case type
    }
}

public struct TONSignDataPayloadText: Codable {
    public var type: TONSignDataType = .text
    public var text: String
    public var network: String?
    public var from: String?
    
    public init(
        text: String,
        network: String? = nil,
        from: String? = nil
    ) {
        self.text = text
        self.network = network
        self.from = from
    }
}

public struct TONSignDataPayloadBinary: Codable {
    public var type: TONSignDataType = .binary
    public var bytes: String
    public var network: String?
    public var from: String?
    
    public init(
        bytes: String,
        network: String? = nil,
        from: String? = nil
    ) {
        self.bytes = bytes
        self.network = network
        self.from = from
    }
}

public struct TONSignDataPayloadCell: Codable {
    public var type: TONSignDataType = .cell
    public var schema: String
    public var cell: String
    public var network: String?
    public var from: String?
    
    public init(
        schema: String,
        cell: String,
        network: String? = nil,
        from: String? = nil
    ) {
        self.schema = schema
        self.cell = cell
        self.network = network
        self.from = from
    }
}
