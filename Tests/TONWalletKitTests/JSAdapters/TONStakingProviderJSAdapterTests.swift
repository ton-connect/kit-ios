import Testing
import JavaScriptCore
@testable import TONWalletKit

@Suite("TONStakingProviderJSAdapter Tests")
struct TONStakingProviderJSAdapterTests {

    private let context = JSContext()!

    private func makeSUT(
        identifierName: String = "tonstakers"
    ) -> TONStakingProviderJSAdapter<MockStakingProvider> {
        let provider = MockStakingProvider(
            identifier: TONTonStakersStakingProviderIdentifier(name: identifierName)
        )
        return TONStakingProviderJSAdapter(context: context, stakingProvider: provider)
    }

    @Test("type returns staking")
    func typeReturnsStaking() {
        let sut = makeSUT()

        #expect(sut.type == "staking")
    }

    @Test("providerId returns identifier name")
    func providerIdReturnsIdentifierName() {
        let sut = makeSUT(identifierName: "test-provider")

        #expect(sut.providerId == "test-provider")
    }

    @Test("quote rejects when context is deallocated")
    func quoteRejectsWhenDeallocated() async {
        var jsContext: JSContext? = JSContext()!
        let provider = MockStakingProvider(
            identifier: TONTonStakersStakingProviderIdentifier(name: "tonstakers")
        )
        let sut = TONStakingProviderJSAdapter(context: jsContext!, stakingProvider: provider)
        jsContext = nil

        let result = sut.quote(params: JSValue(undefinedIn: context)!)

        await #expect(throws: (any Error).self) {
            try await result.then()
        }
    }

    @Test("stakeTransaction rejects when context is deallocated")
    func stakeTransactionRejectsWhenDeallocated() async {
        var jsContext: JSContext? = JSContext()!
        let provider = MockStakingProvider(
            identifier: TONTonStakersStakingProviderIdentifier(name: "tonstakers")
        )
        let sut = TONStakingProviderJSAdapter(context: jsContext!, stakingProvider: provider)
        jsContext = nil

        let result = sut.stakeTransaction(params: JSValue(undefinedIn: context)!)

        await #expect(throws: (any Error).self) {
            try await result.then()
        }
    }

    @Test("stakedBalance rejects when context is deallocated")
    func stakedBalanceRejectsWhenDeallocated() async {
        var jsContext: JSContext? = JSContext()!
        let provider = MockStakingProvider(
            identifier: TONTonStakersStakingProviderIdentifier(name: "tonstakers")
        )
        let sut = TONStakingProviderJSAdapter(context: jsContext!, stakingProvider: provider)
        jsContext = nil

        let result = sut.stakedBalance(
            userAddress: JSValue(undefinedIn: context)!,
            network: JSValue(undefinedIn: context)!
        )

        await #expect(throws: (any Error).self) {
            try await result.then()
        }
    }

    @Test("stakingProviderInfo rejects when context is deallocated")
    func stakingProviderInfoRejectsWhenDeallocated() async {
        var jsContext: JSContext? = JSContext()!
        let provider = MockStakingProvider(
            identifier: TONTonStakersStakingProviderIdentifier(name: "tonstakers")
        )
        let sut = TONStakingProviderJSAdapter(context: jsContext!, stakingProvider: provider)
        jsContext = nil

        let result = sut.stakingProviderInfo(network: JSValue(undefinedIn: context)!)

        await #expect(throws: (any Error).self) {
            try await result.then()
        }
    }

    @Test("supportedUnstakeModes returns undefined when context is deallocated")
    func supportedUnstakeModesReturnsUndefinedWhenDeallocated() {
        var jsContext: JSContext? = JSContext()!
        let provider = MockStakingProvider(
            identifier: TONTonStakersStakingProviderIdentifier(name: "tonstakers")
        )
        let sut = TONStakingProviderJSAdapter(context: jsContext!, stakingProvider: provider)
        jsContext = nil

        let result = sut.supportedUnstakeModes()

        #expect(result.isUndefined)
    }

    @Test("type is accessible from JS")
    func typeAccessibleFromJS() {
        let sut = makeSUT()
        context.evaluateScript("function getType(p) { return p.type; }")

        let result: String? = try? context.getType(sut)

        #expect(result == "staking")
    }

    @Test("providerId is accessible from JS")
    func providerIdAccessibleFromJS() {
        let sut = makeSUT(identifierName: "test-provider")
        context.evaluateScript("function getProviderId(p) { return p.providerId; }")

        let result: String? = try? context.getProviderId(sut)

        #expect(result == "test-provider")
    }

    @Test("quote resolves from JS call")
    func quoteResolvesFromJS() async throws {
        let sut = makeSUT()

        context.evaluateScript("""
        function callGetQuote(adapter) {
            return adapter.getQuote({
                direction: "stake",
                amount: "1000000000"
            });
        }
        """)

        let result: JSValue = try await context.callGetQuote(sut)
        let providerId: String? = result.providerId
        #expect(providerId == "tonstakers")
    }

    @Test("stakeTransaction resolves from JS call")
    func stakeTransactionResolvesFromJS() async throws {
        let sut = makeSUT()

        context.evaluateScript("""
        function callBuildStakeTransaction(adapter) {
            return adapter.buildStakeTransaction({
                quote: {
                    direction: "stake",
                    amountIn: "1000000000",
                    amountOut: "950000000",
                    network: { chainId: "-239" },
                    providerId: "tonstakers"
                },
                userAddress: "EQCrq6urq6urq6urq6urq6urq6urq6urq6urq6urq6urq8Uk"
            });
        }
        """)

        let result: JSValue = try await context.callBuildStakeTransaction(sut)
        let messages: JSValue? = result.messages
        #expect(messages?.isArray == true)
    }

    @Test("stakedBalance resolves from JS call")
    func stakedBalanceResolvesFromJS() async throws {
        let sut = makeSUT()

        context.evaluateScript("""
        function callGetStakedBalance(adapter) {
            return adapter.getStakedBalance(
                "EQCrq6urq6urq6urq6urq6urq6urq6urq6urq6urq6urq8Uk",
                { chainId: "-239" }
            );
        }
        """)

        let result: JSValue = try await context.callGetStakedBalance(sut)
        let providerId: String? = result.providerId
        #expect(providerId == "tonstakers")
    }

    @Test("stakingProviderInfo resolves from JS call")
    func stakingProviderInfoResolvesFromJS() async throws {
        let sut = makeSUT()

        context.evaluateScript("""
        function callGetStakingProviderInfo(adapter) {
            return adapter.getStakingProviderInfo({ chainId: "-239" });
        }
        """)

        let result: JSValue = try await context.callGetStakingProviderInfo(sut)
        let apy: Int? = result.apy
        #expect(apy == 500)
    }

    @Test("supportedUnstakeModes returns first mode from JS")
    func supportedUnstakeModesReturnsFromJS() throws {
        let sut = makeSUT()
        context.evaluateScript("function callFirstMode(adapter) { return adapter.getSupportedUnstakeModes(); }")

        let result: [TONUnstakeMode] = try context.callFirstMode(sut)

        debugPrint("SAdsad")
        #expect(result[0] == .instant)
    }

    @Test("adapter works as JS function argument")
    func adapterWorksAsJSFunctionArgument() throws {
        let sut = makeSUT(identifierName: "test-provider")
        context.evaluateScript("function getProviderType(provider) { return provider.type; }")

        let result: String? = try context.getProviderType(sut)

        #expect(result == "staking")
    }
}
