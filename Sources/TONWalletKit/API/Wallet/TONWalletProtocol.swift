//
//  TONWallet.swift
//  TONWalletKit
//
//  Created by Nikita Rodionov on 12.09.2025.
//

import Foundation

public protocol TONWalletAdapter {
    var publicKey: Data { get }
    var version: TONWalletVersion { get }
    var network: TONNetwork { get }
    
    func address(testnet: Bool) throws -> String
    func stateInit() async throws -> Data
    func signedSendTransaction(input: TONConnectTransactionParamContent, fakeSignature: Bool) async throws -> String
    func signedSignData(input: TONPrepareSignDataResult, fakeSignature: Bool) async throws -> Data
    func signedTonProof(input: TONProofParsedMessage, fakeSignature: Bool) async throws -> Data
}

public protocol TONWalletProtocol {
    var address: String { get }
    var version: TONWalletVersion { get }
    
    func balance() async throws -> TONBalance?
    
    func transferTON(message: TONTransferMessage) async throws -> TONConnectTransactionParamContent
    func transferTON(messages: [TONTransferMessage]) async throws -> TONConnectTransactionParamContent
    
    func transactionPreview(data: TONConnectTransactionParamContent) async throws -> TONTransactionPreview
    
    func transferNFT(parameters: TONNFTTransferParamsHuman) async throws -> TONConnectTransactionParamContent
    func transferNFT(rawParameters: TONNFTTransferParamsRaw) async throws -> TONConnectTransactionParamContent
    
    func nfts(limit: TONLimitRequest) async throws -> TONNFTItems
    func nft(address: String) async throws -> TONNFTItem

    func transferJetton(parameters: TONJettonTransferParams) async throws -> TONConnectTransactionParamContent
    func jettonBalance(jettonAddress: String) async throws -> TONBalance
    func jettonWalletAddress(jettonAddress: String) async throws -> String
}
