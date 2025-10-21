//
//  WalletConnectionRequestViewModel.swift
//  TONWalletApp
//
//  Created by Nikita Rodionov on 03.10.2025.
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
import Combine
import TONWalletKit

@MainActor
class WalletConnectionRequestViewModel: ObservableObject {
    @Published var selectedWallet: SelectableWallet?
    
    let wallets: [SelectableWallet]
    private let request: TONWalletConnectionRequest
    
    var dAppInfo: TONDAppInfo? { request.dAppInfo }
    var permissions: [TONConnectRequestEvent.Preview.ConnectPermission] { request.permissions }
    
    let dismiss = PassthroughSubject<Void, Never>()
    
    init(request: TONWalletConnectionRequest, walletsAddresses: [String]) {
        self.request = request
        self.wallets = walletsAddresses.map { SelectableWallet(address: $0) }
        
        self.selectedWallet = wallets.first
    }

    func approve() {
        guard let selectedWallet else {
            return
        }
        
        let address = selectedWallet.address
        
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

extension WalletConnectionRequestViewModel {
    
    struct SelectableWallet: Identifiable {
        let id = UUID()
        let address: String
        
        init(address: String) {
            self.address = address
        }
    }
}
