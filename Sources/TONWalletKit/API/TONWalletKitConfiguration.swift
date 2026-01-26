//
//  TONWalletKitConfiguration.swift
//  TONWalletKit
//
//  Created by Nikita Rodionov on 07.10.2025.
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

#if os(iOS)
import UIKit
#endif

public struct TONWalletKitConfiguration: Encodable, Hashable {
    let networkConfigurations: [NetworkConfiguration]
    let deviceInfo: DeviceInfo
    let walletManifest: Manifest
    let storage: TONWalletKitStorageType
    let sessionManager: (any TONConnectSessionsManager)?
    let bridge: Bridge?
    let eventsConfiguration: EventsConfiguration?
    
    public init(
        networkConfigurations: Set<NetworkConfiguration>,
        walletManifest: Manifest,
        storage: TONWalletKitStorageType = .keychain,
        sessionManager: (any TONConnectSessionsManager)? = nil,
        bridge: Bridge?,
        eventsConfiguration: EventsConfiguration? = nil,
        features: [any Feature],
    ) {
        self.networkConfigurations = Array(networkConfigurations)
        
        let rawFeatures = features.compactMap(\.raw)
        
        self.deviceInfo = DeviceInfo(
            appName: walletManifest.appName,
            features: rawFeatures
        )
        
        var manifest = walletManifest
        manifest.features = rawFeatures
        
        self.walletManifest = manifest
        self.storage = storage
        self.sessionManager = sessionManager
        self.bridge = bridge
        self.eventsConfiguration = eventsConfiguration
    }
    
    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(
            networkConfigurations.filter {
                $0.apiClientConfiguration != nil
            },
            forKey: .networkConfigurations)
        try container.encode(deviceInfo, forKey: .deviceInfo)
        try container.encode(walletManifest, forKey: .walletManifest)
        try container.encodeIfPresent(bridge, forKey: .bridge)
        try container.encodeIfPresent(eventsConfiguration, forKey: .eventsConfiguration)
    }
    
    public func hash(into hasher: inout Hasher) {
        hasher.combine(networkConfigurations)
        hasher.combine(deviceInfo)
        hasher.combine(walletManifest)
        hasher.combine(bridge)
        hasher.combine(eventsConfiguration)
    }
    
    public static func == (lhs: TONWalletKitConfiguration, rhs: TONWalletKitConfiguration) -> Bool {
        return lhs.hashValue == rhs.hashValue
    }
    
    
    enum CodingKeys: CodingKey {
        case networkConfigurations
        case deviceInfo
        case walletManifest
        case bridge
        case eventsConfiguration
    }
    
}

extension TONWalletKitConfiguration {
    
    public struct EventsConfiguration: Encodable, Hashable {
        let disableEvents: Bool
        let disableTransactionEmulation: Bool
        
        public init(disableEvents: Bool = false, disableTransactionEmulation: Bool = false) {
            self.disableEvents = disableEvents
            self.disableTransactionEmulation = disableTransactionEmulation
        }
    }
    
    public struct NetworkConfiguration: Encodable, Hashable {
        let network: TONNetwork
        let apiClientConfiguration: APIClientConfiguration?
        let apiClient: TONAPIClient?
        
        public init(network: TONNetwork, apiClientConfiguration: APIClientConfiguration) {
            self.network = network
            self.apiClientConfiguration = apiClientConfiguration
            self.apiClient = nil
        }
        
        public init(network: TONNetwork, apiClient: TONAPIClient) {
            self.network = network
            self.apiClient = apiClient
            self.apiClientConfiguration = nil
        }
        
        public func hash(into hasher: inout Hasher) {
            hasher.combine(network)
        }
        
        public static func == (lhs: NetworkConfiguration, rhs: NetworkConfiguration) -> Bool {
            return lhs.network == rhs.network
        }
        
        enum CodingKeys: CodingKey {
            case network
            case apiClientConfiguration
        }
    }
    
    struct DeviceInfo: Codable, Hashable {
        let platform: String
        let appName: String
        let appVersion: String
        
