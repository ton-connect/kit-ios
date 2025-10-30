//
//  WalletNFTsListItemView.swift
//  TONWalletApp
//
//  Created by Nikita Rodionov on 25.12.2025.
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

struct WalletNFTsListItemView: View {
    let nftItem: WalletNFTsListItem
    let onRemove: (WalletNFTsListItem) -> Void
    
    @State private var detailsViewModel: WalletNFTDetailsViewModel?
    
    var body: some View {
        Button(
            action: {
                detailsViewModel = WalletNFTDetailsViewModel(
                    wallet: nftItem.wallet,
                    nft: nftItem.tonNFT,
                    onRemove: {
                        onRemove(nftItem)
                    }
                )
            }) {
            HStack(spacing: AppSpacing.spacing(3)) {
                // NFT Image
                let placeholder = Rectangle()
                    .fill(Color.TON.gray100)
                    .overlay {
                        Image(systemName: "photo")
                            .foregroundColor(Color.TON.gray400)
                            .textSM()
                    }
                
                Group {
                    if let imageURL = nftItem.imageURL {
                        AsyncImage(url: URL(string: imageURL.absoluteString)) { image in
                            image
                                .resizable()
                                .aspectRatio(contentMode: .fill)
                        } placeholder: { placeholder }
                    } else {
                        placeholder
                    }
                }
                .frame(width: 48, height: 48)
                .clipShape(RoundedRectangle(cornerRadius: AppRadius.standard))
                
                // Content
                VStack(alignment: .leading, spacing: AppSpacing.spacing(0.5)) {
                    // NFT Name
                    Text(nftItem.name)
                        .textBase(weight: .medium)
                        .foregroundColor(Color.TON.gray900)
                        .lineLimit(1)
                    
                    // NFT Address
                    Text(formatAddress(nftItem.address))
                        .textSM()
                        .foregroundColor(Color.TON.gray500)
                        .lineLimit(1)
                }
                
                Spacer()
                
                // Right Arrow
                Image(systemName: "chevron.right")
                    .foregroundColor(Color.TON.gray400)
                    .textSM()
            }
            .padding(.horizontal, AppSpacing.spacing(4))
            .padding(.vertical, AppSpacing.spacing(3))
        }
        .buttonStyle(PlainButtonStyle())
        .sheet(item: $detailsViewModel) { details in
            WalletNFTDetailsView(viewModel: details)
                .presentationDragIndicator(.visible)
        }
    }
    
    private func formatAddress(_ address: String) -> String {
        guard address.count > 8 else { return address }
        let start = String(address.prefix(4))
        let end = String(address.suffix(4))
        return "\(start)...\(end)"
    }
}
