//
//  AddWalletViewModel.swift
//  TONWalletApp
//
//  Created by Nikita Rodionov on 06.10.2025.
//

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
            let tonWallet = try await TONWalletKit.mainnet().addV5R1Wallet(
                mnemonic: mnemonic,
                parameters: TONV5R1WalletParameters(
                    network: .mainnet
                )
            )
            
            try storage.add(wallet: WalletEntity(address: tonWallet.address, data: data))
            
            return tonWallet
        } catch {
            isAdding = false
            
            debugPrint(error.localizedDescription)
            
            return nil
        }
    }
}
