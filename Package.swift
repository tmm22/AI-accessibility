// swift-tools-version: 5.9
import PackageDescription

let package = Package(
    name: "VoiceAssistApp",
    platforms: [
        .macOS(.v13)
    ],
    products: [
        .executable(
            name: "VoiceAssistApp",
            targets: ["VoiceAssistApp"]
        )
    ],
    dependencies: [
        // Add any external dependencies here
    ],
    targets: [
        .executableTarget(
            name: "VoiceAssistApp",
            dependencies: [],
            path: "VoiceAssistApp"
        )
    ]
)
