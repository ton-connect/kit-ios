import Foundation
import TONWalletKit

enum SwapProviderOption: String, CaseIterable, Identifiable {
    case omniston = "Omniston"
    case dedust = "DeDust"

    var id: String { rawValue }
}

@MainActor
class SwapViewModel: ObservableObject {
    @Published var fromToken = TONSwapToken(address: "ton", decimals: 9, name: "TON", symbol: "TON")
    @Published var toToken = TONSwapToken(address: "EQCxE6mUtQJKFnGfaROTKOt1lZbDiiX1kCixRv7Nw2Id_sDs", decimals: 6, name: "USDT", symbol: "USDT")
    @Published var fromAmount = ""
    @Published var toAmount = ""
    @Published var isReverseSwap = false
    @Published var selectedProvider: SwapProviderOption = .omniston
    @Published var currentQuote: TONSwapQuote?
    @Published var isLoadingQuote = false
    @Published var isSwapping = false
    @Published var error: String?
    @Published var slippageBps: Int = 100
    @Published var destinationAddress = ""
    @Published var showSettings = false
    @Published var useCustomDestination = false

    let wallet: any TONWalletProtocol

    private var swapManager: TONSwapManagerProtocol?
    private var omnistonIdentifier: TONOmnistonSwapProviderIdentifier?
    private var deDustIdentifier: TONDeDustSwapProviderIdentifier?

    init(wallet: any TONWalletProtocol) {
        self.wallet = wallet
    }

    var fromTokenSymbol: String { fromToken.symbol ?? "???" }
    var toTokenSymbol: String { toToken.symbol ?? "???" }

    var canGetQuote: Bool {
        !fromAmount.isEmpty && Double(fromAmount) ?? 0 > 0 && !isLoadingQuote
    }

    var canSwap: Bool {
        currentQuote != nil && !isSwapping && !isLoadingQuote
    }

    var buttonTitle: String {
        if currentQuote != nil {
            return "Swap \(fromTokenSymbol) for \(toTokenSymbol)"
        }
        return "Get Quote"
    }

    var priceImpactColor: PriceImpactLevel {
        guard let impact = currentQuote?.priceImpact else { return .low }
        if impact > 500 { return .high }
        if impact > 200 { return .medium }
        return .low
    }

    enum PriceImpactLevel {
        case low, medium, high
    }

    func setFromAmount(_ value: String) {
        guard value.isEmpty || Double(value) != nil else { return }
        fromAmount = value
        isReverseSwap = false
        clearQuote()
    }

    func setToAmount(_ value: String) {
        guard value.isEmpty || Double(value) != nil else { return }
        toAmount = value
        isReverseSwap = true
        clearQuote()
    }

    func setProvider(_ provider: SwapProviderOption) {
        selectedProvider = provider
        clearQuote()
    }

    func swapTokens() {
        let temp = fromToken
        fromToken = toToken
        toToken = temp
        fromAmount = ""
        toAmount = ""
        clearQuote()
    }

    func getQuote() {
        let amount = isReverseSwap ? toAmount : fromAmount
        guard !amount.isEmpty, let amountDouble = Double(amount), amountDouble > 0 else { return }

        isLoadingQuote = true
        error = nil

        Task {
            do {
                let manager = try await getSwapManager()
                let quote: TONSwapQuote
                switch selectedProvider {
                case .omniston:
                    let identifier = try await getOmnistonIdentifier()
                    let params = TONSwapQuoteParams<TONOmnistonProviderOptions>(
                        amount: amount,
                        from: fromToken,
                        to: toToken,
                        network: TONNetwork(chainId: "-239"),
                        slippageBps: Double(slippageBps),
                        maxOutgoingMessages: 4,
                        isReverseSwap: isReverseSwap
                    )
                    quote = try await manager.quote(params: params, identifier: identifier)
                case .dedust:
                    let identifier = try await getDeDustIdentifier()
                    let params = TONSwapQuoteParams<TONDeDustProviderOptions>(
                        amount: amount,
                        from: fromToken,
                        to: toToken,
                        network: TONNetwork(chainId: "-239"),
                        slippageBps: Double(slippageBps),
                        maxOutgoingMessages: 4,
                        isReverseSwap: isReverseSwap
                    )
                    quote = try await manager.quote(params: params, identifier: identifier)
                }
                currentQuote = quote
                if isReverseSwap {
                    fromAmount = quote.fromAmount
                } else {
                    toAmount = quote.toAmount
                }
            } catch {
                self.error = error.localizedDescription
            }
            isLoadingQuote = false
        }
    }

    func executeSwap() {
        guard let currentQuote, !isSwapping else { return }

        isSwapping = true
        error = nil

        Task {
            do {
                let manager = try await getSwapManager()
                let dest = useCustomDestination && !destinationAddress.isEmpty
                    ? try TONUserFriendlyAddress(value: destinationAddress)
                    : nil

                let tx: TONTransactionRequest
                switch selectedProvider {
                case .omniston:
                    let params = TONSwapParams<AnyCodable>(
                        quote: currentQuote,
                        userAddress: wallet.address,
                        destinationAddress: dest
                    )
                    tx = try await manager.swapTransaction(params: params)
                case .dedust:
                    let params = TONSwapParams<TONDeDustProviderOptions>(
                        quote: currentQuote,
                        userAddress: wallet.address,
                        destinationAddress: dest
                    )
                    tx = try await manager.swapTransaction(params: params)
                }

                try await TONWalletKit.shared().send(transaction: tx, from: wallet)
                clearQuote()
                fromAmount = ""
                toAmount = ""
            } catch {
                self.error = error.localizedDescription
            }
            isSwapping = false
        }
    }

    func buttonAction() {
        if currentQuote != nil {
            executeSwap()
        } else {
            getQuote()
        }
    }

    private func clearQuote() {
        currentQuote = nil
        error = nil
    }

    private func getSwapManager() async throws -> TONSwapManagerProtocol {
        if let swapManager { return swapManager }
        let kit = try await TONWalletKit.shared()
        let manager = try await kit.swap()

        let omniston = try await kit.omnistoneSwapProvider(config: nil)
        try manager.register(provider: omniston)
        omnistonIdentifier = omniston.identifier

        let deDust = try await kit.dedustSwapProvider(config: nil)
        try manager.register(provider: deDust)
        deDustIdentifier = deDust.identifier

        try manager.set(defaultProviderId: omniston.identifier)

        swapManager = manager
        return manager
    }

    private func getOmnistonIdentifier() async throws -> TONOmnistonSwapProviderIdentifier {
        if let omnistonIdentifier { return omnistonIdentifier }
        _ = try await getSwapManager()
        return omnistonIdentifier!
    }

    private func getDeDustIdentifier() async throws -> TONDeDustSwapProviderIdentifier {
        if let deDustIdentifier { return deDustIdentifier }
        _ = try await getSwapManager()
        return deDustIdentifier!
    }

}
