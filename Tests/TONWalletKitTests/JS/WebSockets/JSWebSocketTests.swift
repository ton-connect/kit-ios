//
//  JSWebSocketTests.swift
//  TONWalletKit
//
//  Created by Nikita Rodionov on 16.03.2026.
//
//  Copyright (c) 2026 TON Connect
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

import Testing
import JavaScriptCore
@testable import TONWalletKit
@_private(sourceFile: "JSWebSocket.swift")
import TONWalletKit

@Suite("JSWebSocket Tests")
struct JSWebSocketTests {

    private let context: JSContext = {
        let ctx = JSContext()!
        try! ctx.install([.blob])
        return ctx
    }()

    private func makeWebSocket(url: String = "ws://localhost:8080", task: MockJSWebSocketTask = MockJSWebSocketTask()) -> JSWebSocket? {
        let protocols = JSValue(undefinedIn: context)!
        return JSWebSocket(url: url, protocols: protocols, context: context, task: task)
    }

    // MARK: - Initialization

    @Test("Initializes with valid ws URL")
    func initWithValidWsURL() {
        let ws = makeWebSocket(url: "ws://localhost:8080")
        #expect(ws != nil)
        #expect(ws?.url == "ws://localhost:8080")
        #expect(ws?._readyState == .connecting)
    }

    @Test("Initializes with valid wss URL")
    func initWithValidWssURL() {
        let ws = makeWebSocket(url: "wss://example.com/socket")
        #expect(ws != nil)
    }

    @Test("Initializes with valid http URL")
    func initWithValidHttpURL() {
        let ws = makeWebSocket(url: "http://example.com/ws")
        #expect(ws != nil)
    }

    @Test("Initializes with valid https URL")
    func initWithValidHttpsURL() {
        let ws = makeWebSocket(url: "https://example.com/ws")
        #expect(ws != nil)
    }

    @Test("Fails with invalid scheme")
    func failsWithInvalidScheme() {
        let ws = makeWebSocket(url: "ftp://example.com")
        #expect(ws == nil)
        #expect(context.exception != nil)
    }

    @Test("Fails with invalid URL")
    func failsWithInvalidURL() {
        let ws = makeWebSocket(url: "")
        #expect(ws == nil)
    }

    @Test("Fails with fragment in URL")
    func failsWithFragment() {
        let ws = makeWebSocket(url: "ws://example.com/path#fragment")
        #expect(ws == nil)
        #expect(context.exception != nil)
    }

    @Test("Fails with duplicate protocols")
    func failsWithDuplicateProtocols() {
        let protocols = JSValue(object: ["soap", "soap"], in: context)!
        let ws = JSWebSocket(url: "ws://localhost", protocols: protocols, context: context, task: MockJSWebSocketTask())
        #expect(ws == nil)
        #expect(context.exception != nil)
    }

    @Test("Parses string protocol")
    func parsesStringProtocol() {
        let protocols = JSValue(object: "soap", in: context)!
        let ws = JSWebSocket(url: "ws://localhost", protocols: protocols, context: context, task: MockJSWebSocketTask())
        #expect(ws != nil)
    }

    @Test("Parses array protocols")
    func parsesArrayProtocols() {
        let protocols = JSValue(object: ["soap", "wamp"], in: context)!
        let ws = JSWebSocket(url: "ws://localhost", protocols: protocols, context: context, task: MockJSWebSocketTask())
        #expect(ws != nil)
    }

    @Test("Default readyState is connecting")
    func defaultReadyState() {
        let ws = makeWebSocket()
        #expect(ws?.readyState == JSWebSocketReadyState.connecting.rawValue)
    }

    @Test("Default binaryType is blob")
    func defaultBinaryType() {
        let ws = makeWebSocket()
        #expect(ws?.binaryType == "blob")
    }

    @Test("Default protocol is empty")
    func defaultProtocol() {
        let ws = makeWebSocket()
        #expect(ws?.protocol == "")
    }

    // MARK: - Event Handling: Open

    @Test("Open event sets readyState to open")
    func openEventSetsReadyState() {
        let ws = makeWebSocket()!
        ws.handleEvent(.open(negotiatedProtocol: nil))
        #expect(ws._readyState == .open)
    }

