//
//  TONNFTTransferParamsRaw.swift
//  TONWalletKit
//
//  Created by Nikita Rodionov on 17.10.2025.
//

import Foundation

public struct TONNFTTransferMessageDTO: Codable {
    public var queryId: String
    public var newOwner: String
    public var responseDestination: String?
    public var customPayload: String?
    public var forwardAmount: String
    public var forwardPayload: String?
    
    public init(queryId: String, newOwner: String, responseDestination: String? = nil, customPayload: String? = nil, forwardAmount: String, forwardPayload: String? = nil) {
        self.queryId = queryId
        self.newOwner = newOwner
        self.responseDestination = responseDestination
        self.customPayload = customPayload
        self.forwardAmount = forwardAmount
        self.forwardPayload = forwardPayload
    }
}

public struct TONNFTTransferParamsRaw: Codable {
    public var nftAddress: String
    public var transferAmount: String
    public var transferMessage: TONNFTTransferMessageDTO

    public init(nftAddress: String, transferAmount: String, transferMessage: TONNFTTransferMessageDTO) {
        self.nftAddress = nftAddress
        self.transferAmount = transferAmount
        self.transferMessage = transferMessage
    }
}
