//
//  JSWebSocket.swift
//  TONWalletKit
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

@preconcurrency import JavaScriptCore

enum JSWebSocketReadyState: Int {
    case connecting = 0
    case open = 1
    case closing = 2
    case closed = 3
}

enum JSWebSocketBinaryType: String {
    case blob
    case arraybuffer
}

@objc private protocol JSWebSocketExport: JSExport {
    init?(url: String, protocols: JSValue)

    var binaryType: String { get set }
    var bufferedAmount: Int { get }
    var extensions: String { get }
    var `protocol`: String { get }
    var readyState: Int { get }
    var url: String { get }

    var onopen: JSValue? { get set }
    var onmessage: JSValue? { get set }
    var onclose: JSValue? { get set }
    var onerror: JSValue? { get set }

    @objc(send:) func send(_ data: JSValue)
    @objc(close::) func close(_ code: JSValue, _ reason: JSValue)

    @objc(addEventListener::) func addEventListener(_ type: String, _ listener: JSValue)
    @objc(removeEventListener::) func removeEventListener(_ type: String, _ listener: JSValue)
}

@objc(WebSocket) class JSWebSocket: NSObject, JSWebSocketExport {
    private(set) var url: String
    private(set) var `protocol`: String = ""
    private(set) var extensions: String = ""
    private(set) var bufferedAmount: Int = 0

    private var _readyState: JSWebSocketReadyState = .connecting
    var readyState: Int { _readyState.rawValue }

    private var _binaryType: JSWebSocketBinaryType = .blob
    var binaryType: String {
        get { _binaryType.rawValue }
        set { _binaryType = JSWebSocketBinaryType(rawValue: newValue) ?? .blob }
    }

    var onopen: JSValue?
    var onmessage: JSValue?
    var onclose: JSValue?
    var onerror: JSValue?

    private var eventListeners: [JSEventType: [JSManagedValue]] = [:]
    private var task: (any JSWebSocketTaskProtocol)?
    private weak var context: JSContext?

    required init?(url urlString: String, protocols: JSValue) {
        guard let context = JSContext.current() else { return nil }
        
        self.context = context

        guard let url = URL(string: urlString),
              let scheme = url.scheme?.lowercased(),
              ["ws", "wss", "http", "https"].contains(scheme) else {
            context.exception = JSValue(
                newErrorFromMessage: "Failed to construct 'WebSocket': The URL '\(urlString)' is invalid.",
                in: context
            )
            return nil
        }

        if url.fragment != nil {
            context.exception = JSValue(
                newErrorFromMessage: "Failed to construct 'WebSocket': The URL contains a fragment identifier ('\(urlString)').",
                in: context
            )
            return nil
        }

        self.url = urlString

        let protocolList: [String]
        
        if protocols.isString {
            protocolList = [protocols.toString()]
        } else if protocols.isArray {
            protocolList = protocols.toArray().compactMap { $0 as? String }
        } else if protocols.isUndefined || protocols.isNull {
            protocolList = []
        } else {
            protocolList = [protocols.toString()]
        }

        if Set(protocolList).count != protocolList.count {
            context.exception = JSValue(
                newErrorFromMessage: "Failed to construct 'WebSocket': The subprotocol is duplicated.",
                in: context
            )
            return nil
        }

        super.init()

        Task { @JSWebSocketActor in
            let task = JSWebSocketTask(url: url, protocols: protocolList)
            
            self.task = task
            
            let stream = task.start()

            for await event in stream {
                self.handleEvent(event)
            }
        }
    }

    @objc(send:)
    func send(_ data: JSValue) {
        guard let context = self.context else { return }

        guard _readyState != .connecting else {
            context.exception = JSValue(
                newErrorFromMessage: "Failed to execute 'send': Still in CONNECTING state.",
                in: context
            )
            return
        }
        guard _readyState == .open else { return }

        Task { @JSWebSocketActor in
            guard let task = self.task else { return }
            do {
                if data.isString {
                    try await task.send(.string(data.toString()))
                } else {
                    let bytes = await MainActor.run { self.extractBytes(from: data, in: context) }
                    
                    if let bytes {
                        try await task.send(.data(bytes))
                    } else {
                        try await task.send(.string(data.toString()))
                    }
                }
            } catch {
                // Send failure will trigger error event through the delegate
            }
        }
    }

