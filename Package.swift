// swift-tools-version: 6.3
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "PixelPeeper",
    platforms: [
        .macOS(.v14),
        .iOS(.v17),
    ],
    products: [
        .library(
            name: "PixelPeeper",
            targets: ["PixelPeeper"],
        ),
        .executable(
            name: "peep",
            targets: ["PeepCommand"],
        ),
    ],
    dependencies: [
        .package(url: "https://github.com/apple/swift-argument-parser", from: "1.5.0"),
        .package(url: "https://github.com/swiftlang/swift-docc-plugin", from: "1.4.3"),
    ],
    targets: [
        .target(
            name: "PixelPeeper",
        ),
        .executableTarget(
            name: "PeepCommand",
            dependencies: [
                "PixelPeeper",
                .product(name: "ArgumentParser", package: "swift-argument-parser"),
            ],
        ),
        .testTarget(
            name: "PixelPeeperTests",
            dependencies: ["PixelPeeper"],
            resources: [
                .copy("Fixtures"),
            ],
        ),
        .testTarget(
            name: "PeepCommandTests",
            dependencies: [
                "PeepCommand",
                "PixelPeeper",
                .product(name: "ArgumentParser", package: "swift-argument-parser"),
            ],
        ),
    ],
    swiftLanguageModes: [.v6],
)
