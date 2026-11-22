import Foundation
import SwiftSIMDMathTestSupport

// MARK: - Deterministic Seeded PRNG & Dense Neighborhood Utilities

struct SeededSplitMix64: Sendable {
    private var state: UInt64

    init(seed: UInt64) {
        state = seed
    }

    mutating func next() -> UInt64 {
        state &+= 0x9E37_79B9_7F4A_7C15
        var z = state
        z = (z ^ (z >> 30)) &* 0xBF58_476D_1CE4_E5B9
        z = (z ^ (z >> 27)) &* 0x94D0_49BB_1331_11EB
        return z ^ (z >> 31)
    }

    mutating func nextUnit() -> Double {
        Double(next() >> 11) * 0x1.0p-53
    }
}

/// Generates a dense + prime-strided ULP window around `anchor` to catch both immediate boundary discontinuities
/// and peak rounding pockets tens of thousands of ULPs from a regime split without power-of-2 bit aliasing.
func denseULPNeighborhood(around anchor: Double, eligible: (Double) -> Bool) -> [Double] {
    var offsets: [Int64] = []
    offsets.reserveCapacity(900)
    for d in Int64(-32)...Int64(32) {
        offsets.append(d)
    }
    for step in stride(from: Int64(93), through: Int64(24_576), by: 61) {
        offsets.append(-step)
        offsets.append(step)
    }
    let base = Int64(bitPattern: anchor.bitPattern)
    var points: [Double] = []
    points.reserveCapacity(offsets.count)
    for delta in offsets {
        let candidate = Double(bitPattern: UInt64(bitPattern: base &+ delta))
        if candidate.isFinite, eligible(candidate) {
            points.append(candidate)
        }
    }
    return points
}

// MARK: - Single-Source-of-Truth Adversarial & Algebraic Invariant Specs (Unary)

enum MonotonicityInvariant: Sendable {
    case nonDecreasing
    case nonIncreasing
}

enum ParityInvariant: Sendable {
    case odd
    case even
}

struct UnaryAdversarialSpec: Sendable {
    let regimeAnchors: [Double]
    let monotonicity: MonotonicityInvariant?
    let parity: ParityInvariant?
    let fuzzInputs: @Sendable () -> [Double]
}

extension SIMDUnaryOperation {
    /// Compile-time exhaustive adversarial & structural spec (zero `default:` branches).
    var adversarialSpec: UnaryAdversarialSpec {
        switch self {
        case .exp: Self.expAdversarial
        case .exp2: Self.exp2Adversarial
        case .exp10: Self.exp10Adversarial
        case .expm1: Self.expm1Adversarial
        case .log, .log2, .log10: Self.logAdversarial
        case .log1p: Self.log1pAdversarial
        case .sin: Self.trigAdversarial(parity: .odd)
        case .cos: Self.trigAdversarial(parity: .even)
        case .tan: Self.trigAdversarial(parity: .odd)
        case .asin: Self.asinAdversarial
        case .acos: Self.acosAdversarial
        case .atan: Self.atanAdversarial
        case .sinpi: Self.piTrigAdversarial(parity: .odd)
        case .cospi: Self.piTrigAdversarial(parity: .even)
        case .tanpi: Self.piTrigAdversarial(parity: .odd)
        case .abs: Self.absAdversarial
        case .cbrt: Self.cbrtAdversarial
        case .sign: Self.signAdversarial
        case .fract: Self.fractAdversarial
        case .sinh: Self.sinhAdversarial
        case .cosh: Self.coshAdversarial
        case .tanh: Self.tanhAdversarial
        case .asinh: Self.asinhAdversarial
        case .acosh: Self.acoshAdversarial
        case .atanh: Self.atanhAdversarial
        case .erf: Self.erfAdversarial
        case .erfc: Self.erfcAdversarial
        case .tgamma: Self.tgammaAdversarial
        case .lgamma: Self.lgammaAdversarial
        }
    }

