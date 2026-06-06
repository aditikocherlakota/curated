// swift-tools-version: 5.9
import PackageDescription

let package = Package(
    name: "Curated",
    platforms: [.iOS(.v17)],
    dependencies: [
        .package(url: "https://github.com/jpsim/Yams.git", from: "5.0.0"),
        .package(url: "https://github.com/elevenlabs/elevenlabs-swift-sdk.git", exact: "3.2.0"),
    ],
    targets: [
        .executableTarget(
            name: "Curated",
            dependencies: [
                .product(name: "Yams", package: "Yams"),
                .product(name: "ElevenLabs", package: "elevenlabs-swift-sdk"),
            ],
            path: "Sources",
            resources: [.process("../Resources")]
        ),
    ]
)
