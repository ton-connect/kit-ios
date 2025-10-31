//
//  WalletInfoViewModel.swift
//  TONWalletApp
//
//  Created by Nikita Rodionov on 30.09.2025.
//

import Foundation
import TONWalletKit

@MainActor
class WalletInfoViewModel: ObservableObject {
    let wallet: TONWalletProtocol
    
    var address: String { wallet.address }
    
    @Published private(set) var balance: String?
    
    init(wallet: TONWalletProtocol) {
        self.wallet = wallet
    }
    
    func load() async {
        if balance != nil { return }
        
        do {
            let formatter = TONBalanceFormatter()
            let balance = try await wallet.balance()
            self.balance = balance.flatMap { formatter.string(from: $0) } ?? "Unknown balance"
        } catch {
            debugPrint(error.localizedDescription)
        }
    }
}
