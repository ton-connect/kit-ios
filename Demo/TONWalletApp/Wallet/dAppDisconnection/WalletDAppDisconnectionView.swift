//
//  WalletDAppDisconnectionView.swift
//  TONWalletApp
//
//  Created by Nikita Rodionov on 03.10.2025.
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

import SwiftUI
import TONWalletKit

struct WalletDAppDisconnectionView: View {
    @ObservedObject var viewModel: WalletDAppDisconnectionViewModel
    
    var body: some View {
        VStack(spacing: 8.0) {
            ForEach(0..<viewModel.events.count, id: \.self) { index in
                DisconnectEventView(event: viewModel.events[index]) {
                    viewModel.removeEvent(at: index)
                }
            }
        }
        .background(.clear)
        .onAppear {
            viewModel.connect()
        }
    }
}

private struct DisconnectEventView: View {
    let event: TONDisconnectEvent
    
    let onDismiss: (() -> Void)?
    
    var body: some View {
        
        HStack(spacing: 4.0) {
            VStack(alignment: .leading, spacing: AppSpacing.spacing(2.0)) {
                Text("Session Disconnected")
                    .textSM()
                    .foregroundColor(Color.TON.yellow800)
                
                Text(event.walletAddress ?? "")
                    .textXS()
                    .foregroundColor(Color.TON.yellow700)
            }
            
            Spacer()
            
            VStack(alignment: .trailing) {
                Button(action: { onDismiss?() }) {
                    Text("Dismiss")
                        .textSM()
                        .foregroundColor(Color.TON.yellow800)
                        .padding(AppSpacing.spacing(2.0))
                        .background(Color.TON.gray200)
                        .clipShape(RoundedRectangle(cornerRadius: AppRadius.standard))

                }
                Spacer()
            }
        }
        .frame(maxWidth: .infinity)
        .widget(style: .block(.warning))
    }
}
