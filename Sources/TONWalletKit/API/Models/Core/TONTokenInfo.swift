//  TONTokenInfo.swift
//  TONWalletKit
//
//  Created by Nikita Rodionov on 14.10.2025.
//

import Foundation

public struct TONTokenInfo: Codable {
    public let description: String?
    public let image: String?
    public let name: String?
    public let nftIndex: String?
    public let symbol: String?
    public let type: String?
    public let valid: Bool?
    
    public init(
        description: String?,
        image: String?,
        name: String?,
        nftIndex: String?,
        symbol: String?,
        type: String?,
        valid: Bool?
    ) {
        self.description = description
        self.image = image
        self.name = name
        self.nftIndex = nftIndex
        self.symbol = symbol
        self.type = type
        self.valid = valid
    }
}
