//
//  MockJSWebSocketTask.swift
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

import Foundation
@testable import TONWalletKit

@JSWebSocketActor
final class MockJSWebSocketTask: JSWebSocketTaskProtocol {
    var sentMessages: [URLSessionWebSocketTask.Message] = []
    var closeCalls: [(code: URLSessionWebSocketTask.CloseCode, reason: Data?)] = []
    var cancelCalled = false

    private var eventContinuation: AsyncStream<JSWebSocketEvent>.Continuation?
    nonisolated(unsafe) private var sendContinuation: AsyncStream<URLSessionWebSocketTask.Message>.Continuation?
    nonisolated(unsafe) private var closeContinuation: AsyncStream<(code: URLSessionWebSocketTask.CloseCode, reason: Data?)>.Continuation?

    nonisolated init() {}

    func start() -> AsyncStream<JSWebSocketEvent> {
        AsyncStream { self.eventContinuation = $0 }
    }

    func yield(_ event: JSWebSocketEvent) {
        eventContinuation?.yield(event)
    }

    func finish() {
        eventContinuation?.finish()
    }

    func send(_ message: URLSessionWebSocketTask.Message) async throws {
        sentMessages.append(message)
        sendContinuation?.yield(message)
    }

    func close(code: URLSessionWebSocketTask.CloseCode, reason: Data?) {
        closeCalls.append((code, reason))
        closeContinuation?.yield((code, reason))
    }

    func cancel() {
        cancelCalled = true
    }

    nonisolated func expectSend(count: Int = 1) async -> [URLSessionWebSocketTask.Message] {
        var received: [URLSessionWebSocketTask.Message] = []
        let stream = AsyncStream<URLSessionWebSocketTask.Message> { self.sendContinuation = $0 }

        for await message in stream {
            received.append(message)
            if received.count >= count { break }
        }

        return received
    }

    nonisolated func expectClose() async -> (code: URLSessionWebSocketTask.CloseCode, reason: Data?) {
        let stream = AsyncStream<(code: URLSessionWebSocketTask.CloseCode, reason: Data?)> { self.closeContinuation = $0 }

        for await call in stream {
            return call
        }

        fatalError("expectClose stream ended without receiving a close call")
    }
}
