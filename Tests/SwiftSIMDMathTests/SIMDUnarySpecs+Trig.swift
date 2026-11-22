import Foundation
import SwiftSIMDMathTestSupport

// MARK: - Trigonometric & Inverse Trigonometric Unary Grounding Specs

extension SIMDUnaryOperation {
    static let trigTransitions: [Double] = [
        -Double.greatestFiniteMagnitude, -1.0e100, -6.13489952541704500e+15,
        -524_288.0.nextUp, -524_288.0, -524_288.0.nextDown,
        -Double.pi * 2.0, -Double.pi, -Double.pi * 0.5, -Double.pi * 0.25,
        Double.pi * 0.25, Double.pi * 0.5, Double.pi, Double.pi * 2.0,
        524_288.0.nextDown, 524_288.0, 524_288.0.nextUp,
        Double(bitPattern: 0x4164_5525_B1B6_F85C),
        7.43570781478630000e+13, 2.14112296674652000e+14,
        5.92078722874239300e+15, 6.13489952541704500e+15,
        Double(bitPattern: 0x43CE_3957_08F0_5C22),
        1.0e22, 1.0e100, 1.0e200, 1.0e300, Double.greatestFiniteMagnitude
    ]

    static let sinSpec = UnaryTestSpec(
        maxULP: 2,
        homogeneousInputs: [-10.5, -3.141592653589793, -1.0, -0.1, 0.0, 0.1, 1.0, 2.5, 10.5],
        heterogeneousLanes: [
            [-3.0, -1.2, -0.3, 0.4, 1.1, 2.3, 3.8, 5.5],
            [0.5, -0.0, 0.0, .infinity, -.infinity, .nan, 1.0e22, -1.0e100]
        ],
        stabilityTransitions: trigTransitions,
        classExpectation: { cls in
            switch cls {
            case .negativeInfinity, .positiveInfinity, .quietNaN, .signalingNaN:
                .nan

            case .negativeZero:
                .negativeZero

            case .positiveZero:
                .positiveZero

            case .negativeSubnormal, .positiveSubnormal:
                .subnormal(cls.representative, maxULP: 1)

            case .negativeNormal, .positiveNormal:
                .finite(SIMDExactReferenceOracles.sine(cls.representative), maxULP: 2)
            }
        },
        oracle: { SIMDExactReferenceOracles.sine($0) },
        exponentSweepEligible: { $0.isFinite }
    )

    static let cosSpec = UnaryTestSpec(
        maxULP: 2,
        homogeneousInputs: [-10.5, -3.141592653589793, -1.0, -0.1, 0.0, 0.1, 1.0, 2.5, 10.5],
        heterogeneousLanes: [
            [-3.0, -1.2, -0.3, 0.4, 1.1, 2.3, 3.8, 5.5],
            [0.5, -0.0, 0.0, .infinity, -.infinity, .nan, 1.0e22, -1.0e100]
        ],
        stabilityTransitions: trigTransitions,
        classExpectation: { cls in
            switch cls {
            case .negativeInfinity, .positiveInfinity, .quietNaN, .signalingNaN:
                .nan

            case .negativeSubnormal, .negativeZero, .positiveZero, .positiveSubnormal:
                .exact(1.0)

            case .negativeNormal, .positiveNormal:
                .finite(SIMDExactReferenceOracles.cosine(cls.representative), maxULP: 2)
            }
        },
        oracle: { SIMDExactReferenceOracles.cosine($0) },
        exponentSweepEligible: { $0.isFinite }
    )

    // Darwin Foundation.tan deviates by up to 2 ULP near pi/4 (so a <= 1-2 ULP SIMD kernel can differ by 3 ULP).
    static let tanSpec = UnaryTestSpec(
        maxULP: 3,
        homogeneousInputs: [-10.5, -3.141592653589793, -1.0, -0.1, 0.0, 0.1, 1.0, 2.5, 10.5],
        heterogeneousLanes: [
            [-3.0, -1.2, -0.3, 0.4, 1.1, 2.3, 3.8, 5.5],
            [0.5, -0.0, 0.0, .infinity, -.infinity, .nan, 1.0e22, -1.0e100]
        ],
        stabilityTransitions: trigTransitions,
        classExpectation: { cls in
            switch cls {
            case .negativeInfinity, .positiveInfinity, .quietNaN, .signalingNaN:
                .nan

            case .negativeZero:
                .negativeZero

            case .positiveZero:
                .positiveZero

            case .negativeSubnormal, .positiveSubnormal:
                .subnormal(cls.representative, maxULP: 1)

            case .negativeNormal, .positiveNormal:
                .finite(SIMDExactReferenceOracles.tangent(cls.representative), maxULP: 2)
            }
        },
        oracle: { SIMDExactReferenceOracles.tangent($0) },
        exponentSweepEligible: { $0.isFinite }
    )