    @objc(close::)
    func close(_ codeValue: JSValue, _ reasonValue: JSValue) {
        guard _readyState == .connecting || _readyState == .open else { return }
        guard let context = self.context else { return }

        let code: Int
        
        if codeValue.isUndefined || codeValue.isNull {
            code = 1000
        } else {
            code = Int(codeValue.toInt32())
            if code != 1000 && !(3000...4999).contains(code) {
                context.exception = JSValue(
                    newErrorFromMessage: "Failed to execute 'close': The code must be either 1000, or between 3000 and 4999.",
                    in: context
                )
                return
            }
        }

        let reason: String
        if reasonValue.isUndefined || reasonValue.isNull {
            reason = ""
        } else {
            reason = reasonValue.toString() ?? ""
            if reason.utf8.count > 123 {
                context.exception = JSValue(
                    newErrorFromMessage: "Failed to execute 'close': The reason must not be greater than 123 bytes.",
                    in: context
                )
                return
            }
        }

        self._readyState = .closing

        Task { @JSWebSocketActor in
            let closeCode = URLSessionWebSocketTask.CloseCode(rawValue: code) ?? .normalClosure
            self.task?.close(code: closeCode, reason: reason.data(using: .utf8))
        }
    }

    @objc(addEventListener::)
    func addEventListener(_ type: String, _ listener: JSValue) {
        guard let eventType = JSEventType(rawValue: type) else { return }
        
        guard listener.isObject,
              let managed = JSManagedValue(value: listener, andOwner: self) else { return }
        
        if eventListeners[eventType] == nil {
            eventListeners[eventType] = []
        }
        eventListeners[eventType]?.append(managed)
    }

    @objc(removeEventListener::)
    func removeEventListener(_ type: String, _ listener: JSValue) {
        guard let eventType = JSEventType(rawValue: type) else { return }
        
        eventListeners[eventType]?.removeAll { managed in
            managed.value?.isEqual(to: listener) ?? false
        }
    }

    private func extractBytes(from value: JSValue, in context: JSContext) -> Data? {
        let uint8Constructor: JSValue? = context.Uint8Array
        
        guard let uint8Constructor else { return nil }
        
        guard let wrapped = uint8Constructor.construct(withArguments: [value]), !wrapped.isUndefined else {
            return nil
        }
        
        let length: Int32 = wrapped.length ?? 0
        var bytes = [UInt8]()
        
        bytes.reserveCapacity(Int(length))
        
        for i in 0..<Int(length) {
            bytes.append(UInt8(wrapped.objectAtIndexedSubscript(i)?.toInt32() ?? 0))
        }
        return Data(bytes)
    }
}

private extension JSWebSocket {
    
    func handleEvent(_ event: JSWebSocketEvent) {
        guard let context = self.context else { return }

        switch event {
        case .open(let negotiatedProtocol):
            self._readyState = .open
            self.protocol = negotiatedProtocol ?? ""
            self.dispatchEvent(JSOpenEvent(), in: context)

        case .message(let message):
            switch message {
            case .text(let text):
                let jsData = JSValue(object: text, in: context)
                let properties = JSMessageEventProperties(data: jsData, origin: self.url)
                self.dispatchEvent(JSMessageEvent(type: .message, properties: properties), in: context)

            case .binary(let data):
                guard let binaryData = self.convertBinaryData(data, in: context) else { return }
                let jsValue = binaryData as? JSValue ?? JSValue(object: binaryData, in: context)
                let properties = JSMessageEventProperties(data: jsValue, origin: self.url)
                self.dispatchEvent(JSMessageEvent(type: .message, properties: properties), in: context)
            }

        case .close(let code, let reason, let wasClean):
            self._readyState = .closed
            let properties = JSCloseEventProperties(wasClean: wasClean, code: code, reason: reason)
            self.dispatchEvent(JSCloseEvent(properties: properties), in: context)

        case .error(let message):
            let properties = JSErrorEventProperties(message: message)
            self.dispatchEvent(JSErrorEvent(type: .error, properties: properties), in: context)
        }
    }

    private func createUint8Array(from data: Data, in context: JSContext) -> JSValue? {
        let uint8Constructor: JSValue? = context.Uint8Array
        return uint8Constructor?.construct(withArguments: [Array(data)])
    }

    private func convertBinaryData(_ data: Data, in context: JSContext) -> Any? {
        guard let uint8Array = createUint8Array(from: data, in: context) else { return nil }

        if self._binaryType == .arraybuffer {
            let buffer: JSValue? = uint8Array.buffer
            return buffer
        }

        let blobClass: JSValue? = context.Blob
        
        if let blobClass, !blobClass.isUndefined {
            return blobClass.construct(withArguments: [[uint8Array] as [Any]])
        }

        let buffer: JSValue? = uint8Array.buffer
        return buffer
    }

    private func dispatchEvent(_ event: JSEvent, in context: JSContext) {
        guard let encoded = try? event.encode(in: context) else { return }

        let handler: JSValue?
        switch event.type {
        case .open: handler = self.onopen
        case .message: handler = self.onmessage
        case .close: handler = self.onclose
        case .error: handler = self.onerror
        }
        if let handler, handler.isObject {
            handler.call(withArguments: [encoded])
        }

        if let listeners = self.eventListeners[event.type] {
            for managedListener in listeners {
                managedListener.value?.call(withArguments: [encoded])
            }
        }
    }
}
