// swift-tools-version:5.0

import PackageDescription

let package = Package(
    name: "OperationPlus",
    platforms: [.macOS(.v10_10), .iOS(.v9), .tvOS(.v10), .watchOS(.v3)],
    products: [
        .library(name: "OperationPlus", targets: ["OperationPlus"]),
        .library(name: "OperationTestingPlus", targets: ["OperationTestingPlus"]),
    ],
    dependencies: [],
    targets: [
        .target(name: "OperationPlus", dependencies: []),
        .target(name: "OperationTestingPlus", dependencies: ["OperationPlus"]),
        .testTarget(name: "OperationPlusTests", dependencies: ["OperationPlus", "OperationTestingPlus"]),
    ],
    swiftLanguageVersions: [.v5]
)
