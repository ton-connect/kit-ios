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
}
