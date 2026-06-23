// swift-tools-version: 5.9

import PackageDescription
import AppleProductTypes

let package = Package(
    name: "MyApp",
    platforms: [
        .iOS(.v15)
    ],
    products: [
        .executable(
            name: "MyApp",
            targets: ["MyApp"]
        )
    ],
    targets: [
        .target(
            name: "MyApp"
        )
    ]
)
