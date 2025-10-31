//  TONNFTItem.swift
//  TONWalletKit
//
//  Created by Nikita Rodionov on 14.10.2025.
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

public struct TONNFTItem: Codable {
    public let address: String
    public let auctionContractAddress: String?
    public let codeHash: String?
    public let dataHash: String?
    public let collection: TONNFTCollection?
    public let collectionAddress: String?
    public let content: [String: String]?
    public let metadata: TONTokenInfo?
    public let index: String?
    public let isInit: Bool?
    public let isSBT: Bool?
    public let lastTransactionLt: String?
    public let onSale: Bool?
    public let ownerAddress: String?
    public let realOwner: String?
    public let saleContractAddress: String?
    public let attributes: [Attribute]?
    
    enum CodingKeys: String, CodingKey {
        case address
        case auctionContractAddress
        case codeHash
        case dataHash
        case collection
        case collectionAddress
        case content
        case metadata
        case index
        case isInit = "init"
        case isSBT = "isSbt"
        case lastTransactionLt
        case onSale
        case ownerAddress
        case realOwner
        case saleContractAddress
        case attributes
    }
}

public extension TONNFTItem {
    
    struct Attribute: Codable {
        let traitType: String?
        let value: String?
        
        enum CodingKeys: String, CodingKey {
            case traitType = "trait_type"
            case value
        }
    }
}
