//
//  JSValueDecodingTests+Helpers.swift
//  TONWalletKit
//
//  Created by Nikita Rodionov on 23.10.2025.
//

import Foundation
import Testing
import JavaScriptCore
@testable import TONWalletKit

extension JSValueDecodingTests {
    
    func testValueThrowingConversion<T, U>(
        _ type: T.Type,
        againstType: U.Type,
        context: JSContext
    ) throws where T: JSValueDecodable & JSFunctionProvider, U: JSValueDecodable {
        #expect(throws: Error.self, "Testing convertion to value recieved from \(T.self) function to \(U.self) throws error") {
            let _: U = try context.objectForKeyedSubscript(T.jsFunctionName).call(withArguments: []).decode()
        }
        
        #expect(throws: Error.self, "Testing convertion to optional value recieved from \(T.self) function to \(U.self) throws error") {
            let _: U? = try context.objectForKeyedSubscript(T.jsFunctionName).call(withArguments: []).decode()
        }
    }
    
    func testValueThrowingConversion<T, U>(
        _ type: T.Type,
        againstType: U.Type,
        context: JSContext
    ) throws where T: JSValueDecodable & JSFunctionProvider, U: JSValueDecodable & JSFunctionProvider {
        #expect(throws: Error.self, "Testing conversion of \(T.self) from JSValue recieved from \(U.self) function throws error") {
            let _: T = try context.objectForKeyedSubscript(againstType.jsFunctionName).call(withArguments: []).decode()
        }
        
        #expect(throws: Error.self, "Testing conversion of optional \(T.self) from JSValue recieved from \(U.self) function throws error") {
            let _: T? = try context.objectForKeyedSubscript(againstType.jsFunctionName).call(withArguments: []).decode()
        }
    }
    
    func testValueThrowingConversion<T>(
        _ type: T.Type,
        functionName: String,
        context: JSContext
    ) throws where T: JSValueDecodable & JSFunctionProvider {
        #expect(throws: Error.self, "Testing conversion of \(T.self) from JSValue recieved from \(functionName) function throws error") {
            let _: T = try context.objectForKeyedSubscript(functionName).call(withArguments: []).decode()
        }
        
        #expect(throws: Error.self, "Testing conversion of optional \(T.self) from JSValue recieved from \(functionName) function throws error") {
            let _: T? = try context.objectForKeyedSubscript(functionName).call(withArguments: []).decode()
        }
    }
    
    func testValueConversion<T, U>(
        _ type: T.Type,
        againstType: U.Type,
        context: JSContext,
        equalTo expected: T
    ) throws where T: JSValueDecodable & JSFunctionProvider & Equatable, U: JSValueDecodable & JSFunctionProvider {
        try testValueConversion(type, againstType: againstType, context: context, equality: {  $0 == expected })
    }
    
    func testValueConversion<T, U>(
        _ type: T.Type,
        againstType: U.Type,
        context: JSContext,
        equality: (T?) -> Bool
    ) throws where T: JSValueDecodable & JSFunctionProvider, U: JSValueDecodable & JSFunctionProvider {
        let value: T = try context.objectForKeyedSubscript(againstType.jsFunctionName).call(withArguments: []).decode()
        let optionalValue: T? = try context.objectForKeyedSubscript(againstType.jsFunctionName).call(withArguments: []).decode()
        
        #expect(equality(value), "Testing conversion of \(T.self) from JSValue recieved from \(U.self) function resulted with expected \(value)")
        #expect(equality(optionalValue), "Testing conversion of optional \(T.self) from JSValue recieved from \(U.self) function resulted with expected \(optionalValue)")
    }
    
    func testValueConversion<T>(
        _ type: T.Type,
        context: JSContext,
        equalTo expected: T
    ) throws where T: JSValueDecodable & JSFunctionProvider & Equatable {
        try testValueConversion(type, context: context, equality: {  $0 == expected })
    }
    
    func testValueConversion<T>(
        _ type: T.Type,
        context: JSContext,
        equality: (T?) -> Bool
    ) throws where T: JSValueDecodable & JSFunctionProvider {
        let value: T = try context.objectForKeyedSubscript(T.jsFunctionName).call(withArguments: []).decode()
        let optionalValue: T? = try context.objectForKeyedSubscript(T.jsFunctionName).call(withArguments: []).decode()
        
        #expect(equality(value), "Testing conversion of \(T.self) from JSValue resulted with expected \(value)")
        #expect(equality(optionalValue), "Testing conversion of optional \(T.self) from JSValue resulted with expected \(value)")
    }
    
    func testUndefinedConversion<T>(_ type: T.Type, context: JSContext) throws where T: JSValueDecodable {
        #expect(throws: JSValueConversionError.self, "Testing conversion of \(T.self) from undefined JSValue") {
            let _: T = try context.objectForKeyedSubscript("undefinedValue").call(withArguments: []).decode()
        }
        
        let optionalValue: T? = try context.objectForKeyedSubscript("undefinedValue").call(withArguments: []).decode()
        #expect(optionalValue == nil, "Testing conversion of optional \(T.self) from undefined JSValue resulted with nil value")
    }
    
    func testNullConversion<T>(_ type: T.Type, context: JSContext) throws where T: JSValueDecodable {
        #expect(throws: JSValueConversionError.self, "Testing conversion of \(T.self) from null JSValue") {
            let _: T = try context.objectForKeyedSubscript("nullValue").call(withArguments: []).decode()
        }
        
        let optionalValue: T? = try context.objectForKeyedSubscript("nullValue").call(withArguments: []).decode()
        #expect(optionalValue == nil, "Testing conversion of optional \(T.self) from null JSValue resulted with nil value")
    }
    
    func testVoidConversion<T>(_ type: T.Type, context: JSContext) throws where T: JSValueDecodable {
        #expect(throws: JSValueConversionError.self, "Testing conversion of \(T.self) from void JSValue") {
            let _: T = try context.objectForKeyedSubscript("voidValue").call(withArguments: []).decode()
        }
        
        let optionalValue: T? = try context.objectForKeyedSubscript("voidValue").call(withArguments: []).decode()
        #expect(optionalValue == nil, "Testing conversion of optional \(T.self) from void JSValue resulted with nil value")
    }
}
