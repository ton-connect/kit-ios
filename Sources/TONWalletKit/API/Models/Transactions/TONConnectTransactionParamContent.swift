//
//  TONConnectTransactionParamContent.swift
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

public struct TONConnectTransactionParamMessage: Codable {
    public var address: String
    public var amount: String
    public var payload: String? // boc
    public var stateInit: String? // boc
    public var extraCurrency: TONConnectExtraCurrency?
    public var mode: Int?
    
    public init(
        address: String,
        amount: String,
        payload: String? = nil,
        stateInit: String? = nil,
        extraCurrency: TONConnectExtraCurrency? = nil,
        mode: Int? = nil
    ) {
        self.address = address
        self.amount = amount
        self.payload = payload
        self.stateInit = stateInit
        self.extraCurrency = extraCurrency
        self.mode = mode
    }
}

public struct TONConnectTransactionParamContent: Codable {
    public var messages: [TONConnectTransactionParamMessage]
    public var network: TONNetwork?
    public var validUntil: Int?
    public var from: String?
    
    public init(
        messages: [TONConnectTransactionParamMessage],
        network: TONNetwork? = nil,
        validUntil: Int? = nil,
        from: String? = nil
    ) {
        self.messages = messages
        self.network = network
        self.validUntil = validUntil
        self.from = from
    }
    
    enum CodingKeys: String, CodingKey {
        case messages
        case network
        case validUntil = "valid_until"
        case from
    }
}
