//  TONNFTCollection.swift
//  TONWalletKit
//
//  Created by Nikita Rodionov on 14.10.2025.
//

import Foundation

public struct TONNFTCollection: Codable {
    public let address: String
    public let codeHash: String?
    public let dataHash: String?
    public let lastTransactionLt: String?
    public let nextItemIndex: String
    public let ownerAddress: String?
}
