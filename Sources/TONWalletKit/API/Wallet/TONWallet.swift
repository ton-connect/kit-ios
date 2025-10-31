//
//  TONV5R1Wallet.swift
//  TONWalletKit
//
//  Created by Nikita Rodionov on 16.10.2025.
//

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
    
    public func transferTON(message: TONTransferMessage) async throws -> TONConnectTransactionParamContent {
        try await wallet.createTransferTonTransaction(message)
    }
    
    public func transferTON(messages: [TONTransferMessage]) async throws -> TONConnectTransactionParamContent {
        try await wallet.createTransferMultiTonTransaction(TONTransferManyParams(messages: messages))
    }
    
    public func transactionPreview(data: TONConnectTransactionParamContent) async throws -> TONTransactionPreview {
        try await wallet.getTransactionPreview(data)
    }
    
    public func transferNFT(parameters: TONNFTTransferParamsHuman) async throws -> TONConnectTransactionParamContent {
        try await wallet.createTransferNftTransaction(parameters)
    }
    
    public func transferNFT(rawParameters: TONNFTTransferParamsRaw) async throws -> TONConnectTransactionParamContent {
        try await wallet.createTransferNftRawTransaction(rawParameters)
    }
    
    public func nfts(limit: TONLimitRequest) async throws -> TONNFTItems {
        try await wallet.getNfts(limit)
    }
    
    public func nft(address: String) async throws -> TONNFTItem {
        try await wallet.getNft(address)
    }
    
    public func transferJetton(parameters: TONJettonTransferParams) async throws -> TONConnectTransactionParamContent {
        try await wallet.createTransferJettonTransaction(parameters)
    }
    
    public func jettonBalance(jettonAddress: String) async throws -> TONBalance {
        try await wallet.getJettonBalance(jettonAddress)
    }
    
    public func jettonWalletAddress(jettonAddress: String) async throws -> String {
        try await wallet.getJettonWalletAddress(jettonAddress)
    }
}
