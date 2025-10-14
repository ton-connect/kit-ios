//
//  TONWalletKitConfiguration.swift
//  TONWalletKit
//
//  Created by Nikita Rodionov on 07.10.2025.
//

import Foundation

#if os(iOS)
import UIKit
#endif

public struct TONWalletKitConfiguration: Encodable {
    let network: TONNetwork
    let deviceInfo: DeviceInfo
    let walletManifest: Manifest
    let bridge: Bridge
    let apiClient: APIClient?
    let storage: Storage
    
    public init(
        network: TONNetwork,
        walletManifest: Manifest,
        bridge: Bridge,
        apiClient: APIClient? = nil,
        features: [any Feature],
        storage: Storage
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
        self.storage = storage
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
    
    struct DeviceInfo: Encodable {
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
    
    public struct Manifest: Encodable {
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
    
    public struct Bridge: Encodable {
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
    
    public struct APIClient: Encodable {
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
    
    enum FeatureName: String, Encodable {
        case sendTransaction = "SendTransaction"
        case signData = "SignData"
    }
    
    public struct RawFeature: Encodable {
        let name: FeatureName
        
        private(set) var types: [SignDataType]?
        
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
        let types: [SignDataType]
        
        public var raw: RawFeature {
            RawFeature(
                name: .signData,
                types: types
            )
        }
        
        public init(types: [SignDataType]) {
            self.types = types
        }
    }
    
    public enum Storage {
        case memory
        case keychain
        case custom(TONWalletKitStorage)
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
