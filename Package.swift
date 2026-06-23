 // swift-tools-version: 6.1
import PackageDescription

let package = Package(
    name: "My App",
    platforms: [
        .iOS(.v15)
    ],
    products: [
        .executable(
            name: "My App",
            targets: ["My App"]
        )
    ],
    targets: [
        .executableTarget(
            name: "My App"
        )
    ]
)
