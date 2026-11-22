import Foundation
import SwiftSIMDMathTestSupport

extension SIMDUnaryOperation {
    static func scalarExp10(_ x: Double) -> Double {
        #if canImport(Darwin)
            __exp10(x)
        #else
            Foundation.pow(10.0, x)
        #endif
    }

    static let exp2Spec = UnaryTestSpec(
        maxULP: 1,
        homogeneousInputs: [-100.0, -10.5, -1.0, -0.5, 0.0, 0.5, 1.0, 10.0, 100.0, 500.0],
        heterogeneousLanes: [
            [-50.0, -0.5, 0.5, 10.0, -1050.0, 0.0, 1023.0, 3.25],
            [1.0, .nan, -1080.0, .infinity, -.infinity, -1074.0, 1024.0, -0.0]
        ],
        stabilityTransitions: [
            -1080.0, -1075.0, -1074.0, -1050.0, -1023.0, -1022.0, -1021.0,
            -1.0e-15, 0.0, 1.0e-15, 10.0, 1021.0, 1022.0, 1023.0, 1023.9999999999999, 1024.0, 1030.0
        ],
        classExpectation: { cls in
            switch cls {
            case .negativeInfinity: .positiveZero
            case .negativeNormal: .finite(Foundation.exp2(cls.representative), maxULP: 1)
            case .negativeSubnormal, .negativeZero, .positiveZero, .positiveSubnormal: .exact(1.0)
            case .positiveNormal: .finite(Foundation.exp2(cls.representative), maxULP: 1)
            case .positiveInfinity: .positiveInfinity
            case .quietNaN, .signalingNaN: .nan
            }
        },
        oracle: { Foundation.exp2($0) },
        exponentSweepEligible: { $0.isFinite }
    )

    static let exp10Spec = UnaryTestSpec(
        maxULP: 1,
        homogeneousInputs: [-50.0, -3.5, -1.0, -0.15, 0.0, 0.15, 1.0, 2.0, 10.0, 22.0, 100.0],
        heterogeneousLanes: [
            [-20.0, -0.3, 0.3, 5.0, -315.0, 0.0, 307.0, 1.5],
            [1.0, .nan, -330.0, .infinity, -.infinity, -323.0, 308.25, -0.0]
        ],
        stabilityTransitions: [
            -330.0, -324.0, -323.3, -315.0, -308.0, -307.0, -1.0e-15, 0.0, 1.0e-15,
            1.0, 2.0, 6.0, 22.0, 306.0, 307.0, 308.0, 308.2547, 309.0
        ],
        classExpectation: { cls in
            switch cls {
            case .negativeInfinity: .positiveZero
            case .negativeNormal: .finite(Self.scalarExp10(cls.representative), maxULP: 1)
            case .negativeSubnormal, .negativeZero, .positiveZero, .positiveSubnormal: .exact(1.0)
            case .positiveNormal: .finite(Self.scalarExp10(cls.representative), maxULP: 1)
            case .positiveInfinity: .positiveInfinity
            case .quietNaN, .signalingNaN: .nan
            }
        },
        oracle: { Self.scalarExp10($0) },
        exponentSweepEligible: { $0.isFinite }
    )

    static let expm1Spec = UnaryTestSpec(
        maxULP: 2,
        homogeneousInputs: [-50.0, -5.0, -0.5, -1.0e-8, -0.0, 0.0, 1.0e-8, 0.34, 0.5, 5.0, 50.0],
        heterogeneousLanes: [
            [-10.0, -0.2, 1.0e-12, 0.2, 10.0, -45.0, 709.0, 0.693],
            [1.0, .nan, -100.0, .infinity, -.infinity, -0.0, 710.0, Double.leastNonzeroMagnitude]
        ],
        stabilityTransitions: [
            -750.0, -45.0, -40.0, -37.0, -1.0, -0.34657359, -1.0e-10, -1.0e-16,
            -Double.leastNormalMagnitude, -Double.leastNonzeroMagnitude, -0.0, 0.0,
            Double.leastNonzeroMagnitude, Double.leastNormalMagnitude, 1.0e-16, 1.0e-10,
            0.34657359, 0.69314718, 1.0, 708.0, Double(bitPattern: 0x4086_2E42_FEFA_39EF), 750.0
        ],
        classExpectation: { cls in
            switch cls {
            case .negativeInfinity: .exact(-1.0)
            case .negativeNormal: .finite(Foundation.expm1(cls.representative), maxULP: 2)
            case .negativeSubnormal: .subnormal(cls.representative, maxULP: 1)
            case .negativeZero: .negativeZero
            case .positiveZero: .positiveZero
            case .positiveSubnormal: .subnormal(cls.representative, maxULP: 1)
            case .positiveNormal: .finite(Foundation.expm1(cls.representative), maxULP: 2)
            case .positiveInfinity: .positiveInfinity
            case .quietNaN, .signalingNaN: .nan
            }
        },
        oracle: { Foundation.expm1($0) },
        exponentSweepEligible: { $0.isFinite }
    )

    static let log1pSpec = UnaryTestSpec(
        maxULP: 2,
        homogeneousInputs: [-0.999, -0.5, -0.1, -1.0e-10, -0.0, 0.0, 1.0e-10, 0.1, 0.5, 1.0, 100.0],
        heterogeneousLanes: [
            [-0.9, -0.25, -1.0e-12, 1.0e-12, 0.25, 1.0, 10.0, 1.0e20],
            [0.5, -1.0, -2.0, .infinity, -.infinity, .nan, -0.0, Double.greatestFiniteMagnitude]
        ],
        stabilityTransitions: [
            -1.0.nextUp, -0.999999, -0.5, -0.29289322, -1.0e-6, -1.0e-12, -1.0e-16,
            -Double.leastNormalMagnitude, -Double.leastNonzeroMagnitude, -0.0, 0.0,
            Double.leastNonzeroMagnitude, Double.leastNormalMagnitude, 1.0e-16, 1.0e-12, 1.0e-6,
            0.41421356, 1.0.nextDown, 1.0, 1.0.nextUp, 1.0e20, 1.0e300, Double.greatestFiniteMagnitude
        ],
        classExpectation: { cls in
            switch cls {
            case .negativeInfinity, .negativeNormal, .quietNaN, .signalingNaN: .nan
            case .negativeSubnormal: .subnormal(cls.representative, maxULP: 1)
            case .negativeZero: .negativeZero
            case .positiveZero: .positiveZero
            case .positiveSubnormal: .subnormal(cls.representative, maxULP: 1)
            case .positiveNormal: .finite(Foundation.log1p(cls.representative), maxULP: 2)
            case .positiveInfinity: .positiveInfinity
            }
        },
        oracle: { Foundation.log1p($0) },
        exponentSweepEligible: { $0 > -1.0 && $0.isFinite }
    )
}
