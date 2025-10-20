//
//  TONProofParsedMessage.swift
//  TONWalletKit
//
//  Created by Nikita Rodionov on 16.10.2025.
//

import Foundation

public struct TONProofDomain: Codable {
    public var lengthBytes: Int
    public var value: String
    
    public init(
        lengthBytes: Int,
        value: String
    ) {
        self.lengthBytes = lengthBytes
        self.value = value
    }
}

public struct TONProofParsedMessage: Codable {
    public var workchain: Int?
    public var address: Data?
    public var timstamp: Int64?
    public var domain: TONProofDomain?
    public var payload: String?
    public var stateInit: String?
    public var signature: Data?
    
    public init(
        workchain: Int? = nil,
        address: Data? = nil,
        timstamp: Int64? = nil,
        domain: TONProofDomain? = nil,
        payload: String? = nil,
        stateInit: String? = nil,
        signature: Data? = nil
    ) {
        self.workchain = workchain
        self.address = address
        self.timstamp = timstamp
        self.domain = domain
        self.payload = payload
        self.stateInit = stateInit
        self.signature = signature
    }
}
