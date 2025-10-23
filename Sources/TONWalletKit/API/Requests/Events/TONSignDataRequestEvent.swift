//
//  SignDataRequestEvent.swift
//  TONWalletKit
//
//  Created by Nikita Rodionov on 11.09.2025.
//

import Foundation

public struct TONSignDataRequestEvent: Codable {
    public let id: String?
    public let from: String?
    public let walletAddress: String?
    public let domain: String?
    public let sessionId: String?
    public let messageId: String?
    public let request: TONSignDataPayload?
    public let dAppInfo: TONDAppInfo?
    public let preview: TONSignDataPreview?
}

public enum TONSignDataPreview: Codable {
    case text(TONSignDataPreviewText)
    case binary(TONSignDataPreviewBinary)
    case cell(TONSignDataPreviewCell)
    
    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let kind = try container.decode(TONSignDataType.self, forKey: .kind)
        
        switch kind {
        case .text:
            let text = try TONSignDataPreviewText(from: decoder)
            self = .text(text)
        case .binary:
            let binary = try TONSignDataPreviewBinary(from: decoder)
            self = .binary(binary)
        case .cell:
            let cell = try TONSignDataPreviewCell(from: decoder)
            self = .cell(cell)
        }
    }
    
    public func encode(to encoder: Encoder) throws {
        switch self {
        case .text(let text):
            try text.encode(to: encoder)
        case .binary(let binary):
            try binary.encode(to: encoder)
        case .cell(let cell):
            try cell.encode(to: encoder)
        }
    }
    
    private enum CodingKeys: String, CodingKey {
        case kind
    }
}

public struct TONSignDataPreviewText: Codable {
    public var kind: TONSignDataType = .text
    public let content: String
    
    public init(content: String) {
        self.content = content
    }
}

public struct TONSignDataPreviewBinary: Codable {
    public var kind: TONSignDataType = .binary
    public let content: String
    
    public init(content: String) {
        self.content = content
    }
}

public struct TONSignDataPreviewCell: Codable {
    public var kind: TONSignDataType = .cell
    public let content: String
    public let schema: String?
    public let parsed: [String: AnyCodable]?
    
    public init(
        content: String,
        schema: String? = nil,
        parsed: [String: AnyCodable]? = nil
    ) {
        self.content = content
        self.schema = schema
        self.parsed = parsed
    }
}

public enum TONSignDataType: String, Codable {
    case text
    case binary
    case cell
}
