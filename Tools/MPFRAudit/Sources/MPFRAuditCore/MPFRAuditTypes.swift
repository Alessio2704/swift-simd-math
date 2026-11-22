import SwiftSIMDMathTestSupport

// MARK: - MPFR Certification Data Types & Deterministic Generator

struct MPFRUnaryAuditProfile: Sendable {
    let maxULP: UInt64
    let nearZeroAbsThreshold: Double?
    let nearZeroAbsTolerance: Double?
    let referenceEvaluator: @Sendable (Double) -> Double
    let sampleGenerator: @Sendable (_ count: Int) -> [Double]
    let goldenAnchors: [Double]

    init(
        maxULP: UInt64,
        nearZeroAbsThreshold: Double? = nil,
        nearZeroAbsTolerance: Double? = nil,
        referenceEvaluator: @escaping @Sendable (Double) -> Double,
        sampleGenerator: @escaping @Sendable (_ count: Int) -> [Double],
        goldenAnchors: [Double]
    ) {
        self.maxULP = maxULP
        self.nearZeroAbsThreshold = nearZeroAbsThreshold
        self.nearZeroAbsTolerance = nearZeroAbsTolerance
        self.referenceEvaluator = referenceEvaluator
        self.sampleGenerator = sampleGenerator
        self.goldenAnchors = goldenAnchors
    }
}

struct MPFRBinaryAuditProfile: Sendable {
    let maxULP: UInt64
    let referenceEvaluator: @Sendable (Double, Double) -> Double
    let sampleGenerator: @Sendable (_ count: Int) -> [(Double, Double)]
    let goldenAnchors: [(Double, Double)]
}

struct MPFRTernaryAuditProfile: Sendable {
    let maxULP: UInt64
    let referenceEvaluator: @Sendable (Double, Double, Double) -> Double
    let sampleGenerator: @Sendable (_ count: Int) -> [(Double, Double, Double)]
    let goldenAnchors: [(Double, Double, Double)]
}

struct MPFRDualUnaryAuditProfile: Sendable {
    let maxULP: UInt64
    let referenceEvaluator: @Sendable (Double) -> (first: Double, second: Double)
    let sampleGenerator: @Sendable (_ count: Int) -> [Double]
    let goldenAnchors: [Double]
}

public struct MPFRAuditOperationScorecard: Sendable {
    public static let maxAllowedContractULP: UInt64 = 8

    public let operationName: String
    public let contractMaxULP: UInt64
    public let totalEvaluations: Int
    public let observedMaxULP: UInt64
    public let exactZeroULPCount: Int
    public let crossWidthMismatchCount: Int
    public let specialValueMismatchCount: Int
    public let worstInputDescription: String
    public let worstInputBitPatterns: [UInt64]
    public let topWorstInputBitPatterns: [[UInt64]]

    public var passed: Bool {
        totalEvaluations > 0
            && contractMaxULP <= Self.maxAllowedContractULP
            && observedMaxULP <= contractMaxULP
            && crossWidthMismatchCount == 0
            && specialValueMismatchCount == 0
    }

    public var exactRoundedPercent: Double {
        guard totalEvaluations > 0 else { return 0.0 }
        return (Double(exactZeroULPCount) / Double(totalEvaluations)) * 100.0
    }
}

public struct MPFRAuditOracleReport: Sendable {
    public let oracleName: String
    public let contractMaxULP: UInt64
    public let totalEvaluations: Int
    public let observedMaxULP: UInt64
    public let specialValueMismatchCount: Int
    public let worstInputDescription: String

    public var passed: Bool {
        totalEvaluations > 0 && observedMaxULP <= contractMaxULP && specialValueMismatchCount == 0
    }
}

/// Deterministic SplitMix64 generator for reproducible multi-million-point stratified MPFR audits.
struct DeterministicSplitMix64: Sendable {
    private var state: UInt64

    init(seed: UInt64) {
        state = seed
    }

    mutating func nextUInt64() -> UInt64 {
        state &+= 0x9E37_79B9_7F4A_7C15
        var z = state
        z = (z ^ (z >> 30)) &* 0xBF58_476D_1CE4_E5B9
        z = (z ^ (z >> 27)) &* 0x94D0_49BB_1331_11EB
        return z ^ (z >> 31)
    }

    mutating func nextUnitDouble() -> Double {
        Double(nextUInt64() >> 11) * 0x1.0p-53
    }

    mutating func nextSignedUnitDouble() -> Double {
        nextUnitDouble() * 2.0 - 1.0
    }

    mutating func nextExponentDouble(minExp: Int, maxExp: Int, signed: Bool) -> Double {
        let span = UInt64(maxExp - minExp + 1)
        let exp = minExp + Int(nextUInt64() % span)
        let mantissa = 1.0 + nextUnitDouble()
        let magnitude = Double(sign: .plus, exponent: exp, significand: mantissa)
        if signed, (nextUInt64() & 1) != 0 {
            return -magnitude
        }
        return magnitude
    }
}

func formatHexBits(_ bits: UInt64) -> String {
    let hex = String(bits, radix: 16, uppercase: true)
    let padded = String(repeating: "0", count: Swift.max(0, 16 - hex.count)) + hex
    return "0x" + padded
}

func matchesIEEE754SpecialOrFinite(
    actual: Double,
    expected: Double
) -> (isSpecialMismatch: Bool, ulp: UInt64) {
    if expected.isNaN {
        return (!actual.isNaN, 0)
    }
    if expected.isInfinite {
        return (!(actual.isInfinite && actual.sign == expected.sign), 0)
    }
    if !actual.isFinite {
        return (true, 0)
    }
    if expected == 0.0, actual == 0.0 {
        return (actual.sign != expected.sign, 0)
    }
    return (false, ieee754ULPDistance(actual, expected))
}
