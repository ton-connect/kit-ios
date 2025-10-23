//
//  JSObject.swift
//  TONWalletKit
//
//  Created by Nikita Rodionov on 12.09.2025.
//

import Foundation
import JavaScriptCore

@dynamicMemberLookup
protocol JSDynamicObject {
    var jsContext: JSContext { get }
    
    subscript<T: JSValueDecodable>(dynamicMember member: String) -> T? { get }
    subscript(dynamicMember member: String) -> any JSDynamicObjectMember { get }
}

@dynamicCallable
protocol JSDynamicObjectMember: JSDynamicObject {
    
    @discardableResult
    func dynamicallyCall(withArguments args: [any JSValueEncodable]) async throws -> JSValue
    func dynamicallyCall<T>(withArguments args: [any JSValueEncodable]) async throws -> T where T: JSValueDecodable
    
    @discardableResult
    func dynamicallyCall(withArguments args: [any JSValueEncodable]) throws -> JSValue
    func dynamicallyCall<T>(withArguments args: [any JSValueEncodable]) throws -> T where T: JSValueDecodable
}

struct JSFunction: JSDynamicObjectMember {
    var jsContext: JSContext { parent.jsContext }
    
    let parent: any JSDynamicObject
    let value: any JSDynamicObject
    
    subscript<T: JSValueDecodable>(dynamicMember member: String) -> T? {
        value[dynamicMember: member]
    }
    
    subscript(dynamicMember member: String) -> any JSDynamicObjectMember {
        value[dynamicMember: member]
    }
    
    @discardableResult
    func dynamicallyCall(withArguments args: [any JSValueEncodable]) async throws -> JSValue {
        try await jsContext.promise(wrap: self, args: args.map { try $0.encode(in: jsContext) }).then()
    }
    
    func dynamicallyCall<T>(withArguments args: [any JSValueEncodable]) async throws -> T where T: JSValueDecodable {
        try await dynamicallyCall(withArguments: args).decode()
    }
    
    @discardableResult
    func dynamicallyCall(withArguments args: [any JSValueEncodable]) throws -> JSValue {
        try jsContext.throwErrorToReturn(wrap: self, args: args.map { try $0.encode(in: jsContext) })
    }
    
    func dynamicallyCall<T>(withArguments args: [any JSValueEncodable]) throws -> T where T: JSValueDecodable {
        try dynamicallyCall(withArguments: args).decode()
    }
}

extension JSValue: JSDynamicObject {
    var jsContext: JSContext { context }
    
    subscript<T: JSValueDecodable>(dynamicMember member: String) -> T? {
        try? objectForKeyedSubscript(member).decode()
    }
    
    subscript(dynamicMember member: String) -> any JSDynamicObjectMember {
        JSFunction(parent: self, value: objectForKeyedSubscript(member))
    }
    
}

extension JSContext: JSDynamicObject {
    var jsContext: JSContext { self }
    
    subscript<T: JSValueDecodable>(dynamicMember member: String) -> T? {
        try? objectForKeyedSubscript(member)?.decode()
    }
    
    subscript(dynamicMember member: String) -> JSDynamicObjectMember {
        JSFunction(parent: self, value: objectForKeyedSubscript(member))
    }
}

extension JSValue {

    fileprivate func then(
        _ onResolved: @escaping (JSValue) -> Void,
        _ onRejected: @escaping (JSValue) -> Void,
    ) throws {
        let onResolvedWrapper: @convention(block) (JSValue) -> Void = { value in
            onResolved(value)
        }
        
        let onRejectedWrapper: @convention(block) (JSValue) -> Void = { value in
            onRejected(value)
        }
        try self[dynamicMember: "then"](AnyJSValueEncodable(onResolvedWrapper), AnyJSValueEncodable(onRejectedWrapper))
    }
    
    fileprivate func then() async throws -> JSValue {
        try await withCheckedThrowingContinuation { continuation in
            do {
                try then(
                    { continuation.resume(returning: $0) },
                    { continuation.resume(throwing: $0.toJSError() ?? $0.toString()) }
                )
            } catch {
                continuation.resume(throwing: error)
            }
        }
    }
}

private extension JSContext {
    
    func promise(wrap function: JSFunction, args: [Any]) async throws -> JSValue {
        let functionName = "__promiseWrapper"
        
        var promiseWrapper: JSValue? = self[dynamicMember: functionName]
        
        if let promiseWrapper {
            return try call(function: function, args: args, on: promiseWrapper)
        }
        
        let script = """
            function \(functionName)(fn, context = null, ...args) {
                try {
                  const result = fn.apply(context, args);
                  
                  if (result instanceof Promise) {
                    return result;
                  } else {
                    return Promise.resolve(result);
                  }
                } catch (error) {
                    return Promise.reject(error);
                }
            }
        """
        
        evaluateScript(script)
        
        promiseWrapper = self[dynamicMember: functionName]
        
        guard let promiseWrapper else {
            throw "JSFunctionError: No promise wrapper found"
        }
        
        return try call(function: function, args: args, on: promiseWrapper)
    }
    
    func throwErrorToReturn(wrap function: JSFunction, args: [Any]) throws -> JSValue {
        let functionName = "__throwErrorToReturn"
        
        var throwErrorToReturnWrapper: JSValue? = self[dynamicMember: functionName]
        
        if let throwErrorToReturnWrapper {
            return try call(function: function, args: args, on: throwErrorToReturnWrapper)
        }
        
        let script = """
            function \(functionName)(fn, context = null, ...args) {
                try {
                    return fn.apply(context, args);
                } catch (error) {
                    return error;
                }
            }
        """
        
        evaluateScript(script)
        
        throwErrorToReturnWrapper = self[dynamicMember: functionName]
        
        guard let throwErrorToReturnWrapper else {
            throw "JSFunctionError: No promise wrapper found"
        }
        
        return try call(function: function, args: args, on: throwErrorToReturnWrapper)
    }

    func call(function: JSFunction, args: [Any], on wrapper: JSValue) throws -> JSValue {
        let value: JSValue = wrapper.call(withArguments: [function.value, function.parent] + args)
        
        if value.isJSError == true, let error = value.toJSError() {
            throw error
        }
        return value
    }
}
