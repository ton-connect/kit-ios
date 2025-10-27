//
//  JSConsoleLogPolyfill.swift
//  TONWalletKit
//
//  Created by Nikita Rodionov on 11.09.2025.
//

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