    @Test("Open event sets negotiated protocol")
    func openEventSetsProtocol() {
        let ws = makeWebSocket()!
        ws.handleEvent(.open(negotiatedProtocol: "soap"))
        #expect(ws.protocol == "soap")
    }

    @Test("Open event with nil protocol sets empty string")
    func openEventNilProtocol() {
        let ws = makeWebSocket()!
        ws.handleEvent(.open(negotiatedProtocol: nil))
        #expect(ws.protocol == "")
    }

    @Test("Open event dispatches to onopen handler")
    func openEventDispatchesToHandler() {
        let ws = makeWebSocket()!

        context.evaluateScript("var openCalled = false;")
        ws.onopen = context.evaluateScript("(function(e) { openCalled = true; })")

        ws.handleEvent(.open(negotiatedProtocol: nil))

        let called: Bool = context.evaluateScript("openCalled").toBool()
        #expect(called == true)
    }

    @Test("Open event has correct type")
    func openEventHasCorrectType() {
        let ws = makeWebSocket()!

        context.evaluateScript("var eventType = '';")
        ws.onopen = context.evaluateScript("(function(e) { eventType = e.type; })")

        ws.handleEvent(.open(negotiatedProtocol: nil))

        let type: String = context.evaluateScript("eventType").toString()
        #expect(type == "open")
    }

    // MARK: - Event Handling: Message

    @Test("Text message dispatches to onmessage with data and origin")
    func textMessageEvent() {
        let ws = makeWebSocket()!
        ws.handleEvent(.open(negotiatedProtocol: nil))

        context.evaluateScript("var msgData = ''; var msgOrigin = '';")
        ws.onmessage = context.evaluateScript("(function(e) { msgData = e.data; msgOrigin = e.origin; })")

        ws.handleEvent(.message(.text("hello")))

        let data: String = context.evaluateScript("msgData").toString()
        let origin: String = context.evaluateScript("msgOrigin").toString()
        #expect(data == "hello")
        #expect(origin == "ws://localhost:8080")
    }

    @Test("Message event has correct type")
    func messageEventHasCorrectType() {
        let ws = makeWebSocket()!

        context.evaluateScript("var eventType = '';")
        ws.onmessage = context.evaluateScript("(function(e) { eventType = e.type; })")

        ws.handleEvent(.message(.text("test")))

        let type: String = context.evaluateScript("eventType").toString()
        #expect(type == "message")
    }

    // MARK: - Event Handling: Close

    @Test("Close event sets readyState to closed")
    func closeEventSetsReadyState() {
        let ws = makeWebSocket()!
        ws.handleEvent(.open(negotiatedProtocol: nil))
        ws.handleEvent(.close(code: 1000, reason: "normal", wasClean: true))
        #expect(ws._readyState == .closed)
    }

    @Test("Close event dispatches with code, reason, and wasClean")
    func closeEventProperties() {
        let ws = makeWebSocket()!

        context.evaluateScript("var closeCode = 0; var closeReason = ''; var closeWasClean = false;")
        ws.onclose = context.evaluateScript("""
            (function(e) {
                closeCode = e.code;
                closeReason = e.reason;
                closeWasClean = e.wasClean;
            })
        """)

        ws.handleEvent(.close(code: 1001, reason: "going away", wasClean: true))

        let code: Int32 = context.evaluateScript("closeCode").toInt32()
        let reason: String = context.evaluateScript("closeReason").toString()
        let wasClean: Bool = context.evaluateScript("closeWasClean").toBool()
        #expect(code == 1001)
        #expect(reason == "going away")
        #expect(wasClean == true)
    }

    // MARK: - Event Handling: Error

    @Test("Error event dispatches with message")
    func errorEventMessage() {
        let ws = makeWebSocket()!

        context.evaluateScript("var errorMsg = '';")
        ws.onerror = context.evaluateScript("(function(e) { errorMsg = e.message; })")

        ws.handleEvent(.error("connection refused"))

        let message: String = context.evaluateScript("errorMsg").toString()
        #expect(message == "connection refused")
    }

