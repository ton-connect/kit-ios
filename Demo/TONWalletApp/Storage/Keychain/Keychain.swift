//
//  Keychain.swift
//  TONWalletApp
//
//  Created by Nikita Rodionov on 06.10.2025.
//

import Foundation

public final class Keychain<Value: Codable> {
    private let key: String

    public init(key: String) {
        self.key = key
    }

    public func save(_ value: Value) throws(KeychainError) {
        let encoder = JSONEncoder()

        do {
            let data = try encoder.encode(value)
            guard storeData(data, forKey: key) else {
                throw KeychainError.storeFailed
            }
        } catch {
            throw KeychainError.storeFailed
        }
    }

    public func load() throws(KeychainError) -> Value? {
        guard let data = loadData(forKey: key) else {
            return nil
        }
        let decoder = JSONDecoder()
        do {
            return try decoder.decode(Value.self, from: data)
        } catch {
            throw KeychainError.loadFailed
        }
    }

    public func clear() throws(KeychainError) {
        guard removeData(forKey: key) else {
            throw KeychainError.removeFailed
        }
    }
    
    func storeData(_ data: Data, forKey key: String) -> Bool {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrAccount as String: key,
            kSecValueData as String: data,
            kSecAttrAccessible as String: kSecAttrAccessibleAfterFirstUnlockThisDeviceOnly
        ]
        SecItemDelete(query as CFDictionary)
        let status = SecItemAdd(query as CFDictionary, nil)
        return status == errSecSuccess
    }

    func loadData(forKey key: String) -> Data? {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrAccount as String: key,
            kSecReturnData as String: true,
            kSecMatchLimit as String: kSecMatchLimitOne
        ]
        var dataTypeRef: AnyObject?
        let status = SecItemCopyMatching(query as CFDictionary, &dataTypeRef)
        guard status == errSecSuccess else { return nil }
        return dataTypeRef as? Data
    }

    func removeData(forKey key: String) -> Bool {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrAccount as String: key
        ]
        let status = SecItemDelete(query as CFDictionary)
        return status == errSecSuccess
    }
}

public enum KeychainError: Error {
    case storeFailed
    case loadFailed
    case removeFailed
}

