//
//  PasswordStorage.swift
//  TONWalletApp
//
//  Created by Nikita Rodionov on 06.10.2025.
//

import Foundation

class PasswordStorage {
    private var keychain = Keychain<String>(key: "com.walletkit.demoapp.keychain.password")
    
    public func hasPassword() -> Bool {
        let password = try? self.password()
        return password != nil
    }
    
    public func set(password: String) throws {
        try keychain.save(password)
    }
    
    public func password() throws -> String? {
        try keychain.load()
    }
    
    public func removePassword() throws {
        try keychain.clear()
    }
}
