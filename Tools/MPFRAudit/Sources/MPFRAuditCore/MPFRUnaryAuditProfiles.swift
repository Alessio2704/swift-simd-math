import CMPFRBridge
import SwiftSIMDMathTestSupport

// MARK: - Compile-Time Exhaustive Unary MPFR Certification Profiles (Exp, Log & Core Trig)

extension SIMDUnaryOperation {
    /// Exhaustive MPFR certification profile for every unary operation (zero `default:` branches).
    /// Adding a new case to `SIMDUnaryOperation` causes a hard compile error here until certified.
    var mpfrAuditProfile: MPFRUnaryAuditProfile {
        switch self {
        case .exp: Self.expProfile
        case .exp2: Self.exp2Profile
        case .exp10: Self.exp10Profile
        case .expm1: Self.expm1Profile
        case .log: Self.logProfile
        case .log2: Self.log2Profile
        case .log10: Self.log10Profile
        case .log1p: Self.log1pProfile
        case .sin: Self.sinProfile
        case .cos: Self.cosProfile
        case .tan: Self.tanProfile
        case .asin: Self.asinProfile
        case .acos: Self.acosProfile
        case .atan: Self.atanProfile
        case .sinpi: Self.sinpiProfile
        case .cospi: Self.cospiProfile
        case .tanpi: Self.tanpiProfile
        case .abs: Self.absProfile
        case .cbrt: Self.cbrtProfile
        case .sign: Self.signProfile
        case .fract: Self.fractProfile
        case .sinh: Self.sinhProfile
        case .cosh: Self.coshProfile
        case .tanh: Self.tanhProfile
        case .asinh: Self.asinhProfile
        case .acosh: Self.acoshProfile
        case .atanh: Self.atanhProfile
        case .erf: Self.erfProfile
        case .erfc: Self.erfcProfile
        case .tgamma: Self.tgammaProfile
        case .lgamma: Self.lgammaProfile
        }
    }

    private static let expProfile = MPFRUnaryAuditProfile(
        maxULP: 1,
        referenceEvaluator: { mpfr_ieee754_exp($0) },
        sampleGenerator: { count in
            MPFRDomainSamplers.uniformInterval(
                seed: 0xE001, count: count, low: -750.0, high: 715.0,
                anchors: [-745.1332191019412, -708.3964185322641, -0.0, 0.0, 709.782712893384]
            )
                + MPFRDomainSamplers.stratifiedExponents(
                    seed: 0xE002, count: count / 4, minExp: -1074, maxExp: 10, signed: true, anchors: []
                )
        },
        goldenAnchors: [-746.0, -745.1332191019412, -708.3964185322641, -1.0, -0.0, 0.0, 1.0, 709.782712893384]
    )

    private static let exp2Profile = MPFRUnaryAuditProfile(
        maxULP: 1,
        referenceEvaluator: { mpfr_ieee754_exp2($0) },
        sampleGenerator: { count in
            MPFRDomainSamplers.uniformInterval(
                seed: 0xE003, count: count, low: -1080.0, high: 1030.0,
                anchors: [-1074.0, -1022.0, 0.0, 1023.0, 1024.0]
            )
        },
        goldenAnchors: [-1075.0, -1074.0, -1022.0, -0.0, 0.0, 0.5, 1023.0, 1024.0]
    )

    private static let exp10Profile = MPFRUnaryAuditProfile(
        maxULP: 1,
        referenceEvaluator: { mpfr_ieee754_exp10($0) },
        sampleGenerator: { count in
            MPFRDomainSamplers.uniformInterval(
                seed: 0xE004, count: count, low: -326.0, high: 312.0,
                anchors: [-323.3062153431158, -307.6526555685888, 0.0, 308.2547155599167]
            )
        },
        goldenAnchors: [-324.0, -323.3, -307.65, -0.0, 0.0, 1.0, 308.2547155599167, 309.0]
    )

    private static let expm1Profile = MPFRUnaryAuditProfile(
        maxULP: 2,
        referenceEvaluator: { mpfr_ieee754_expm1($0) },
        sampleGenerator: { count in
            let half = (count + 1) / 2
            return MPFRDomainSamplers.uniformInterval(
                seed: 0xE005, count: half, low: -45.0, high: 712.0,
                anchors: [-37.0, -0.34657359027997264, 0.34657359027997264, 709.782712893384]
            )
                + MPFRDomainSamplers.stratifiedExponents(
                    seed: 0xE006, count: half, minExp: -1074, maxExp: 2, signed: true, anchors: [0.0]
                )
        },
        goldenAnchors: [-40.0, -0.35, -1.0e-12, -0.0, 0.0, 1.0e-12, 0.3760586277533662, 709.782712893384]
    )

