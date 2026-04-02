import Testing
import Foundation
import Combine
import JavaScriptCore
@testable import TONWalletKit

@Suite("TONStreamingProvider Tests")
struct TONStreamingProviderTests {

    private func makeSUT() -> (sut: TONStreamingProvider, mock: MockJSDynamicObject) {
        let mock = MockJSDynamicObject()
        let sut = TONStreamingProvider(jsObject: mock)
        return (sut, mock)
    }

    @Test("balance calls watchBalance with correct address")
    func balanceCallsWatchBalance() {
        let (sut, mock) = makeSUT()

        let cancellable = sut.balance(address: "test-address").sink(
            receiveCompletion: { _ in },
            receiveValue: { _ in }
        )

        #expect(mock.callRecords.count == 1)
        #expect(mock.callRecords[0].path == "watchBalance")
        #expect(mock.callRecords[0].args[0] as? String == "test-address")
        cancellable.cancel()
    }

    @Test("transactions calls watchTransactions with correct address")
    func transactionsCallsWatchTransactions() {
        let (sut, mock) = makeSUT()

        let cancellable = sut.transactions(address: "test-address").sink(
            receiveCompletion: { _ in },
            receiveValue: { _ in }
        )

        #expect(mock.callRecords.count == 1)
        #expect(mock.callRecords[0].path == "watchTransactions")
        #expect(mock.callRecords[0].args[0] as? String == "test-address")
        cancellable.cancel()
    }

    @Test("jettons calls watchJettons with correct address")
    func jettonsCallsWatchJettons() {
        let (sut, mock) = makeSUT()

        let cancellable = sut.jettons(address: "test-address").sink(
            receiveCompletion: { _ in },
            receiveValue: { _ in }
        )

        #expect(mock.callRecords.count == 1)
        #expect(mock.callRecords[0].path == "watchJettons")
        #expect(mock.callRecords[0].args[0] as? String == "test-address")
        cancellable.cancel()
    }

    @Test("balance delivers values through JS handler")
    func balanceDeliversValues() throws {
        let (sut, mock) = makeSUT()
        let update = MockStreamingData.balanceUpdate(status: .confirmed, balance: "2.5")

        var received: TONBalanceUpdate?
        let cancellable = sut.balance(address: "test-address").sink(
            receiveCompletion: { _ in },
            receiveValue: { received = $0 }
        )

        let handler = mock.callRecords[0].args[1] as! JSValue
        let encoded = try update.encode(in: mock.jsContext)
        handler.call(withArguments: [encoded])

        #expect(received?.status == .confirmed)
        #expect(received?.balance == "2.5")
        cancellable.cancel()
    }

    @Test("transactions delivers values through JS handler")
    func transactionsDeliversValues() throws {
        let (sut, mock) = makeSUT()
        let update = MockStreamingData.transactionsUpdate(status: .finalized)

        var received: TONTransactionsUpdate?
        let cancellable = sut.transactions(address: "test-address").sink(
            receiveCompletion: { _ in },
            receiveValue: { received = $0 }
        )

        let handler = mock.callRecords[0].args[1] as! JSValue
        let encoded = try update.encode(in: mock.jsContext)
        handler.call(withArguments: [encoded])

        #expect(received?.status == .finalized)
        #expect(received?.transactions.count == 1)
        cancellable.cancel()
    }

    @Test("jettons delivers values through JS handler")
    func jettonsDeliversValues() throws {
        let (sut, mock) = makeSUT()
        let update = MockStreamingData.jettonUpdate(status: .pending, balance: "50.0")

        var received: TONJettonUpdate?
        let cancellable = sut.jettons(address: "test-address").sink(
            receiveCompletion: { _ in },
            receiveValue: { received = $0 }
        )

        let handler = mock.callRecords[0].args[1] as! JSValue
        let encoded = try update.encode(in: mock.jsContext)
        handler.call(withArguments: [encoded])

        #expect(received?.status == .pending)
        #expect(received?.balance == "50.0")
        cancellable.cancel()
    }

    @Test("balance sends failure when watch throws")
    func balanceSendsFailureOnThrow() {
        let (sut, mock) = makeSUT()
        mock.shouldThrowOnCall = true

        var completionError: (any Error)?
        let cancellable = sut.balance(address: "test-address").sink(
            receiveCompletion: { completion in
                if case .failure(let error) = completion {
                    completionError = error
                }
            },
            receiveValue: { _ in }
        )

        #expect(completionError != nil)
        cancellable.cancel()
    }

    @Test("transactions sends failure when watch throws")
    func transactionsSendsFailureOnThrow() {
        let (sut, mock) = makeSUT()
        mock.shouldThrowOnCall = true

        var completionError: (any Error)?
        let cancellable = sut.transactions(address: "test-address").sink(
            receiveCompletion: { completion in
                if case .failure(let error) = completion {
                    completionError = error
                }
            },
            receiveValue: { _ in }
        )

        #expect(completionError != nil)
        cancellable.cancel()
    }

    @Test("jettons sends failure when watch throws")
    func jettonsSendsFailureOnThrow() {
        let (sut, mock) = makeSUT()
        mock.shouldThrowOnCall = true

        var completionError: (any Error)?
        let cancellable = sut.jettons(address: "test-address").sink(
            receiveCompletion: { completion in
                if case .failure(let error) = completion {
                    completionError = error
                }
            },
            receiveValue: { _ in }
        )

        #expect(completionError != nil)
        cancellable.cancel()
    }

    @Test("balance cancel stops delivering values")
    func balanceCancelStopsDelivery() throws {
        let (sut, mock) = makeSUT()
        let update = MockStreamingData.balanceUpdate()

        var receivedCount = 0
        let cancellable = sut.balance(address: "test-address").sink(
            receiveCompletion: { _ in },
            receiveValue: { _ in receivedCount += 1 }
        )

        let handler = mock.callRecords[0].args[1] as! JSValue
        let encoded = try update.encode(in: mock.jsContext)

        handler.call(withArguments: [encoded])
        #expect(receivedCount == 1)

        cancellable.cancel()

        handler.call(withArguments: [encoded])
        #expect(receivedCount == 1)
    }

    @Test("transactions cancel stops delivering values")
    func transactionsCancelStopsDelivery() throws {
        let (sut, mock) = makeSUT()
        let update = MockStreamingData.transactionsUpdate()

        var receivedCount = 0
        let cancellable = sut.transactions(address: "test-address").sink(
            receiveCompletion: { _ in },
            receiveValue: { _ in receivedCount += 1 }
        )

        let handler = mock.callRecords[0].args[1] as! JSValue
        let encoded = try update.encode(in: mock.jsContext)

        handler.call(withArguments: [encoded])
        #expect(receivedCount == 1)

        cancellable.cancel()

        handler.call(withArguments: [encoded])
        #expect(receivedCount == 1)
    }

    @Test("jettons cancel stops delivering values")
    func jettonsCancelStopsDelivery() throws {
        let (sut, mock) = makeSUT()
        let update = MockStreamingData.jettonUpdate()

        var receivedCount = 0
        let cancellable = sut.jettons(address: "test-address").sink(
            receiveCompletion: { _ in },
            receiveValue: { _ in receivedCount += 1 }
        )

        let handler = mock.callRecords[0].args[1] as! JSValue
        let encoded = try update.encode(in: mock.jsContext)

        handler.call(withArguments: [encoded])
        #expect(receivedCount == 1)

        cancellable.cancel()

        handler.call(withArguments: [encoded])
        #expect(receivedCount == 1)
    }
}
