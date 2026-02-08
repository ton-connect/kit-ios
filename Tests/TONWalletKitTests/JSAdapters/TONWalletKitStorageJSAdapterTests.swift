//
//  TONWalletKitStorageJSAdapterTests.swift
//  TONWalletKit
//
//  Created by Nikita Rodionov on 08.02.2026.
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

@Suite("TONWalletKitStorageJSAdapter Tests")
struct TONWalletKitStorageJSAdapterTests {

    private let context = JSContext()!

    private func makeSUT(
        storage: MockStorage = MockStorage()
    ) -> (sut: TONWalletKitStorageJSAdapter, storage: MockStorage) {
        let sut = TONWalletKitStorageJSAdapter(context: context, storage: storage)
        return (sut, storage)
    }

    private func resolvePromise(_ promise: JSValue) -> JSValue? {
        context.setObject(promise, forKeyedSubscript: "__promise" as NSString)
        context.evaluateScript("var __resolved = '__SENTINEL__'; __promise.then(function(v) { __resolved = v; })")
        let result = context.objectForKeyedSubscript("__resolved")
        if result?.toString() == "__SENTINEL__" { return nil }
        return result
    }

    @Test("Set delegates to storage with correct key and value")
    func saveDelegates() {
        let (sut, storage) = makeSUT()

        _ = sut.set(key: "testKey", value: "testValue")

        #expect(storage.setCalls.count == 1)
        #expect(storage.setCalls.first?.key == "testKey")
        #expect(storage.setCalls.first?.value == "testValue")
    }

    @Test("Set resolves with undefined")
    func saveResolvesWithUndefined() {
        let (sut, _) = makeSUT()

        let result = sut.set(key: "key", value: "value")
        let resolved = resolvePromise(result)

        #expect(resolved?.isUndefined == true)
    }

    @Test("Set rejects when storage throws")
    func saveRejectsWhenStorageThrows() async {
        let storage = MockStorage()
        storage.shouldThrow = true
        let (sut, _) = makeSUT(storage: storage)

        let result = sut.set(key: "key", value: "value")

        await #expect(throws: (any Error).self) {
            try await result.then()
        }
    }

    @Test("Get delegates to storage with correct key")
    func getDelegates() {
        let storage = MockStorage()
        storage.store["myKey"] = "myValue"
        let (sut, _) = makeSUT(storage: storage)

        _ = sut.get(key: "myKey")

        #expect(storage.getCalls == ["myKey"])
    }

    @Test("Get resolves with stored value")
    func getResolvesWithStoredValue() {
        let storage = MockStorage()
        storage.store["myKey"] = "myValue"
        let (sut, _) = makeSUT(storage: storage)

        let result = sut.get(key: "myKey")
        let resolved = resolvePromise(result)

        #expect(resolved?.toString() == "myValue")
    }

    @Test("Get resolves with null for missing key")
    func getResolvesWithNullForMissingKey() {
        let (sut, _) = makeSUT()

        let result = sut.get(key: "nonExistent")
        let resolved = resolvePromise(result)

        #expect(resolved?.isNull == true)
    }

    @Test("Get rejects when storage throws")
    func getRejectsWhenStorageThrows() async {
        let storage = MockStorage()
        storage.shouldThrow = true
        let (sut, _) = makeSUT(storage: storage)

        let result = sut.get(key: "key")

        await #expect(throws: (any Error).self) {
            try await result.then()
        }
    }

    @Test("Remove delegates to storage with correct key")
    func removeDelegates() {
        let (sut, storage) = makeSUT()

        _ = sut.remove(key: "removeMe")

        #expect(storage.removeCalls == ["removeMe"])
    }

    @Test("Remove resolves with undefined")
    func removeResolvesWithUndefined() {
        let (sut, _) = makeSUT()

        let result = sut.remove(key: "key")
        let resolved = resolvePromise(result)

        #expect(resolved?.isUndefined == true)
    }

    @Test("Remove rejects when storage throws")
    func removeRejectsWhenStorageThrows() async {
        let storage = MockStorage()
        storage.shouldThrow = true
        let (sut, _) = makeSUT(storage: storage)

        let result = sut.remove(key: "key")

        await #expect(throws: (any Error).self) {
            try await result.then()
        }
    }

    @Test("Clear delegates to storage")
    func clearDelegates() {
        let (sut, storage) = makeSUT()

        _ = sut.clear()

        #expect(storage.clearCallCount == 1)
    }

    @Test("Clear resolves with undefined")
    func clearResolvesWithUndefined() {
        let (sut, _) = makeSUT()

        let result = sut.clear()
        let resolved = resolvePromise(result)

        #expect(resolved?.isUndefined == true)
    }

    @Test("set rejects when context is deallocated")
    func setRejectsWhenDeallocated() async {
        let storage = MockStorage()
        var jsContext: JSContext? = JSContext()!
        let sut = TONWalletKitStorageJSAdapter(context: jsContext!, storage: storage)
        jsContext = nil

        let result = sut.set(key: "key", value: "value")

        await #expect(throws: (any Error).self) {
            try await result.then()
        }
    }

    @Test("get rejects when context is deallocated")
    func getRejectsWhenDeallocated() async {
        let storage = MockStorage()
        var jsContext: JSContext? = JSContext()!
        let sut = TONWalletKitStorageJSAdapter(context: jsContext!, storage: storage)
        jsContext = nil

        let result = sut.get(key: "key")

        await #expect(throws: (any Error).self) {
            try await result.then()
        }
    }

    @Test("remove rejects when context is deallocated")
    func removeRejectsWhenDeallocated() async {
        let storage = MockStorage()
        var jsContext: JSContext? = JSContext()!
        let sut = TONWalletKitStorageJSAdapter(context: jsContext!, storage: storage)
        jsContext = nil

        let result = sut.remove(key: "key")

        await #expect(throws: (any Error).self) {
            try await result.then()
        }
    }

    @Test("clear rejects when context is deallocated")
    func clearRejectsWhenDeallocated() async {
        let storage = MockStorage()
        var jsContext: JSContext? = JSContext()!
        let sut = TONWalletKitStorageJSAdapter(context: jsContext!, storage: storage)
        jsContext = nil

        let result = sut.clear()

        await #expect(throws: (any Error).self) {
            try await result.then()
        }
    }

    @Test("Clear rejects when storage throws")
    func clearRejectsWhenStorageThrows() async {
        let storage = MockStorage()
        storage.shouldThrow = true
        let (sut, _) = makeSUT(storage: storage)

        let result = sut.clear()

        await #expect(throws: (any Error).self) {
            try await result.then()
        }
    }
}
