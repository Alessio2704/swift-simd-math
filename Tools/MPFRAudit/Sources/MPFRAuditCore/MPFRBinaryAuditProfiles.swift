import CMPFRBridge
import Foundation
import SwiftSIMDMathTestSupport

// MARK: - Compile-Time Exhaustive Binary MPFR Audit Profiles (Zero default: Branches)

extension SIMDBinaryOperation {
    /// Exhaustive MPFR certification profile for every binary operation (zero `default:` branches).
    var mpfrAuditProfile: MPFRBinaryAuditProfile {
        switch self {
        case .pow: Self.powProfile
        case .atan2: Self.atan2Profile
        case .hypot: Self.hypotProfile
        case .min: Self.minProfile
        case .max: Self.maxProfile
        case .step: Self.stepProfile
        }
    }

    private static let powProfile = MPFRBinaryAuditProfile(
        maxULP: 2,
        referenceEvaluator: { x, y in
            if x.isSignalingNaN || y.isSignalingNaN { return .nan }
            return mpfr_ieee754_pow(x, y)
        },
        sampleGenerator: { count in
            var rng = DeterministicSplitMix64(seed: 0xB001)
            var pairs: [(Double, Double)] = []
            pairs.reserveCapacity(count)
            for _ in 0..<(count / 3) {
                let x = 0.01 + rng.nextUnitDouble() * 100.0
                if x == 1.0 { continue }
                pairs.append((x, (rng.nextSignedUnitDouble() * 1076.0) / Foundation.log2(x)))
            }
            for _ in 0..<(count / 3) {
                let x = 1.0 + rng.nextSignedUnitDouble() * 0.02
                if x <= 0.0 || x == 1.0 { continue }
                pairs.append((x, (rng.nextSignedUnitDouble() * 1076.0) / Foundation.log2(x)))
            }
            while pairs.count < count {
                pairs.append(
                    (
                        rng.nextExponentDouble(minExp: -1074, maxExp: 1023, signed: false),
                        rng.nextSignedUnitDouble() * 4.0
                    ))
            }
            return pairs
        },
        goldenAnchors: [
            (2.0, 1023.0), (2.0, -1074.0), (1.0.nextUp, 1.0e18), (-2.0, -3.0),
            (1.0, Double(bitPattern: 0x7FF0_0000_0000_0001)),
            (Double(bitPattern: 0x7FF0_0000_0000_0001), 0.0),
            (1.0, Double(bitPattern: 0x7FF8_0000_0000_0042))
        ]
    )

    private static let atan2Profile = MPFRBinaryAuditProfile(
        maxULP: 2,
        referenceEvaluator: { y, x in mpfr_ieee754_atan2(y, x) },
        sampleGenerator: { count in
            var rng = DeterministicSplitMix64(seed: 0xB002)
            return (0..<count).map { _ in
                (
                    rng.nextExponentDouble(minExp: -1074, maxExp: 1023, signed: true),
                    rng.nextExponentDouble(minExp: -1074, maxExp: 1023, signed: true)
                )
            }
        },
        goldenAnchors: [
            (1.0, 1.0), (-1.0, -1.0), (0.0, -0.0), (-0.0, -0.0),
            (-4.0 * Double.leastNonzeroMagnitude, 2.0 * Double.leastNonzeroMagnitude),
            (Double.greatestFiniteMagnitude, Double.greatestFiniteMagnitude),
            (1.0e-300, 1.0e300)
        ]
    )

    private static let hypotProfile = MPFRBinaryAuditProfile(
        maxULP: 1,
        referenceEvaluator: { x, y in mpfr_ieee754_hypot(x, y) },
        sampleGenerator: { count in
            var rng = DeterministicSplitMix64(seed: 0xB003)
            return (0..<count).map { idx in
                if idx.isMultiple(of: 2) {
                    let exp = Int(rng.nextUInt64() % 2098) - 1074
                    let a = Double(sign: .plus, exponent: exp, significand: 1.0 + rng.nextUnitDouble())
                    let b = Double(sign: .plus, exponent: exp, significand: 1.0 + rng.nextUnitDouble())
                    return ((rng.nextUInt64() & 1) == 0 ? a : -a, (rng.nextUInt64() & 2) == 0 ? b : -b)
                }
                return (
                    rng.nextExponentDouble(minExp: -1074, maxExp: 1023, signed: true),
                    rng.nextExponentDouble(minExp: -1074, maxExp: 1023, signed: true)
                )
            }
        },
        goldenAnchors: [
            (3.0, 4.0), (0x1.0p500, 0x1.0p500), (0x1.0p-450, 0x1.0p-450),
            (1.0e308, 1.0e308), (Double.leastNonzeroMagnitude, Double.leastNonzeroMagnitude),
            (.infinity, .nan)
        ]
    )

    private static let minProfile = MPFRBinaryAuditProfile(
        maxULP: 0,
        referenceEvaluator: { SIMDExactReferenceOracles.ieeeMinimumNumber($0, $1) },
        sampleGenerator: { count in
            var rng = DeterministicSplitMix64(seed: 0xB004)
            return (0..<count).map { _ in
                (
                    rng.nextExponentDouble(minExp: -1074, maxExp: 1023, signed: true),
                    rng.nextExponentDouble(minExp: -1074, maxExp: 1023, signed: true)
                )
            }
        },
        goldenAnchors: [
            (-5.0, 0.0), (-0.0, 0.0), (0.0, -0.0), (.nan, 3.0),
            (Double(bitPattern: 0x7FF0_0000_0000_0001), 3.0)
        ]
    )

    private static let maxProfile = MPFRBinaryAuditProfile(
        maxULP: 0,
        referenceEvaluator: { SIMDExactReferenceOracles.ieeeMaximumNumber($0, $1) },
        sampleGenerator: { count in
            var rng = DeterministicSplitMix64(seed: 0xB005)
            return (0..<count).map { _ in
                (
                    rng.nextExponentDouble(minExp: -1074, maxExp: 1023, signed: true),
                    rng.nextExponentDouble(minExp: -1074, maxExp: 1023, signed: true)
                )
            }
        },
        goldenAnchors: [
            (-5.0, 0.0), (-0.0, 0.0), (0.0, -0.0), (.nan, 3.0),
            (Double(bitPattern: 0x7FF0_0000_0000_0001), 3.0)
        ]
    )

    private static let stepProfile = MPFRBinaryAuditProfile(
        maxULP: 0,
        referenceEvaluator: { x, edge in x < edge ? 0.0 : 1.0 },
        sampleGenerator: { count in
            var rng = DeterministicSplitMix64(seed: 0xB006)
            return (0..<count).map { _ in
                (
                    rng.nextExponentDouble(minExp: -1074, maxExp: 1023, signed: true),
                    rng.nextExponentDouble(minExp: -1074, maxExp: 1023, signed: true)
                )
            }
        },
        goldenAnchors: [(1.0.nextDown, 1.0), (1.0, 1.0), (1.0.nextUp, 1.0), (-0.0, 0.0), (.nan, 0.0)]
    )
}
