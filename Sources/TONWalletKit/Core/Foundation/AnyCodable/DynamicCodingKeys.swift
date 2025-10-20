//
//  DynamicCodingKeys.swift
//  TONWalletKit
//
//  Created by Nikita Rodionov on 20.10.2025.
//

import Foundation

struct DynamicCodingKeys: CodingKey {
    var stringValue: String
    var intValue: Int?
    
    init?(stringValue: String) {
        self.stringValue = stringValue
        self.intValue = nil
    }
    
    init?(intValue: Int) {
        self.stringValue = "\(intValue)"
        self.intValue = intValue
    }
}

