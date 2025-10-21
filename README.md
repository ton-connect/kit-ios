# iOS TONWalletKit

Swift Package providing TON wallet capabilities for iOS and macOS.

- Minimum: iOS 14, macOS 11

## Installation
#### Xcode
File > Add Packages… and enter https://github.com/ton-connect/kit-ios.git. 

Select the TONWalletKit product for your target.

#### Swift package manager

```swift
// In your Package.swift
.dependencies = [
    .package(url: "https://github.com/ton-connect/kit-ios.git", branch: "main")
]
// Then add "TONWalletKit" to your target dependencies
```

## Quick start

#### Initialize TONWalletKit:
```swift
import TONWalletKit

// Create configuration that fits your app
let configuration = TONWalletKitConfiguration(
    network: .testnet,
    walletManifest: TONWalletKitConfiguration.Manifest(
        name: "MyTONWallet",
        appName: "MyTONWalletIdentifier",
        imageUrl: "https://example.com/image.png",
        aboutUrl: "https://example.com/about",
        universalLink: "https://example.com/universal-link",
        bridgeUrl: "https://bridge.tonapi.io/bridge"
    ),
    bridge: TONWalletKitConfiguration.Bridge(bridgeUrl: bridgeURL),
    apiClient: TONWalletKitConfiguration.APIClient(url: <api_client_key>, key: <api_client_key>),
    features: [
        TONWalletKitConfiguration.SendTransactionFeature(maxMessages: 1),
        TONWalletKitConfiguration.SignDataFeature(types: [.text, .binary, .cell]),
    ]
)

// Initialize the kit (choose storage as needed: .memory, .keychain, or .custom(...))
let kit = try await TONWalletKit.initialize(
    configuration: config,
    storage: .memory
)
```

#### Add events listener:
```swift
import TONWalletKit

final class MyAppEventsListener: TONBridgeEventsHandler {
    func handle(event: TONWalletKitEvent) throws {
        print("TONWalletKit event:", event)
    }
}

let events = MyAppEventsListener()
try await kit.add(eventsHandler: events)
```

#### Create and add a v5r1 wallet using mnemonic:
```swift
var mnemonic = TONMnemonic(string: <TON compatible mnemonic>)
let params = TONV5R1WalletParameters(network: .testnet)
let wallet = try await kit.addV5R1Wallet(mnemonic: mnemonic, parameters: params)
```

#### Read wallet address and balance:
```swift
let address = wallet.address
let balance = try await wallet.balance()

print("Address:", address ?? "<none>")
print("Balance:", balance ?? "<unknown>")
```

#### Notes
- For persistent storage across app launches, consider using `.keychain` or `.custom(...)` instead of `.memory` as a storage.
- To add wallets using a secret key or external signer, see the other TONWalletKit addV5R1/addV4R2 overloads.
- Demo app in Demo/TONWalletApp shows a more complete integration.

#### Development (optional)
- If you are developing this package and need to rebuild the JS bridge file:
  - Run: `make js` to build from the bundled walletkit repo
  - Or: `make js WALLETKIT_PATH=<YOUR_LOCAL_PATH>` to build from a local path
