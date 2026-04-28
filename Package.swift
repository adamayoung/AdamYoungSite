// swift-tools-version:5.9
import PackageDescription

let package = Package(
    name: "AdamYoungSite",
    platforms: [.macOS(.v12)],
    products: [
        .executable(name: "AdamYoungSite", targets: ["AdamYoungSite"])
    ],
    dependencies: [
        .package(url: "https://github.com/johnsundell/publish.git", from: "0.9.0"),
        .package(url: "https://github.com/johnsundell/splashpublishplugin", from: "0.2.0")
    ],
    targets: [
        .executableTarget(
            name: "AdamYoungSite",
            dependencies: [
                .product(name: "Publish", package: "publish"),
                .product(name: "SplashPublishPlugin", package: "splashpublishplugin")
            ]
        )
    ]
)
