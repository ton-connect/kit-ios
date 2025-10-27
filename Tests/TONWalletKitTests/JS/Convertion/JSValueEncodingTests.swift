//
//  JSValueEncodingTests.swift
//  TONWalletKit
//
//  Created by Nikita Rodionov on 23.10.2025.
//

import Testing
import JavaScriptCore
@testable import TONWalletKit

@Suite("Navive Types To JSValue Conversion Tests")
struct JSValueEncodingTests {
    
    @Test("Check correctness of converted types")
    func testNativeTypesToJSValueConversion() throws {
        let context = JSTestConversionContext()
        
        try checkBoolResult(functionName: "_isString", with: [String()], in: context)
        
        let isNumber = "_isNumber"
        
        try checkBoolResult(functionName: isNumber, with: [Int()], in: context)
        try checkBoolResult(functionName: isNumber, with: [Int32()], in: context)
        try checkBoolResult(functionName: isNumber, with: [Int64()], in: context)
        try checkBoolResult(functionName: isNumber, with: [UInt()], in: context)
        try checkBoolResult(functionName: isNumber, with: [UInt32()], in: context)
        try checkBoolResult(functionName: isNumber, with: [UInt64()], in: context)
        try checkBoolResult(functionName: isNumber, with: [Float()], in: context)
        try checkBoolResult(functionName: isNumber, with: [Double()], in: context)
        
        try checkBoolResult(functionName: "_isBoolean", with: [true], in: context)
        
        try checkBoolResult(functionName: "_isDate", with: [Date()], in: context)
        
        try checkBoolResult(functionName: "_isNull", with: [NSNull()], in: context)
        
        try checkBoolResult(functionName: "_validateJSTestDecodable", with: [JSTestDecodable(test: "testValue")], in: context)
        
        try checkBoolResult(functionName: "_isArray", with: [[1, 2, 3]], in: context)
        
        try checkBoolResult(
            functionName: "_validateMultipleParameters",
            with: [
                "testString",
                42,
                true
            ],
            in: context
        )
    }
    
    private func checkBoolResult(
        functionName: String,
        with arguments: [any JSValueEncodable],
        in context: JSContext
    ) throws {
        #expect(try context[dynamicMember: functionName].dynamicallyCall(withArguments: arguments) == true)
    }
}
