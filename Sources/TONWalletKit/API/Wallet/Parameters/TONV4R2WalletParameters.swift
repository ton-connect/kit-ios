//
//  TONV4R2WalletParameters.swift
//  TONWalletKit
//
//  Created by Nikita Rodionov on 16.10.2025.
//

import Foundation

public struct TONV4R2WalletParameters: Codable {
    public let network: TONNetwork
    
    public init(network: TONNetwork) {
        self.network = network
    }
}
