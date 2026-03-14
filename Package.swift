// swift-tools-version: 5.9
import PackageDescription

let package = Package(
    name: "StandupTimer",
    platforms: [.macOS(.v13)],
    targets: [
        .executableTarget(name: "StandupTimer")
    ]
)
