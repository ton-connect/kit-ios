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
}

public struct TONMoneyFlowSelf: Codable {
    public let type: TONAssetType
    public let jetton: String?
    public let amount: String
}

public struct TONMoneyFlow: Codable {
    public let outputs: String?
    public let inputs: String?
    public let allJettonTransfers: [TONMoneyFlowRow]?
    public let ourTransfers: [TONMoneyFlowSelf]?
    public let ourAddress: String?
}
