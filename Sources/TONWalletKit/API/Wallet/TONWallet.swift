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
    public let id: String
    public let address: TONUserFriendlyAddress

    let jsWallet: any JSDynamicObject

    init(
        jsWallet: any JSDynamicObject,
        id: String,
        address: TONUserFriendlyAddress
    ) {
        self.jsWallet = jsWallet
        self.id = id
        self.address = address
    }
    
    public func balance() async throws -> TONBalance {
        try await jsWallet.getBalance()
    }
    
    public func transferTONTransaction(request: TONTransferRequest) async throws -> TONTransactionRequest {
        try await jsWallet.createTransferTonTransaction(request)
    }
    
    public func transferTONTransaction(requests: [TONTransferRequest]) async throws -> TONTransactionRequest {
        try await jsWallet.createTransferMultiTonTransaction(requests)
    }
    
    public func send(transactionRequest: TONTransactionRequest) async throws {
        try await jsWallet.sendTransaction(transactionRequest)
    }
    
    public func preview(transactionRequest: TONTransactionRequest) async throws -> TONTransactionEmulatedPreview {
        try await jsWallet.getTransactionPreview(transactionRequest)
    }
    
    public func transferNFTTransaction(request: TONNFTTransferRequest) async throws -> TONTransactionRequest {
        try await jsWallet.createTransferNftTransaction(request)
    }
    
    public func transferNFTTransaction(request: TONNFTRawTransferRequest) async throws -> TONTransactionRequest {
        try await jsWallet.createTransferNftRawTransaction(request)
    }
    
    public func nfts(request: TONNFTsRequest) async throws -> TONNFTsResponse {
        try await jsWallet.getNfts(request)
    }
    
    public func nft(address: TONUserFriendlyAddress) async throws -> TONNFT{
        try await jsWallet.getNft(address.value)
    }
    
    public func jettonBalance(jettonAddress: TONUserFriendlyAddress) async throws -> TONBalance {
        try await jsWallet.getJettonBalance(jettonAddress.value)
    }
    
    public func jettonWalletAddress(jettonAddress: TONUserFriendlyAddress) async throws -> TONUserFriendlyAddress {
        try await jsWallet.getJettonWalletAddress(jettonAddress.value)
    }
    
    public func transferJettonTransaction(request: TONJettonsTransferRequest) async throws -> TONTransactionRequest {
        try await jsWallet.createTransferJettonTransaction(request)
    }

    public func jettons(request: TONJettonsRequest) async throws -> TONJettonsResponse {
        try await jsWallet.getJettons(request)
    }
}

extension TONWallet: JSValueEncodable {
    
    func encode(in context: JSContext) throws -> Any { jsWallet }
}
