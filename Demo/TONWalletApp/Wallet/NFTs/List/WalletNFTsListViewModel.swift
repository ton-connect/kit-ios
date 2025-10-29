//
//  WalletNFTsListViewModel.swift
//  TONWalletApp
//
//  Created by Nikita Rodionov on 29.10.2025.
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
final class WalletNFTsListViewModel: ObservableObject {
    @Published private(set) var state: State = .initial
    @Published private(set) var nfts: [WalletNFTsListItem] = []
    @Published private(set) var isLoadingMore = false
    @Published var details: WalletNFTDetailsViewModel?
    
    private var pagination: TONPagination?
    private let limit = 10
    
    private let wallet: TONWalletProtocol
    
    var canLoadMore: Bool {
        pagination != nil
    }
    
    init(wallet: TONWalletProtocol) {
        self.wallet = wallet
    }
    
    func loadNFTs() async {
        guard state == .initial else { return }
        
        state = .loading
        
        do {
            let nfts = try await wallet.nfts(limit: limit)
            
            if nfts.items.isEmpty {
                state = .empty
            } else {
                pagination = nfts.pagination
                self.nfts = nfts.items.map { WalletNFTsListItem(nft: $0) }
                state = .nfts
            }
        } catch {
            state = .empty
            debugPrint(error)
        }
    }
    
    func loadMoreNFTs() {
        guard let pagination, state == .nfts && !isLoadingMore else { return }
        
        isLoadingMore = true
        
        Task { [weak self] in
            guard let self = self else { return }
            do {
                let nfts = try await wallet.nfts(limit: TONLimitRequest(limit: limit, offset: pagination.offset))
                
                self.pagination = nfts.pagination
                self.nfts.append(contentsOf: nfts.items.map { WalletNFTsListItem(nft: $0) })
            } catch {
                debugPrint(error)
            }
            isLoadingMore = false
        }
    }
    
    func showDetails(item: WalletNFTsListItem) {
        self.details = WalletNFTDetailsViewModel(wallet: wallet, nft: item.tonNFT)
    }
}

extension WalletNFTsListViewModel {
    
    enum State {
        case initial
        case loading
        case empty
        case nfts
    }
}
