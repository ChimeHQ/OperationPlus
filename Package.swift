// swift-tools-version:5.0

import PackageDescription

let package = Package(
    name: "OperationPlus",
    platforms: [.macOS(.v10_10), .iOS(.v8), .tvOS(.v10), .watchOS(.v3)],
    products: [
        .library(name: "OperationPlus", targets: ["OperationPlus"]),
        .library(name: "OperationTestingPlus", targets: ["OperationTestingPlus"]),
    ],
    dependencies: [],
    targets: [
        .target(name: "OperationPlus", dependencies: [], path: "OperationPlus/"),
        .target(name: "OperationTestingPlus", dependencies: ["OperationPlus"], path: "OperationTestingPlus/"),
        .testTarget(name: "OperationPlusTests", dependencies: ["OperationPlus", "OperationTestingPlus"], path: "OperationPlusTests/"),
    ],
    swiftLanguageVersions: [.v5]
)
