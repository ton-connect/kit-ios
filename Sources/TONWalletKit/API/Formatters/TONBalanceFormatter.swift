//
//  TONBalanceFormatter.swift
//  TONWalletKit
//
//  Created by Nikita Rodionov on 31.10.2025.
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

import Foundation
import BigInt

open class TONBalanceFormatter: Formatter {
    // Defaults to 9, as TON uses nano units (1 TON = 10^9 nanoTON)
    open var nanoUnitDecimalsNumber: Int = 9
    
    open func string(from balance: TONBalance) -> String? {
        return nil
    }
    
    open func balance(from string: String) -> TONBalance? {
        let trimmedString = string.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmedString.isEmpty else { return nil }
        
        let components = trimmedString.components(separatedBy: ".")
        guard components.count <= 2 else { return nil }
        
        let integerPart = components[0]
        let fractionalPart = components.count > 1 ? components[1] : ""
        
        guard let integerBigInt = BigInt(integerPart) else { return nil }
        
        var nanoUnits = integerBigInt * BigInt(10).power(nanoUnitDecimalsNumber)
        
        if !fractionalPart.isEmpty {
            let paddedFractional = fractionalPart.padding(
                toLength: nanoUnitDecimalsNumber, 
                withPad: "0", 
                startingAt: 0
            ).prefix(nanoUnitDecimalsNumber)
            
            guard let fractionalBigInt = BigInt(String(paddedFractional)) else { return nil }
            nanoUnits += fractionalBigInt
        }
        
        return TONBalance(nanoUnits: nanoUnits)
    }
}
