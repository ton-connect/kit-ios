//
//  JSWalletSigner.swift
//  TONWalletKit
//
//  Created by Nikita Rodionov on 16.10.2025.
//

import Foundation
import JavaScriptCore

@objc protocol JSWalletSigner {
    @objc(sign:) func sign(data: [UInt8]) -> JSValue
}
