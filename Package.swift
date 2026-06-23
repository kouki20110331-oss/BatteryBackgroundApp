import PackageDescription

let package = Package(
    name: "HelloApp",
    platforms: [
        .iOS(.v15)
    ],
    products: [
        .library(
            name: "HelloApp",
            targets: ["HelloApp"]
        ),
    ],
    targets: [
        .target(
            name: "HelloApp"
        )
    ]
)