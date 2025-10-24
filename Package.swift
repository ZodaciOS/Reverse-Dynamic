// swift-tools-version: 6.1
import PackageDescription

let package = Package(
    name: "ReverseDynamic",
    platforms: [
        .iOS("14.0")
    ],
    products: [
        .library(name: "ReverseDynamic", type: .dynamic, targets: ["ReverseDynamic"])
    ],
    targets: [
        .target(
            name: "ReverseDynamic",
            path: "Sources/ReverseDynamic",
            resources: [
                .copy("Assets")
            ]
        ),
        .executableTarget(
            name: "SampleHost",
            path: "SampleHost/App",
            dependencies: ["ReverseDynamic"]
        )
    ]
)
