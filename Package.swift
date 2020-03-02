// swift-tools-version:5.1
import PackageDescription

let package = Package(
    name: "app",
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
        .package(url: "https://github.com/jp-fan-app/swift-client.git", from: "1.3.7")
    ],
    targets: [
        .target(name: "App", dependencies: ["Vapor", "Leaf", "JPFanAppClient"]),
        .target(name: "Run", dependencies: ["App"]),
        .testTarget(name: "AppTests", dependencies: ["App", "XCTVapor"])
    ]
)

