//  TONMoneyFlow.swift
//  TONWalletKit
//
//  Created by Nikita Rodionov on 13.10.2025.
//

import Foundation

public struct TONMoneyFlowRow: Codable {
    public let type: TONAssetType
    public let jetton: String?
    public let from: String?
    public let to: String?
    public let amount: String?
    
    public init(
        type: TONAssetType,
        jetton: String?,
        from: String?,
        to: String?,
        amount: String?
    ) {
        self.type = type
        self.jetton = jetton
        self.from = from
        self.to = to
        self.amount = amount
    }
}

public struct TONMoneyFlowSelf: Codable {
    public let type: TONAssetType
    public let jetton: String?
    public let amount: String
    
    public init(
        type: TONAssetType,
        jetton: String?,
        amount: String
    ) {
        self.type = type
        self.jetton = jetton
        self.amount = amount
    }
}

public struct TONMoneyFlow: Codable {
    public let outputs: String?
    public let inputs: String?
    public let allJettonTransfers: [TONMoneyFlowRow]?
    public let ourTransfers: [TONMoneyFlowSelf]?
    public let ourAddress: String?
    
    public init(
        outputs: String?,
        inputs: String?,
        allJettonTransfers: [TONMoneyFlowRow]?,
        ourTransfers: [TONMoneyFlowSelf]?,
        ourAddress: String?
    ) {
        self.outputs = outputs
        self.inputs = inputs
        self.allJettonTransfers = allJettonTransfers
        self.ourTransfers = ourTransfers
        self.ourAddress = ourAddress
    }
}
