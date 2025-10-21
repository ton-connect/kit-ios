//
//  ConnectRequestEvent.swift
//  TONWalletKit
//
//  Created by Nikita Rodionov on 11.09.2025.
//

import Foundation

public struct TONConnectRequestEvent: Codable {
    private let id: String
    private let from: String
    
    public let preview: Preview?
    public let request: [Request]?
    public let dAppInfo: TONDAppInfo?
    
    public var walletAddress: String?
}

public extension TONConnectRequestEvent {
    
    public struct Preview: Codable {
        public let manifestURL: URL?
        public let manifest: Manifest?
        public let permissions: [ConnectPermission]
        
        public let requestedItems: [TONConnectRequestEvent.Request]
    }
}

public extension TONConnectRequestEvent.Preview {
    
    public struct Manifest: Codable {
        public let name: String?
        public let description: String?
        public let url: String?
        public let iconUrl: String?
    }
    
    public struct ConnectPermission: Codable {
        public let name: String?
        public let title: String?
        public let description: String?
    }
}

extension TONConnectRequestEvent {
    
    public struct Request: Codable {
        let name: String?
        let payload: String?
    }
}
