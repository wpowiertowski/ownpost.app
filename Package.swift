// swift-tools-version: 6.2

import PackageDescription

let package = Package(
    name: "OwnPost",
    platforms: [
        .iOS(.v26),
        .macOS(.v26)
    ],
    dependencies: [
        .package(url: "https://github.com/apple/swift-markdown.git", from: "0.5.0"),
    ],
    targets: [
        .executableTarget(
            name: "OwnPost",
            dependencies: [
                .product(name: "Markdown", package: "swift-markdown"),
            ],
            path: "OwnPost",
            swiftSettings: [
                .defaultIsolation(MainActor.self)
            ]
        ),
    ]
)
