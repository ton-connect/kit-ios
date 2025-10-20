//
//  WalletDAppConnectionViewModel.swift
//  TONWalletApp
//
//  Created by Nikita Rodionov on 30.09.2025.
//

import Foundation
import Combine
import TONWalletKit

@MainActor
class WalletDAppConnectionViewModel: ObservableObject {
    let wallet: TONWalletProtocol
    
    @Published var link = ""

    private var subscribers = Set<AnyCancellable>()
    
    init(wallet: TONWalletProtocol) {
        self.wallet = wallet
    }
    
    func connect() {
        Task {
            do {
                try await TONWalletKit.mainnet().connect(url: link)
            } catch {
                debugPrint(error.localizedDescription)
            }
        }
    }
}

extension WalletDAppConnectionViewModel {
    
    enum Approval {
        case connection
    }
}
