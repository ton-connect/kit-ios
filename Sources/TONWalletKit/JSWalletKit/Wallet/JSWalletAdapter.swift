//
//  JSWalletAdapter.swift
//  TONWalletKit
//
//  Created by Nikita Rodionov on 17.10.2025.
//

import Foundation
import JavaScriptCore

@objc public protocol JSWalletAdapter: JSExport {
    @objc(publicKey) var publicKey: JSValue { get }
    @objc(version) var version: JSValue { get }
    @objc(getNetwork) var network: JSValue { get }
    
    @objc(getAddress:) func address(options: JSValue) -> JSValue
    @objc(getStateInit) func stateInit() -> JSValue
    
    @objc(getSignedSendTransaction::) func signedSendTransaction(input: JSValue, options: JSValue) -> JSValue
    @objc(getSignedSignData::) func signedSignData(input: JSValue, options: JSValue) -> JSValue
    @objc(getSignedTonProof::) func signedTonProof(input: JSValue, options: JSValue) -> JSValue
}
