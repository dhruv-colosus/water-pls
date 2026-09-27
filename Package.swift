// swift-tools-version: 5.9
import PackageDescription
let package = Package(
    name: "WaterPls",
    platforms: [.macOS(.v14)],
    products: [.executable(name: "WaterPls", targets: ["WaterPls"])],
    targets: [.executableTarget(name: "WaterPls"), .testTarget(name: "WaterPlsTests", dependencies: ["WaterPls"])]
)
