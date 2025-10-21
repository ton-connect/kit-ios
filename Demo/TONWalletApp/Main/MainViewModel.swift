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
            let kit = try await TONWalletKit.mainnet()
            let wallets = try storage.wallets()
            
            var tonWallets: [TONWalletProtocol] = []
            
            for wallet in wallets {
                switch wallet.data.version {
                case .unknown: continue
                case .v4r2:
                    let tonWallet = try await kit.addV4R2Wallet(
                        mnemonic: TONMnemonic(
                            value: wallet.data.mnemonic
                        ),
                        parameters: .init(network: .mainnet)
                    )
                    tonWallets.append(tonWallet)
                case .v5r1:
                    let tonWallet = try await kit.addV5R1Wallet(
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
                show(wallets: tonWallets, walletKit: kit)
            }
        } catch {
            state = .addWallet
        }
    }
    
    func onWalletAdded(_ wallet: TONWalletProtocol) async {
        do {
            let kit = try await TONWalletKit.mainnet()
            show(wallets: [wallet], walletKit: kit)
        } catch {
            debugPrint("Failed to initialize TONWalletKit:", error)
        }
    }
    
    func show(wallets: [TONWalletProtocol], walletKit: TONWalletKit) {
        if wallets.isEmpty {
            return
        }
        
        let wallets = wallets.map { wallet in
            WalletViewModel(tonWallet: wallet)
        }
        
        let viewModel = WalletsListViewModel(wallets: [], walletKit: walletKit)
        viewModel.onRemoveAll = { [weak self] in
            self?.state = .addWallet
        }
        viewModel.add(wallets: wallets)
        
        state = .wallets(viewModel: viewModel)
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
