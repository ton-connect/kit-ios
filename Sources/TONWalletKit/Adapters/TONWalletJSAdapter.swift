//
//  TONWalletJSAdapter.swift
//  TONWalletKit
//
//  Created by Nikita Rodionov on 17.10.2025.
//

import Foundation
import JavaScriptCore

class TONWalletJSAdapter: JSWalletAdapter {
    private weak var context: JSContext?
    private let wallet: TONWalletAdapter
    
    init(context: JSContext, wallet: TONWalletAdapter) {
        self.context = context
        self.wallet = wallet
    }
    
    var publicKey: JSValue { JSValue(object: wallet.publicKey.hex, in: context) }
    var version: JSValue { JSValue(object: wallet.version.rawValue, in: context) }
    var network: JSValue { JSValue(object: wallet.network.rawValue, in: context) }
    
    func address(options: JSValue) -> JSValue {
        let options: GetAddressOptions? = try? options.decode()
        
        do {
            let address = try wallet.address(testnet: options?.testnet == true)
            return JSValue(object: address, in: context)
        } catch {
            return JSValue(undefinedIn: context)
        }
    }
    
    func stateInit() -> JSValue {
        JSValue(newPromiseIn: context) { [weak self] resolve, reject in
            Task {
                guard let self else { return }
                
                do {
                    let value = try await self.wallet.stateInit()
                    
                    await MainActor.run { _ = resolve?.call(withArguments: [value]) }
                } catch {
                    await MainActor.run { _ = reject?.call(withArguments: [error.localizedDescription]) }
                }
            }
        }
    }
    
    func signedSendTransaction(input: JSValue, options: JSValue) -> JSValue {
        let options: AllOptions? = try? options.decode()
        
        do {
            let input: TONConnectTransactionParamContent = try input.decode()
            
            return JSValue(newPromiseIn: context) { [weak self] resolve, reject in
                Task {
                    guard let self else { return }
                    
                    do {
                        let value = try await self.wallet.signedSendTransaction(
                            input: input,
                            fakeSignature: options?.fakeSignature == true
                        )
                        
                        await MainActor.run { _ = resolve?.call(withArguments: [value]) }
                    } catch {
                        await MainActor.run { _ = reject?.call(withArguments: [error.localizedDescription]) }
                    }
                }
            }
        } catch {
            return JSValue(newPromiseRejectedWithReason: error.localizedDescription, in: context)
        }
    }
    
    func signedSignData(input: JSValue, options: JSValue) -> JSValue {
        let options: AllOptions? = try? options.decode()
        
        do {
            let input: TONPrepareSignDataResult = try input.decode()
            
            return JSValue(newPromiseIn: context) { [weak self] resolve, reject in
                Task {
                    guard let self else { return }
                    
                    do {
                        let value = try await self.wallet.signedSignData(
                            input: input,
                            fakeSignature: options?.fakeSignature == true
                        )
                        
                        await MainActor.run { _ = resolve?.call(withArguments: [value]) }
                    } catch {
                        await MainActor.run { _ = reject?.call(withArguments: [error.localizedDescription]) }
                    }
                }
            }
        } catch {
            return JSValue(newPromiseRejectedWithReason: error.localizedDescription, in: context)
        }
    }
    
    func signedTonProof(input: JSValue, options: JSValue) -> JSValue {
        let options: AllOptions? = try? options.decode()
        
        do {
            let input: TONProofParsedMessage = try input.decode()
            
            return JSValue(newPromiseIn: context) { [weak self] resolve, reject in
                Task {
                    guard let self else { return }
                    
                    do {
                        let value = try await self.wallet.signedTonProof(
                            input: input,
                            fakeSignature: options?.fakeSignature == true
                        )
                        
                        await MainActor.run { _ = resolve?.call(withArguments: [value]) }
                    } catch {
                        await MainActor.run { _ = reject?.call(withArguments: [error.localizedDescription]) }
                    }
                }
            }
        } catch {
            return JSValue(newPromiseRejectedWithReason: error.localizedDescription, in: context)
        }
    }
}

private struct AllOptions: Decodable, JSValueDecodable {
    let fakeSignature: Bool
}

private struct GetAddressOptions: Decodable, JSValueDecodable {
    let testnet: Bool?
}
