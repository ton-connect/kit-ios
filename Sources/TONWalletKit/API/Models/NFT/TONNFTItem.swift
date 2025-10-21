//  TONNFTItem.swift
//  TONWalletKit
//
//  Created by Nikita Rodionov on 14.10.2025.
//

import Foundation

public struct TONNFTItem: Codable {
    public let address: String
    public let auctionContractAddress: String?
    public let codeHash: String?
    public let dataHash: String?
    public let collection: TONNFTCollection?
    public let collectionAddress: String?
    public let metadata: TONTokenInfo?
    public let index: String?
    public let initFlag: Bool?
    public let lastTransactionLt: String?
    public let onSale: Bool?
    public let ownerAddress: String?
    public let realOwner: String?
    public let saleContractAddress: String?
    
    public init(
        address: String,
        auctionContractAddress: String?,
        codeHash: String?,
        dataHash: String?,
        collection: TONNFTCollection?,
        collectionAddress: String?,
        metadata: TONTokenInfo?,
        index: String?,
        initFlag: Bool?,
        lastTransactionLt: String?,
        onSale: Bool?,
        ownerAddress: String?,
        realOwner: String?,
        saleContractAddress: String?
    ) {
        self.address = address
        self.auctionContractAddress = auctionContractAddress
        self.codeHash = codeHash
        self.dataHash = dataHash
        self.collection = collection
        self.collectionAddress = collectionAddress
        self.metadata = metadata
        self.index = index
        self.initFlag = initFlag
        self.lastTransactionLt = lastTransactionLt
        self.onSale = onSale
        self.ownerAddress = ownerAddress
        self.realOwner = realOwner
        self.saleContractAddress = saleContractAddress
    }
}
