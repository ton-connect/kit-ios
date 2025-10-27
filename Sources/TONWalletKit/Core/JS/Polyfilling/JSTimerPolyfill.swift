//
//  JSTimerPolyfill.swift
//  TONWalletKit
//
//  Created by Nikita Rodionov on 11.09.2025.
//

import Foundation
import JavaScriptCore

@objc
public protocol JSTimerManager: JSExport {
    @objc(setTimeout:::) func setTimeout(callback: JSValue, interval: Double, parameters: [Any]) -> String
    @objc(clearTimeout:) func clearTimeout(identifier: String)
    @objc(setInterval:::) func setInterval(callback: JSValue, interval: Double, parameters: [Any]) -> String
    @objc(clearInterval:) func clearInterval(identifier: String)
}

public class JSTimerPolyfill: NSObject, JSPolyfill, JSTimerManager {
    private var timers: [String: Timer?] = [:]
    private let timersQueue = DispatchQueue(label: "com.jstimers.queue")
    
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
    public func setTimeout(callback: JSValue, interval: Double, parameters: [Any]) -> String {
        guard callback.isObject && callback.isFunction else {
            return ""
        }
        
        let identifier = UUID().uuidString
        
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
    public func clearTimeout(identifier: String) {
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
    public func setInterval(callback: JSValue, interval: Double, parameters: [Any]) -> String {
        guard callback.isObject && callback.isFunction else {
            return ""
        }
        
        let identifier = UUID().uuidString
        
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
    public func clearInterval(identifier: String) {
        clearTimeout(identifier: identifier)
    }
    
    private func preserveTimerSlot(for identifier: String) {
        timersQueue.sync {
            timers[identifier] = Optional<Timer>.none
        }
    }
    
    private func set(timer: Timer, for identifier: String) {
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
