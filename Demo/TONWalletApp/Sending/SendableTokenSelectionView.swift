//
//  SendableTokenSelectionView.swift
//  TONWalletApp
//
//  Created by Nikita Rodionov on 01.11.2025.
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
import SwiftUI

struct SendableTokenSelectionView: View {
    let tokens: [any SendableTokenViewModel]
    let onTokenSelected: (any SendableTokenViewModel) -> Void
    
    var body: some View {
        VStack(spacing: AppSpacing.spacing(3)) {
            ForEach(0..<tokens.count, id: \.self) { index in
                SendableTokenRowView(token: tokens[index]) {
                    onTokenSelected(tokens[index])
                }
            }
        }
        .background(Color.TON.white)
        .cornerRadius(AppRadius.standard)
    }
}

private struct SendableTokenRowView: View {
    let token: any SendableTokenViewModel
    let onTap: () -> Void
    
    var body: some View {
        Button(action: onTap) {
            HStack(spacing: AppSpacing.spacing(3)) {
                // Token Icon
                SendableTokenInitialsView(initials: token.initials)
                
                // Token Info
                VStack(alignment: .leading, spacing: AppSpacing.spacing(0.5)) {
                    // Token Name
                    Text(token.name)
                        .textBase(weight: .medium)
                        .foregroundColor(Color.TON.gray900)
                        .lineLimit(1)
                    
                    // Token Symbol
                    Text(token.symbol)
                        .textSM()
                        .foregroundColor(Color.TON.gray500)
                        .lineLimit(1)
                }
                
                Spacer()
                
                // Balance Info
                VStack(alignment: .trailing, spacing: AppSpacing.spacing(0.5)) {
                    // Balance Amount
                    Text(token.balance)
                        .textBase(weight: .medium)
                        .foregroundColor(Color.TON.gray900)
                        .lineLimit(1)
                    
                    // Token Symbol (right side)
                    Text(token.symbol)
                        .textSM()
                        .foregroundColor(Color.TON.gray500)
                        .lineLimit(1)
                }
            }
            .contentShape(.rect)
        }
        .buttonStyle(PlainButtonStyle())
    }
}
