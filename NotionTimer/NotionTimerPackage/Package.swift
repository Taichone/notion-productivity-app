// swift-tools-version: 6.0
import PackageDescription

let package = Package(
    name: "NotionTimerPackage",
    defaultLocalization: "ja",
    platforms: [
        .iOS(.v17),
    ],
    products: [
        .library(
            name: "NotionTimerPackage",
            targets: ["Presentation"]
        ),
    ],
    dependencies: [
        .package(url: "https://github.com/Alamofire/Alamofire.git", .upToNextMajor(from: "5.10.0")),
        .package(url: "https://github.com/chojnac/NotionSwift.git", .upToNextMajor(from: "0.9.0")),
    ],
    targets: [
        // MARK: Targets
        .target(
            name: "DataLayer",
            dependencies: [
                .product(name: "Alamofire", package: "Alamofire"),
                .product(name: "NotionSwift", package: "NotionSwift")
            ]
        ),
        .target(
            name: "Domain",
            dependencies: [
                "DataLayer",
                .product(name: "NotionSwift", package: "NotionSwift")
            ]
        ),
        .target(
            name: "Presentation",
            dependencies: ["DataLayer", "Domain", "Timer"],
            resources: [
                .process("Resources/Localizable.xcstrings")
            ]
        ),
        .target(
            name: "Timer",
            dependencies: ["DataLayer", "Domain"]
        ),
        
        // MARK: TestTargets
        .testTarget(
            name: "PresentationTests",
            dependencies: ["Presentation"]
        ),
        .testTarget(
            name: "NotionTests",
            dependencies: ["Domain"]
        ),
    ]
)
