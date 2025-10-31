//
//  TONModelsJSConvertion.swift
//  TONWalletKit
//
//  Created by Nikita Rodionov on 22.10.2025.
//

import Foundation

extension TONConnectTransactionParamContent: JSValueDecodable {}
extension TONTransactionPreview: JSValueDecodable {}
extension TONNFTItems: JSValueDecodable {}
extension TONNFTItem: JSValueDecodable {}
extension TONPrepareSignDataResult: JSValueDecodable {}
extension TONProofParsedMessage: JSValueDecodable {}
extension TONWalletTransactionResponse: JSValueDecodable {}
extension TONWalletSignDataResponse: JSValueDecodable {}
extension TONConnectRequestEvent: JSValueDecodable {}
extension TONSignDataRequestEvent: JSValueDecodable {}
extension TONTransactionRequestEvent: JSValueDecodable {}
extension TONDisconnectEvent: JSValueDecodable {}
extension TONBalance: JSValueDecodable {}

extension TONTransferMessage: JSValueEncodable {}
extension TONTransferManyParams: JSValueEncodable {}
extension TONConnectTransactionParamContent: JSValueEncodable {}
extension TONNFTTransferParamsHuman: JSValueEncodable {}
extension TONNFTTransferParamsRaw: JSValueEncodable {}
extension TONLimitRequest: JSValueEncodable {}
extension TONJettonTransferParams: JSValueEncodable {}
extension TONV4R2WalletParameters: JSValueEncodable {}
extension TONV5R1WalletParameters: JSValueEncodable {}
extension TONConnectRequestEvent: JSValueEncodable {}
extension TONSignDataRequestEvent: JSValueEncodable {}
extension TONTransactionRequestEvent: JSValueEncodable {}
extension TONDisconnectEvent: JSValueEncodable {}
extension TONWalletKitConfiguration: JSValueEncodable {}
extension TONBalance: JSValueEncodable {}
