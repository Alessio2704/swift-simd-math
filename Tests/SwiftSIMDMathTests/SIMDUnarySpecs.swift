import Foundation
import SwiftSIMDMathTestSupport

// MARK: - Compile-Time Exhaustive Unary Specs (Zero default: Branches)

extension SIMDUnaryOperation {
    var spec: UnaryTestSpec {
        switch self {
        case .exp: Self.expSpec
        case .exp2: Self.exp2Spec
        case .exp10: Self.exp10Spec
        case .expm1: Self.expm1Spec
        case .log: Self.logSpec
        case .log2: Self.log2Spec
        case .log10: Self.log10Spec
        case .log1p: Self.log1pSpec
        case .sin: Self.sinSpec
        case .cos: Self.cosSpec
        case .tan: Self.tanSpec
        case .asin: Self.asinSpec
        case .acos: Self.acosSpec
        case .atan: Self.atanSpec
        case .sinpi: Self.sinpiSpec
        case .cospi: Self.cospiSpec
        case .tanpi: Self.tanpiSpec
        case .abs: Self.absSpec
        case .cbrt: Self.cbrtSpec
        case .sign: Self.signSpec
        case .fract: Self.fractSpec
        case .sinh: Self.sinhSpec
        case .cosh: Self.coshSpec
        case .tanh: Self.tanhSpec
        case .asinh: Self.asinhSpec
        case .acosh: Self.acoshSpec
        case .atanh: Self.atanhSpec
        case .erf: Self.erfSpec
        case .erfc: Self.erfcSpec
        case .tgamma: Self.tgammaSpec
        case .lgamma: Self.lgammaSpec
        }
    }

    private static let expTransitions: [Double] = [
        -750.0,
        Double(bitPattern: 0xC087_4910_D52D_3052),
        Double(bitPattern: 0xC087_4910_D52D_3051),
        -740.0,
        -720.0,
        -708.3964185322641,
        -708.0,
        -100.0,
        -1.0e-15,
        1.0e-15,
        100.0,
        708.0,
        Double(bitPattern: 0x4086_2E42_FEFA_39EF),
        Double(bitPattern: 0x4086_2E42_FEFA_39F0),
        750.0
    ]

    private static let logTransitions: [Double] = [
        Double.leastNonzeroMagnitude,
        Double.leastNonzeroMagnitude * 7.0,
        Double.leastNormalMagnitude.nextDown,
        Double.leastNormalMagnitude,
        Double.leastNormalMagnitude.nextUp,
        1.0.nextDown,
        1.0,
        1.0.nextUp,
        (2.0).squareRoot().nextDown,
        (2.0).squareRoot(),
        (2.0).squareRoot().nextUp,
        10.0,
        1.0e100,
        1.0e300,
        Double.greatestFiniteMagnitude
    ]

    private static let expSpec = UnaryTestSpec(
        maxULP: 1,
        homogeneousInputs: [-15.0, -5.0, -1.0, -0.34657359, 0.0, 0.34657359, 1.0, 5.0, 10.0, 50.0],
        heterogeneousLanes: [
            [-12.0, -0.5, 0.5, 12.0, -720.0, 0.0, 709.0, 3.5],
            [1.0, .nan, -750.0, .infinity, -.infinity, -730.0, 709.78, -0.0]
        ],
        stabilityTransitions: expTransitions,
        classExpectation: { cls in
            switch cls {
            case .negativeInfinity: .positiveZero
            case .negativeNormal: .finite(Foundation.exp(cls.representative), maxULP: 1)
            case .negativeSubnormal, .negativeZero, .positiveZero, .positiveSubnormal: .exact(1.0)
            case .positiveNormal: .finite(Foundation.exp(cls.representative), maxULP: 1)
            case .positiveInfinity: .positiveInfinity
            case .quietNaN, .signalingNaN: .nan
            }
        },
        oracle: { Foundation.exp($0) },
        exponentSweepEligible: { $0.isFinite }
    )

    private static let logSpec = makeLogSpec { Foundation.log($0) }
    private static let log2Spec = makeLogSpec { Foundation.log2($0) }
    private static let log10Spec = makeLogSpec { Foundation.log10($0) }

    private static func makeLogSpec(oracle: @escaping @Sendable (Double) -> Double) -> UnaryTestSpec {
        let eligible: @Sendable (Double) -> Bool = { $0 > 0.0 && $0.isFinite }
        return UnaryTestSpec(
            maxULP: 2,
            homogeneousInputs: [1.0e-4, 0.1, 0.5, 0.70710678, 1.0, 1.41421356, 2.0, 10.0, 1000.0],
            heterogeneousLanes: [
                [0.25, 0.9, 1.1, 1.5, 2.0, 10.0, 100.0, 1.0e-5],
                [2.0, 0.0, -1.0, .infinity, -.infinity, .nan, Double.leastNonzeroMagnitude * 8.0, 1.0]
            ],
            stabilityTransitions: logTransitions,
            classExpectation: { cls in
                switch cls {
                case .negativeInfinity, .negativeNormal, .negativeSubnormal, .quietNaN, .signalingNaN: .nan
                case .negativeZero, .positiveZero: .negativeInfinity
                case .positiveSubnormal, .positiveNormal: .finite(oracle(cls.representative), maxULP: 2)
                case .positiveInfinity: .positiveInfinity
                }
            },
            oracle: oracle,
            exponentSweepEligible: eligible
        )
    }

    private static let absSpec = UnaryTestSpec(
        maxULP: 0,
        homogeneousInputs: [-100.0, -1.0, -0.0, 0.0, 1.0, 100.0],
        heterogeneousLanes: [
            [-5.0, 3.0, -0.0, 0.0, -.infinity, .infinity, .nan, -Double.leastNonzeroMagnitude]
        ],
        stabilityTransitions: [
            -Double.greatestFiniteMagnitude, -Double.leastNormalMagnitude, -Double.leastNonzeroMagnitude,
            -0.0, 0.0, Double.leastNonzeroMagnitude, Double.leastNormalMagnitude, Double.greatestFiniteMagnitude
        ],
        classExpectation: { cls in
            switch cls {
            case .negativeInfinity, .positiveInfinity: .positiveInfinity
            case .negativeZero, .positiveZero: .positiveZero
            case .negativeSubnormal, .positiveSubnormal: .exact(Swift.abs(cls.representative))
            case .negativeNormal, .positiveNormal: .exact(Swift.abs(cls.representative))
            case .quietNaN, .signalingNaN: .nan
            }
        },
        oracle: { Swift.abs($0) },
        exponentSweepEligible: { $0.isFinite }
    )
}
