// swift-tools-version: 5.9
import PackageDescription

let package = Package(
    name: "Caos",
    platforms: [.iOS(.v16), .macOS(.v13)],
    products: [
        .library(name: "Caos", targets: ["Caos"]),
        .executable(name: "caos-lint", targets: ["CaosLint"]),
    ],
    targets: [
        .target(
            name: "Caos",
            path: "Sources/Caos",
            swiftSettings: [
                .enableExperimentalFeature("StrictConcurrency"),
            ]
        ),
        .executableTarget(
            name: "CaosLint",
            dependencies: ["Caos"],
            path: "Sources/CaosLint"
        ),
        .testTarget(
            name: "CaosTests",
            dependencies: ["Caos"],
            path: "Tests/CaosTests",
            resources: [.copy("Fixtures"), .process("caos_empty_screens.yaml"), .process("caos_invalid_version.yaml")]
        ),
    ]
)