    @Test("Error event has correct type")
    func errorEventHasCorrectType() {
        let ws = makeWebSocket()!

        context.evaluateScript("var eventType = '';")
        ws.onerror = context.evaluateScript("(function(e) { eventType = e.type; })")

        ws.handleEvent(.error("fail"))

        let type: String = context.evaluateScript("eventType").toString()
        #expect(type == "error")
    }

    // MARK: - addEventListener

    @Test("addEventListener receives dispatched events")
    func addEventListenerReceivesEvents() {
        let ws = makeWebSocket()!

        context.evaluateScript("var listenerCalled = false;")
        let listener = context.evaluateScript("(function(e) { listenerCalled = true; })")!
        ws.addEventListener("open", listener)

        ws.handleEvent(.open(negotiatedProtocol: nil))

        let called: Bool? = context.evaluateScript("listenerCalled").toBool()
        #expect(called == true)
    }

    @Test("Multiple listeners all get called")
    func multipleListenersGetCalled() {
        let ws = makeWebSocket()!

        context.evaluateScript("var count = 0;")
        let listener1 = context.evaluateScript("(function(e) { count++; })")!
        let listener2 = context.evaluateScript("(function(e) { count++; })")!
        ws.addEventListener("message", listener1)
        ws.addEventListener("message", listener2)

        ws.handleEvent(.message(.text("test")))

        let count: Int32 = context.evaluateScript("count").toInt32()
        #expect(count == 2)
    }

    @Test("removeEventListener stops dispatching")
    func removeEventListenerStopsDispatching() {
        let ws = makeWebSocket()!

        context.evaluateScript("var count = 0;")
        let listener = context.evaluateScript("(function(e) { count++; })")!
        ws.addEventListener("open", listener)
        ws.removeEventListener("open", listener)

        ws.handleEvent(.open(negotiatedProtocol: nil))

        let count: Int32 = context.evaluateScript("count").toInt32()
        #expect(count == 0)
    }

    @Test("addEventListener ignores unknown event types")
    func addEventListenerIgnoresUnknownTypes() {
        let ws = makeWebSocket()!

        context.evaluateScript("var called = false;")
        let listener = context.evaluateScript("(function(e) { called = true; })")!
        ws.addEventListener("unknown", listener)

        #expect(context.evaluateScript("called").toBool() == false)
    }

    // MARK: - Both on* handler and addEventListener

    @Test("Both onopen and addEventListener listener are called")
    func bothHandlerAndListenerCalled() {
        let ws = makeWebSocket()!

        context.evaluateScript("var handlerCalled = false; var listenerCalled = false;")
        ws.onopen = context.evaluateScript("(function(e) { handlerCalled = true; })")
        let listener = context.evaluateScript("(function(e) { listenerCalled = true; })")!
        ws.addEventListener("open", listener)

        ws.handleEvent(.open(negotiatedProtocol: nil))

        #expect(context.evaluateScript("handlerCalled").toBool() == true)
        #expect(context.evaluateScript("listenerCalled").toBool() == true)
    }

    // MARK: - Binary Message Reception: ArrayBuffer

    @Test("Binary message with arraybuffer type delivers ArrayBuffer")
    func binaryMessageArrayBuffer() {
        let ws = makeWebSocket()!
        ws.binaryType = "arraybuffer"
        ws.handleEvent(.open(negotiatedProtocol: nil))

        context.evaluateScript("var isArrayBuffer = false; var byteLength = -1;")
        ws.onmessage = context.evaluateScript("""
            (function(e) {
                isArrayBuffer = e.data instanceof ArrayBuffer;
                byteLength = e.data.byteLength;
            })
        """)

        ws.handleEvent(.message(.binary(Data([1, 2, 3]))))

        #expect(context.evaluateScript("isArrayBuffer").toBool() == true)
        #expect(context.evaluateScript("byteLength").toInt32() == 3)
    }

