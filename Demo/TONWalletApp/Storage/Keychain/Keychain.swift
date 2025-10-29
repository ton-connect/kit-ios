//
//  Keychain.swift
//  TONWalletApp
//
//  Created by Nikita Rodionov on 06.10.2025.
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

