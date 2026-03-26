import Testing
import JavaScriptCore
@testable import TONWalletKit

@Suite("TONSwapProviderJSAdapter Tests")
struct TONSwapProviderJSAdapterTests {

    private let context = JSContext()!

    private func makeSUT(
        identifierName: String = "omniston"
    ) -> TONSwapProviderJSAdapter<MockSwapProvider> {
        let provider = MockSwapProvider(
            identifier: TONOmnistonSwapProviderIdentifier(name: identifierName)
        )
        return TONSwapProviderJSAdapter(context: context, swapProvider: provider)
    }

    @Test("type returns swap")
    func typeReturnsSwap() {
        let sut = makeSUT()

        #expect(sut.type == "swap")
    }

    @Test("providerId returns identifier name")
    func providerIdReturnsIdentifierName() {
        let sut = makeSUT(identifierName: "test-provider")

        #expect(sut.providerId == "test-provider")
    }

    @Test("quote rejects when context is deallocated")
    func quoteRejectsWhenDeallocated() async {
        var jsContext: JSContext? = JSContext()!
        let provider = MockSwapProvider(
            identifier: TONOmnistonSwapProviderIdentifier(name: "omniston")
        )
        let sut = TONSwapProviderJSAdapter(context: jsContext!, swapProvider: provider)
        jsContext = nil

        let result = sut.quote(params: JSValue(undefinedIn: context)!)

        await #expect(throws: (any Error).self) {
            try await result.then()
        }
    }

    @Test("swapTransaction rejects when context is deallocated")
    func swapTransactionRejectsWhenDeallocated() async {
        var jsContext: JSContext? = JSContext()!
        let provider = MockSwapProvider(
            identifier: TONOmnistonSwapProviderIdentifier(name: "omniston")
        )
        let sut = TONSwapProviderJSAdapter(context: jsContext!, swapProvider: provider)
        jsContext = nil

        let result = sut.swapTransaction(params: JSValue(undefinedIn: context)!)

        await #expect(throws: (any Error).self) {
            try await result.then()
        }
    }
}
