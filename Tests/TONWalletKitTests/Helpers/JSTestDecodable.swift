//
//  JSTestDecodable.swift
//  TONWalletKit
//
//  Created by Nikita Rodionov on 23.10.2025.
//

import Testing
@testable import TONWalletKit

struct JSTestDecodable: JSValueDecodable, JSValueEncodable, JSFunctionProvider, Codable {
    var test: String
}

extension JSTestDecodable: Equatable {
    static func == (lhs: JSTestDecodable, rhs: JSTestDecodable) -> Bool {
        lhs.test == rhs.test
    }
}
