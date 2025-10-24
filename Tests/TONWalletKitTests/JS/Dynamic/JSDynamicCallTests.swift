//
//  JSDynamicCallTests.swift
//  TONWalletKit
//
//  Created by Nikita Rodionov on 24.10.2025.
//

import Testing
import JavaScriptCore
@testable import TONWalletKit

@Suite("JSContext function calls wrappers tests")
struct JSDynamicCallTests {
    
    @Test("Check Promise Wrapper")
    func testFunctionsCorrectlyWrappedToPromise() async throws {
        let context = JSContext()!
        
        let script = """
        
        function _testPromiseFunctionSuccess(value) {
            return new Promise((resolve, reject) => {
                resolve(value);
            });
        }
        
        function _testPromiseFunctionFailure(errorMessage) {
            return new Promise((resolve, reject) => {
                reject(new Error(errorMessage));
            });
        }
        
        function _testPromiseFunctionNativeSuccess(value) {
            return value;
        }
        
        function _testPromiseFunctionNativeFailure(errorMessage) {
            throw new Error(errorMessage);
        }
        
        """
        
        context.evaluateScript(script)
        
        let testPromiseFunctionSuccess = JSFunction(
            parent: context,
            value: context.objectForKeyedSubscript("_testPromiseFunctionSuccess")
        )
        let testPromiseFunctionFailure = JSFunction(
            parent: context,
            value: context.objectForKeyedSubscript("_testPromiseFunctionFailure")
        )
        let testPromiseFunctionNativeSuccess = JSFunction(
            parent: context,
            value: context.objectForKeyedSubscript("_testPromiseFunctionNativeSuccess")
        )
        let testPromiseFunctionNativeFailure = JSFunction(
            parent: context,
            value: context.objectForKeyedSubscript("_testPromiseFunctionNativeFailure")
        )
        
        let testPromiseFunctionSuccessResult = try context.promise(wrap: testPromiseFunctionSuccess, args: ["success"])
        let testPromiseFunctionFailureResult = try context.promise(wrap: testPromiseFunctionFailure, args: ["failure"])
        let testPromiseFunctionNativeSuccessResult = try context.promise(wrap: testPromiseFunctionNativeSuccess, args: ["native success"])
        let testPromiseFunctionNativeFailureResult = try context.promise(wrap: testPromiseFunctionNativeFailure, args: ["native failure"])
    
        #expect(testPromiseFunctionSuccessResult.isPromise == true)
        #expect(testPromiseFunctionFailureResult.isPromise == true)
        #expect(testPromiseFunctionNativeSuccessResult.isPromise == true)
        #expect(testPromiseFunctionNativeFailureResult.isPromise == true)
        
        let resolvedSuccess = try await testPromiseFunctionSuccessResult.then().toString()
        #expect(resolvedSuccess == "success")
        #expect(try await testPromiseFunctionSuccessResult.then().toString() == "success")
        await #expect(throws: JSError.self) {
            try await testPromiseFunctionFailureResult.then()
        }
        #expect(try await testPromiseFunctionNativeSuccessResult.then().toString() == "native success")
        await #expect(throws: JSError.self) {
            try await testPromiseFunctionNativeFailureResult.then()
        }
    }
    
    @Test("Check Error Throw Wrapper")
    func testFunctionsCorrectlyWrappedErrorThrow() async throws {
        
    }
}
