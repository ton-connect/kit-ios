//
//  TONTonProofParsedMessage.swift
//  TONWalletKit
//
//  Created by Nikita Rodionov on 16.10.2025.
//

import Foundation

public struct TONTonProofDomain: Codable {
    public var lengthBytes: Int
    public var value: String
}

public struct TONTonProofParsedMessage: Codable {
    public var workchain: Int?
    public var address: Data?
    public var timstamp: Int64?
    public var domain: TONTonProofDomain?
    public var payload: String?
    public var stateInit: String?
    public var signature: Data?
}
