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
    public let address: String
    public let version: TONWalletVersion

    let wallet: any JSDynamicObject

    init(
        wallet: any JSDynamicObject,
        address: String,
        version: TONWalletVersion
    ) {
        self.wallet = wallet
        self.address = address
        self.version = version
    }
    
    public func balance() async throws -> TONBalance? {
        let balance: String = try await wallet.getBalance()
        let bigInt = BigInt(balance)
        return bigInt.flatMap { TONBalance(nanoUnits: $0) }
    }
    
    public func transferTONTransaction(message: TONTransferMessage) async throws -> TONConnectTransactionParamContent {
        try await wallet.createTransferTonTransaction(message)
    }
    
    public func transferTONTransaction(messages: [TONTransferMessage]) async throws -> TONConnectTransactionParamContent {
        try await wallet.createTransferMultiTonTransaction(TONTransferManyParams(messages: messages))
    }
    
    public func send(transaction: TONConnectTransactionParamContent) async throws {
        try await wallet.sendTransaction(transaction)
    }
    
    public func preview(transaction: TONConnectTransactionParamContent) async throws -> TONTransactionPreview {
        try await wallet.getTransactionPreview(transaction)
    }
    
    public func transferNFTTransaction(parameters: TONNFTTransferParamsHuman) async throws -> TONConnectTransactionParamContent {
        try await wallet.createTransferNftTransaction(parameters)
    }
    
    public func transferNFTTransaction(rawParameters: TONNFTTransferParamsRaw) async throws -> TONConnectTransactionParamContent {
        try await wallet.createTransferNftRawTransaction(rawParameters)
    }
    
    public func nfts(limit: TONLimitRequest) async throws -> TONNFTItems {
        try await wallet.getNfts(limit)
    }
    
    public func nft(address: String) async throws -> TONNFTItem {
        try await wallet.getNft(address)
    }
    
    public func transferJettonTransaction(parameters: TONJettonTransferParams) async throws -> TONConnectTransactionParamContent {
        try await wallet.createTransferJettonTransaction(parameters)
    }

    public func jettonsWallets(limit: TONLimitRequest) async throws -> TONJettonWallets {
        // TODO: Remove this hack after JettonInfo is added into JettonWallet on JS side
        var wallets: TONJettonWallets = try await wallet.getJettons(limit)
        var items: [TONJettonWallet] = []
        
        for var wallet in wallets.items {
            guard let jettonAddress = wallet.jettonAddress else {
                items.append(wallet)
                continue
            }
            
            let jetton: TONJetton = try await self.wallet.jsContext.walletKit.jettonsManager().getJettonInfo(jettonAddress)
            
            wallet.jetton = jetton

            items.append(wallet)
        }
        wallets.items = items
        return wallets
    }
}