    static let asinSpec = UnaryTestSpec(
        maxULP: 2,
        homogeneousInputs: [-1.0, -0.9, -0.5, -0.25, -0.0, 0.0, 0.25, 0.5, 0.9, 1.0],
        heterogeneousLanes: [
            [-1.0, -0.75, -0.5, -0.1, 0.1, 0.5, 0.75, 1.0],
            [0.5, -0.0, 0.0, 1.5, -1.5, .infinity, -.infinity, .nan]
        ],
        stabilityTransitions: [
            -1.0, -1.0.nextUp, -0.5.nextUp, -0.5, -0.5.nextDown, -Double.leastNonzeroMagnitude,
            -0.0, 0.0, Double.leastNonzeroMagnitude, 0.5.nextDown, 0.5, 0.5.nextUp, 1.0.nextDown, 1.0
        ],
        classExpectation: { cls in
            switch cls {
            case .negativeInfinity, .negativeNormal, .positiveNormal, .positiveInfinity, .quietNaN, .signalingNaN:
                .nan

            case .negativeSubnormal, .positiveSubnormal:
                .subnormal(cls.representative, maxULP: 1)

            case .negativeZero:
                .negativeZero

            case .positiveZero:
                .positiveZero
            }
        },
        oracle: { Foundation.asin($0) },
        exponentSweepEligible: { Swift.abs($0) <= 1.0 }
    )

    static let acosSpec = UnaryTestSpec(
        maxULP: 2,
        homogeneousInputs: [-1.0, -0.9, -0.5, -0.25, -0.0, 0.0, 0.25, 0.5, 0.9, 1.0],
        heterogeneousLanes: [
            [-1.0, -0.75, -0.5, -0.1, 0.1, 0.5, 0.75, 1.0],
            [0.5, -0.0, 0.0, 1.5, -1.5, .infinity, -.infinity, .nan]
        ],
        stabilityTransitions: [
            -1.0, -1.0.nextUp, -0.5.nextUp, -0.5, -0.5.nextDown, -Double.leastNonzeroMagnitude,
            -0.0, 0.0, Double.leastNonzeroMagnitude, 0.5.nextDown, 0.5, 0.5.nextUp, 1.0.nextDown, 1.0
        ],
        classExpectation: { cls in
            switch cls {
            case .negativeInfinity, .negativeNormal, .positiveNormal, .positiveInfinity, .quietNaN, .signalingNaN:
                .nan

            case .negativeSubnormal, .negativeZero, .positiveZero, .positiveSubnormal:
                .finite(Double.pi * 0.5, maxULP: 1)
            }
        },
        oracle: { Foundation.acos($0) },
        exponentSweepEligible: { Swift.abs($0) <= 1.0 }
    )

    static let atanSpec = UnaryTestSpec(
        maxULP: 2,
        homogeneousInputs: [-100.0, -2.5, -1.0, -0.4, -0.0, 0.0, 0.4, 1.0, 2.5, 100.0],
        heterogeneousLanes: [
            [-10.0, -2.4, -0.42, -0.1, 0.1, 0.42, 2.4, 10.0],
            [1.0, -0.0, 0.0, .infinity, -.infinity, .nan, 1.0e100, -Double.greatestFiniteMagnitude]
        ],
        stabilityTransitions: [
            -Double.greatestFiniteMagnitude, -1.0e100, -2.414213562373095, -1.0, -0.414213562373095,
            -Double.leastNonzeroMagnitude, -0.0, 0.0, Double.leastNonzeroMagnitude,
            0.414213562373095, 1.0, 2.414213562373095, 1.0e100, Double.greatestFiniteMagnitude
        ],
        classExpectation: { cls in
            switch cls {
            case .negativeInfinity: .finite(-Double.pi * 0.5, maxULP: 1)
            case .positiveInfinity: .finite(Double.pi * 0.5, maxULP: 1)
            case .negativeZero: .negativeZero
            case .positiveZero: .positiveZero
            case .negativeSubnormal, .positiveSubnormal: .subnormal(cls.representative, maxULP: 1)
            case .negativeNormal, .positiveNormal: .finite(Foundation.atan(cls.representative), maxULP: 2)
            case .quietNaN, .signalingNaN: .nan
            }
        },
        oracle: { Foundation.atan($0) },
        exponentSweepEligible: { $0.isFinite }
    )
}
