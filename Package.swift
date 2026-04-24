// swift-tools-version: 6.0

import PackageDescription

let package = Package(
    name: "sortis-ios",
    platforms: [
        .iOS(.v17),
    ],
    products: [
        .library(
            name: "Sortis",
            targets: ["Sortis"]
        ),
    ],
    targets: [
        .target(
            name: "Sortis",
            path: "Sortis",
            exclude: ["Info.plist"],
            resources: [
                .process("Assets.xcassets"),
            ]
        ),
    ]
)
