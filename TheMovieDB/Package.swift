// swift-tools-version: 5.10
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "TheMovieDB",
    platforms: [
        .iOS(.v15),
        .macOS(.v12),
    ],
    products: [
        .library(name: "TheMovieDB", targets: ["TheMovieDB"]),
    ],
    dependencies: [
        .package(url: "https://github.com/Moya/Moya", .upToNextMajor(from: "15.0.3")),
        .package(url: "https://github.com/funky-monkey/IsoCountryCodes", .upToNextMajor(from: "1.0.1")),
    ],
    targets: [
        .target(name: "TheMovieDB", dependencies: [
            .byName(name: "Moya"),
            .product(name: "CombineMoya", package: "Moya"),
            .byName(name: "IsoCountryCodes"),
        ]),
        .testTarget(name: "TheMovieDBTests", dependencies: [
            "TheMovieDB",
            .byName(name: "Moya"),
            .product(name: "CombineMoya", package: "Moya"),
        ]),
    ]
)
