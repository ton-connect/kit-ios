//
//  WalletConnectionRequestViewModel.swift
//  TONWalletApp
//
//  Created by Nikita Rodionov on 03.10.2025.
//

import Foundation
import Combine
import TONWalletKit

@MainActor
class WalletConnectionRequestViewModel: ObservableObject {
    private let wallet: TONWalletProtocol
    private let request: TONWalletConnectionRequest
    
    var dAppInfo: TONDAppInfo? { request.dAppInfo }
    var permissions: [TONConnectRequestEvent.Preview.ConnectPermission] { request.permissions }
    
    let dismiss = PassthroughSubject<Void, Never>()
    
    init(request: TONWalletConnectionRequest, wallet: TONWalletProtocol) {
        self.request = request
        self.wallet = wallet
    }
    
    func approve() {
        guard let address = wallet.address else {
            return
        }
        
        Task {
            do {
                try await request.approve(walletAddress: address)
                dismiss.send()
            } catch {
                debugPrint(error.localizedDescription)
            }
        }
    }
    
    func reject() {
        Task {
            do {
                try await request.reject()
                dismiss.send()
            } catch {
                debugPrint(error.localizedDescription)
            }
        }
    }
}
