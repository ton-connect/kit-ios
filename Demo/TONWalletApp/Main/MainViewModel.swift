//
//  MainViewModel.swift
//  TONWalletApp
//
//  Created by Nikita Rodionov on 06.10.2025.
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
class MainViewModel: ObservableObject {
    @Published var state: State = .loading
    
    private let storage = WalletsStorage()
    
    func load() async {
        do {
            let wallets = try storage.wallets()
            
            var tonWallets: [TONWalletProtocol] = []
            
            for wallet in wallets {
                switch wallet.data.version {
                case .unknown: continue
                case .v4r2:
                    let tonWallet = try await TONWalletKit.mainnet().addV4R2Wallet(
                        mnemonic: TONMnemonic(
                            value: wallet.data.mnemonic
                        ),
                        parameters: .init(network: .mainnet)
                    )
                    tonWallets.append(tonWallet)
                case .v5r1:
                    let tonWallet = try await TONWalletKit.mainnet().addV5R1Wallet(
                        mnemonic: TONMnemonic(
                            value: wallet.data.mnemonic
                        ),
                        parameters: .init(network: .mainnet)
                    )
                    tonWallets.append(tonWallet)
                }
            }
            
            if tonWallets.isEmpty {
                state = .addWallet
            } else {
                show(wallets: tonWallets)
            }
        } catch {
            state = .addWallet
        }
    }
    
    func show(wallets: [TONWalletProtocol]) {
        if wallets.isEmpty {
            return
        }
        
        let wallets = wallets.map { wallet in
            WalletViewModel(tonWallet: wallet)
        }
        
        let viewModel = walletsListViewModel()
        viewModel.add(wallets: wallets)
        
        state = .wallets(viewModel: viewModel)
    }
    
    func walletsListViewModel() -> WalletsListViewModel {
        switch state {
        case .loading, .addWallet:
            let viewModel = WalletsListViewModel(wallets: [])
            
            viewModel.onRemoveAll = { [weak self] in
                self?.state = .addWallet
            }
            return viewModel
        case .wallets(let viewModel):
            return viewModel
        }
    }
}

extension MainViewModel {
    
    enum State {
        case loading
        case addWallet
        case wallets(viewModel: WalletsListViewModel)
        
        var isLoading: Bool {
            switch self {
            case .loading:
                return true
            default:
                return false
            }
        }
    }
}
