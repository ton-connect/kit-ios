//
//  TONTransferMessage.swift
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

public struct TONTransferMessage: Codable {
    public var toAddress: String
    public var amount: String
    public var stateInit: String? // base64 boc
    public var extraCurrency: TONConnectExtraCurrency?
    public var mode: TONSendMode?
    public var body: String? // base64 boc
    public var comment: String?
    
    public init(
        toAddress: String,
        amount: String,
        stateInit: String? = nil,
        extraCurrency: TONConnectExtraCurrency? = nil,
        mode: TONSendMode? = nil,
        body: String? = nil,
        comment: String? = nil
    ) {
        self.toAddress = toAddress
        self.amount = amount
        self.stateInit = stateInit
        self.extraCurrency = extraCurrency
        self.mode = mode
        self.body = body
        self.comment = comment
    }
}

struct TONTransferManyParams: Codable {
    var messages: [TONTransferMessage]
    
    init(messages: [TONTransferMessage]) {
        self.messages = messages
    }
}

public typealias TONConnectExtraCurrency = [Int: String]