    private static let expAdversarial = UnaryAdversarialSpec(
        regimeAnchors: [
            0.0, -708.0, 708.0, -715.785592,
            Double(bitPattern: 0x4086_2E42_FEFA_39EF),
            Double(bitPattern: 0xC087_4910_D52D_3052)
        ],
        monotonicity: .nonDecreasing,
        parity: nil
    ) {
        var rng = SeededSplitMix64(seed: 0xE101_2026)
        var xs: [Double] = []
        xs.reserveCapacity(4500)
        for idx in 0..<1000 {
            xs.append(-746.0 + Double(idx) * (38.0 / 1000.0))
        }
        for _ in 0..<3000 {
            xs.append((rng.nextUnit() * 2.0 - 1.0) * 710.0)
        }
        for exp in stride(from: -1074, through: 10, by: 4) {
            let value = scalbn(1.0 + rng.nextUnit(), exp)
            xs.append(value)
            xs.append(-value)
        }
        return xs
    }

    private static let logAdversarial = UnaryAdversarialSpec(
        regimeAnchors: [
            Double.leastNonzeroMagnitude, Double.leastNormalMagnitude,
            0.5, (0.5).squareRoot(), 1.0, (2.0).squareRoot(), 2.0, 10.0
        ],
        monotonicity: .nonDecreasing,
        parity: nil
    ) {
        var rng = SeededSplitMix64(seed: 0x1062_2026)
        var xs: [Double] = []
        xs.reserveCapacity(4500)
        for k in -308...308 {
            xs.append(Foundation.pow(10.0, Double(k)))
        }
        for exp in stride(from: -1074, through: 1023, by: 2) {
            let value = scalbn(1.0 + rng.nextUnit(), exp)
            if value > 0.0, value.isFinite { xs.append(value) }
        }
        for _ in 0..<2500 {
            let exp = Int(rng.next() % 2098) - 1074
            let value = scalbn(1.0 + rng.nextUnit(), exp)
            if value > 0.0, value.isFinite { xs.append(value) }
        }
        return xs
    }

    private static func trigAdversarial(parity: ParityInvariant) -> UnaryAdversarialSpec {
        UnaryAdversarialSpec(
            regimeAnchors: [
                0.0, Double.pi * 0.25, Double.pi * 0.5, Double.pi, 524_288.0,
                Double(bitPattern: 0x4164_5525_B1B6_F85C),
                Double(bitPattern: 0x4679_397E_307C_D3AA),
                Double(bitPattern: 0x7506_AC5B_262C_A1FF),
                Double(bitPattern: 0x7FE9_21FB_5444_2D18)
            ],
            monotonicity: nil,
            parity: parity
        ) {
            var rng = SeededSplitMix64(seed: 0x7160_2026)
            var xs: [Double] = []
            xs.reserveCapacity(5000)
            for k in stride(from: 1, through: 333_772, by: 251) {
                let mult = Double(k) * (Double.pi * 0.5)
                xs.append(mult.nextDown)
                xs.append(mult)
                xs.append(mult.nextUp)
            }
            for _ in 0..<1500 {
                xs.append((rng.nextUnit() * 2.0 - 1.0) * 524_288.0)
            }
            for _ in 0..<1000 {
                let exp = 19 + Int(rng.next() % 1005)
                let value = scalbn(1.0 + rng.nextUnit(), exp)
                xs.append((rng.next() & 1) == 0 ? value : -value)
            }
            return xs
        }
    }

    private static let absAdversarial = UnaryAdversarialSpec(
        regimeAnchors: [
            0.0, Double.leastNonzeroMagnitude, Double.leastNormalMagnitude, Double.greatestFiniteMagnitude
        ],
        monotonicity: nil,
        parity: .even
    ) {
        var rng = SeededSplitMix64(seed: 0xAB50_2026)
        return (0..<1000).map { _ in
            let exp = Int(rng.next() % 2098) - 1074
            let value = scalbn(1.0 + rng.nextUnit(), exp)
            return (rng.next() & 1) == 0 ? value : -value
        }
    }
}
