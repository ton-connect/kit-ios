//
//  TONV5R1Wallet.swift
//  TONWalletKit
//
//  Created by Nikita Rodionov on 16.10.2025.
//

import Foundation

public class TONWallet: TONWalletProtocol {
    public let address: String?
    public let version: TONWalletVersion

    let wallet: any JSDynamicObject

    init(
        wallet: any JSDynamicObject,
        address: String?,
        version: TONWalletVersion
    ) {
        self.wallet = wallet
        self.address = address
        self.version = version
    }
    
    public func balance() async throws -> String? {
        try await wallet.getBalance()?.toString()
    }
    
    public func transferTON(message: TONTransferMessage) async throws -> TONConnectTransactionParamContent? {
        try await wallet.createTransferTonTransaction(message)?.decode()
    }
    
    public func transferTON(messages: [TONTransferMessage]) async throws -> TONConnectTransactionParamContent? {
        try await wallet.createTransferMultiTonTransaction(TONTransferManyParams(messages: messages))?.decode()
    }
    
    public func transactionPreview(data: TONConnectTransactionParamContent) async throws -> TONTransactionPreview? {
        try await wallet.getTransactionPreview(data)?.decode()
    }
    
    public func transferNFT(parameters: TONNFTTransferParamsHuman) async throws -> TONConnectTransactionParamContent? {
        try await wallet.createTransferNftTransaction(parameters)?.decode()
    }
    
    public func transferNFT(rawParameters: TONNFTTransferParamsRaw) async throws -> TONConnectTransactionParamContent? {
        try await wallet.createTransferNftRawTransaction(rawParameters)?.decode()
    }
    
    public func nfts(limit: TONLimitRequest) async throws -> TONNFTItems? {
        try await wallet.getNfts(limit)?.decode()
    }
    
    public func nft(address: String) async throws -> TONNFTItem? {
        try await wallet.getNft(address)?.decode()
    }
    
    public func transferJetton(parameters: TONJettonTransferParams) async throws -> TONConnectTransactionParamContent? {
        try await wallet.createTransferJettonTransaction(parameters)?.decode()
    }
    
    public func jettonBalance(jettonAddress: String) async throws -> String? {
        try await wallet.getJettonBalance(jettonAddress)?.toString()
    }
    
    public func jettonWalletAddress(jettonAddress: String) async throws -> String? {
        try await wallet.getJettonWalletAddress(jettonAddress)?.toString()
    }
}
