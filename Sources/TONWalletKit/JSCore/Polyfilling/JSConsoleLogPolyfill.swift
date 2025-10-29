//
//  JSConsoleLogPolyfill.swift
//  TONWalletKit
//
//  Created by Nikita Rodionov on 11.09.2025.
//
//  Copyright (c) 2025 TON Connect
//
//  Permission is hereby granted, free of charge, to any person obtaining a copy
//  of this software and associated documentation files (the "Software"), to deal
//  in the Software without restriction, including without limitation the rights
//  to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
//  copies of the Software, and to permit persons to whom the Software is
//  furnished to do so, subject to the following conditions:
//  
//  The above copyright notice and this permission notice shall be included in all
//  copies or substantial portions of the Software.
//  
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
//  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
//  SOFTWARE.

import Foundation
import JavaScriptCore

public class JSConsoleLogPolyfill: NSObject, JSPolyfill {
    
    public func apply(to context: JSContext) {
        let consoleLog: @convention(block) (String) -> () = { message in
            self.consoleLog(message)
        }

        let consoleTrace: @convention(block) (JSValue) -> () = { message in
            self.consoleTrace(message.toString() ?? "")
        }
        
        context.setObject(consoleLog, forKeyedSubscript: "nativeLog" as NSString)
        context.setObject(consoleTrace, forKeyedSubscript: "nativeTrace" as NSString)
        
        context.evaluateScript(
            """
                // Add basic console object
                const console = {
                    log: function(...args) {
                        nativeLog(args.map(a => typeof a === 'object' ? JSON.stringify(a) : String(a)).join(' '));
                    },
                    warn: function(...args) { 
                        nativeLog('[WARN] ' + args.map(a => typeof a === 'object' ? JSON.stringify(a) : String(a)).join(' ')); 
                    },
                    error: function(...args) { 
                        nativeLog('[ERROR] ' + args.map(a => typeof a === 'object' ? JSON.stringify(a) : String(a)).join(' ')); 
                    },
                    info: function(...args) { 
                        nativeLog('[INFO] ' + args.map(a => typeof a === 'object' ? JSON.stringify(a) : String(a)).join(' ')); 
                    },
                    debug: function(...args) { 
                        nativeLog('[DEBUG] ' + args.map(a => typeof a === 'object' ? JSON.stringify(a) : String(a)).join(' ')); 
                    },
                    trace: function(...args) { 
                        nativeTrace(args);
                    }
                };
            
                window.console = console;
            """
        )
    }
    
    @objc private func consoleLog(_ message: String) {
        print("[JS Console]: \(message)")
    }

    @objc private func consoleTrace(_ message: String) {
        print("[JS Trace]: \(message)")
    }
}
