//
//  WalletViewModel.swift
//  TONWalletApp
//
//  Created by Nikita Rodionov on 30.09.2025.
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
