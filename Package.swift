// swift-tools-version: 6.1
import PackageDescription

let package = Package(
    name: "ReverseDynamic",
    platforms: [
        .iOS(.v14)
    ],
    products: [
        .library(
            name: "ReverseDynamic",
            type: .dynamic,
            targets: ["ReverseDynamic"]
        ),
    ],
    targets: [
        .target(
            name: "ReverseDynamic",
            path: "Sources"
        ),
        .executableTarget(
            name: "SampleHost",
            dependencies: ["ReverseDynamic"],
            path: "SampleHost/App"
        )
    ]
)
