// swift-tools-version: 6.0
import PackageDescription

let swiftSettings: [SwiftSetting] = [
    .swiftLanguageMode(.v6),
    .enableUpcomingFeature("ExistentialAny"),
    .enableUpcomingFeature("InternalImportsByDefault"),
    .enableUpcomingFeature("MemberImportVisibility")
]

let package = Package(
    name: "mpfr-audit",
    platforms: [
        .macOS(.v13)
    ],
    dependencies: [
        .package(path: "../..")
    ],
    targets: [
        .systemLibrary(
            name: "CGMP",
            pkgConfig: "gmp",
            providers: [
                .brew(["gmp"]),
                .apt(["libgmp-dev"]),
                .yum(["gmp-devel"])
            ]
        ),
        .systemLibrary(
            name: "CMPFR",
            pkgConfig: "mpfr",
            providers: [
                .brew(["mpfr"]),
                .apt(["libmpfr-dev"]),
                .yum(["mpfr-devel"])
            ]
        ),
        .target(
            name: "CMPFRBridge",
            dependencies: ["CGMP", "CMPFR"],
            linkerSettings: [.linkedLibrary("m", .when(platforms: [.linux]))]
        ),
        .target(
            name: "MPFRAuditCore",
            dependencies: [
                "CMPFRBridge",
                .product(name: "SwiftSIMDMath", package: "swift-simd-math"),
                .product(name: "_SwiftSIMDMathTestSupport", package: "swift-simd-math")
            ],
            swiftSettings: swiftSettings
        ),
        .executableTarget(
            name: "MPFRAudit",
            dependencies: [
                "CMPFRBridge",
                "MPFRAuditCore",
                .product(name: "_SwiftSIMDMathTestSupport", package: "swift-simd-math")
            ],
            swiftSettings: swiftSettings
        ),
        .testTarget(
            name: "MPFRAuditTests",
            dependencies: [
                "CMPFRBridge",
                "MPFRAuditCore",
                .product(name: "SwiftSIMDMath", package: "swift-simd-math"),
                .product(name: "_SwiftSIMDMathTestSupport", package: "swift-simd-math")
            ],
            swiftSettings: swiftSettings
        )
    ]
)
