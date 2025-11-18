//
//  TONNFTTransferParamsRaw.swift
//  TONWalletKit
//
//  Created by Nikita Rodionov on 17.10.2025.
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

public struct TONNFTTransferMessageDTO: Codable {
    public var queryId: String
    public var newOwner: String
    public var responseDestination: String?
    public var customPayload: String?
    public var forwardAmount: String
    public var forwardPayload: String?
    
    public init(
        queryId: String,
        newOwner: String,
        responseDestination: String? = nil,
        customPayload: String? = nil,
        forwardAmount: String,
        forwardPayload: String? = nil
    ) {
        self.queryId = queryId
        self.newOwner = newOwner
        self.responseDestination = responseDestination
        self.customPayload = customPayload
        self.forwardAmount = forwardAmount
        self.forwardPayload = forwardPayload
    }
}

public struct TONNFTTransferParamsRaw: Codable {
    public var nftAddress: TONUserFriendlyAddress
    public var transferAmount: String
    public var transferMessage: TONNFTTransferMessageDTO

    public init(
        nftAddress: TONUserFriendlyAddress,
        transferAmount: String,
        transferMessage: TONNFTTransferMessageDTO
    ) {
        self.nftAddress = nftAddress
        self.transferAmount = transferAmount
        self.transferMessage = transferMessage
    }
}
