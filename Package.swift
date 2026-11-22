// swift-tools-version: 6.0
import PackageDescription

let swiftSettings: [SwiftSetting] = [
    .swiftLanguageMode(.v6),
    .enableUpcomingFeature("ExistentialAny"),
    .enableUpcomingFeature("InternalImportsByDefault"),
    .enableUpcomingFeature("MemberImportVisibility")
]

let package = Package(
    name: "swift-simd-math",
    products: [
        .library(name: "SwiftSIMDMath", targets: ["SwiftSIMDMath"]),
        // Internal testing/certification support consumed by Tools/MPFRAudit; not part of the public API.
        .library(name: "_SwiftSIMDMathTestSupport", targets: ["SwiftSIMDMathTestSupport"])
    ],
    targets: [
        .target(
            name: "SwiftSIMDMath",
            swiftSettings: swiftSettings
        ),
        .target(
            name: "SwiftSIMDMathTestSupport",
            dependencies: ["SwiftSIMDMath"],
            swiftSettings: swiftSettings
        ),
        .testTarget(
            name: "SwiftSIMDMathTests",
            dependencies: ["SwiftSIMDMath", "SwiftSIMDMathTestSupport"],
            swiftSettings: swiftSettings
        )
    ]
)
