//
//  WalletsListView.swift
//  TONWalletApp
//
//  Created by Nikita Rodionov on 09.10.2025.
//

import SwiftUI

struct WalletsListView: View {
    @State private(set) var navigationPath = NavigationPath()
    @ObservedObject var viewModel: WalletsListViewModel
    
    var body: some View {
        NavigationStack(path: $navigationPath) {
            VStack {
                ScrollView {
                    LazyVStack {
                        ForEach(viewModel.wallets) { wallet in
                            WalletRowView(
                                walletViewModel: wallet,
                                walletInfoViewModel: wallet.info
                            )
                            .widget()
                            .contentShape(.rect)
                            .onTapGesture {
                                navigationPath.append(Paths.wallet(viewModel: wallet))
                            }
                        }
                    }
                }
                
                Spacer()
                
                Button("Add Wallet") {
                    navigationPath.append(Paths.addWallet)
                }
                .buttonStyle(TONButtonStyle(type: .primary))
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .padding(AppSpacing.spacing(4.0))
            .background(Color.TON.gray100)
            .navigationTitle("TON Wallets")
            .navigationBarTitleDisplayMode(.inline)
            .onAppear {
                viewModel.waitForEvents()
            }
            .navigationDestination(for: Paths.self) { value in
                switch value {
                case .wallet(let viewModel):
                    WalletView(viewModel: viewModel)
                case .addWallet:
                    AddWalletView() {
                        viewModel.add(wallets: [$0])
                        navigationPath.removeLast()
                    }
                case .browser:
                    WebView(url: URL(string: "https://tonconnect-demo-dapp-with-react-ui.vercel.app/iframe/iframe")!)
                        .ignoresSafeArea()
                }
            }
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button(
                        action: {
                            navigationPath.append(Paths.browser)
                        },
                        label: {
                            Image(systemName: "safari")
                        }
                    )
                }
            }
        }
        .sheet(item: $viewModel.event) { event in
            if let transactionRequest = event.transactionRequest {
                WalletTransactionRequestView(viewModel: .init(request: transactionRequest))
                    .automaticHeightPresentationDetents()
            } else if let signDataRequest = event.signDataRequest {
                WalletSignDataRequestView(viewModel: .init(request: signDataRequest))
                    .automaticHeightPresentationDetents()
            }
        }
    }
}

private enum Paths: Hashable {
    case wallet(viewModel: WalletViewModel)
    case addWallet
    case browser
    
    func hash(into hasher: inout Hasher) {
        switch self {
        case .wallet(let viewModel):
            hasher.combine(viewModel.id)
        case .addWallet:
            hasher.combine("addWallet")
        case .browser:
            hasher.combine("browser")
        }
    }
    
    static func == (lhs: Paths, rhs: Paths) -> Bool {
        switch (lhs, rhs) {
        case (.wallet(let lhsViewModel), .wallet(let rhsViewModel)):
            return lhsViewModel.id == rhsViewModel.id
        case (.addWallet, .addWallet):
            return true
        default:
            return false
        }
    }
}

private struct WalletRowView: View {
    @ObservedObject var walletViewModel: WalletViewModel
    @ObservedObject var walletInfoViewModel: WalletInfoViewModel
    
    @State private var balance: String = "Loading balance..."
    
    var body: some View {
        HStack(spacing: 16) {
            Image(systemName: "wallet.pass.fill")
                .font(.title2)
                .foregroundColor(.blue)
                .frame(width: 40, height: 40)
                .background(Color.blue.opacity(0.1))
                .clipShape(Circle())
            
            VStack(alignment: .leading, spacing: 4) {
                // Address
                Text(walletInfoViewModel.address)
                    .font(.headline)
                    .fontWeight(.medium)
                    .lineLimit(1)
                    .truncationMode(.middle)
                
                if let balance = walletInfoViewModel.balance {
                    Text("\(balance) TON")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
            }
            
            Spacer()
            
            Button(action: {
                walletViewModel.remove()
            }) {
                Image(systemName: "trash")
                    .font(.title3)
                    .foregroundColor(.red)
            }
        }
        .frame(minHeight: 60.0)
        .task {
            await walletInfoViewModel.load()
        }
    }
}
