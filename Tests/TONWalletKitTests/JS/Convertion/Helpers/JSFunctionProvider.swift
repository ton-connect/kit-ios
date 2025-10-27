//
//  JSFunctionProvider.swift
//  TONWalletKit
//
//  Created by Nikita Rodionov on 23.10.2025.
//

import Testing
@testable import TONWalletKit

protocol JSFunctionProvider {
    static var jsFunctionName: String { get }
}

extension JSFunctionProvider {
    static var jsFunctionName: String {
        return String(describing: Self.self).split(separator: ".").last.map(String.init) ?? ""
    }
}

extension String: JSFunctionProvider {}
extension Int: JSFunctionProvider {}
extension Int64: JSFunctionProvider {}
extension Int32: JSFunctionProvider {}
extension UInt: JSFunctionProvider {}
extension UInt64: JSFunctionProvider {}
extension UInt32: JSFunctionProvider {}
extension Double: JSFunctionProvider {}
extension Float: JSFunctionProvider {}
extension Bool: JSFunctionProvider {}

extension Date: JSFunctionProvider {
    static var jsFunctionName: String { "DateValue" }
}

extension Array: JSFunctionProvider {
    static var jsFunctionName: String { "Array" }
}

extension Dictionary: JSFunctionProvider {
    static var jsFunctionName: String { "Dictionary" }
}
