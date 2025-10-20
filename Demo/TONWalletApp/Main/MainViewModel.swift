//
//  MainViewModel.swift
//  TONWalletApp
//
//  Created by Nikita Rodionov on 06.10.2025.
//

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
