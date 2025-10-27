//
//  JSValue+Promise.swift
//  TONWalletKit
//
//  Created by Nikita Rodionov on 24.10.2025.
//

import Foundation
import JavaScriptCore

extension JSValue {
    
    var isPromise: Bool {
        isInstance(of: context.objectForKeyedSubscript("Promise"))
    }
}
