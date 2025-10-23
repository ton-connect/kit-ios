//
//  TONWalletKitKeychainStorage.swift
//  TONWalletKit
//
//  Created by Nikita Rodionov on 09.10.2025.
//

import Foundation
import Security

public class TONWalletKitKeychainStorage: TONWalletKitStorage {
    private let service = "com.tonwalletkit.keychain"

    public func save(key: String, value: String) throws {
        let data = value.data(using: .utf8)
        
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrAccount as String: key,
            kSecAttrService as String: service,
            kSecValueData as String: data as Any,
            kSecAttrAccessible as String: kSecAttrAccessibleAfterFirstUnlockThisDeviceOnly
        ]
        SecItemDelete(query as CFDictionary)
        
        let status = SecItemAdd(query as CFDictionary, nil)
        
        if status != errSecSuccess {
            throw KeychainError.saveFailed(status)
        }
    }
    
    public func get(key: String) throws -> String? {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: service,
            kSecAttrAccount as String: key,
            kSecReturnData as String: true,
            kSecMatchLimit as String: kSecMatchLimitOne
        ]
        
        var result: AnyObject?
        let status = SecItemCopyMatching(query as CFDictionary, &result)
        
        if status == errSecItemNotFound {
            return nil
        }
        
        guard status == errSecSuccess else {
            throw KeychainError.getFailed(status)
        }
        
        guard let data = result as? Data,
              let string = String(data: data, encoding: .utf8) else {
            throw KeychainError.invalidData
        }
        
        return string
    }
    
    public func remove(key: String) throws {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: service,
            kSecAttrAccount as String: key
        ]
        
        let status = SecItemDelete(query as CFDictionary)
        
        if status != errSecSuccess && status != errSecItemNotFound {
            throw KeychainError.deleteFailed(status)
        }
    }
    
    public func clear() throws {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: service
        ]
        
        let status = SecItemDelete(query as CFDictionary)
        
        if status != errSecSuccess && status != errSecItemNotFound {
            throw KeychainError.clearFailed(status)
        }
    }
}

private enum KeychainError: Error {
    case saveFailed(OSStatus)
    case getFailed(OSStatus)
    case deleteFailed(OSStatus)
    case clearFailed(OSStatus)
    case invalidData
    
    var localizedDescription: String {
        switch self {
        case .saveFailed(let status):
            return "Failed to save to keychain: \(status)"
        case .getFailed(let status):
            return "Failed to get from keychain: \(status)"
        case .deleteFailed(let status):
            return "Failed to delete from keychain: \(status)"
        case .clearFailed(let status):
            return "Failed to clear keychain: \(status)"
        case .invalidData:
            return "Invalid data retrieved from keychain"
        }
    }
}
