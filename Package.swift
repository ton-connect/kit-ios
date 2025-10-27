// swift-tools-version: 6.2
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "TONWalletKit",
    platforms: [
        .iOS(.v14),
        .macOS(.v11),
    ],
    products: [
        // Products define the executables and libraries a package produces, making them visible to other packages.
        .library(
            name: "TONWalletKit",
            targets: ["TONWalletKit"]),
    ],
    targets: [
        // Targets are the basic building blocks of a package, defining a module or a test suite.
        // Targets can depend on other targets in this package and products from dependencies.
        .target(
            name: "TONWalletKit",
            resources: [
                .process("Resources/JS/walletkit-ios-bridge.mjs"),
                .process("JSCore/Polyfilling/Fetch/JS")
            ],
            swiftSettings: [
                .unsafeFlags(["-enable-private-imports"], .when(configuration: .debug)),
            ]
        ),
        .testTarget(
            name: "TONWalletKitTests",
            dependencies: ["TONWalletKit"]
        ),
    ],
    swiftLanguageModes: [.v5]
)
