//
//  JSValue+Function.swift
//  TONWalletKit
//
//  Created by Nikita Rodionov on 27.10.2025.
//

import Foundation
import JavaScriptCore

extension JSValue {
    
    var isFunction: Bool {
        isInstance(of: context.objectForKeyedSubscript("Function"))
    }
}
