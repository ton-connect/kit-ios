//
//  TONWalletAppView.swift
//  TONWalletApp
//
//  Created by Nikita Rodionov on 06.10.2025.
//

import Foundation
import SwiftUI

struct TONWalletAppView: View {
    @StateObject var appStateManager = TONWalletAppStateManager()
    
    public var body: some View {
        Group {
            switch appStateManager.state {
            case .idle:
                Color.white
                    .onAppear { appStateManager.checkState() }
            case .locked:
                UnlockWalletView()
            case .unlocked:
                MainView()
            case .createPassword:
                CreatePasswordView()
            }
        }
        .environmentObject(appStateManager)
    }
}

@MainActor
class TONWalletAppStateManager: ObservableObject {
    private let passwordStorage = PasswordStorage()
    
    @Published fileprivate var state: TONWalletAppState = .idle
    
    fileprivate func checkState() {
        if passwordStorage.hasPassword() {
            state = .locked
        } else {
            state = .createPassword
        }
    }
    
    func lock() {
        state = .locked
    }
    
    func unlock() {
        state = .unlocked
    }
    
    func reset() {
        checkState()
    }
}

enum TONWalletAppState {
    case idle
    case createPassword
    case locked
    case unlocked
    
    private func checkSate() {
        
    }
}
