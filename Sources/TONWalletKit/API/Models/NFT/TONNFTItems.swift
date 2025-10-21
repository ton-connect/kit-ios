//  TONNFTItems.swift
//  TONWalletKit
//
//  Created by Nikita Rodionov on 14.10.2025.
//

import Foundation

public struct TONNFTItems: Codable {
    public let items: [TONNFTItem]
    public let pagination: TONPagination
    
    public init(
        items: [TONNFTItem],
        pagination: TONPagination
    ) {
        self.items = items
        self.pagination = pagination
    }
}
