// swift-tools-version:5.0
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "Yarp",
    products: [
        .library(name: "Yarp", targets: ["Yarp"]),
    ],
    targets: [
        .target(name: "Yarp", path: "Source"),
        .testTarget(name: "YarpTests", dependencies: ["Yarp"]),
    ]
)
