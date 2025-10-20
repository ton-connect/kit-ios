//
//  SignDataRequestEvent.swift
//  TONWalletKit
//
//  Created by Nikita Rodionov on 11.09.2025.
//

import Foundation

public struct TONSignDataRequestEvent: Codable {
    let id: String?
    let from: String?
    let walletAddress: String?
    let domain: String?
    let sessionId: String?
    let messageId: String?
    
    let request: TONSignDataPayload?
    let dAppInfo: TONDAppInfo?
    let preview: Preview?
}

extension TONSignDataRequestEvent {
    
    struct Preview: Codable {
        let type: TONSignDataType
        let content: String?
        let schema: String?
        
        enum CodingKeys: String, CodingKey {
            case type = "kind"
            case content
            case schema
        }
    }
}

public enum TONSignDataType: String, Codable {
    case text
    case binary
    case cell
}
