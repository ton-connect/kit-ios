//
//  TONStakingManager.swift
//  TONWalletKit
//
//  Created by Nikita Rodionov on 06.04.2026.
//
//  Copyright (c) 2026 TON Connect
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

public protocol TONStakingManagerProtocol {

    func quote<Identifier: TONStakingProviderIdentifier>(
        params: TONStakingQuoteParams<Identifier.QuoteOptions>,
        identifier: Identifier
    ) async throws -> TONStakingQuote

    func quote(params: TONStakingQuoteParams<AnyCodable>) async throws -> TONStakingQuote
    
    func stakeTransaction<Identifier: TONStakingProviderIdentifier>(
        params: TONStakeParams<Identifier.StakeOptions>,
        identifier: Identifier
    ) async throws -> TONTransactionRequest
    
    func stakeTransaction(params: TONStakeParams<AnyCodable>) async throws -> TONTransactionRequest

    func stakedBalance(
        userAddress: TONUserFriendlyAddress,
        network: TONNetwork?,
        identifier: (any TONStakingProviderIdentifier)?
    ) async throws -> TONStakingBalance

    func stakingProviderInfo(
        network: TONNetwork?,
        identifier: (any TONStakingProviderIdentifier)?
    ) async throws -> TONStakingProviderInfo

    func supportedUnstakeModes(
        identifier: (any TONStakingProviderIdentifier)?
    ) throws -> [TONUnstakeMode]
}

public extension TONStakingManagerProtocol {
    
    func stakedBalance(
        userAddress: TONUserFriendlyAddress,
        network: TONNetwork?,
    ) async throws -> TONStakingBalance {
        try await stakedBalance(
            userAddress: userAddress,
            network: network,
            identifier: nil
        )
    }

    func stakingProviderInfo<Identifier: TONStakingProviderIdentifier>(
        network: TONNetwork?,
        identifier: Identifier?
    ) async throws -> TONStakingProviderInfo {
        try await stakingProviderInfo(
            network: network,
            identifier: nil
        )
    }

    func supportedUnstakeModes<Identifier: TONStakingProviderIdentifier>(
        identifier: Identifier?
    ) throws -> [TONUnstakeMode] {
        try supportedUnstakeModes(identifier: nil)
    }
}

class TONStakingManager: TONStakingManagerProtocol {
    let jsObject: any JSDynamicObject

    required init(jsObject: any JSDynamicObject) {
        self.jsObject = jsObject
    }

    func register<Provider: TONStakingProviderProtocol>(provider: Provider) throws {
        try jsObject.registerProvider(TONEncodableStakingProvider(stakingProvider: provider))
    }

    func set<Identifier: TONStakingProviderIdentifier>(defaultProviderId: Identifier) throws {
        try jsObject.setDefaultProvider(defaultProviderId.name)
    }

    func provider<Identifier: TONStakingProviderIdentifier>(
        with id: Identifier
    ) throws -> TONStakingProvider<Identifier>? {
        let jsObject: JSValue = try self.jsObject.getProvider(id.name)
        return TONStakingProvider<Identifier>(jsObject: jsObject, identifier: id)
    }

    func registeredProviders() throws -> [AnyTONProviderIdentifier] {
        let names: [String] = try self.jsObject.getRegisteredProviders()
        return names.map { AnyTONProviderIdentifier(name: $0) }
    }

    func hasProvider<Identifier: TONStakingProviderIdentifier>(
        with id: Identifier
    ) throws -> Bool {
        try jsObject.hasProvider(id.name)
    }

    func quote<Identifier: TONStakingProviderIdentifier>(
        params: TONStakingQuoteParams<Identifier.QuoteOptions>,
        identifier: Identifier
    ) async throws -> TONStakingQuote {
        try await jsObject.getQuote(params, identifier.name)
    }
    
    func quote(params: TONStakingQuoteParams<AnyCodable>) async throws -> TONStakingQuote {
        try await jsObject.getQuote(params)
    }

    func stakeTransaction<Identifier: TONStakingProviderIdentifier>(
        params: TONStakeParams<Identifier.StakeOptions>,
        identifier: Identifier
    ) async throws -> TONTransactionRequest {
        try await jsObject.buildStakeTransaction(params, identifier.name)
    }
    
    func stakeTransaction(params: TONStakeParams<AnyCodable>) async throws -> TONTransactionRequest {
        try await jsObject.buildStakeTransaction(params)
    }
    
    func stakedBalance(
        userAddress: TONUserFriendlyAddress,
        network: TONNetwork?,
        identifier: (any TONStakingProviderIdentifier)?
    ) async throws -> TONStakingBalance {
        try await jsObject.getStakedBalance(userAddress, network, identifier?.name)
    }

    func stakingProviderInfo(
        network: TONNetwork?,
        identifier: (any TONStakingProviderIdentifier)?
    ) async throws -> TONStakingProviderInfo {
        try await jsObject.getStakingProviderInfo(network, identifier?.name)
    }

    func supportedUnstakeModes(
        identifier: (any TONStakingProviderIdentifier)?
    ) throws -> [TONUnstakeMode] {
        try jsObject.getSupportedUnstakeModes(identifier?.name)
    }
}

extension TONStakingManager: JSValueDecodable {

    static func from(_ value: JSValue) throws -> Self? {
        Self(jsObject: value)
    }
}
