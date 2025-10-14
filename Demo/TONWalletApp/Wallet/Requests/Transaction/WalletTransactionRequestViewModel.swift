//
//  WalletTransactionRequestViewModel.swift
//  TONWalletApp
//
//  Created by GitHub Copilot on 10.10.2025.
//

import Foundation
import Combine
import TONWalletKit

@MainActor
class WalletTransactionRequestViewModel: ObservableObject {
    private let request: TONWalletTransactionRequest
    
    var dAppInfo: DAppInfo? { request.dAppInfo }
    
    let dismiss = PassthroughSubject<Void, Never>()
    
    init(request: TONWalletTransactionRequest) {
        self.request = request
    }
    
    func approve() {
        Task {
            do {
                try await request.approve()
                dismiss.send()
            } catch {
                debugPrint("Error approving transaction: \(error.localizedDescription)")
            }
        }
    }
    
    func reject() {
        Task {
            do {
                try await request.reject(reason: "User rejected transaction")
                dismiss.send()
            } catch {
                debugPrint("Error rejecting transaction: \(error.localizedDescription)")
            }
        }
    }
}