// swift-tools-version:5.9
import PackageDescription

let package = Package(
    name: "LCDView",
    platforms: [
        .iOS(.v16),
        .macOS(.v13)
    ],
    products: [
        .library(
            name: "LCDView",
            targets: ["LCDView"]),
    ],
    dependencies: [],
    targets: [
        .target(
            name: "LCDView",
            dependencies: [],
            resources: [
                .process("Resources")
            ]),
        .testTarget(
            name: "LCDViewTests",
            dependencies: ["LCDView"]),
    ]
)