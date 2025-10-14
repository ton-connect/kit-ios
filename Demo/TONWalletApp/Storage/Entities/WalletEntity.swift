//
//  WalletEntity.swift
//  TONWalletApp
//
//  Created by Nikita Rodionov on 06.10.2025.
//

import Foundation
import TONWalletKit

struct WalletEntity: Codable {
    let address: String?
    let data: TONWalletData
}
