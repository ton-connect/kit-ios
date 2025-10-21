//
//  MainView.swift
//  TONWalletApp
//
//  Created by Nikita Rodionov on 06.10.2025.
//

import SwiftUI

struct MainView: View {
    @StateObject private var viewModel = MainViewModel()
    
    var body: some View {
        switch viewModel.state {
        case .loading:
            ProgressView()
                .task {
                    await viewModel.load()
                }
        case .addWallet:
            AddWalletView() { wallet in
                Task {
                    await viewModel.onWalletAdded(wallet)
                }
            }
        case .wallets(let viewModel):
            WalletsListView(viewModel: viewModel)
        }
    }
}
