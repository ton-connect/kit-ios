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
    let wallet: TONWallet
    
    @Published var link = ""
    @Published var isConnecting = false

    private var subscribers = Set<AnyCancellable>()
    
    init(wallet: TONWallet) {
        self.wallet = wallet
    }
    
    func connect() {
        isConnecting = true
        
        Task {
            do {
                try await wallet.connect(url: link)
            } catch {
                debugPrint(error.localizedDescription)
                isConnecting = false
            }
        }
    }
    
    func waitForEvent() {
        subscribers.removeAll()
        
        TONEventsHandler.shared.events
            .receive(on: DispatchQueue.main)
            .sink { [weak self] event in
                switch event {
                case .connectRequest:
                    self?.isConnecting = false
                default: ()
                }
            }
            .store(in: &subscribers)
    }
}

extension WalletDAppConnectionViewModel {
    
    enum Approval {
        case connection
    }
}
