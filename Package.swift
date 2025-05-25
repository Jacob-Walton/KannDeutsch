// swift-tools-version: 6.0

import PackageDescription

let package = Package(
    name: "KannDeutsch",
    platforms: [
        .iOS(.v17),
        .macOS(.v14),
    ],
    products: [
        .library(
            name: "KannDeutsch",
            targets: ["KannDeutsch"]
        ),
    ],
    dependencies: [
        .package(url: "https://github.com/stephencelis/SQLite.swift.git", from: "0.15.0")
    ],
    targets: [
        .target(
            name: "KannDeutsch",
            dependencies: [
                .product(name: "SQLite", package: "SQLite.swift")
            ],
            resources: [
                .copy("Resources/output.db")
            ]
        ),
    ]
)
