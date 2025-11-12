//
//  TONWalletAdapterJSAdapter.swift
//  TONWalletKit
//
//  Created by Nikita Rodionov on 17.10.2025.
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
import JavaScriptCore

class TONWalletAdapterJSAdapter: NSObject, JSWalletAdapter {
    private weak var context: JSContext?
    private let wallet: any TONWalletAdapterProtocol
    
    init(context: JSContext, wallet: any TONWalletAdapterProtocol) {
        self.context = context
        self.wallet = wallet
    }
    
    @objc(publicKey) var publicKey: JSValue { JSValue(object: wallet.publicKey.value, in: context) }
    @objc(version) var version: JSValue { JSValue(object: wallet.version.rawValue, in: context) }
    @objc(getNetwork) var network: JSValue { JSValue(object: wallet.network.rawValue, in: context) }
    
    @objc(getAddress:) func address(options: JSValue) -> JSValue {
        let options: TONGetAddressOptions? = try? options.decode()
        
        do {
            let address = try wallet.address(testnet: options?.testnet == true)
            return JSValue(object: address, in: context)
        } catch {
            return JSValue(undefinedIn: context)
        }
    }
    
    @objc(getStateInit) func stateInit() -> JSValue {
        JSValue(newPromiseIn: context) { [weak self] resolve, reject in
            Task {
                guard let self else { return }
                
                do {
                    let value = try await self.wallet.stateInit().value
                    
                    resolve?.call(withArguments: [value])
                } catch {
                    reject?.call(withArguments: [error.localizedDescription])
                }
            }
        }
    }
    
    @objc(getSignedSendTransaction::) func signedSendTransaction(input: JSValue, options: JSValue) -> JSValue {
        let options: TONSignedSendTransactionAllOptions? = try? options.decode()
        
        do {
            let input: TONConnectTransactionParamContent = try input.decode()
            
            return JSValue(newPromiseIn: context) { [weak self] resolve, reject in
                Task {
                    guard let self else { return }
                    
                    do {
                        let value = try await self.wallet.signedSendTransaction(
                            input: input,
                            fakeSignature: options?.fakeSignature
                        ).value
                        
                        resolve?.call(withArguments: [value])
                    } catch {
                        reject?.call(withArguments: [error.localizedDescription])
                    }
                }
            }
        } catch {
            return JSValue(newPromiseRejectedWithReason: error.localizedDescription, in: context)
        }
    }
    
    @objc(getSignedSignData::) func signedSignData(input: JSValue, options: JSValue) -> JSValue {
        let options: TONSignedSendTransactionAllOptions? = try? options.decode()
        
        do {
            let input: TONPrepareSignDataResult = try input.decode()
            
            return JSValue(newPromiseIn: context) { [weak self] resolve, reject in
                Task {
                    guard let self else { return }
                    
                    do {
                        let value = try await self.wallet.signedSignData(
                            input: input,
                            fakeSignature: options?.fakeSignature
                        ).value
                        
                        resolve?.call(withArguments: [value])
                    } catch {
                        reject?.call(withArguments: [error.localizedDescription])
                    }
                }
            }
        } catch {
            return JSValue(newPromiseRejectedWithReason: error.localizedDescription, in: context)
        }
    }
    
    @objc(getSignedTonProof::) func signedTonProof(input: JSValue, options: JSValue) -> JSValue {
        let options: TONSignedSendTransactionAllOptions? = try? options.decode()
        
        do {
            let input: TONProofParsedMessage = try input.decode()
            
            return JSValue(newPromiseIn: context) { [weak self] resolve, reject in
                Task {
                    guard let self else { return }
                    
                    do {
                        let value = try await self.wallet.signedTonProof(
                            input: input,
                            fakeSignature: options?.fakeSignature
                        ).value
                        
                        resolve?.call(withArguments: [value])
                    } catch {
                        reject?.call(withArguments: [error.localizedDescription])
                    }
                }
            }
        } catch {
            return JSValue(newPromiseRejectedWithReason: error.localizedDescription, in: context)
        }
    }
}
