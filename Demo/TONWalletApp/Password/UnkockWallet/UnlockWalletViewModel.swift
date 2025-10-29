//
//  UnlockWalletViewModel.swift
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
import LocalAuthentication

@MainActor
class UnlockWalletViewModel: ObservableObject {
    @Published var error: String?
    @Published var password: String = ""
    
    private let passwordStorage = PasswordStorage()
    private let walletsStorage = WalletsStorage()
    
    var canUnlock: Bool {
        !password.isEmpty
    }
    
    func checkPassword() -> Bool {
        do {
            let existingPassword = try passwordStorage.password()
            let isEqual = existingPassword == password
            
            if !isEqual {
                error = "Invalid password"
            }
            
            return isEqual
        } catch {
            debugPrint(error.localizedDescription)
            return false
        }
    }
    
    func reset() {
        try? passwordStorage.removePassword()
        try? walletsStorage.removeAllWallets()
    }
    
    func tryBiometryAuthentication() async -> Bool {
        let context = LAContext()
        var error: NSError?
        
        let canEvaluate = context.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: &error)
        
        if canEvaluate {
            do {
                let result = try await context.evaluatePolicy(
                    .deviceOwnerAuthenticationWithBiometrics,
                    localizedReason: "This app uses Face ID to authenticate the user."
                )
                
                if result {
                    fillPassword()
                }
                return result
            } catch {}
        }
        return false
    }
    
    private func fillPassword() {
        do {
            password = try passwordStorage.password() ?? ""
        } catch {
            debugPrint(error.localizedDescription)
        }
    }
}
