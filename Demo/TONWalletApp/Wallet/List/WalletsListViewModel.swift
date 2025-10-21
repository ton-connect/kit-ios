//
//  WalletsListViewModel.swift
//  TONWalletApp
//
//  Created by Nikita Rodionov on 09.10.2025.
//

import Foundation
import Combine
import TONWalletKit

@MainActor
class WalletsListViewModel: ObservableObject {
    @Published private(set) var wallets: [WalletViewModel] = []
    
    var onRemoveAll: (() -> Void)?
    let walletKit: TONWalletKit?
    
    private var subscribers = Set<AnyCancellable>()
    
    @Published var event: Event?

    init(wallets: [WalletViewModel], walletKit: TONWalletKit?) {
        self.wallets = wallets
        self.walletKit = walletKit
    }
    
    func add(wallets: [TONWalletProtocol]) {
        let viewModels = wallets.map { WalletViewModel(tonWallet: $0) }
        add(wallets: viewModels)
    }
    
    func add(wallets: [WalletViewModel]) {
        self.wallets.append(contentsOf: wallets)
        
        wallets.forEach { wallet in
            let id = wallet.id
            
            wallet.onRemove = { [weak self] in
                self?.remove(walletID: id)
                
                if self?.wallets.isEmpty == true {
                    self?.onRemoveAll?()
                }
            }
        }
    }
    
    func waitForEvents() {
        subscribers.removeAll()
        
        TONEventsHandler.shared.events
            .receive(on: DispatchQueue.main)
            .sink { [weak self] event in
                switch event {
                case .transactionRequest(let request):
                    self?.event = Event(transactionRequest: request)
                case .signDataRequest(let request):
                    self?.event = Event(signDataRequest: request)
                default: ()
                }
            }
            .store(in: &subscribers)
    }
    
    private func remove(walletID: WalletViewModel.ID) {
        self.wallets.removeAll { $0.id == walletID }
    }
}

extension WalletsListViewModel {
    
    struct Event: Identifiable {
        let id = UUID()
        let transactionRequest: TONWalletTransactionRequest?
        let signDataRequest: TONWalletSignDataRequest?
        
        init(
            transactionRequest: TONWalletTransactionRequest? = nil,
            signDataRequest: TONWalletSignDataRequest? = nil
        ) {
            self.transactionRequest = transactionRequest
            self.signDataRequest = signDataRequest
        }
    }
}
