// swift-tools-version:5.3
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "PapyrusAlamofire",
    platforms: [
        .macOS(.v10_15),
        .iOS(.v13),
    ],
    products: [
        .library(
            name: "PapyrusAlamofire",
            targets: ["PapyrusAlamofire"]),
    ],
    dependencies: [
        .package(url: "https://github.com/Alamofire/Alamofire", from: "5.0.0"),
        .package(url: "https://github.com/alchemy-swift/papyrus", .branch("main")),
    ],
    targets: [
        .target(
            name: "PapyrusAlamofire",
            dependencies: [
                .product(name: "Papyrus", package: "papyrus"),
                .product(name: "Alamofire", package: "Alamofire")
            ]),
    ]
)
