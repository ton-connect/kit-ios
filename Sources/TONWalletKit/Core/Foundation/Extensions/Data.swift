//
//  Data.swift
//  TONWalletKit
//
//  Created by Nikita Rodionov on 16.10.2025.
//

import Foundation

typealias Hex = String

extension Data {
    
    var hex: Hex {
        return "0x" + self.map { String(format: "%02x", $0) }.joined()
    }
}
