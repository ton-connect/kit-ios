//
//  AddWalletView.swift
//  TONWalletApp
//
//  Created by Nikita Rodionov on 12.09.2025.
//

import Foundation
import Combine
import SwiftUI
import TONWalletKit

@MainActor
struct AddWalletView: View {
    @StateObject var viewModel = AddWalletViewModel()
    
    let onAddWallet: (TONWalletProtocol) -> Void
    
    var body: some View {
        VStack {
            VStack(spacing: 8.0) {
                Text("Setup Wallet")
                    .font(.title)
                Text("Create a new wallet or import an existing one.")
                    .font(.subheadline)
            }
            
            MnemonicInputView(mnemonic: $viewModel.mnemonic)
                .allowsHitTesting(!viewModel.isAdding)
            
            HStack(spacing: 16.0) {
                Button("Clear all") {
                    viewModel.clear()
                }
                .buttonStyle(TONLinkButtonStyle(type: .secondary))
                
                Button("Paste from Clipboard") {
                    if let string = UIPasteboard.general.string {
                        viewModel.insert(text: string)
                        viewModel.mnemonic = TONMnemonic(string: string)
                    }
                }
                .buttonStyle(TONLinkButtonStyle(type: .primary))
            }
            
            Spacer()

            VStack {
                Button("Import Wallet") {
                    Task {
                        if let wallet = await viewModel.add() {
                            onAddWallet(wallet)
                        }
                    }
                }
                .buttonStyle(TONButtonStyle(type: .secondary, isLoading: viewModel.isAdding))
                .disabled(!viewModel.canAdd)
                
                Text("Restore wallet using recovery phrase")
                    .foregroundStyle(.gray)
                    .font(.caption)
            }
        }
        .padding(.horizontal, 16.0)
    }
}
