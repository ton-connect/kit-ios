//
//  WalletSignDataRequestViewModel.swift
//  TONWalletApp
//
//  Created by GitHub Copilot on 10.10.2025.
//

import Foundation
import Combine
import TONWalletKit

@MainActor
class WalletSignDataRequestViewModel: ObservableObject {
    private let request: TONWalletSignDataRequest
    
    var dAppInfo: TONDAppInfo? { request.dAppInfo }
    var walletAddress: String? { request.walletAddress }
    
    let dismiss = PassthroughSubject<Void, Never>()
    
    init(request: TONWalletSignDataRequest) {
        self.request = request
    }
    
    func approve() {
        Task {
            do {
                _ = try await request.approve()
                dismiss.send()
            } catch {
                debugPrint("Error approving sign data request: \(error.localizedDescription)")
            }
        }
    }
    
    func reject() {
        Task {
            do {
                try await request.reject(reason: "User rejected sign data request")
                dismiss.send()
            } catch {
                debugPrint("Error rejecting sign data request: \(error.localizedDescription)")
            }
        }
    }
}
