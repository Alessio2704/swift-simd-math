import CMPFRBridge
import SwiftSIMDMathTestSupport

// MARK: - Unary MPFR Audit Profiles: Hyperbolic & Special Functions

extension SIMDUnaryOperation {
    static let sinhProfile = MPFRUnaryAuditProfile(
        maxULP: 2,
        referenceEvaluator: { mpfr_ieee754_sinh($0) },
        sampleGenerator: { count in
            let third = Swift.max(64, (count + 2) / 3)
            return MPFRDomainSamplers.uniformInterval(
                seed: 0xE019, count: third, low: -712.0, high: 712.0,
                anchors: [-710.4758600739439, -708.0, -1.0, 1.0, 708.0, 710.4758600739439]
            )
                + MPFRDomainSamplers.uniformInterval(
                    seed: 0xE119, count: third, low: -20.0, high: 20.0,
                    anchors: [-1.0, -0.8828125, -0.7982323160529248, -0.5, 0.5, 0.7982323160529248, 0.8828125, 1.0]
                )
                + MPFRDomainSamplers.stratifiedExponents(
                    seed: 0xE01A, count: third, minExp: -1074, maxExp: 2, signed: true, anchors: [0.0]
                )
        },
        goldenAnchors: [-711.0, -710.4758600739439, -1.0, -0.7982323160529248, -0.0, 0.0, 1.0, 710.4758600739439]
    )

    static let coshProfile = MPFRUnaryAuditProfile(
        maxULP: 2,
        referenceEvaluator: { mpfr_ieee754_cosh($0) },
        sampleGenerator: { count in
            let half = Swift.max(64, (count + 1) / 2)
            return MPFRDomainSamplers.uniformInterval(
                seed: 0xE01B, count: half, low: -712.0, high: 712.0,
                anchors: [-710.4758600739439, -708.0, 0.0, 708.0, 710.4758600739439]
            )
                + MPFRDomainSamplers.uniformInterval(
                    seed: 0xE11B, count: half, low: -20.0, high: 20.0,
                    anchors: [-1.0, -0.5, 0.0, 0.5, 1.0]
                )
        },
        goldenAnchors: [-711.0, -710.4758600739439, -1.0, -0.0, 0.0, 1.0, 708.0, 710.4758600739439]
    )

    static let tanhProfile = MPFRUnaryAuditProfile(
        maxULP: 2,
        referenceEvaluator: { mpfr_ieee754_tanh($0) },
        sampleGenerator: { count in
            let half = (count + 1) / 2
            return MPFRDomainSamplers.uniformInterval(
                seed: 0xE01C, count: half, low: -25.0, high: 25.0,
                anchors: [-20.0, -0.5625, -0.5, 0.5, 0.500000000000002, 0.5625, 20.0]
            )
                + MPFRDomainSamplers.stratifiedExponents(
                    seed: 0xE01D, count: half, minExp: -1074, maxExp: 10, signed: true, anchors: [352.0]
                )
        },
        goldenAnchors: [-25.0, -0.5625, -0.0, 0.0, 0.500000000000002, 0.5625, 20.0, 352.0]
    )

    static let asinhProfile = MPFRUnaryAuditProfile(
        maxULP: 2,
        referenceEvaluator: { mpfr_ieee754_asinh($0) },
        sampleGenerator: { count in
            MPFRDomainSamplers.stratifiedExponents(
                seed: 0xE01E, count: count, minExp: -1074, maxExp: 1023, signed: true,
                anchors: [-0.5, 0.0, 0.5, 0x1.0p26]
            )
        },
        goldenAnchors: [-Double.greatestFiniteMagnitude, -0.5, -0.0, 0.0, 0.5, Double.greatestFiniteMagnitude]
    )

    static let acoshProfile = MPFRUnaryAuditProfile(
        maxULP: 2,
        referenceEvaluator: { mpfr_ieee754_acosh($0) },
        sampleGenerator: { count in
            MPFRDomainSamplers.acoshSamples(seed: 0xE01F, count: count, anchors: [1.0, 1.5, 2.0, 0x1.0p26])
        },
        goldenAnchors: [1.0, 1.0.nextUp, 1.0001, 1.5, 2.0, 0x1.0p26, Double.greatestFiniteMagnitude]
    )

    static let atanhProfile = MPFRUnaryAuditProfile(
        maxULP: 2,
        referenceEvaluator: { mpfr_ieee754_atanh($0) },
        sampleGenerator: { count in
            MPFRDomainSamplers.unitIntervalAndEdges(
                seed: 0xE020, count: count, includeEndpoints: false,
                anchors: [-1.0.nextUp, -0.5, 0.0, 0.5, 1.0.nextDown]
            )
        },
        goldenAnchors: [-1.0.nextUp, -0.5, -Double.leastNonzeroMagnitude, -0.0, 0.0, 0.5, 1.0.nextDown]
    )

    static let erfProfile = MPFRUnaryAuditProfile(
        maxULP: 2,
        referenceEvaluator: { mpfr_ieee754_erf($0) },
        sampleGenerator: { count in
            let half = (count + 1) / 2
            return MPFRDomainSamplers.uniformInterval(
                seed: 0xE021, count: half, low: -7.0, high: 7.0,
                anchors: [-6.0, -1.84, -0.84375, 0.84375, 1.84, 6.0]
            )
                + MPFRDomainSamplers.stratifiedExponents(
                    seed: 0xE022, count: half, minExp: -1074, maxExp: 5, signed: true, anchors: [0.0]
                )
        },
        goldenAnchors: [-6.5, -1.84, -0.84375, -0.0, 0.0, 0.84375, 1.84, 6.5]
    )

    static let erfcProfile = MPFRUnaryAuditProfile(
        maxULP: 6,
        referenceEvaluator: { mpfr_ieee754_erfc($0) },
        sampleGenerator: { count in
            MPFRDomainSamplers.uniformInterval(
                seed: 0xE023, count: count, low: -7.0, high: 28.0,
                anchors: [-6.0, 0.0, 0.84375, 1.84, 4.5, 26.54, 27.2, 27.35]
            )
        },
        goldenAnchors: [-6.0, 0.0, 0.84375, 1.84, 4.5, 26.54, 27.2, 27.35]
    )

    static let tgammaProfile = MPFRUnaryAuditProfile(
        maxULP: 4,
        referenceEvaluator: { mpfr_ieee754_tgamma($0) },
        sampleGenerator: { count in
            MPFRDomainSamplers.gammaSamples(
                seed: 0xE024, count: count, minX: -175.0, maxX: 171.624,
                anchors: [-170.5, -10.5, -0.5, 0.5, 1.0, 8.0, 170.0, 171.624]
            )
        },
        goldenAnchors: [-171.5, -170.5, -24.821860057464534, -10.5, -0.5, 0.5, 1.0, 8.0, 171.624]
    )

    static let lgammaProfile = MPFRUnaryAuditProfile(
        maxULP: 4,
        nearZeroAbsThreshold: 0.5,
        nearZeroAbsTolerance: 4.0 * Double.ulpOfOne,
        referenceEvaluator: { mpfr_ieee754_lgamma($0) },
        sampleGenerator: { count in
            MPFRDomainSamplers.gammaSamples(
                seed: 0xE025, count: count, minX: -200.0, maxX: 1.0e6,
                anchors: [-10.5, -2.7467848223885483, -1.5, -0.5, 0.5, 1.0, 1.5, 2.0, 8.0]
            )
        },
        goldenAnchors: [-100.5, -10.5, -1.5, -0.5, 0.5, 1.0, 1.5, 8.0, 1.0e100]
    )
}
