//
//  TONSendMode.swift
//  TONWalletKit
//
//  Created by Nikita Rodionov on 13.10.2025.
//

import Foundation

public enum TONSendMode: Int {
    case carryAllRemainingBalance = 128
    case carryAllRemainingIncomingValue = 64
    case destroyAccountIfZero = 32
    case payGasSeparately = 1
    case ignoreErrors = 2
    case none = 0
}
