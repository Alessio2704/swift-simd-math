import CMPFRBridge
import SwiftSIMDMathTestSupport

// MARK: - Unary MPFR Audit Profiles: Inverse Trig, Pi-Trig & Shaping

extension SIMDUnaryOperation {
    static let asinProfile = MPFRUnaryAuditProfile(
        maxULP: 2,
        referenceEvaluator: { mpfr_ieee754_asin($0) },
        sampleGenerator: { count in
            MPFRDomainSamplers.unitIntervalAndEdges(
                seed: 0xE00F, count: count, includeEndpoints: true, anchors: [-1.0, -0.5, 0.0, 0.5, 1.0]
            )
        },
        goldenAnchors: [-1.0, -1.0.nextUp, -0.5, -0.0, 0.0, 0.5, 1.0.nextDown, 1.0]
    )

    static let acosProfile = MPFRUnaryAuditProfile(
        maxULP: 2,
        referenceEvaluator: { mpfr_ieee754_acos($0) },
        sampleGenerator: { count in
            MPFRDomainSamplers.unitIntervalAndEdges(
                seed: 0xE010, count: count, includeEndpoints: true, anchors: [-1.0, -0.5, 0.0, 0.5, 1.0]
            )
        },
        goldenAnchors: [-1.0, -1.0.nextUp, -0.5, -0.0, 0.0, 0.5, 1.0.nextDown, 1.0]
    )

    static let atanProfile = MPFRUnaryAuditProfile(
        maxULP: 2,
        referenceEvaluator: { mpfr_ieee754_atan($0) },
        sampleGenerator: { count in
            MPFRDomainSamplers.stratifiedExponents(
                seed: 0xE011, count: count, minExp: -1074, maxExp: 1023, signed: true,
                anchors: [-2.414213562373095, -0.414213562373095, 0.0, 0.414213562373095, 2.414213562373095]
            )
        },
        goldenAnchors: [
            -Double.greatestFiniteMagnitude, -2.414213562373095, -0.414213562373095,
            -0.0, 0.0, 0.414213562373095, 2.414213562373095, Double.greatestFiniteMagnitude
        ]
    )

    static let sinpiProfile = MPFRUnaryAuditProfile(
        maxULP: 2,
        referenceEvaluator: { mpfr_ieee754_sinpi($0) },
        sampleGenerator: { count in
            MPFRDomainSamplers.stratifiedExponents(
                seed: 0xE012, count: count, minExp: -1074, maxExp: 60, signed: true,
                anchors: MPFRDomainSamplers.piTrigCriticalAnchors
            )
        },
        goldenAnchors: MPFRDomainSamplers.piTrigCriticalAnchors
    )

    static let cospiProfile = MPFRUnaryAuditProfile(
        maxULP: 2,
        referenceEvaluator: { mpfr_ieee754_cospi($0) },
        sampleGenerator: { count in
            MPFRDomainSamplers.stratifiedExponents(
                seed: 0xE013, count: count, minExp: -1074, maxExp: 60, signed: true,
                anchors: MPFRDomainSamplers.piTrigCriticalAnchors
            )
        },
        goldenAnchors: MPFRDomainSamplers.piTrigCriticalAnchors
    )

    static let tanpiProfile = MPFRUnaryAuditProfile(
        maxULP: 2,
        referenceEvaluator: { mpfr_ieee754_tanpi($0) },
        sampleGenerator: { count in
            MPFRDomainSamplers.stratifiedExponents(
                seed: 0xE014, count: count, minExp: -1074, maxExp: 60, signed: true,
                anchors: MPFRDomainSamplers.piTrigCriticalAnchors
            )
        },
        goldenAnchors: MPFRDomainSamplers.piTrigCriticalAnchors
    )

    static let absProfile = MPFRUnaryAuditProfile(
        maxULP: 0,
        referenceEvaluator: { Swift.abs($0) },
        sampleGenerator: { count in
            MPFRDomainSamplers.stratifiedExponents(
                seed: 0xE015, count: count, minExp: -1074, maxExp: 1023, signed: true, anchors: [-0.0, 0.0]
            )
        },
        goldenAnchors: [-Double.greatestFiniteMagnitude, -Double.leastNonzeroMagnitude, -0.0, 0.0, 1.0]
    )

    static let cbrtProfile = MPFRUnaryAuditProfile(
        maxULP: 1,
        referenceEvaluator: { mpfr_ieee754_cbrt($0) },
        sampleGenerator: { count in
            MPFRDomainSamplers.stratifiedExponents(
                seed: 0xE016, count: count, minExp: -1074, maxExp: 1023, signed: true,
                anchors: [
                    -Double.leastNormalMagnitude, 0.0, Double.leastNormalMagnitude, Double.greatestFiniteMagnitude
                ]
            )
        },
        goldenAnchors: [
            -Double.greatestFiniteMagnitude, -Double.leastNormalMagnitude, -Double.leastNonzeroMagnitude,
            -0.0, 0.0, 8.455e+266, 2.364e+284, 6.492e+298, Double.greatestFiniteMagnitude
        ]
    )

    static let signProfile = MPFRUnaryAuditProfile(
        maxULP: 0,
        referenceEvaluator: { x in
            if x < 0.0 { return -1.0 }
            if x > 0.0 { return 1.0 }
            return 0.0
        },
        sampleGenerator: { count in
            MPFRDomainSamplers.stratifiedExponents(
                seed: 0xE017, count: count, minExp: -1074, maxExp: 1023, signed: true, anchors: [-0.0, 0.0]
            )
        },
        goldenAnchors: [-Double.greatestFiniteMagnitude, -Double.leastNonzeroMagnitude, -0.0, 0.0, 1.0]
    )

    static let fractProfile = MPFRUnaryAuditProfile(
        maxULP: 0,
        referenceEvaluator: { x in
            SIMDExactReferenceOracles.ieeeMinimumNumber(x - x.rounded(.down), 0x1.FFFF_FFFF_FFFF_Fp-1)
        },
        sampleGenerator: { count in
            MPFRDomainSamplers.stratifiedExponents(
                seed: 0xE018, count: count, minExp: -1074, maxExp: 60, signed: true, anchors: [-1.0, 0.0, 1.0, 0x1.0p52]
            )
        },
        goldenAnchors: [-0x1.0p52, -1.0.nextUp, -Double.leastNonzeroMagnitude, -0.0, 0.0, 1.0.nextDown, 0x1.0p52]
    )
}
