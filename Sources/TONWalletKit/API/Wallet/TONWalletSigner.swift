//
//  TONWalletSigner.swift
//  TONWalletKit
//
//  Created by Nikita Rodionov on 16.10.2025.
//

import Foundation

public protocol TONWalletSigner {
    
    func sign(data: Data) throws -> Data
}
