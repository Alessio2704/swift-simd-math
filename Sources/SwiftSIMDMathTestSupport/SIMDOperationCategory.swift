// MARK: - Single-Source-of-Truth Top-Level SIMD Operation Category Catalog

/// Exhaustive catalog of every operation category exported by `SIMDMath`.
///
/// Adding a new category (for example, `quaternary`) triggers compile-time exhaustive `switch`
/// errors across `SwiftSIMDMathTestSupport`, `SwiftSIMDMathTests` (API coverage, Layers 1–5,
/// and benchmarks), and `Tools/MPFRAudit` (audit executor and golden corpus emitter).
public enum SIMDOperationCategory: String, CaseIterable, Sendable {
    case unary
    case binary
    case ternary
    case dualUnary

    /// Number of cataloged operations in this category.
    public var operationCount: Int {
        switch self {
        case .unary: SIMDUnaryOperation.allCases.count
        case .binary: SIMDBinaryOperation.allCases.count
        case .ternary: SIMDTernaryOperation.allCases.count
        case .dualUnary: SIMDDualUnaryOperation.allCases.count
        }
    }

    /// Ordered raw names of every cataloged operation in this category.
    public var operationNames: [String] {
        switch self {
        case .unary: SIMDUnaryOperation.allCases.map(\.rawValue)
        case .binary: SIMDBinaryOperation.allCases.map(\.rawValue)
        case .ternary: SIMDTernaryOperation.allCases.map(\.rawValue)
        case .dualUnary: SIMDDualUnaryOperation.allCases.map(\.rawValue)
        }
    }

    /// Total number of cataloged operations across every category.
    public static var totalOperationCount: Int {
        Self.allCases.reduce(0) { $0 + $1.operationCount }
    }
}
