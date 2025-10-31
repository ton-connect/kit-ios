//
//  TONModelsJSConvertion.swift
//  TONWalletKit
//
//  Created by Nikita Rodionov on 22.10.2025.
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
extension TONJetton: JSValueDecodable {}
extension TONJettons: JSValueDecodable {}

extension TONBalance: JSValueDecodable {
    
    static func from(_ value: JSValue) throws -> Self? {
        let stringValue: String = try value.decode()
        
        guard let bigInt = BigInt(stringValue) else {
            throw JSValueConversionError.unknown(message: "Unable to convert JS value \(stringValue) to BigInt")
        }
        return TONBalance(nanoUnits: bigInt)
    }
}

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

extension TONBalance: JSValueEncodable {
    
    func encode(in context: JSContext) throws -> Any {
        return String(nanoUnits)
    }
}
