// swift-tools-version:5.4
// The swift-tools-version declares the minimum version of Swift required to build this package.
import PackageDescription

let package = Package(
    name: "JWT",
    platforms: [
        .iOS(.v9),
        .macOS(.v10_10),
        .watchOS(.v3),
        .tvOS(.v9),
    ],
    products: [
        // Products define the executables and libraries produced by a package, and make them visible to other packages.
        .library(
            name: "JWT",
            targets: ["JWT"]
        )
    ],
    dependencies: [.package(url: "https://github.com/lolgear/Base64", ._branchItem("distribution/swift_package_manager_support"))],
    targets: [
        // Targets are the basic building blocks of a package. A target can define a module or a test suite.
        // Targets can depend on other targets in this package, and on products in packages which this package depends on.
        .target(name: "JWT",
                dependencies: ["Base64"],
                exclude: ["FrameworkSupplement"])
    ]
)
