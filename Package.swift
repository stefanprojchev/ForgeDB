// swift-tools-version: 6.3

import PackageDescription

let package = Package(
    name: "ForgeDB",
    platforms: [
        .iOS(.v18),
        .macOS(.v15),
    ],
    products: [
        .library(name: "ForgeDB", targets: ["ForgeDB"]),
        .library(name: "ForgeDBGRDB", targets: ["ForgeDBGRDB"]),
    ],
    dependencies: [
        .package(path: "../ForgeCore"),
        .package(url: "https://github.com/groue/GRDB.swift.git", from: "7.0.0"),
    ],
    targets: [
        .target(
            name: "ForgeDB",
            dependencies: [
                .product(name: "ForgeCore", package: "ForgeCore"),
            ]
        ),
        .target(
            name: "ForgeDBGRDB",
            dependencies: [
                "ForgeDB",
                .product(name: "GRDB", package: "GRDB.swift"),
            ]
        ),
        .testTarget(name: "ForgeDBTests", dependencies: ["ForgeDB"]),
        .testTarget(
            name: "ForgeDBGRDBTests",
            dependencies: ["ForgeDBGRDB"]
        ),
    ],
    swiftLanguageModes: [.v6]
)
