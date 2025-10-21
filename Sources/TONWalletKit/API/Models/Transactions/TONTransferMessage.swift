//
//  TONTransferMessage.swift
//  TONWalletKit
//
//  Created by Nikita Rodionov on 13.10.2025.
//

import Foundation

public struct TONTransferMessage: Codable {
    public var toAddress: String
    public var amount: String
    public var stateInit: String? // base64 boc
    public var extraCurrency: TONConnectExtraCurrency?
    public var mode: TONSendMode?
    public var body: String? // base64 boc
    public var comment: String?
    
    public init(
        toAddress: String,
        amount: String,
        stateInit: String? = nil,
        extraCurrency: TONConnectExtraCurrency? = nil,
        mode: TONSendMode? = nil,
        body: String? = nil,
        comment: String? = nil
    ) {
        self.toAddress = toAddress
        self.amount = amount
        self.stateInit = stateInit
        self.extraCurrency = extraCurrency
        self.mode = mode
        self.body = body
        self.comment = comment
    }
}

struct TONTransferManyParams: Codable {
    var messages: [TONTransferMessage]
    
    init(messages: [TONTransferMessage]) {
        self.messages = messages
    }
}

public typealias TONConnectExtraCurrency = [Int: String]
