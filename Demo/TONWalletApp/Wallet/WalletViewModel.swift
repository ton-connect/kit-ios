//
//  WalletViewModel.swift
//  TONWalletApp
//
//  Created by Nikita Rodionov on 30.09.2025.
//

import Foundation
import Combine
import TONWalletKit

@MainActor
class WalletViewModel: Identifiable, ObservableObject {
    let id = UUID()

    let tonWallet: TONWalletProtocol
    
    let info: WalletInfoViewModel
    let dAppConnection: WalletDAppConnectionViewModel
    let dAppDisconnect: WalletDAppDisconnectionViewModel
    
    private let storage = WalletsStorage()
    
    var onRemove: (() -> Void)?
    
    init(
        tonWallet: TONWalletProtocol
    ) {
        self.tonWallet = tonWallet
        
        self.info = WalletInfoViewModel(wallet: tonWallet)
        self.dAppConnection = WalletDAppConnectionViewModel(wallet: tonWallet)
        self.dAppDisconnect = WalletDAppDisconnectionViewModel(wallet: tonWallet)
    }
    
    func remove() {
        do {
            try storage.remove(walletAddress: tonWallet.address)
            
            Task {
                try await TONWalletKit.mainnet().remove(walletAddress: tonWallet.address)
            }
            
            onRemove?()
        } catch {
            debugPrint(error.localizedDescription)
        }
    }
}

@MainActor
class WalletEventsViewModel: ObservableObject {
    private var subscribers = Set<AnyCancellable>()
    
    @Published var event: Event?
    
    func waitForEvent() {
        subscribers.removeAll()
        
        TONEventsHandler.shared.events
            .receive(on: DispatchQueue.main)
            .sink { [weak self] event in
                switch event {
                case .connectRequest(let request):
                    self?.event = Event(conenctionRequest: request)
                default: ()
                }
            }
            .store(in: &subscribers)
    }
}

extension WalletEventsViewModel {
    
    struct Event: Identifiable {
        let id = UUID()
        let conenctionRequest: TONWalletConnectionRequest
    }
}
