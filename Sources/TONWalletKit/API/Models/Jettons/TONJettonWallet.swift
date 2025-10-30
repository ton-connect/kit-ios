//
//  TONJettonWallet.swift
//  TONWalletKit
//
//  Created by Nikita Rodionov on 30.10.2025.
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

public struct TONJettonWallet: Codable {
    public let address: String
    public let balance: String?
    public let owner: String?
    // TODO: Remove this hack after JettonInfo is added into JettonWallet on JS side
    public internal(set) var jetton: TONJetton?
    public let jettonAddress: String?
    public let lastTransactionLt: String?
    public let codeHash: String?
    public let dataHash: String?
    
    enum CodingKeys: String, CodingKey {
        case address
        case balance
        case owner
        case jettonAddress = "jetton"
        case lastTransactionLt = "last_transaction_lt"
        case codeHash = "code_hash"
        case dataHash = "data_hash"
    }
}
