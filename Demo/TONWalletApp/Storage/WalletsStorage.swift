//
//  WalletsStorage.swift
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

class WalletsStorage {
    private var keychain = Keychain<[WalletEntity]>(key: "com.walletkit.demoapp.keychain.wallets")
    
    public func wallets() throws -> [WalletEntity] {
        let wallets = try keychain.load()
        return wallets ?? []
    }
    
    public func add(wallet: WalletEntity) throws {
        var wallets = try self.wallets()
        wallets.append(wallet)
        try keychain.save(wallets)
    }
    
    func remove(walletAddress: String?) throws {
        var wallets = try self.wallets()
        wallets.removeAll { $0.address == walletAddress }
        try keychain.save(wallets)
    }
    
    public func removeAllWallets() throws {
        try keychain.clear()
    }
}
