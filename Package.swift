// swift-tools-version: 5.9
// NOTE: Stub for SPM recognition. Full implementation in Phase 5.
import PackageDescription

let package = Package(
    name: "Caos",
    platforms: [.iOS(.v16)],
    products: [
        .library(name: "Caos", targets: ["Caos"]),
    ],
    targets: [
        .target(
            name: "Caos",
            path: "Caos/Classes"
        ),
    ]
)