    @Test("Binary message with arraybuffer preserves byte values")
    func binaryMessageArrayBufferBytes() {
        let ws = makeWebSocket()!
        ws.binaryType = "arraybuffer"
        ws.handleEvent(.open(negotiatedProtocol: nil))

        context.evaluateScript("var receivedBytes = [];")
        ws.onmessage = context.evaluateScript("""
            (function(e) {
                var view = new Uint8Array(e.data);
                for (var i = 0; i < view.length; i++) {
                    receivedBytes.push(view[i]);
                }
            })
        """)

        ws.handleEvent(.message(.binary(Data([10, 20, 30, 255, 0, 128]))))

        #expect(context.evaluateScript("receivedBytes[0]").toInt32() == 10)
        #expect(context.evaluateScript("receivedBytes[1]").toInt32() == 20)
        #expect(context.evaluateScript("receivedBytes[2]").toInt32() == 30)
        #expect(context.evaluateScript("receivedBytes[3]").toInt32() == 255)
        #expect(context.evaluateScript("receivedBytes[4]").toInt32() == 0)
        #expect(context.evaluateScript("receivedBytes[5]").toInt32() == 128)
    }

    @Test("Binary message preserves all 256 byte values")
    func binaryMessageAll256Bytes() {
        let ws = makeWebSocket()!
        ws.binaryType = "arraybuffer"
        ws.handleEvent(.open(negotiatedProtocol: nil))

        context.evaluateScript("var allMatch = false;")
        ws.onmessage = context.evaluateScript("""
            (function(e) {
                var view = new Uint8Array(e.data);
                if (view.length !== 256) { allMatch = false; return; }
                allMatch = true;
                for (var i = 0; i < 256; i++) {
                    if (view[i] !== i) { allMatch = false; break; }
                }
            })
        """)

        let allBytes = Data((0...255).map { UInt8($0) })
        ws.handleEvent(.message(.binary(allBytes)))

        #expect(context.evaluateScript("allMatch").toBool() == true)
    }

    @Test("Empty binary data delivers empty ArrayBuffer")
    func emptyBinaryArrayBuffer() {
        let ws = makeWebSocket()!
        ws.binaryType = "arraybuffer"
        ws.handleEvent(.open(negotiatedProtocol: nil))

        context.evaluateScript("var called = false; var len = -1;")
        ws.onmessage = context.evaluateScript("""
            (function(e) {
                called = true;
                len = e.data.byteLength;
            })
        """)

        ws.handleEvent(.message(.binary(Data())))

        #expect(context.evaluateScript("called").toBool() == true)
        #expect(context.evaluateScript("len").toInt32() == 0)
    }

    @Test("Binary message origin matches URL with arraybuffer type")
    func binaryMessageOriginArrayBuffer() {
        let ws = makeWebSocket(url: "wss://example.com/ws")!
        ws.binaryType = "arraybuffer"
        ws.handleEvent(.open(negotiatedProtocol: nil))

        context.evaluateScript("var origin = '';")
        ws.onmessage = context.evaluateScript("(function(e) { origin = e.origin; })")

        ws.handleEvent(.message(.binary(Data([1]))))

        #expect(context.evaluateScript("origin").toString() == "wss://example.com/ws")
    }

    @Test("Large binary data preserves integrity")
    func largeBinaryData() {
        let ws = makeWebSocket()!
        ws.binaryType = "arraybuffer"
        ws.handleEvent(.open(negotiatedProtocol: nil))

        context.evaluateScript("var size = 0; var checksum = 0;")
        ws.onmessage = context.evaluateScript("""
            (function(e) {
                var view = new Uint8Array(e.data);
                size = view.length;
                for (var i = 0; i < view.length; i++) {
                    checksum = (checksum + view[i]) & 0xFFFFFFFF;
                }
            })
        """)

        var data = Data(count: 1024)
        for i in 0..<1024 { data[i] = UInt8(i % 256) }
        let expectedChecksum: Int32 = (0..<1024).reduce(0) { ($0 + Int32($1 % 256)) & 0x7FFFFFFF }

        ws.handleEvent(.message(.binary(data)))

        #expect(context.evaluateScript("size").toInt32() == 1024)
        #expect(context.evaluateScript("checksum").toInt32() == expectedChecksum)
    }

    // MARK: - Binary Message Reception: Blob

