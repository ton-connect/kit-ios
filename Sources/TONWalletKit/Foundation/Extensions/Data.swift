//
//  Data.swift
//  TONWalletKit
//
//  Created by Nikita Rodionov on 16.10.2025.
//

import Foundation

extension Data {
    
    var hex: String {
        return "0x" + self.map { String(format: "%02x", $0) }.joined()
    }
    
    init?(hex: String) {
        let hexString = hex.hasPrefix("0x") ? String(hex.dropFirst(2)) : hex
        
        guard hexString.count % 2 == 0 else { return nil }
        
        var data = Data(capacity: hexString.count / 2)
        
        var index = hexString.startIndex
        
        while index < hexString.endIndex {
            let nextIndex = hexString.index(index, offsetBy: 2)
            let byteString = hexString[index..<nextIndex]
            
            guard let byte = UInt8(byteString, radix: 16) else {
                return nil
            }
            
            data.append(byte)
            index = nextIndex
        }
        
        self = data
    }
}
