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
    let network: TONNetwork
    let deviceInfo: DeviceInfo
    let walletManifest: Manifest
    let bridge: Bridge
    let apiClient: APIClient?
    
    public init(
        network: TONNetwork,
        walletManifest: Manifest,
        bridge: Bridge,
        apiClient: APIClient? = nil,
        features: [any Feature],
    ) {
        self.network = network
        
        let rawFeatures = features.compactMap(\.raw)
        
        self.deviceInfo = DeviceInfo(
            appName: walletManifest.appName,
            features: rawFeatures
        )
        
        var manifest = walletManifest
        manifest.features = rawFeatures
        
        self.walletManifest = manifest
        self.bridge = bridge
        self.apiClient = apiClient
    }
    
    public func hash(into hasher: inout Hasher) {
        hasher.combine(network)
        hasher.combine(deviceInfo)
        hasher.combine(walletManifest)
        hasher.combine(bridge)
        hasher.combine(apiClient)
    }
    
    enum CodingKeys: CodingKey {
        case network
        case deviceInfo
        case walletManifest
        case bridge
        case apiClient
    }
}

extension TONWalletKitConfiguration {
    
    struct DeviceInfo: Codable, Hashable {
        let platform: String
        let appName: String
        let appVersion: String
        
        // Currently just a constant
        let maxProtocolVersion: Int = 2
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
        let platforms = ["ios"]
        
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
        
        let heartbeatInterval: TimeInterval?
        let reconnectInterval: TimeInterval?
        let maxReconnectAttempts: Int?
        
        public init(
            bridgeUrl: String,
            heartbeatInterval: TimeInterval? = nil,
            reconnectInterval: TimeInterval? = nil,
            maxReconnectAttempts: Int? = nil
        ) {
            self.bridgeUrl = bridgeUrl
            self.heartbeatInterval = heartbeatInterval
            self.reconnectInterval = reconnectInterval
            self.maxReconnectAttempts = maxReconnectAttempts
        }
    }
    
    public struct APIClient: Encodable, Hashable {
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