    @Test("Binary message with blob type delivers Blob instance")
    func binaryMessageBlob() {
        let ws = makeWebSocket()!
        ws.handleEvent(.open(negotiatedProtocol: nil))

        context.evaluateScript("var isBlob = false; var hasSize = false;")
        ws.onmessage = context.evaluateScript("""
            (function(e) {
                isBlob = e.data instanceof Blob;
                hasSize = typeof e.data.size === 'number';
            })
        """)

        ws.handleEvent(.message(.binary(Data([1, 2, 3, 4, 5]))))

        #expect(context.evaluateScript("isBlob").toBool() == true)
        #expect(context.evaluateScript("hasSize").toBool() == true)
    }

    @Test("Empty binary data delivers Blob instance")
    func emptyBinaryBlob() {
        let ws = makeWebSocket()!
        ws.handleEvent(.open(negotiatedProtocol: nil))

        context.evaluateScript("var called = false; var isBlob = false;")
        ws.onmessage = context.evaluateScript("""
            (function(e) {
                called = true;
                isBlob = e.data instanceof Blob;
            })
        """)

        ws.handleEvent(.message(.binary(Data())))

        #expect(context.evaluateScript("called").toBool() == true)
        #expect(context.evaluateScript("isBlob").toBool() == true)
    }

    @Test("Binary message origin matches URL with blob type")
    func binaryMessageOriginBlob() {
        let ws = makeWebSocket(url: "ws://test.local:9090/path")!
        ws.handleEvent(.open(negotiatedProtocol: nil))

        context.evaluateScript("var origin = '';")
        ws.onmessage = context.evaluateScript("(function(e) { origin = e.origin; })")

        ws.handleEvent(.message(.binary(Data([42]))))

        #expect(context.evaluateScript("origin").toString() == "ws://test.local:9090/path")
    }

    // MARK: - Switching binaryType

    @Test("Switching binaryType between messages changes data format")
    func switchBinaryType() {
        let ws = makeWebSocket()!
        ws.handleEvent(.open(negotiatedProtocol: nil))

        context.evaluateScript("var firstIsBlob = false; var secondIsArrayBuffer = false;")
        ws.onmessage = context.evaluateScript("""
            (function(e) {
                if (e.data instanceof Blob) { firstIsBlob = true; }
                if (e.data instanceof ArrayBuffer) { secondIsArrayBuffer = true; }
            })
        """)

        ws.handleEvent(.message(.binary(Data([1]))))
        #expect(context.evaluateScript("firstIsBlob").toBool() == true)

        ws.binaryType = "arraybuffer"
        ws.handleEvent(.message(.binary(Data([2]))))
        #expect(context.evaluateScript("secondIsArrayBuffer").toBool() == true)
    }

    // MARK: - Binary + addEventListener

    @Test("Binary message dispatches to addEventListener")
    func binaryMessageAddEventListener() {
        let ws = makeWebSocket()!
        ws.binaryType = "arraybuffer"
        ws.handleEvent(.open(negotiatedProtocol: nil))

        context.evaluateScript("var listenerByteLength = -1;")
        let listener = context.evaluateScript("""
            (function(e) { listenerByteLength = e.data.byteLength; })
        """)!
        ws.addEventListener("message", listener)

        ws.handleEvent(.message(.binary(Data([10, 20]))))

        #expect(context.evaluateScript("listenerByteLength").toInt32() == 2)
    }

    @Test("Binary message dispatches to both onmessage and addEventListener")
    func binaryMessageBothHandlerAndListener() {
        let ws = makeWebSocket()!
        ws.binaryType = "arraybuffer"
        ws.handleEvent(.open(negotiatedProtocol: nil))

        context.evaluateScript("var handlerLen = -1; var listenerLen = -1;")
        ws.onmessage = context.evaluateScript("(function(e) { handlerLen = e.data.byteLength; })")
        let listener = context.evaluateScript("(function(e) { listenerLen = e.data.byteLength; })")!
        ws.addEventListener("message", listener)

        ws.handleEvent(.message(.binary(Data([1, 2, 3, 4]))))

        #expect(context.evaluateScript("handlerLen").toInt32() == 4)
        #expect(context.evaluateScript("listenerLen").toInt32() == 4)
    }

    // MARK: - Send: String

    @Test("Send string when open")
    func sendString() async {
        let mockTask = MockJSWebSocketTask()
        let ws = makeWebSocket(task: mockTask)!
        ws.handleEvent(.open(negotiatedProtocol: nil))

        async let sent = mockTask.expectSend(count: 1)
        ws.send(JSValue(object: "hello", in: context))
        let messages = await sent

        #expect(messages.count == 1)
        if case .string(let text) = messages.first {
            #expect(text == "hello")
        } else {
            Issue.record("Expected string message")
        }
    }

