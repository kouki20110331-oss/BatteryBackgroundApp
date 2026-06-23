// swift-tools-version: 6.1

import PackageDescription

let package = Package(
    name: "BatteryBackgroundApp",
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
        .executableTarget(
            name: "MyApp"
        )
    ]
)