        // Currently just a constant
        private var maxProtocolVersion: Int = 2
        let features: [RawFeature]
        
        init(appName: String, features: [RawFeature]) {
#if os(iOS)
            self.platform = UIDevice.current.userInterfaceIdiom == .pad ? "ipad" : "iphone"
#else
            self.platform = "unknown"
#endif
            self.appName = appName
            self.appVersion = Bundle.main.appVersion
            self.features = features
        }
    }
    
    public struct Manifest: Codable, Hashable {
        let name: String
        let appName: String
        let imageUrl: String
        let tondns: String?
        let aboutUrl: String
        private var platforms = ["ios"]
        
        let universalLink: String
        let deepLink: String?
        let bridgeUrl: String
        
        var features: [RawFeature] = []
        
        public init(
            name: String,
            appName: String,
            imageUrl: String,
            tondns: String? = nil,
            aboutUrl: String,
            universalLink: String,
            deepLink: String? = nil,
            bridgeUrl: String
        ) {
            self.name = name
            self.appName = appName
            self.imageUrl = imageUrl
            self.tondns = tondns
            self.aboutUrl = aboutUrl
            self.universalLink = universalLink
            self.deepLink = deepLink
            self.bridgeUrl = bridgeUrl
        }
    }
    
    public struct Bridge: Encodable, Hashable {
        let bridgeUrl: String
        let webViewInjectionKey: String?
        
        let heartbeatInterval: TimeInterval?
        let reconnectInterval: TimeInterval?
        let maxReconnectAttempts: Int?
        
        public init(
            bridgeUrl: String,
            webViewInjectionKey: String? = nil,
            heartbeatInterval: TimeInterval? = nil,
            reconnectInterval: TimeInterval? = nil,
            maxReconnectAttempts: Int? = nil
        ) {
            self.bridgeUrl = bridgeUrl
            self.heartbeatInterval = heartbeatInterval
            self.reconnectInterval = reconnectInterval
            self.maxReconnectAttempts = maxReconnectAttempts
            self.webViewInjectionKey = webViewInjectionKey
        }
    }
    
    public struct APIClientConfiguration: Encodable, Hashable {
        let url: URL?
        let key: String
        
        public init(
            url: URL? = nil,
            key: String
        ) {
            self.url = url
            self.key = key
        }
    }
    
    enum FeatureName: String, Codable {
        case sendTransaction = "SendTransaction"
        case signData = "SignData"
    }
    
    public struct RawFeature: Codable, Hashable {
        let name: FeatureName
        
        private(set) var types: [TONSignDataType]?
        
        private(set) var maxMessages: Int?
        private(set) var extraCurrencySupported: Bool?
    }
    
    public protocol Feature {
        var raw: RawFeature { get }
    }
    
    public struct SendTransactionFeature: Feature {
        let maxMessages: Int?
        let extraCurrencySupported: Bool?
        
        public var raw: RawFeature {
            RawFeature(
                name: .sendTransaction,
                maxMessages: maxMessages,
                extraCurrencySupported: extraCurrencySupported
            )
        }
        
        public init(
            maxMessages: Int? = nil,
            extraCurrencySupported: Bool? = nil
        ) {
            self.maxMessages = maxMessages
            self.extraCurrencySupported = extraCurrencySupported
        }
    }
    
    public struct SignDataFeature: Feature {
        let types: [TONSignDataType]
        
        public var raw: RawFeature {
            RawFeature(
                name: .signData,
                types: types
            )
        }
        
        public init(types: [TONSignDataType]) {
            self.types = types
        }
    }
}

private extension Bundle {
    
    var appName: String {
        return object(forInfoDictionaryKey: "CFBundleDisplayName") as? String ??
               object(forInfoDictionaryKey: "CFBundleName") as? String ??
               "Unknown App"
    }
    
    var appVersion: String {
        return object(forInfoDictionaryKey: "CFBundleShortVersionString") as? String ?? "1.0"
    }
}
