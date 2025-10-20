//
//  TONWalletSignerAdapter.swift
//  TONWalletKit
//
//  Created by Nikita Rodionov on 16.10.2025.
//

import Foundation

class TONWalletSignerAdapter: NSObject, JSWalletSigner {
    private weak var context: JSContext?
    private let signer: TONWalletSigner
    
    init(
        context: JSContext,
        signer: TONWalletSigner
    ) {
        self.context = context
        self.signer = signer
    }
    
    @objc(sign:) func sign(data: [UInt8]) -> JSValue {
        let data = Data(data)
        
        do {
            let signedData = try signer.sign(data: data)
            let signedDataArray = [UInt8](signedData)
            
            return JSValue(newPromiseResolvedWithResult: signedDataArray, in: context)
        } catch {
            return JSValue(newPromiseRejectedWithReason: error.localizedDescription, in: context)
        }
    }
}
