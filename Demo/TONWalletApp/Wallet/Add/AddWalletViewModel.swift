//
//  AddWalletViewModel.swift
//  TONWalletApp
//
//  Created by Nikita Rodionov on 06.10.2025.
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

@MainActor
class AddWalletViewModel: ObservableObject {
    @Published var isAdding = false
    @Published var mnemonic = TONMnemonic()
    
    var canAdd: Bool { mnemonic.isFilled }
    
    private let storage = WalletsStorage()
    
    func clear() {
        mnemonic = TONMnemonic()
    }
    
    func insert(text: String) {
        mnemonic = TONMnemonic(string: text)
    }
    
    func add() async -> TONWalletProtocol? {
        isAdding = true
        
        let data = TONWalletData(
            mnemonic: mnemonic,
            name: "Test",
            network: .mainnet,
            version: .v5r1
        )
        
        do {
            let kit = try await TONWalletKit.mainnet()
            let signer = try await kit.signer(mnemonic: mnemonic)
            let adapter = try await kit.walletV5R1Adapter(
                signer: signer,
                parameters: TONV5R1WalletParameters(
                    network: .mainnet
                )
            )
            let tonWallet = try await kit.add(walletAdapter: adapter)
            try storage.add(wallet: WalletEntity(address: tonWallet.address, data: data))
            
            return tonWallet
        } catch {
            isAdding = false
            
            debugPrint(error.localizedDescription)
            
            return nil
        }
    }
}
