//
//  WalletJettonsListViewModel.swift
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
import Combine
import TONWalletKit

@MainActor
final class WalletJettonsListViewModel: ObservableObject {
    @Published private(set) var state: State = .initial
    @Published private(set) var jettons: [WalletJettonsListItem] = []
    @Published private(set) var isLoadingMore = false
    
    private let limit = 10
    
    private let wallet: TONWalletProtocol
    
    @Published private(set) var canLoadMore: Bool = false
    
    private var subscribers = Set<AnyCancellable>()
    
    init(wallet: TONWalletProtocol) {
        self.wallet = wallet
    }
    
    func loadJettons() async {
        guard state == .initial else { return }
        
        subscribeToBalanceChanges()
        
        state = .loading
        
        do {
            let request = TONJettonsRequest(pagination: TONPagination(limit: limit))
            let response = try await wallet.jettons(request: request)
            
            if response.jettons.isEmpty {
                state = .empty
            } else {
                canLoadMore = response.jettons.count == limit
                self.jettons = response.jettons.map { WalletJettonsListItem(jetton: $0, wallet: wallet) }
                state = self.jettons.isEmpty ? .empty : .jettons
            }
        } catch {
            state = .empty
            debugPrint("Failed to load jettons: \(error)")
        }
    }
    
    func loadMoreJettons() {
        guard canLoadMore && state == .jettons && !isLoadingMore else { return }
        
        isLoadingMore = true
        
        Task { [weak self] in
            guard let self = self else { return }
            
            do {
                let request = TONJettonsRequest(pagination: TONPagination(limit: limit, offset: jettons.count))
                let response = try await wallet.jettons(request: request)
                
                let newJettonItems = response.jettons.map { jetton in
                    WalletJettonsListItem(jetton: jetton, wallet: self.wallet)
                }
                
                self.jettons.append(contentsOf: newJettonItems)
            } catch {
                debugPrint("Failed to load more jettons: \(error)")
            }
            isLoadingMore = false
        }
    }
    
    func remove(jetton: WalletJettonsListItem) {
        jettons.removeAll { $0.id == jetton.id }
    }
    
    func subscribeToBalanceChanges() {
        Task {
            try await TONWalletKit.shared().streaming().jettons(network: .mainnet, address: wallet.address.value)
                .receive(on: DispatchQueue.main)
                .sink(
                    receiveCompletion: { _ in },
                    receiveValue: { [weak self] update in
                        guard let self else { return }
                        
                        if update.status == .finalized {
                            self.jettons = self.jettons.map { $0.applying(update: update) }
                        }
                    }
                )
                .store(in: &subscribers)
        }
    }
}

extension WalletJettonsListViewModel {
    
    enum State {
        case initial
        case loading
        case empty
        case jettons
    }
}