    @Test("Send throws when connecting")
    func sendThrowsWhenConnecting() {
        let ws = makeWebSocket()!

        ws.send(JSValue(object: "test", in: context))

        #expect(context.exception != nil)
    }

    @Test("Send ignored when closed")
    func sendIgnoredWhenClosed() async {
        let mockTask = MockJSWebSocketTask()
        let ws = makeWebSocket(task: mockTask)!
        ws.handleEvent(.open(negotiatedProtocol: nil))
        ws.handleEvent(.close(code: 1000, reason: "done", wasClean: true))

        ws.send(JSValue(object: "test", in: context))

        try? await Task.sleep(for: .milliseconds(50))

        let messages = await mockTask.sentMessages
        #expect(messages.isEmpty)
    }

    @Test("Send number creates Uint8Array of that length")
    func sendNumberCreatesTypedArray() async {
        let mockTask = MockJSWebSocketTask()
        let ws = makeWebSocket(task: mockTask)!
        ws.handleEvent(.open(negotiatedProtocol: nil))

        async let sent = mockTask.expectSend(count: 1)
        ws.send(JSValue(int32: 3, in: context))
        let messages = await sent

        #expect(messages.count == 1)
        if case .data(let data) = messages.first {
            #expect(data.count == 3)
            #expect(Array(data) == [0, 0, 0])
        } else {
            Issue.record("Expected data message")
        }
    }

    @Test("Send boolean creates Uint8Array of length 1")
    func sendBooleanCreatesTypedArray() async {
        let mockTask = MockJSWebSocketTask()
        let ws = makeWebSocket(task: mockTask)!
        ws.handleEvent(.open(negotiatedProtocol: nil))

        async let sent = mockTask.expectSend(count: 1)
        ws.send(JSValue(bool: true, in: context))
        let messages = await sent

        #expect(messages.count == 1)
        if case .data(let data) = messages.first {
            #expect(data.count == 1)
            #expect(Array(data) == [0])
        } else {
            Issue.record("Expected data message")
        }
    }

    // MARK: - Send: Binary

    @Test("Send Uint8Array")
    func sendUint8Array() async {
        let mockTask = MockJSWebSocketTask()
        let ws = makeWebSocket(task: mockTask)!
        ws.handleEvent(.open(negotiatedProtocol: nil))

        async let sent = mockTask.expectSend(count: 1)
        let uint8Array = context.evaluateScript("new Uint8Array([1, 2, 3])")!
        ws.send(uint8Array)
        let messages = await sent

        #expect(messages.count == 1)
        if case .data(let data) = messages.first {
            #expect(Array(data) == [1, 2, 3])
        } else {
            Issue.record("Expected data message")
        }
    }

    @Test("Send ArrayBuffer")
    func sendArrayBuffer() async {
        let mockTask = MockJSWebSocketTask()
        let ws = makeWebSocket(task: mockTask)!
        ws.handleEvent(.open(negotiatedProtocol: nil))

        async let sent = mockTask.expectSend(count: 1)
        let arrayBuffer = context.evaluateScript("""
            (function() {
                var buf = new ArrayBuffer(3);
                var view = new Uint8Array(buf);
                view[0] = 10; view[1] = 20; view[2] = 30;
                return buf;
            })()
        """)!
        ws.send(arrayBuffer)
        let messages = await sent

        #expect(messages.count == 1)
        if case .data(let data) = messages.first {
            #expect(Array(data) == [10, 20, 30])
        } else {
            Issue.record("Expected data message")
        }
    }

    @Test("Send Uint16Array copies elements as Uint8 values")
    func sendUint16Array() async {
        let mockTask = MockJSWebSocketTask()
        let ws = makeWebSocket(task: mockTask)!
        ws.handleEvent(.open(negotiatedProtocol: nil))

        async let sent = mockTask.expectSend(count: 1)
        let typedArray = context.evaluateScript("new Uint16Array([256, 512])")!
        ws.send(typedArray)
        let messages = await sent

        #expect(messages.count == 1)
        if case .data(let data) = messages.first {
            #expect(data.count == 2)
            #expect(Array(data) == [0, 0])
        } else {
            Issue.record("Expected data message")
        }
    }

