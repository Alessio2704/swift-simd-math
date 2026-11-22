import Foundation
import SwiftSIMDMathTestSupport

// MARK: - Cube Root & Unary Shaping Grounding Specs (cbrt, sign, fract)

extension SIMDUnaryOperation {
    static let cbrtSpec = UnaryTestSpec(
        maxULP: 1,
        homogeneousInputs: [-1000.0, -27.0, -8.0, -1.0, -0.125, -0.0, 0.0, 0.125, 1.0, 8.0, 27.0, 1000.0],
        heterogeneousLanes: [
            [-64.0, -2.0, -0.5, -Double.leastNonzeroMagnitude, Double.leastNonzeroMagnitude, 0.5, 2.0, 64.0],
            [8.0, -8.0, -0.0, 0.0, .infinity, -.infinity, .nan, Double.greatestFiniteMagnitude]
        ],
        stabilityTransitions: [
            -Double.greatestFiniteMagnitude, -1.0e300, -1000.0, -8.0, -1.0,
            -Double.leastNormalMagnitude, -Double.leastNormalMagnitude.nextDown, -Double.leastNonzeroMagnitude,
            -0.0, 0.0, Double.leastNonzeroMagnitude, Double.leastNormalMagnitude.nextDown,
            Double.leastNormalMagnitude, 1.0, 2.0, 4.0, 8.0, 27.0, 64.0, 1.0e300, Double.greatestFiniteMagnitude
        ],
        classExpectation: { cls in
            switch cls {
            case .negativeInfinity:
                .negativeInfinity

            case .positiveInfinity:
                .positiveInfinity

            case .negativeZero:
                .negativeZero

            case .positiveZero:
                .positiveZero

            case .negativeSubnormal, .positiveSubnormal, .negativeNormal, .positiveNormal:
                .finite(SIMDExactReferenceOracles.cubeRoot(cls.representative), maxULP: 1)

            case .quietNaN, .signalingNaN:
                .nan
            }
        },
        oracle: { SIMDExactReferenceOracles.cubeRoot($0) },
        exponentSweepEligible: { $0.isFinite }
    )

    static let signSpec = UnaryTestSpec(
        maxULP: 0,
        homogeneousInputs: [-100.0, -1.0, -Double.leastNonzeroMagnitude, -0.0, 0.0, Double.leastNonzeroMagnitude, 1.0],
        heterogeneousLanes: [
            [-5.0, -0.0, 0.0, 3.0, -.infinity, .infinity, .nan, -Double.leastNonzeroMagnitude]
        ],
        stabilityTransitions: [
            -Double.greatestFiniteMagnitude, -Double.leastNormalMagnitude, -Double.leastNonzeroMagnitude,
            -0.0, 0.0, Double.leastNonzeroMagnitude, Double.leastNormalMagnitude, Double.greatestFiniteMagnitude
        ],
        classExpectation: { cls in
            switch cls {
            case .negativeInfinity, .negativeNormal, .negativeSubnormal: .exact(-1.0)
            case .negativeZero, .positiveZero, .quietNaN, .signalingNaN: .positiveZero
            case .positiveSubnormal, .positiveNormal, .positiveInfinity: .exact(1.0)
            }
        },
        oracle: { x in
            if x < 0.0 { return -1.0 }
            if x > 0.0 { return 1.0 }
            return 0.0
        },
        exponentSweepEligible: { $0.isFinite }
    )

    static let fractSpec = UnaryTestSpec(
        maxULP: 0,
        homogeneousInputs: [-2.75, -1.0, -0.5, -Double.leastNonzeroMagnitude, -0.0, 0.0, 0.25, 1.0, 2.75],
        heterogeneousLanes: [
            [-2.5, -1.0, -Double.leastNonzeroMagnitude, -0.0, 0.0, Double.leastNonzeroMagnitude, 0.5, 3.75],
            [-0.25, 0.25, -.infinity, .infinity, .nan, 0x1.0p52, -0x1.0p52, Double.greatestFiniteMagnitude]
        ],
        stabilityTransitions: [
            -Double.greatestFiniteMagnitude, -0x1.0p52, -2.0, -1.0.nextUp, -1.0, -1.0.nextDown,
            -Double.leastNonzeroMagnitude, -0.0, 0.0, Double.leastNonzeroMagnitude,
            1.0.nextDown, 1.0, 1.0.nextUp, 0x1.0p52, Double.greatestFiniteMagnitude
        ],
        classExpectation: { cls in
            switch cls {
            case .negativeInfinity, .positiveInfinity, .quietNaN, .signalingNaN:
                .exact(0x1.FFFF_FFFF_FFFF_Fp-1)

            case .negativeSubnormal:
                .exact(0x1.FFFF_FFFF_FFFF_Fp-1)

            case .negativeZero, .positiveZero:
                .positiveZero

            case .positiveSubnormal, .negativeNormal, .positiveNormal:
                .exact(
                    SIMDExactReferenceOracles.ieeeMinimumNumber(
                        cls.representative - cls.representative.rounded(.down), 0x1.FFFF_FFFF_FFFF_Fp-1))
            }
        },
        oracle: { x in
            SIMDExactReferenceOracles.ieeeMinimumNumber(x - x.rounded(.down), 0x1.FFFF_FFFF_FFFF_Fp-1)
        },
        exponentSweepEligible: { $0.isFinite }
    )
}
