//
//  WalletNFTDetails.swift
//  TONWalletApp
//
//  Created by Nikita Rodionov on 29.10.2025.
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
import TONWalletKit

struct WalletNFTDetails {
    let name: String
    let description: String
    
    // TODO: Play lottie animation when added into wallet kit
    let imageURL: URL?
    let collectionName: String
    let index: String
    let status: String
    let contractAddress: String
    let ownerAddress: String
    let canTransfer: Bool
    
    init(from nftItem: TONNFT) {
        self.name = nftItem.info?.name ?? "Unknown NFT"
        self.description = nftItem.info?.description ?? "No description available"
        self.imageURL = nftItem.info?.image.flatMap { $0.url }
        
        self.collectionName = nftItem.collection?.name ?? "Unknown Collection"
        
        if let index = nftItem.index {
            self.index = "#\(index)"
        } else {
            self.index = "#0"
        }
        
        self.status = (nftItem.isOnSale == true) ? "On Sale" : "Not on Sale"
        
        self.contractAddress = nftItem.address.value
        self.ownerAddress = nftItem.ownerAddress?.value ?? nftItem.realOwnerAddress?.value ?? "Unknown"
        
        self.canTransfer = nftItem.isOnSale == false && nftItem.ownerAddress != nil
    }
}