    @Test("Send empty Uint8Array")
    func sendEmptyUint8Array() async {
        let mockTask = MockJSWebSocketTask()
        let ws = makeWebSocket(task: mockTask)!
        ws.handleEvent(.open(negotiatedProtocol: nil))

        async let sent = mockTask.expectSend(count: 1)
        let empty = context.evaluateScript("new Uint8Array([])")!
        ws.send(empty)
        let messages = await sent

        #expect(messages.count == 1)
        if case .data(let data) = messages.first {
            #expect(data.isEmpty)
        } else {
            Issue.record("Expected data message")
        }
    }

    // MARK: - Round-Trip JS Tests

    @Test("JS Uint8Array round-trip: send and verify exact bytes")
    func jsUint8ArrayRoundTrip() async {
        let mockTask = MockJSWebSocketTask()
        let ws = makeWebSocket(task: mockTask)!
        ws.handleEvent(.open(negotiatedProtocol: nil))

        async let sent = mockTask.expectSend(count: 1)
        let jsArray = context.evaluateScript("new Uint8Array([72, 101, 108, 108, 111])")!
        ws.send(jsArray)
        let messages = await sent

        #expect(messages.count == 1)
        if case .data(let data) = messages.first {
            #expect(Array(data) == [72, 101, 108, 108, 111])
            #expect(String(data: data, encoding: .utf8) == "Hello")
        } else {
            Issue.record("Expected data message")
        }
    }

    @Test("Receive binary and read back as Uint8Array in JS")
    func receiveBinaryReadAsUint8Array() {
        let ws = makeWebSocket()!
        ws.binaryType = "arraybuffer"
        ws.handleEvent(.open(negotiatedProtocol: nil))

        context.evaluateScript("""
            var receivedValues = [];
            var receivedLength = 0;
        """)
        ws.onmessage = context.evaluateScript("""
            (function(e) {
                var view = new Uint8Array(e.data);
                receivedLength = view.length;
                for (var i = 0; i < view.length; i++) {
                    receivedValues.push(view[i]);
                }
            })
        """)

        ws.handleEvent(.message(.binary(Data([10, 20, 30]))))

        #expect(context.evaluateScript("receivedLength").toInt32() == 3)
        #expect(context.evaluateScript("receivedValues[0]").toInt32() == 10)
        #expect(context.evaluateScript("receivedValues[1]").toInt32() == 20)
        #expect(context.evaluateScript("receivedValues[2]").toInt32() == 30)
    }

    @Test("Receive binary as Blob instance in JS")
    func receiveBinaryAsBlob() {
        let ws = makeWebSocket()!
        ws.handleEvent(.open(negotiatedProtocol: nil))

        context.evaluateScript("var isBlob = false; var hasSize = false;")
        ws.onmessage = context.evaluateScript("""
            (function(e) {
                isBlob = e.data instanceof Blob;
                hasSize = typeof e.data.size === 'number';
            })
        """)

        let data = Data(repeating: 0xAB, count: 100)
        ws.handleEvent(.message(.binary(data)))

        #expect(context.evaluateScript("isBlob").toBool() == true)
        #expect(context.evaluateScript("hasSize").toBool() == true)
    }

    @Test("JS DataView fill ArrayBuffer, send, verify bytes")
    func jsDataViewRoundTrip() async {
        let mockTask = MockJSWebSocketTask()
        let ws = makeWebSocket(task: mockTask)!
        ws.handleEvent(.open(negotiatedProtocol: nil))

        async let sent = mockTask.expectSend(count: 1)
        let buf = context.evaluateScript("""
            (function() {
                var buf = new ArrayBuffer(4);
                var view = new DataView(buf);
                view.setUint8(0, 0xDE);
                view.setUint8(1, 0xAD);
                view.setUint8(2, 0xBE);
                view.setUint8(3, 0xEF);
                return buf;
            })()
        """)!
        ws.send(buf)
        let messages = await sent

        #expect(messages.count == 1)
        if case .data(let data) = messages.first {
            #expect(Array(data) == [0xDE, 0xAD, 0xBE, 0xEF])
        } else {
            Issue.record("Expected data message")
        }
    }

