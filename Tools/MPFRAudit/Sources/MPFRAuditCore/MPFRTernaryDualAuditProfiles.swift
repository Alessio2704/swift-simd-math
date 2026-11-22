import CMPFRBridge
import SwiftSIMDMathTestSupport

// MARK: - Compile-Time Exhaustive Ternary & Dual-Unary MPFR Audit Profiles (Zero default: Branches)

extension SIMDTernaryOperation {
    /// Exhaustive certification profile for every ternary operation (zero `default:` branches).
    var mpfrAuditProfile: MPFRTernaryAuditProfile {
        switch self {
        case .clamp:
            MPFRTernaryAuditProfile(
                maxULP: 0,
                referenceEvaluator: { x, lo, hi in
                    SIMDExactReferenceOracles.ieeeMinimumNumber(
                        SIMDExactReferenceOracles.ieeeMaximumNumber(x, lo), hi
                    )
                },
                sampleGenerator: { count in Self.ternarySamples(seed: 0xC001, count: count) },
                goldenAnchors: [(-15.0, -10.0, 10.0), (0.0, -10.0, 10.0), (15.0, -10.0, 10.0), (.nan, -1.0, 1.0)]
            )

        case .mix:
            MPFRTernaryAuditProfile(
                maxULP: 0,
                referenceEvaluator: { a, b, t in a.addingProduct(t, b - a) },
                sampleGenerator: { count in Self.ternarySamples(seed: 0xC002, count: count) },
                goldenAnchors: [(1.0, 5.0, 0.0), (1.0, 5.0, 0.5), (1.0, 5.0, 1.0), (-10.0, 20.0, 0.25)]
            )

        case .smoothstep:
            MPFRTernaryAuditProfile(
                maxULP: 0,
                referenceEvaluator: { x, e0, e1 in
                    let raw = (x - e0) / (e1 - e0)
                    let u = SIMDExactReferenceOracles.ieeeMinimumNumber(
                        SIMDExactReferenceOracles.ieeeMaximumNumber(raw, 0.0), 1.0
                    )
                    return u * u * 3.0.addingProduct(-2.0, u)
                },
                sampleGenerator: { count in Self.ternarySamples(seed: 0xC003, count: count) },
                goldenAnchors: [(-1.0, 0.0, 1.0), (0.25, 0.0, 1.0), (0.5, 0.0, 1.0), (2.0, 0.0, 1.0)]
            )
        }
    }

    private static func ternarySamples(seed: UInt64, count: Int) -> [(Double, Double, Double)] {
        var rng = DeterministicSplitMix64(seed: seed)
        return (0..<count).map { _ in
            let lo = rng.nextSignedUnitDouble() * 100.0
            let hi = lo + rng.nextUnitDouble() * 100.0
            let x = lo + (rng.nextUnitDouble() * 3.0 - 1.0) * (hi - lo)
            return (x, lo, hi)
        }
    }
}

extension SIMDDualUnaryOperation {
    /// Exhaustive MPFR certification profile for every dual-output unary operation (zero `default:` branches).
    var mpfrAuditProfile: MPFRDualUnaryAuditProfile {
        switch self {
        case .sincos:
            MPFRDualUnaryAuditProfile(
                maxULP: 2,
                referenceEvaluator: { x in
                    var sinOut = 0.0
                    var cosOut = 0.0
                    mpfr_ieee754_sincos(x, &sinOut, &cosOut)
                    return (first: sinOut, second: cosOut)
                },
                sampleGenerator: { count in
                    MPFRDomainSamplers.stratifiedExponents(
                        seed: 0xD001, count: count, minExp: -1074, maxExp: 1023, signed: true,
                        anchors: MPFRDomainSamplers.trigCriticalAnchors
                    )
                },
                goldenAnchors: MPFRDomainSamplers.trigCriticalAnchors
            )

        case .sincospi:
            MPFRDualUnaryAuditProfile(
                maxULP: 2,
                referenceEvaluator: { x in
                    var sinOut = 0.0
                    var cosOut = 0.0
                    mpfr_ieee754_sincospi(x, &sinOut, &cosOut)
                    return (first: sinOut, second: cosOut)
                },
                sampleGenerator: { count in
                    MPFRDomainSamplers.stratifiedExponents(
                        seed: 0xD002, count: count, minExp: -1074, maxExp: 60, signed: true,
                        anchors: MPFRDomainSamplers.piTrigCriticalAnchors
                    )
                },
                goldenAnchors: MPFRDomainSamplers.piTrigCriticalAnchors
            )
        }
    }
}
