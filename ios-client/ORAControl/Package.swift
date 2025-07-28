// swift-tools-version: 5.9
import PackageDescription

let package = Package(
    name: "ORAControl",
    platforms: [.iOS(.v17)],
    products: [
        .library(name: "ORAControl", targets: ["ORAControl"])
    ],
    targets: [
        .target(name: "ORAControl", resources: [.process("Resources")]),
    ]
)
