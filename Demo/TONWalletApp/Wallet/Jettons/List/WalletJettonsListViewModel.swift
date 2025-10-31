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
import TONWalletKit

@MainActor
final class WalletJettonsListViewModel: ObservableObject {
    @Published private(set) var state: State = .initial
    @Published private(set) var jettons: [WalletJettonsListItem] = []
    @Published private(set) var isLoadingMore = false
    
    private var pagination: TONPagination?
    private let limit = 10
    
    private let wallet: TONWalletProtocol
    
    var canLoadMore: Bool {
        pagination != nil
    }
    
    init(wallet: TONWalletProtocol) {
        self.wallet = wallet
    }
    
    func loadJettons() async {
        guard state == .initial else { return }
        
        state = .loading
        
        do {
            let jettons = try await wallet.jettons(limit: TONLimitRequest(limit: limit))
            
            if jettons.items.isEmpty {
                state = .empty
            } else {
                self.jettons = jettons.items.map { WalletJettonsListItem(jetton: $0, wallet: wallet) }
                state = self.jettons.isEmpty ? .empty : .jettons
                pagination = jettons.pagination
            }
        } catch {
            state = .empty
            debugPrint("Failed to load jettons: \(error)")
        }
    }
    
    func loadMoreJettons() {
        guard let pagination, state == .jettons && !isLoadingMore else { return }
        
        isLoadingMore = true
        
        Task { [weak self] in
            guard let self = self else { return }
            
            do {
                let jettons = try await wallet.jettons(limit: TONLimitRequest(limit: limit, offset: pagination.offset))
                
                let newJettonItems = jettons.items.map { jetton in
                    WalletJettonsListItem(jetton: jetton, wallet: self.wallet)
                }
                
                self.jettons.append(contentsOf: newJettonItems)
                self.pagination = jettons.pagination
            } catch {
                debugPrint("Failed to load more jettons: \(error)")
            }
            isLoadingMore = false
        }
    }
    
    func remove(jetton: WalletJettonsListItem) {
        jettons.removeAll { $0.id == jetton.id }
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
