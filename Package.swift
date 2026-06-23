 // swift-tools-version: 6.1
import PackageDescription

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