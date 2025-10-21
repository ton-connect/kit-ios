//
//  WebViewBridgeManager.swift
//  TONWalletApp
//
//  Created by AI Assistant on 21.10.2025.
//

import Foundation
import TONWalletKit

struct BridgeRequest: Codable {
    let messageId: String
    let payload: BridgePayload
}

struct BridgePayload: Codable {
    let method: String
    let params: [String: AnyCodable]?
    let traceId: String?
}

struct BridgeResponse: Codable {
    let type: String
    let source: String
    let messageId: String
    let success: Bool
    let payload: AnyCodable?
    let error: String?
    
    init(messageId: String, success: Bool, payload: AnyCodable? = nil, error: String? = nil) {
        self.type = "TONCONNECT_BRIDGE_RESPONSE"
        self.source = "ton-tonconnect"
        self.messageId = messageId
        self.success = success
        self.payload = payload
        self.error = error
    }
}

// Helper to encode/decode Any values
struct AnyCodable: Codable {
    let value: Any
    
    init(_ value: Any) {
        self.value = value
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        
        if let string = try? container.decode(String.self) {
            value = string
        } else if let int = try? container.decode(Int.self) {
            value = int
        } else if let double = try? container.decode(Double.self) {
            value = double
        } else if let bool = try? container.decode(Bool.self) {
            value = bool
        } else if let array = try? container.decode([AnyCodable].self) {
            value = array.map { $0.value }
        } else if let dict = try? container.decode([String: AnyCodable].self) {
            value = dict.mapValues { $0.value }
        } else if container.decodeNil() {
            value = NSNull()
        } else {
            throw DecodingError.dataCorruptedError(in: container, debugDescription: "Cannot decode value")
        }
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()
        
        switch value {
        case let string as String:
            try container.encode(string)
        case let int as Int:
            try container.encode(int)
        case let double as Double:
            try container.encode(double)
        case let bool as Bool:
            try container.encode(bool)
        case let array as [Any]:
            try container.encode(array.map { AnyCodable($0) })
        case let dict as [String: Any]:
            try container.encode(dict.mapValues { AnyCodable($0) })
        case is NSNull:
            try container.encodeNil()
        default:
            let context = EncodingError.Context(codingPath: container.codingPath, debugDescription: "Cannot encode value")
            throw EncodingError.invalidValue(value, context)
        }
    }
}

@MainActor
class WebViewBridgeManager {
    private let walletKit: TONWalletKit
    
    init(walletKit: TONWalletKit) {
        self.walletKit = walletKit
    }
    
    func processMessage(_ messageBody: Any) async -> String {
        do {
            // Convert message body to JSON data
            let jsonData = try JSONSerialization.data(withJSONObject: messageBody, options: [])
            
            // Decode the bridge request
            let request = try JSONDecoder().decode(BridgeRequest.self, from: jsonData)
            
            debugPrint("Processing bridge request: \(request.payload.method)")
            
            // Process the request based on method
            let result = try await processRequest(request)
            
            // Create success response
            let response = BridgeResponse(
                messageId: request.messageId,
                success: true,
                payload: result
            )
            
            return try encodeResponse(response)
            
        } catch {
            debugPrint("Error processing bridge request: \(error)")
            
            // Try to extract messageId if possible
            var messageId = "unknown"
            if let dict = messageBody as? [String: Any],
               let id = dict["messageId"] as? String {
                messageId = id
            }
            
            let response = BridgeResponse(
                messageId: messageId,
                success: false,
                error: error.localizedDescription
            )
            
            do {
                return try encodeResponse(response)
            } catch {
                return "{\"type\":\"TONCONNECT_BRIDGE_RESPONSE\",\"success\":false,\"error\":\"Failed to encode response\"}"
            }
        }
    }
    
    private func processRequest(_ request: BridgeRequest) async throws -> AnyCodable? {
        // Convert AnyCodable params to [String: Any]
        let params = request.payload.params?.mapValues { $0.value } as? [String: Any]
        
        debugPrint("📱 WebViewBridgeManager processing method: \(request.payload.method)")
        debugPrint("📱 Params:", params ?? [:])
        
        // Forward the request to TONWalletKit which will call the JS instance
        let result = try await walletKit.handleBridgeMessage(
            method: request.payload.method,
            params: params
        )
        
        debugPrint("📱 Result from TONWalletKit:", result ?? "nil")
        
        // Convert result back to AnyCodable if present
        if let result = result {
            return AnyCodable(result)
        }
        
        return nil
    }
    
    
    private func encodeResponse(_ response: BridgeResponse) throws -> String {
        let encoder = JSONEncoder()
        let data = try encoder.encode(response)
        guard let jsonString = String(data: data, encoding: .utf8) else {
            throw NSError(domain: "WebViewBridge", code: -1, userInfo: [NSLocalizedDescriptionKey: "Failed to convert response to string"])
        }
        return jsonString
    }
}