    @Test("Send multiple messages in sequence")
    func sendMultipleMessages() async {
        let mockTask = MockJSWebSocketTask()
        let ws = makeWebSocket(task: mockTask)!
        ws.handleEvent(.open(negotiatedProtocol: nil))

        async let sent = mockTask.expectSend(count: 3)
        ws.send(JSValue(object: "first", in: context))
        ws.send(JSValue(object: "second", in: context))
        ws.send(context.evaluateScript("new Uint8Array([1, 2])")!)
        let messages = await sent

        #expect(messages.count == 3)
        if case .string(let text) = messages[0] { #expect(text == "first") }
        if case .string(let text) = messages[1] { #expect(text == "second") }
        if case .data(let data) = messages[2] { #expect(Array(data) == [1, 2]) }
    }

    @Test("Receive multiple binary messages preserves order and data")
    func receiveMultipleBinaryMessages() {
        let ws = makeWebSocket()!
        ws.binaryType = "arraybuffer"
        ws.handleEvent(.open(negotiatedProtocol: nil))

        context.evaluateScript("var messages = [];")
        ws.onmessage = context.evaluateScript("""
            (function(e) {
                var view = new Uint8Array(e.data);
                var arr = [];
                for (var i = 0; i < view.length; i++) arr.push(view[i]);
                messages.push(arr);
            })
        """)

        ws.handleEvent(.message(.binary(Data([1, 2]))))
        ws.handleEvent(.message(.binary(Data([3, 4, 5]))))
        ws.handleEvent(.message(.binary(Data([6]))))

        #expect(context.evaluateScript("messages.length").toInt32() == 3)
        #expect(context.evaluateScript("messages[0].length").toInt32() == 2)
        #expect(context.evaluateScript("messages[0][0]").toInt32() == 1)
        #expect(context.evaluateScript("messages[0][1]").toInt32() == 2)
        #expect(context.evaluateScript("messages[1].length").toInt32() == 3)
        #expect(context.evaluateScript("messages[1][0]").toInt32() == 3)
        #expect(context.evaluateScript("messages[2][0]").toInt32() == 6)
    }

    @Test("Mixed text and binary messages dispatch correctly")
    func mixedTextAndBinaryMessages() {
        let ws = makeWebSocket()!
        ws.binaryType = "arraybuffer"
        ws.handleEvent(.open(negotiatedProtocol: nil))

        context.evaluateScript("var results = [];")
        ws.onmessage = context.evaluateScript("""
            (function(e) {
                if (typeof e.data === 'string') {
                    results.push('text:' + e.data);
                } else {
                    results.push('binary:' + new Uint8Array(e.data).length);
                }
            })
        """)

        ws.handleEvent(.message(.text("hello")))
        ws.handleEvent(.message(.binary(Data([1, 2, 3]))))
        ws.handleEvent(.message(.text("world")))

        #expect(context.evaluateScript("results[0]").toString() == "text:hello")
        #expect(context.evaluateScript("results[1]").toString() == "binary:3")
        #expect(context.evaluateScript("results[2]").toString() == "text:world")
    }

    // MARK: - Close via send

    @Test("Close dispatches to mock task with code and reason")
    func closeDispatchesToTask() async {
        let mockTask = MockJSWebSocketTask()
        let ws = makeWebSocket(task: mockTask)!
        ws.handleEvent(.open(negotiatedProtocol: nil))

        async let closed = mockTask.expectClose()
        ws.close(JSValue(int32: 1001, in: context), JSValue(object: "going away", in: context))
        let call = await closed

        #expect(call.code == .goingAway)
        let reason = call.reason.flatMap { String(data: $0, encoding: .utf8) }
        #expect(reason == "going away")
    }

    @Test("Close sets readyState to closing")
    func closeSetsClosingState() {
        let ws = makeWebSocket()!
        ws.handleEvent(.open(negotiatedProtocol: nil))

        ws.close(JSValue(int32: 1000, in: context), JSValue(object: "", in: context))

        #expect(ws._readyState == .closing)
    }
}
