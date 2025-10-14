//
//  WalletTransactionRequestView.swift
//  TONWalletApp
//
//  Created by GitHub Copilot on 10.10.2025.
//

import SwiftUI

struct WalletTransactionRequestView: View {
    @StateObject var viewModel: WalletTransactionRequestViewModel
    
    @Environment(\.dismiss) var dismiss
    
    var body: some View {
        VStack(spacing: 0) {
            // Scrollable content
            VStack(spacing: AppSpacing.spacing(4.0)) {
                // Header
                VStack(spacing: AppSpacing.spacing(2.0)) {
                    Text("Transaction Request")
                        .textXL(weight: .bold)
                        .foregroundColor(Color.TON.gray900)
                    
                    Text("A dApp wants to send a transaction from your wallet")
                        .textSM()
                        .foregroundColor(Color.TON.gray600)
                        .fixedSize(horizontal: false, vertical: true)
                        .multilineTextAlignment(.center)
                }
                
                // DApp Info
                if let dAppInfo = viewModel.dAppInfo {
                    DAppView(dAppInfo: dAppInfo)
                }
                
                // Warning
                HStack(spacing: AppSpacing.spacing(2.0)) {
                    Image(systemName: "exclamationmark.triangle.fill")
                        .foregroundColor(Color.orange)
                        .font(.system(size: 16))
                    
                    VStack(alignment: .leading, spacing: 4) {
                        Text("Warning: This transaction will be irreversible. Only approve if you trust the requesting dApp and understand the transaction details.")
                            .textSM()
                            .foregroundColor(Color.orange)
                            .fixedSize(horizontal: false, vertical: true)
                    }
                    
                    Spacer()
                }
                .padding(AppSpacing.spacing(3.0))
                .background(Color.orange.opacity(0.1))
                .cornerRadius(12)
            }
            .padding(AppSpacing.spacing(4.0))
            
            // Fixed bottom buttons
            VStack(spacing: 0) {
                HStack(spacing: AppSpacing.spacing(2.0)) {
                    Button("Reject") {
                        viewModel.reject()
                    }
                    .buttonStyle(TONButtonStyle(type: .secondary))
                    
                    Button("Approve") {
                        viewModel.approve()
                    }
                    .buttonStyle(TONButtonStyle(type: .primary))
                }
                .padding(AppSpacing.spacing(4.0))
            }
        }
        .onReceive(viewModel.dismiss) { dismiss() }
    }
}

#Preview {
    Text("WalletTransactionRequestView Preview")
}
