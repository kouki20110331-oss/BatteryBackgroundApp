 // swift-tools-version: 6.1
import PackageDescription

let package = Package(
    name: "HelloApp",
    platforms: [
        .iOS(.v15)
    ],
    products: [
        .executable(
            name: "HelloApp",
            targets: ["HelloApp"]
        )
    ],
    targets: [
        .executableTarget(
            name: "HelloApp"
        )
    ]
)
