import Testing
import Foundation
import Combine
import JavaScriptCore
@testable import TONWalletKit

@Suite("TONStreamingManager Tests")
struct TONStreamingManagerTests {

    private let network = TONNetwork(chainId: "-239")

    private func makeSUT() -> (sut: TONStreamingManager, mock: MockJSDynamicObject) {
        let mock = MockJSDynamicObject()
        let sut = TONStreamingManager(jsObject: mock)
        return (sut, mock)
    }

    @Test("hasProvider calls hasProvider on jsObject")
    func hasProviderCallsJS() throws {
        let (sut, mock) = makeSUT()
        mock.stubbedResults["hasProvider"] = true

        let result = try sut.hasProvider(network: network)

        #expect(mock.callRecords.count == 1)
        #expect(mock.callRecords[0].path == "hasProvider")
        #expect(result == true)
    }

    @Test("hasProvider throws when jsObject throws")
    func hasProviderThrows() {
        let (sut, mock) = makeSUT()
        mock.shouldThrowOnCall = true

        #expect(throws: (any Error).self) {
            try sut.hasProvider(network: network)
        }
    }

    @Test("balance calls watchBalance with network and address")
    func balanceCallsWatchBalance() {
        let (sut, mock) = makeSUT()

        let cancellable = sut.balance(network: network, address: "test-address").sink(
            receiveCompletion: { _ in },
            receiveValue: { _ in }
        )

        #expect(mock.callRecords.count == 1)
        #expect(mock.callRecords[0].path == "watchBalance")
        cancellable.cancel()
    }

    @Test("transactions calls watchTransactions with network and address")
    func transactionsCallsWatchTransactions() {
        let (sut, mock) = makeSUT()

        let cancellable = sut.transactions(network: network, address: "test-address").sink(
            receiveCompletion: { _ in },
            receiveValue: { _ in }
        )

        #expect(mock.callRecords.count == 1)
        #expect(mock.callRecords[0].path == "watchTransactions")
        cancellable.cancel()
    }

    @Test("jettons calls watchJettons with network and address")
    func jettonsCallsWatchJettons() {
        let (sut, mock) = makeSUT()

        let cancellable = sut.jettons(network: network, address: "test-address").sink(
            receiveCompletion: { _ in },
            receiveValue: { _ in }
        )

        #expect(mock.callRecords.count == 1)
        #expect(mock.callRecords[0].path == "watchJettons")
        cancellable.cancel()
    }

    @Test("updates calls watch with network, address and types")
    func updatesCallsWatch() {
        let (sut, mock) = makeSUT()

        let cancellable = sut.updates(
            network: network,
            address: "test-address",
            types: [.balance, .transactions]
        ).sink(
            receiveCompletion: { _ in },
            receiveValue: { _ in }
        )

        #expect(mock.callRecords.count == 1)
        #expect(mock.callRecords[0].path == "watch")
        cancellable.cancel()
    }

    @Test("balance delivers values through JS handler")
    func balanceDeliversValues() throws {
        let (sut, mock) = makeSUT()
        let update = MockStreamingData.balanceUpdate(status: .confirmed, balance: "3.0")

        var received: TONBalanceUpdate?
        let cancellable = sut.balance(network: network, address: "test-address").sink(
            receiveCompletion: { _ in },
            receiveValue: { received = $0 }
        )

        let handler = mock.callRecords[0].args[2] as! JSValue
        let encoded = try update.encode(in: mock.jsContext)
        handler.call(withArguments: [encoded])

        #expect(received?.status == .confirmed)
        #expect(received?.balance == "3.0")
        cancellable.cancel()
    }

    @Test("transactions delivers values through JS handler")
    func transactionsDeliversValues() throws {
        let (sut, mock) = makeSUT()
        let update = MockStreamingData.transactionsUpdate(status: .finalized)

        var received: TONTransactionsUpdate?
        let cancellable = sut.transactions(network: network, address: "test-address").sink(
            receiveCompletion: { _ in },
            receiveValue: { received = $0 }
        )

        let handler = mock.callRecords[0].args[2] as! JSValue
        let encoded = try update.encode(in: mock.jsContext)
        handler.call(withArguments: [encoded])

        #expect(received?.status == .finalized)
        #expect(received?.transactions.count == 1)
        cancellable.cancel()
    }

    @Test("jettons delivers values through JS handler")
    func jettonsDeliversValues() throws {
        let (sut, mock) = makeSUT()
        let update = MockStreamingData.jettonUpdate(status: .pending, balance: "99.9")

        var received: TONJettonUpdate?
        let cancellable = sut.jettons(network: network, address: "test-address").sink(
            receiveCompletion: { _ in },
            receiveValue: { received = $0 }
        )

        let handler = mock.callRecords[0].args[2] as! JSValue
        let encoded = try update.encode(in: mock.jsContext)
        handler.call(withArguments: [encoded])

        #expect(received?.status == .pending)
        #expect(received?.balance == "99.9")
        cancellable.cancel()
    }

    @Test("updates delivers balance update through JS handler")
    func updatesDeliversBalanceUpdate() throws {
        let (sut, mock) = makeSUT()
        let balanceUpdate = MockStreamingData.balanceUpdate(status: .confirmed)

        var received: TONStreamingUpdate?
        let cancellable = sut.updates(
            network: network,
            address: "test-address",
            types: [.balance]
        ).sink(
            receiveCompletion: { _ in },
            receiveValue: { received = $0 }
        )

        let handler = mock.callRecords[0].args[3] as! JSValue
        let encoded = try balanceUpdate.encode(in: mock.jsContext) as! JSValue
        handler.call(withArguments: [JSValue(undefinedIn: mock.jsContext)!, encoded])

        if case .balance(let update) = received {
            #expect(update.status == .confirmed)
        } else {
            #expect(Bool(false), "Expected .balance update")
        }
        cancellable.cancel()
    }

    @Test("balance sends failure when watch throws")
    func balanceSendsFailureOnThrow() {
        let (sut, mock) = makeSUT()
        mock.shouldThrowOnCall = true

        var completionError: (any Error)?
        let cancellable = sut.balance(network: network, address: "test-address").sink(
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
        let cancellable = sut.transactions(network: network, address: "test-address").sink(
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
        let cancellable = sut.jettons(network: network, address: "test-address").sink(
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

    @Test("updates sends failure when watch throws")
    func updatesSendsFailureOnThrow() {
        let (sut, mock) = makeSUT()
        mock.shouldThrowOnCall = true

        var completionError: (any Error)?
        let cancellable = sut.updates(
            network: network,
            address: "test-address",
            types: [.balance]
        ).sink(
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
        let cancellable = sut.balance(network: network, address: "test-address").sink(
            receiveCompletion: { _ in },
            receiveValue: { _ in receivedCount += 1 }
        )

        let handler = mock.callRecords[0].args[2] as! JSValue
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
        let cancellable = sut.transactions(network: network, address: "test-address").sink(
            receiveCompletion: { _ in },
            receiveValue: { _ in receivedCount += 1 }
        )

        let handler = mock.callRecords[0].args[2] as! JSValue
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
        let cancellable = sut.jettons(network: network, address: "test-address").sink(
            receiveCompletion: { _ in },
            receiveValue: { _ in receivedCount += 1 }
        )

        let handler = mock.callRecords[0].args[2] as! JSValue
        let encoded = try update.encode(in: mock.jsContext)

        handler.call(withArguments: [encoded])
        #expect(receivedCount == 1)

        cancellable.cancel()

        handler.call(withArguments: [encoded])
        #expect(receivedCount == 1)
    }

    @Test("updates cancel stops delivering values")
    func updatesCancelStopsDelivery() throws {
        let (sut, mock) = makeSUT()
        let update = MockStreamingData.balanceUpdate()

        var receivedCount = 0
        let cancellable = sut.updates(
            network: network,
            address: "test-address",
            types: [.balance]
        ).sink(
            receiveCompletion: { _ in },
            receiveValue: { _ in receivedCount += 1 }
        )

        let handler = mock.callRecords[0].args[3] as! JSValue
        let encoded = try update.encode(in: mock.jsContext) as! JSValue

        handler.call(withArguments: [JSValue(undefinedIn: mock.jsContext)!, encoded])
        #expect(receivedCount == 1)

        cancellable.cancel()

        handler.call(withArguments: [JSValue(undefinedIn: mock.jsContext)!, encoded])
        #expect(receivedCount == 1)
    }
}
