//
//  CreatePasswordViewModel.swift
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
class CreatePasswordViewModel: ObservableObject {
    @Published var password = ""
    @Published var confirmPassword = ""
    
    private let passwordStorage = PasswordStorage()
    
    var isPasswordValid: Bool {
        password.count >= 8 &&
        password.contains(where: { $0.isUppercase }) &&
        password.contains(where: { $0.isLowercase }) &&
        password.contains(where: { $0.isNumber })
    }
    
    var passwordsMatch: Bool {
        !confirmPassword.isEmpty && password == confirmPassword
    }
    
    var canContinue: Bool {
        isPasswordValid && passwordsMatch
    }
    
    func `continue`() async -> Bool {
        guard canContinue else {
            return false
        }
        
        do {
            try passwordStorage.set(password: password)
            await requestBiometry()
            return true
        } catch {
            debugPrint(error.localizedDescription)
            return false
        }
    }
    
    private func requestBiometry() async {
        let context = LAContext()
        var error: NSError?
        
        let canEvaluate = context.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: &error)
        
        if canEvaluate && context.biometryType != .none {
            do {
                try await context.evaluatePolicy(
                    .deviceOwnerAuthenticationWithBiometrics,
                    localizedReason: "This app uses Face ID to authenticate the user."
                )
            } catch {
                debugPrint(error.localizedDescription)
            }
        }
    }
}
