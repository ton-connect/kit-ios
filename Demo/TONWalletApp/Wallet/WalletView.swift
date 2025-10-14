//
//  WalletView.swift
//  TONWalletApp
//
//  Created by Nikita Rodionov on 12.09.2025.
//

import Foundation
import SwiftUI

struct WalletView: View {
    @ObservedObject var viewModel: WalletViewModel
    @StateObject var eventsViewModel = WalletEventsViewModel()
    
    @EnvironmentObject var appStateManager: TONWalletAppStateManager
    
    var body: some View {
        ScrollView {
            VStack(spacing: 16.0) {
                WalletInfoView(viewModel: viewModel.info)
                    .widget()
                
                WalletDAppConnectionView(viewModel: viewModel.dAppConnection)
                    .widget()
                
                WalletDAppDisconnectionView(viewModel: viewModel.dAppDisconnect)
            }
            .padding(16.0)
            .frame(maxWidth: .infinity, maxHeight: .infinity)
        }
        .background(Color.TON.gray100)
        .onAppear {
            eventsViewModel.waitForEvent()
        }
        .navigationTitle("TON Wallet")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Button(
                    action: {
                        viewModel.remove()
                    },
                    label: {
                        Image(systemName: "trash")
                            .foregroundStyle(Color.TON.red600)
                    }
                )
            }
        }
        .sheet(item: $eventsViewModel.event) { event in
            WalletConnectionRequestView(
                viewModel: .init(
                    request: event.conenctionRequest,
                    wallet: viewModel.tonWallet
                )
            )
            .automaticHeightPresentationDetents()
        }
    }
}
