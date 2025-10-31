//
//  AddWalletView.swift
//  TONWalletApp
//
//  Created by Nikita Rodionov on 12.09.2025.
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
