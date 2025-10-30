//
//  TONJettonWallets.swift
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

public struct TONJettonWallets: Codable {
    // TODO: Remove this hack after JettonInfo is added into JettonWallet on JS side
    public internal(set) var items: [TONJettonWallet]
    public let addressBook: [String: TONEmulationAddressBookEntry]?
    public let metadata: [String: TONEmulationAddressMetadata]?
    public let pagination: TONPagination?
    
    enum CodingKeys: String, CodingKey {
        case items = "jetton_wallets"
        case addressBook = "address_book"
        case metadata
        case pagination
    }
    
    init(
        items: [TONJettonWallet],
        addressBook: [String : TONEmulationAddressBookEntry]?,
        metadata: [String : TONEmulationAddressMetadata]?,
        pagination: TONPagination?
    ) {
        self.items = items
        self.addressBook = addressBook
        self.metadata = metadata
        self.pagination = pagination
    }
}