    private static let logProfile = MPFRUnaryAuditProfile(
        maxULP: 1,
        referenceEvaluator: { mpfr_ieee754_log($0) },
        sampleGenerator: { count in
            MPFRDomainSamplers.stratifiedExponents(
                seed: 0xE007, count: count, minExp: -1074, maxExp: 1023, signed: false,
                anchors: [Double.leastNonzeroMagnitude, Double.leastNormalMagnitude, 0.7071067811865476, 1.0]
            )
        },
        goldenAnchors: [Double.leastNonzeroMagnitude, Double.leastNormalMagnitude, 0.5, 1.0.nextDown, 1.0, 2.0]
    )

    private static let log2Profile = MPFRUnaryAuditProfile(
        maxULP: 1,
        referenceEvaluator: { mpfr_ieee754_log2($0) },
        sampleGenerator: { count in
            MPFRDomainSamplers.stratifiedExponents(
                seed: 0xE008, count: count, minExp: -1074, maxExp: 1023, signed: false,
                anchors: [Double.leastNonzeroMagnitude, Double.leastNormalMagnitude, 1.0, 2.0]
            )
        },
        goldenAnchors: [Double.leastNonzeroMagnitude, Double.leastNormalMagnitude, 0.5, 1.0.nextDown, 1.0, 0x1.0p500]
    )

    private static let log10Profile = MPFRUnaryAuditProfile(
        maxULP: 1,
        referenceEvaluator: { mpfr_ieee754_log10($0) },
        sampleGenerator: { count in
            MPFRDomainSamplers.stratifiedExponents(
                seed: 0xE009, count: count, minExp: -1074, maxExp: 1023, signed: false,
                anchors: [Double.leastNonzeroMagnitude, Double.leastNormalMagnitude, 1.0, 10.0]
            )
        },
        goldenAnchors: [Double.leastNonzeroMagnitude, Double.leastNormalMagnitude, 0.1, 1.0.nextDown, 1.0, 1.0e100]
    )

    private static let log1pProfile = MPFRUnaryAuditProfile(
        maxULP: 1,
        referenceEvaluator: { mpfr_ieee754_log1p($0) },
        sampleGenerator: { count in
            let half = (count + 1) / 2
            return MPFRDomainSamplers.stratifiedExponents(
                seed: 0xE00A, count: half, minExp: -1074, maxExp: 1023, signed: false,
                anchors: [0.4142135623730951]
            )
                + MPFRDomainSamplers.uniformInterval(
                    seed: 0xE00B, count: half, low: -0.9999999999999999, high: 1.0,
                    anchors: [-0.9999999999999999, -0.2928932188134525, 0.0]
                )
        },
        goldenAnchors: [-1.0.nextUp, -0.2928932188134525, -0.0, 0.0, 0.4142135623730951, Double.greatestFiniteMagnitude]
    )

    private static let sinProfile = MPFRUnaryAuditProfile(
        maxULP: 2,
        referenceEvaluator: { mpfr_ieee754_sin($0) },
        sampleGenerator: { count in
            MPFRDomainSamplers.stratifiedExponents(
                seed: 0xE00C, count: count, minExp: -1074, maxExp: 1023, signed: true,
                anchors: MPFRDomainSamplers.trigCriticalAnchors
            )
        },
        goldenAnchors: MPFRDomainSamplers.trigCriticalAnchors
    )

    private static let cosProfile = MPFRUnaryAuditProfile(
        maxULP: 2,
        referenceEvaluator: { mpfr_ieee754_cos($0) },
        sampleGenerator: { count in
            MPFRDomainSamplers.stratifiedExponents(
                seed: 0xE00D, count: count, minExp: -1074, maxExp: 1023, signed: true,
                anchors: MPFRDomainSamplers.trigCriticalAnchors
            )
        },
        goldenAnchors: MPFRDomainSamplers.trigCriticalAnchors
    )

    private static let tanProfile = MPFRUnaryAuditProfile(
        maxULP: 2,
        referenceEvaluator: { mpfr_ieee754_tan($0) },
        sampleGenerator: { count in
            MPFRDomainSamplers.stratifiedExponents(
                seed: 0xE00E, count: count, minExp: -1074, maxExp: 1023, signed: true,
                anchors: MPFRDomainSamplers.trigCriticalAnchors
            )
        },
        goldenAnchors: MPFRDomainSamplers.trigCriticalAnchors
    )
}
