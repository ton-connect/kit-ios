//
//  JSTimerPolyfill.swift
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

@objc
public protocol JSTimerManager: JSExport {
    
    @objc(setTimeout:::) func setTimeout(callback: JSValue, interval: Double, parameters: [Any]) -> Int32
    @objc(clearTimeout:) func clearTimeout(identifier: Int32)
    @objc(setInterval:::) func setInterval(callback: JSValue, interval: Double, parameters: [Any]) -> Int32
    @objc(clearInterval:) func clearInterval(identifier: Int32)
}

class JSTimerIdentifierProvider {
    private var lastID: Int32 = 0
    
    func nextTimerIdentifier() -> Int32 {
        let id = lastID
        lastID = lastID &+ 1
        return id
    }
}

public class JSTimerPolyfill: NSObject, JSPolyfill, JSTimerManager {
    private var timers: [Int32: Timer?] = [:]
    private let timersQueue = DispatchQueue(label: "com.jstimers.queue")
    private let timerIdentifierProvider = JSTimerIdentifierProvider()
    
    public func apply(to context: JSContext) {
        context.setObject(self,
                          forKeyedSubscript: "__nativeTimersManager" as NSString)
        
        context.evaluateScript(
            """
            function setTimeout(callback, interval, ...parameters) {
                return __nativeTimersManager.setTimeout(callback, interval, parameters);
            }
            
            function clearTimeout(identifier) {
                __nativeTimersManager.clearTimeout(identifier);
            }
            
            function setInterval(callback, interval) {
                return __nativeTimersManager.setInterval(callback, interval);
            }
            
            function clearInterval(identifier) {
                __nativeTimersManager.clearInterval(identifier);
            }
            """
        )
    }
    
    @objc
    public func setTimeout(callback: JSValue, interval: Double, parameters: [Any]) -> Int32 {
        guard callback.isObject && callback.isFunction else {
            return -1
        }
        
        let identifier = timersQueue.sync { self.timerIdentifierProvider.nextTimerIdentifier() }
        
        preserveTimerSlot(for: identifier)
        
        DispatchQueue.main.async { [weak self] in
            let function = JSManagedValue(value: callback, andOwner: callback.context)
            
            let timer = Timer.scheduledTimer(withTimeInterval: max(0.0, interval) / 1000.0, repeats: false) { [weak self] timer in
                timer.invalidate()
                
                function?.value?.call(withArguments: parameters)
                
                self?.timersQueue.async {
                    self?.timers.removeValue(forKey: identifier)
                }
            }
            
            self?.set(timer: timer, for: identifier)
        }
        
        return identifier
    }
    
    @objc
    public func clearTimeout(identifier: Int32) {
        DispatchQueue.main.async { [weak self] in
            guard let self = self else { return }
            
            self.timersQueue.sync {
                if let timer = self.timers.removeValue(forKey: identifier) {
                    timer?.invalidate()
                }
            }
        }
    }
    
    @objc
    public func setInterval(callback: JSValue, interval: Double, parameters: [Any]) -> Int32 {
        guard callback.isObject && callback.isFunction else {
            return -1
        }
        
        let identifier = timersQueue.sync { self.timerIdentifierProvider.nextTimerIdentifier() }
        
        preserveTimerSlot(for: identifier)
        
        DispatchQueue.main.async { [weak self] in
            let function = JSManagedValue(value: callback, andOwner: callback.context)
            
            let timer = Timer.scheduledTimer(withTimeInterval: max(0.0, interval) / 1000.0, repeats: true) { timer in
                function?.value?.call(withArguments: parameters)
            }
            
            self?.set(timer: timer, for: identifier)
        }
        
        return identifier
    }
    
    @objc
    public func clearInterval(identifier: Int32) {
        clearTimeout(identifier: identifier)
    }
    
    private func preserveTimerSlot(for identifier: Int32) {
        timersQueue.sync {
            timers[identifier] = Optional<Timer>.none
        }
    }
    
    private func set(timer: Timer, for identifier: Int32) {
        let timerIsValid = timer.isValid
        
        timersQueue.sync { [weak self] in
            guard let self = self else { return }
            
            if timerIsValid && self.timers[identifier] == Optional<Timer>.none {
                self.timers[identifier] = timer
            } else {
                self.timers.removeValue(forKey: identifier)
            }
        }
    }
}
