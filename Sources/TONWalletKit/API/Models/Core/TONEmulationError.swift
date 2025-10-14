//  TONEmulationError.swift
//  TONWalletKit
//
//  Created by Nikita Rodionov on 13.10.2025.
//

import Foundation

public struct TONEmulationError: Codable {
    public let name: String
    public let message: String?
    public let cause: String?
}
