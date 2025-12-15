//
//  WalletJettonsListItemView.swift
//  TONWalletApp
//
//  Created by Nikita Rodionov on 30.10.2025.
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

struct WalletJettonsListItemView: View {
    let jettonItem: WalletJettonsListItem
    let onTap: () -> Void
    
    var body: some View {
        Button(action: onTap) {
            HStack(spacing: AppSpacing.spacing(3)) {
                
                Group {
                    if let image = jettonItem.image {
                        image
                            .resizable()
                            .aspectRatio(contentMode: .fill)
                    } else {
                        AsyncImage(url: jettonItem.imageURL) { image in
                            image
                                .resizable()
                                .aspectRatio(contentMode: .fill)
                        } placeholder: {
                            // File icon placeholder similar to the design
                            RoundedRectangle(cornerRadius: 8)
                                .fill(Color.TON.gray100)
                                .overlay {
                                    VStack(spacing: 2) {
                                        // File icon
                                        Image(systemName: "doc.fill")
                                            .foregroundColor(Color.TON.gray600)
                                            .font(.system(size: 16, weight: .medium))
                                        
                                        // Symbol/Type
                                        Text(jettonItem.symbol)
                                            .font(.system(size: 8, weight: .bold))
                                            .foregroundColor(Color.TON.gray600)
                                            .lineLimit(1)
                                    }
                                }
                        }
                    }
                }
                .frame(width: 48, height: 48)
                .clipShape(RoundedRectangle(cornerRadius: 8))
                
                // Content
                VStack(alignment: .leading, spacing: AppSpacing.spacing(0.5)) {
                    // Jetton Name
                    Text(jettonItem.name)
                        .textBase(weight: .medium)
                        .foregroundColor(Color.TON.gray900)
                        .lineLimit(1)
                    
                    // Symbol and Address
                    HStack(spacing: AppSpacing.spacing(1)) {
                        Text(jettonItem.symbol)
                            .textSM(weight: .medium)
                            .foregroundColor(Color.TON.gray600)
                        
                        Text(formatAddress(jettonItem.address))
                            .textSM()
                            .foregroundColor(Color.TON.gray500)
                            .lineLimit(1)
                    }
                }
                
                Spacer()
                
                // Balance and Value
                VStack(alignment: .trailing, spacing: AppSpacing.spacing(0.5)) {
                    // Balance
                    Text(jettonItem.balance)
                        .textBase(weight: .medium)
                        .foregroundColor(Color.TON.gray900)
                        .lineLimit(1)
                }
            }
        }
        .buttonStyle(PlainButtonStyle())
    }
    
    private func formatAddress(_ address: String) -> String {
        guard address.count > 8 else { return address }
        let start = String(address.prefix(4))
        let end = String(address.suffix(4))
        return "\(start)...\(end)"
    }
}
