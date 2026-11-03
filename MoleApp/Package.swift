// swift-tools-version: 5.9
import PackageDescription

let package = Package(
    name: "MoleApp",
    platforms: [.macOS(.v14)],
    products: [
        .executable(name: "MoleApp", targets: ["MoleApp"]),
    ],
    targets: [
        .executableTarget(name: "MoleApp", path: "Sources"),
    ]
)
