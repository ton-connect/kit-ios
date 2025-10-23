//
//  JSTestDecodable.swift
//  TONWalletKit
//
//  Created by Nikita Rodionov on 23.10.2025.
//

import Testing
@testable import TONWalletKit

struct JSTestDecodable: JSValueDecodable, JSFunctionProvider, Decodable {
    var test: String
}
