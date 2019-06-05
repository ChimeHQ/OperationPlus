// swift-tools-version:5.0

import PackageDescription

let package = Package(
    name: "OperationPlus",
    platforms: [.macOS("10.10")],
    products: [
        .library(name: "OperationPlus", targets: ["OperationPlus"]),
        .library(name: "OperationTestingPlus", targets: ["OperationTestingPlus"]),
    ],
    dependencies: [],
    targets: [
        .target(name: "OperationPlus", dependencies: [], path: "OperationPlus/"),
        .target(name: "OperationTestingPlus", dependencies: ["OperationPlus"], path: "OperationTestingPlus/"),
        .testTarget(name: "OperationPlusTests", dependencies: ["OperationPlus", "OperationTestingPlus"], path: "OperationPlusTests/"),
    ]
)
