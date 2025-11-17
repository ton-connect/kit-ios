//
//  TONWallet.swift
//  TONWalletKit
//
//  Created by Nikita Rodionov on 12.09.2025.
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

public protocol TONWalletAdapterProtocol: AnyObject {

    func publicKey() -> TONHex
    func network() -> TONNetwork
    func address(testnet: Bool) throws -> String
    func stateInit() async throws -> TONBase64
    func signedSendTransaction(input: TONConnectTransactionParamContent, fakeSignature: Bool?) async throws -> TONBase64
    func signedSignData(input: TONPrepareSignDataResult, fakeSignature: Bool?) async throws -> TONHex
    func signedTonProof(input: TONProofParsedMessage, fakeSignature: Bool?) async throws -> TONHex
}

public protocol TONWalletProtocol {
    var address: String { get }
    
    func balance() async throws -> TONBalance
    
    func transferTONTransaction(message: TONTransferMessage) async throws -> TONConnectTransactionParamContent
    func transferTONTransaction(messages: [TONTransferMessage]) async throws -> TONConnectTransactionParamContent
    
    func send(transaction: TONConnectTransactionParamContent) async throws
    func preview(transaction: TONConnectTransactionParamContent) async throws -> TONTransactionPreview
    
    func transferNFTTransaction(parameters: TONNFTTransferParamsHuman) async throws -> TONConnectTransactionParamContent
    func transferNFTTransaction(rawParameters: TONNFTTransferParamsRaw) async throws -> TONConnectTransactionParamContent
    
    func nfts(limit: TONLimitRequest) async throws -> [TONNFTItem]
    func nft(address: String) async throws -> TONNFTItem
    
    func jettonBalance(jettonAddress: String) async throws -> TONBalance
    func jettonWalletAddress(jettonAddress: String) async throws -> String
    
    func transferJettonTransaction(parameters: TONJettonTransferParams) async throws -> TONConnectTransactionParamContent
    func jettons(limit: TONLimitRequest) async throws -> TONJettons
}

public extension TONWalletProtocol {
    
    func nfts(limit: Int) async throws -> [TONNFTItem] {
        try await nfts(limit: TONLimitRequest(limit: limit))
    }
}
