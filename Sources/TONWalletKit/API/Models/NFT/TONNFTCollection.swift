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
    
    public init(
        address: String,
        codeHash: String?,
        dataHash: String?,
        lastTransactionLt: String?,
        nextItemIndex: String,
        ownerAddress: String?
    ) {
        self.address = address
        self.codeHash = codeHash
        self.dataHash = dataHash
        self.lastTransactionLt = lastTransactionLt
        self.nextItemIndex = nextItemIndex
        self.ownerAddress = ownerAddress
    }
}
