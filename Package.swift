// swift-tools-version:5.1
import PackageDescription

let package = Package(
    name: "JPFanAppAdmin",
    platforms: [
       .macOS(.v10_15)
    ],
    products: [
        .executable(name: "Run", targets: ["Run"]),
        .library(name: "App", targets: ["App"]),
    ],
    dependencies: [
        .package(url: "https://github.com/vapor/vapor.git", from: "4.0.0-beta.3"),
        .package(url: "https://github.com/vapor/leaf.git", from: "4.0.0-beta.2"),
        .package(url: "https://github.com/jp-fan-app/swift-client.git", from: "1.4.1"),
        .package(url: "https://github.com/twostraws/SwiftGD.git", from: "2.4.0")
    ],
    targets: [
        .target(name: "App", dependencies: ["Vapor", "Leaf", "JPFanAppClient", "SwiftGD"]),
        .target(name: "Run", dependencies: ["App"]),
        .testTarget(name: "AppTests", dependencies: ["App", "XCTVapor"])
    ]
)

