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

    @Test("type is accessible from JS")
    func typeAccessibleFromJS() {
        let sut = makeSUT()
        context.setObject(sut, forKeyedSubscript: "adapter" as NSString)

        let result = context.evaluateScript("adapter.type")

        #expect(result?.toString() == "swap")
    }

    @Test("providerId is accessible from JS")
    func providerIdAccessibleFromJS() {
        let sut = makeSUT(identifierName: "test-provider")
        context.setObject(sut, forKeyedSubscript: "adapter" as NSString)

        let result = context.evaluateScript("adapter.providerId")

        #expect(result?.toString() == "test-provider")
    }

    @Test("quote resolves from JS call")
    func quoteResolvesFromJS() async throws {
        let sut = makeSUT()
        context.setObject(sut, forKeyedSubscript: "adapter" as NSString)

        let promise = context.evaluateScript("""
        adapter.getQuote({
            amount: "1000000000",
            from: { address: "ton", decimals: 9 },
            to: { address: "ton", decimals: 9 },
            network: { chainId: "-239" }
        })
        """)!

        let result = try await promise.then()
        #expect(result.forProperty("providerId")?.toString() == "omniston")
    }

    @Test("adapter works as JS function argument")
    func adapterWorksAsJSFunctionArgument() throws {
        let sut = makeSUT(identifierName: "test-provider")
        context.evaluateScript("function getProviderType(provider) { return provider.type; }")

        let result: String? = try context.getProviderType(sut)

        #expect(result == "swap")
    }

    @Test("swapTransaction resolves from JS call")
    func swapTransactionResolvesFromJS() async throws {
        let sut = makeSUT()
        context.setObject(sut, forKeyedSubscript: "adapter" as NSString)

        let promise = context.evaluateScript("""
        adapter.buildSwapTransaction({
            quote: {
                fromToken: { address: "ton", decimals: 9 },
                toToken: { address: "ton", decimals: 9 },
                rawFromAmount: "1000000000",
                rawToAmount: "1000000",
                fromAmount: "1",
                toAmount: "1",
                rawMinReceived: "990000",
                minReceived: "0.99",
                network: { chainId: "-239" },
                providerId: "omniston"
            },
            userAddress: "EQCrq6urq6urq6urq6urq6urq6urq6urq6urq6urq6urq8Uk"
        })
        """)!

        let result = try await promise.then()
        #expect(result.forProperty("messages")?.isArray == true)
    }
}
