// swift-tools-version:5.3
import PackageDescription

let package = Package(
    name: "Interceptor",
    products: [
        .library(
            name: "Interceptor",
            targets: ["Interceptor"]),
    ],
    dependencies: [
        .package(url: "https://github.com/bfernandesbfs/Responder.git", .upToNextMajor(from: "0.0.1"))
    ],
    targets: [
        .target(
            name: "Interceptor",
            dependencies: ["Responder"]),
        .testTarget(
            name: "InterceptorTests",
            dependencies: ["Interceptor"]),
    ]
)
