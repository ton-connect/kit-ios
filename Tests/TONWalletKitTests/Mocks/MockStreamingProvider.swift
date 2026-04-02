import Foundation
import Combine
@testable import TONWalletKit

class MockStreamingProvider: TONStreamingProviderProtocol {
    var balanceSubject = PassthroughSubject<TONBalanceUpdate, any Error>()
    var transactionsSubject = PassthroughSubject<TONTransactionsUpdate, any Error>()
    var jettonsSubject = PassthroughSubject<TONJettonUpdate, any Error>()

    var balanceCalledWith: String?
    var transactionsCalledWith: String?
    var jettonsCalledWith: String?

    func balance(address: String) -> AnyPublisher<TONBalanceUpdate, any Error> {
        balanceCalledWith = address
        return balanceSubject.eraseToAnyPublisher()
    }

    func transactions(address: String) -> AnyPublisher<TONTransactionsUpdate, any Error> {
        transactionsCalledWith = address
        return transactionsSubject.eraseToAnyPublisher()
    }

    func jettons(address: String) -> AnyPublisher<TONJettonUpdate, any Error> {
        jettonsCalledWith = address
        return jettonsSubject.eraseToAnyPublisher()
    }
}
