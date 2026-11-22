import Foundation
import SwiftSIMDMathTestSupport

// MARK: - Complete IEEE-754 Binary64 State-Space Partitions

/// Mutually exclusive, collectively exhaustive 10-class partition of all 2^64 IEEE-754 `Double` bit patterns.
enum IEEE754Class: String, CaseIterable, Sendable {
    case negativeInfinity
    case negativeNormal
    case negativeSubnormal
    case negativeZero
    case positiveZero
    case positiveSubnormal
    case positiveNormal
    case positiveInfinity
    case quietNaN
    case signalingNaN

    var representative: Double {
        switch self {
        case .negativeInfinity: -.infinity
        case .negativeNormal: -2.5
        case .negativeSubnormal: -Double(bitPattern: 0x0000_0000_0000_0010)
        case .negativeZero: -0.0
        case .positiveZero: 0.0
        case .positiveSubnormal: Double(bitPattern: 0x0000_0000_0000_0010)
        case .positiveNormal: 2.5
        case .positiveInfinity: .infinity
        case .quietNaN: Double(bitPattern: 0x7FF8_0000_0000_0042)
        case .signalingNaN: Double(bitPattern: 0x7FF0_0000_0000_0001)
        }
    }
}

/// Refined 19-class partition covering every distinct cell of IEEE-754-2019 §9.2.1 `pow(x, y)` (19x19 = 361 pairs).
enum PowIEEE754Class: String, CaseIterable, Sendable {
    case negativeInfinity
    case negativeLarge
    case negativeOddInteger
    case negativeEvenInteger
    case negativeOne
    case negativeFraction
    case negativeSubnormal
    case negativeZero
    case positiveZero
    case positiveSubnormal
    case positiveFraction
    case positiveOne
    case positiveEvenInteger
    case positiveOddInteger
    case positiveNonIntegerGtOne
    case positiveLarge
    case positiveInfinity
    case quietNaN
    case signalingNaN

    var representative: Double {
        switch self {
        case .negativeInfinity: -.infinity
        case .negativeLarge: -1e200
        case .negativeOddInteger: -3.0
        case .negativeEvenInteger: -2.0
        case .negativeOne: -1.0
        case .negativeFraction: -0.5
        case .negativeSubnormal: -Double(bitPattern: 0x0000_0000_0000_0010)
        case .negativeZero: -0.0
        case .positiveZero: 0.0
        case .positiveSubnormal: Double(bitPattern: 0x0000_0000_0000_0010)
        case .positiveFraction: 0.5
        case .positiveOne: 1.0
        case .positiveEvenInteger: 2.0
        case .positiveOddInteger: 3.0
        case .positiveNonIntegerGtOne: 2.5
        case .positiveLarge: 1e200
        case .positiveInfinity: .infinity
        case .quietNaN: Double(bitPattern: 0x7FF8_0000_0000_0042)
        case .signalingNaN: Double(bitPattern: 0x7FF0_0000_0000_0001)
        }
    }
}

// MARK: - Expected IEEE-754 Result Categories & ULP Distance

/// Semantic IEEE-754 result category avoiding brittle raw bit comparisons on NaN payloads or infinities.
enum ExpectedIEEE754Result: Sendable {
    case exact(Double)
    case finite(Double, maxULP: UInt64)
    case positiveZero
    case negativeZero
    case positiveInfinity
    case negativeInfinity
    case nan
    case subnormal(Double, maxULP: UInt64)

    static func fromOracle(_ reference: Double, maxULP: UInt64) -> Self {
        if reference.isNaN {
            return .nan
        }
        if reference.isInfinite {
            return reference.sign == .minus ? .negativeInfinity : .positiveInfinity
        }
        if reference == 0.0 {
            return reference.sign == .minus ? .negativeZero : .positiveZero
        }
        if reference.isSubnormal {
            return .subnormal(reference, maxULP: maxULP)
        }
        return maxULP == 0 ? .exact(reference) : .finite(reference, maxULP: maxULP)
    }

    func matches(_ actual: Double) -> Bool {
        switch self {
        case .exact(let expected):
            if expected == 0.0 {
                return actual == 0.0 && actual.sign == expected.sign
            }
            return actual == expected

        case let .finite(expected, maxULP):
            return actual.isFinite && ieee754ULPDistance(actual, expected) <= maxULP

        case .positiveZero:
            return actual == 0.0 && actual.sign == .plus

        case .negativeZero:
            return actual == 0.0 && actual.sign == .minus

        case .positiveInfinity:
            return actual.isInfinite && actual.sign == .plus

        case .negativeInfinity:
            return actual.isInfinite && actual.sign == .minus

        case .nan:
            return actual.isNaN

        case let .subnormal(expected, maxULP):
            return actual.isSubnormal && ieee754ULPDistance(actual, expected) <= maxULP
        }
    }
}

// MARK: - Strongly-Typed Input & Output Containers (Avoiding Large Tuples)

struct BinaryInput: Sendable {
    let a: Double
    let b: Double
}

struct TernaryInput: Sendable {
    let x: Double
    let lower: Double
    let upper: Double
}

struct DualExpectedResult: Sendable {
    let first: ExpectedIEEE754Result
    let second: ExpectedIEEE754Result
}

struct DualScalar: Sendable {
    let first: Double
    let second: Double
}

// MARK: - Compile-Time Enforced Data-Driven Spec Containers

struct UnaryTestSpec: Sendable {
    let maxULP: UInt64
    let homogeneousInputs: [Double]
    let heterogeneousLanes: [[Double]]
    let stabilityTransitions: [Double]
    let classExpectation: @Sendable (IEEE754Class) -> ExpectedIEEE754Result
    let oracle: @Sendable (Double) -> Double
    let exponentSweepEligible: @Sendable (Double) -> Bool
}

struct BinaryTestSpec: Sendable {
    let maxULP: UInt64
    let homogeneousPairs: [BinaryInput]
    let heterogeneousPairs: [[BinaryInput]]
    let stabilityTransitions: [BinaryInput]
    let oracle: @Sendable (Double, Double) -> Double
}

struct TernaryTestSpec: Sendable {
    let maxULP: UInt64
    let homogeneousTriplets: [TernaryInput]
    let heterogeneousTriplets: [[TernaryInput]]
    let oracle: @Sendable (Double, Double, Double) -> Double
}

struct DualUnaryTestSpec: Sendable {
    let maxULP: UInt64
    let homogeneousInputs: [Double]
    let heterogeneousLanes: [[Double]]
    let stabilityTransitions: [Double]
    let classExpectation: @Sendable (IEEE754Class) -> DualExpectedResult
    let oracle: @Sendable (Double) -> DualScalar
}
