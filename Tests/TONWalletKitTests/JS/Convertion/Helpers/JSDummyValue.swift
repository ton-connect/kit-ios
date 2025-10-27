//
//  JSDummyValue.swift
//  TONWalletKit
//
//  Created by Nikita Rodionov on 23.10.2025.
//

import Foundation
@testable import TONWalletKit

struct JSDummyValue: JSValueDecodable {
    
    static func from(_ value: JSValue) throws -> JSDummyValue? {
        return nil
    }
}
