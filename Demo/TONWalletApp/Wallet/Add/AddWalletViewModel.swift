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
    
    func add() async -> TONWallet? {
        isAdding = true
        
        let data = TONWalletData(
            mnemonic: mnemonic,
            name: "Test",
            network: .mainnet
        )
        
        do {
            let tonWallet = try await TONWallet.add(data: data)
            
            try storage.add(wallet: WalletEntity(address: tonWallet.address, data: data))
            
            return tonWallet
        } catch {
            isAdding = false
            
            debugPrint(error.localizedDescription)
            
            return nil
        }
    }
}
