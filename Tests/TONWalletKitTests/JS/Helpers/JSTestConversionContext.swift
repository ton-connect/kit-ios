//
//  JSTestConversionContext.swift
//  TONWalletKit
//
//  Created by Nikita Rodionov on 23.10.2025.
//

import Foundation
import JavaScriptCore

class JSTestConversionContext: JSContext {
    
    override init() {
        super.init()
        
        let js = """
            function String() {
                return "String";
            }
            
            function Int() {
                return \(Int.max);
            }
            
            function Int64() {
                return \(Int64.max);
            }
            
            function Int32() {
                return \(Int32.max);
            }
            
            function UInt() {
                return \(UInt.max);
            }
            
            function UInt64() {
                return \(UInt64.max);
            }
            
            function UInt32() {
                return \(UInt32.max);
            }
            
            function Double() {
                return \(Double.greatestFiniteMagnitude);
            }
            
            function Float() {
                return \(Float.greatestFiniteMagnitude);
            }
            
            function Bool() {
                return true;
            }
            
            function DateValue() {
                return new Date("2023-01-01T00:00:00Z");
            }
            
            function Dictionary() {
                return { key: "value" };
            }
            
            function Array() {
                return [1, 2, 3];
            }
            
            function JSTestDecodable() {
                return { test: "testValue" };
            }
            
            function undefinedValue() {
                return undefined;
            }
            
            function nullValue() {
                return null;
            }
            
            function voidValue() {
                return;
            }
             
            function IntInString() {
                return "12345";
            }
            
            function _isString(value) {
                return typeof value === 'string';
            }
            
            function _isNumber(value) {
                return typeof value === 'number';
            }
            
            function _isBoolean(value) {
                return typeof value === 'boolean';
            }
            
            function _isDate(value) {
                return value instanceof Date;
            }
            
            function _isArray(value) {
                return Object.prototype.toString.call(value) === '[object Array]'
            }
            
            function _isNull(value) {
                return value === null;
            }
            
            function _validateJSTestDecodable(value) {
                return typeof value === 'object' && value.hasOwnProperty('test') && typeof value.test === 'string' && value.test === 'testValue';
            }
            
            function _validateMultipleParameters(stringValue, intValue, boolValue) {
                return typeof stringValue === 'string' && stringValue === 'testString' &&
                       typeof intValue === 'number' && intValue === 42 &&
                       typeof boolValue === 'boolean' && boolValue === true;
            }
            """
        evaluateScript(js)
    }
    
    override init!(virtualMachine: JSVirtualMachine!) {
        super.init(virtualMachine: virtualMachine)
    }
}
