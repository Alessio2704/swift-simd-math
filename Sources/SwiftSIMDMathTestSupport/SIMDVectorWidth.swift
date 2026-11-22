// MARK: - Single-Source-of-Truth SIMD Vector Lane Width Catalog

/// Exhaustive catalog of every SIMD vector lane width exported by `SIMDMath`.
///
/// Adding a new lane width (for example, `lanes16`) triggers compile-time exhaustive `switch`
/// errors across `SwiftSIMDMathTestSupport`, `SwiftSIMDMathTests` (API coverage, Grounding,
/// Adversarial, Layer 5 MPFR Golden), and `Tools/MPFRAudit`.
public enum SIMDVectorWidth: Int, CaseIterable, Sendable {
    case lanes2 = 2
    case lanes4 = 4
    case lanes8 = 8

    /// Number of IEEE-754 Binary64 lanes in this vector width.
    public var laneCount: Int { rawValue }

    /// Exact Swift type spelling required on every `SIMDMath` public overload.
    public var swiftTypeName: String {
        switch self {
        case .lanes2: "SIMD2<Double>"
        case .lanes4: "SIMD4<Double>"
        case .lanes8: "SIMD8<Double>"
        }
    }
}
