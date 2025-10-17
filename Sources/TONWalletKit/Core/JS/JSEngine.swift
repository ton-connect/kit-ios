//
//  JSEngine.swift
//  TONWalletKit
//
//  Created by Nikita Rodionov on 11.09.2025.
//

import Foundation
import JavaScriptCore

public protocol JSEngine: JSDynamicObject, AnyObject {
    func loadJS() async throws
    func processJS() async throws
}

public extension JSEngine {
    
    func start() async throws {
        try await loadJS()
        try await processJS()
    }
}
