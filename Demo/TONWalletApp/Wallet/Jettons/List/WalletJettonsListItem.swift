//
//  WalletJettonsListItem.swift
//  TONWalletApp
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
import SwiftUI
import TONWalletKit

struct WalletJettonsListItem: Identifiable {
    let id = UUID()
    let name: String
    let symbol: String
    let address: String
    let balance: String
    let image: Image?
    let imageURL: URL?
    
    let jetton: TONJetton
    let wallet: TONWalletProtocol
    
    init(jetton: TONJetton, wallet: TONWalletProtocol) {
        self.wallet = wallet
        self.jetton = jetton
        
        self.name = jetton.info.name ?? "Unknown Jetton"
        self.symbol = jetton.info.symbol ?? "UNKNOWN"
        self.address = jetton.address.value
        
        let formatter = TONTokenAmountFormatter()
        formatter.nanoUnitDecimalsNumber = min(jetton.decimalsNumber ?? 0, 9)
        self.balance = formatter.string(from: jetton.balance) ?? "Unknown balance"
        
        if let imageUrl = jetton.info.image?.url {
            self.image = nil
            self.imageURL = imageUrl
        } else if let imageData = jetton.info.image?.data, let uiImage = UIImage(data: imageData) {
            self.image = Image(uiImage: uiImage)
            self.imageURL = nil
        } else {
            self.imageURL = nil
            self.image = nil
        }
    }
}
