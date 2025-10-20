//
//  TONWalletVersion.swift
//  TONWalletKit
//
//  Created by Nikita Rodionov on 16.10.2025.
//

import Foundation

public enum TONWalletVersion: String, Codable {
    case v4r2
    case v5r1
    case unknown
    
    public init(value: String?) {
        guard let value else {
            self = .unknown
            return
        }
        
        self = TONWalletVersion(rawValue: value) ?? .unknown
    }
}
