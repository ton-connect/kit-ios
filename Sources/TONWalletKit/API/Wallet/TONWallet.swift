//
//  TONV5R1Wallet.swift
//  TONWalletKit
//
//  Created by Nikita Rodionov on 16.10.2025.
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
import BigInt

public class TONWallet: TONWalletProtocol {
    public let address: TONUserFriendlyAddress

    let jsWallet: any JSDynamicObject

    init(
        jsWallet: any JSDynamicObject,
        address: TONUserFriendlyAddress
    ) {
        self.jsWallet = jsWallet
        self.address = address
    }
    
    public func balance() async throws -> TONBalance {
        try await jsWallet.getBalance()
    }
    
    public func transferTONTransaction(message: TONTransferMessage) async throws -> TONConnectTransactionParamContent {
        try await jsWallet.createTransferTonTransaction(message)
    }
    
    public func transferTONTransaction(messages: [TONTransferMessage]) async throws -> TONConnectTransactionParamContent {
        try await jsWallet.createTransferMultiTonTransaction(TONTransferManyParams(messages: messages))
    }
    
    public func send(transaction: TONConnectTransactionParamContent) async throws {
        try await jsWallet.sendTransaction(transaction)
    }
    
    public func preview(transaction: TONConnectTransactionParamContent) async throws -> TONTransactionPreview {
        try await jsWallet.getTransactionPreview(transaction)
    }
    
    public func transferNFTTransaction(parameters: TONNFTTransferParamsHuman) async throws -> TONConnectTransactionParamContent {
        try await jsWallet.createTransferNftTransaction(parameters)
    }
    
    public func transferNFTTransaction(rawParameters: TONNFTTransferParamsRaw) async throws -> TONConnectTransactionParamContent {
        try await jsWallet.createTransferNftRawTransaction(rawParameters)
    }
    
    public func nfts(limit: TONLimitRequest) async throws -> TONNFTItems {
        try await jsWallet.getNfts(limit)
    }
    
    public func nft(address: String) async throws -> TONNFTItem {
        try await jsWallet.getNft(address)
    }
    
    public func jettonBalance(jettonAddress: String) async throws -> TONBalance {
        try await jsWallet.getJettonBalance(jettonAddress)
    }
    
    public func jettonWalletAddress(jettonAddress: String) async throws -> String {
        try await jsWallet.getJettonWalletAddress(jettonAddress)
    }
    
    public func transferJettonTransaction(parameters: TONJettonTransferParams) async throws -> TONConnectTransactionParamContent {
        try await jsWallet.createTransferJettonTransaction(parameters)
    }

    public func jettons(limit: TONLimitRequest) async throws -> TONJettons {
        try await jsWallet.getJettons(limit)
    }
}

extension TONWallet: JSValueEncodable {
    
    func encode(in context: JSContext) throws -> Any { jsWallet }
}
