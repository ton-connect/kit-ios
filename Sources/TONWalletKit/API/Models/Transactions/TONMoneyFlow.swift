//  TONMoneyFlow.swift
//  TONWalletKit
//
//  Created by Nikita Rodionov on 13.10.2025.
//
//  Copyright (c) 2025 TON Connect
//
//  Permission is hereby granted, free of charge, to any person obtaining a copy
//  of this software and associated documentation files (the "Software"), to deal
//  in the Software without restriction, including without limitation the rights
//  to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
//  copies of the Software, and to permit persons to whom the Software is
//  furnished to do so, subject to the following conditions:
//  
//  The above copyright notice and this permission notice shall be included in all
//  copies or substantial portions of the Software.
//  
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
//  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
//  SOFTWARE.

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
