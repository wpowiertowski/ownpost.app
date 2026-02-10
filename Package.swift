// swift-tools-version: 6.0

import PackageDescription

let package = Package(
    name: "OwnPost",
    platforms: [
        .iOS(.v18),
        .macOS(.v15)
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
            path: "OwnPost"
        ),
    ]
)
