import Foundation
import SwiftSIMDMathTestSupport

extension SIMDUnaryOperation {
    static let sinhSpec = UnaryTestSpec(
        maxULP: 2,
        homogeneousInputs: [-50.0, -5.0, -1.0, -1.0e-8, -0.0, 0.0, 1.0e-8, 1.0, 5.0, 50.0],
        heterogeneousLanes: [
            [-10.0, -0.5, 1.0e-12, 0.5, 10.0, 709.9, -710.2, 2.5],
            [1.0, .nan, -715.0, .infinity, -.infinity, -0.0, 710.4, Double.leastNonzeroMagnitude]
        ],
        stabilityTransitions: [
            -715.0, -710.4758, -710.0, -709.78, -708.0, -22.0, -1.0, -1.0e-10,
            -Double.leastNonzeroMagnitude, -0.0, 0.0, Double.leastNonzeroMagnitude,
            1.0e-10, 1.0, 22.0, 708.0, 709.78, 710.0, 710.4758, 715.0
        ],
        classExpectation: { cls in
            switch cls {
            case .negativeInfinity: .negativeInfinity
            case .negativeNormal: .finite(Foundation.sinh(cls.representative), maxULP: 2)
            case .negativeSubnormal: .subnormal(cls.representative, maxULP: 1)
            case .negativeZero: .negativeZero
            case .positiveZero: .positiveZero
            case .positiveSubnormal: .subnormal(cls.representative, maxULP: 1)
            case .positiveNormal: .finite(Foundation.sinh(cls.representative), maxULP: 2)
            case .positiveInfinity: .positiveInfinity
            case .quietNaN, .signalingNaN: .nan
            }
        },
        oracle: { Foundation.sinh($0) },
        exponentSweepEligible: { $0.isFinite }
    )

    static let coshSpec = UnaryTestSpec(
        maxULP: 2,
        homogeneousInputs: [-50.0, -5.0, -1.0, -1.0e-8, -0.0, 0.0, 1.0e-8, 1.0, 5.0, 50.0],
        heterogeneousLanes: [
            [-10.0, -0.5, 0.0, 0.5, 10.0, 709.9, -710.2, 2.5],
            [1.0, .nan, -715.0, .infinity, -.infinity, -0.0, 710.4, Double.leastNonzeroMagnitude]
        ],
        stabilityTransitions: [
            -715.0, -710.4758, -710.0, -709.78, -708.0, -22.0, -1.0, -1.0e-10,
            -0.0, 0.0, 1.0e-10, 1.0, 22.0, 708.0, 709.78, 710.0, 710.4758, 715.0
        ],
        classExpectation: { cls in
            switch cls {
            case .negativeInfinity, .positiveInfinity: .positiveInfinity
            case .negativeNormal, .positiveNormal: .finite(Foundation.cosh(cls.representative), maxULP: 2)
            case .negativeSubnormal, .negativeZero, .positiveZero, .positiveSubnormal: .exact(1.0)
            case .quietNaN, .signalingNaN: .nan
            }
        },
        oracle: { Foundation.cosh($0) },
        exponentSweepEligible: { $0.isFinite }
    )

    static let tanhSpec = UnaryTestSpec(
        maxULP: 2,
        homogeneousInputs: [-30.0, -5.0, -1.0, -1.0e-8, -0.0, 0.0, 1.0e-8, 1.0, 5.0, 30.0],
        heterogeneousLanes: [
            [-25.0, -1.0, -1.0e-12, 0.0, 1.0e-12, 1.0, 19.5, 25.0],
            [0.5, .nan, -.infinity, .infinity, -0.0, 20.0, -20.0, Double.leastNonzeroMagnitude]
        ],
        stabilityTransitions: [
            -1000.0, -21.0, -20.0, -19.5, -1.0, -0.5, -1.0e-10, -Double.leastNonzeroMagnitude,
            -0.0, 0.0, Double.leastNonzeroMagnitude, 1.0e-10, 0.5, 1.0, 19.5, 20.0, 21.0, 1000.0
        ],
        classExpectation: { cls in
            switch cls {
            case .negativeInfinity: .exact(-1.0)
            case .negativeNormal: .finite(Foundation.tanh(cls.representative), maxULP: 2)
            case .negativeSubnormal: .subnormal(cls.representative, maxULP: 1)
            case .negativeZero: .negativeZero
            case .positiveZero: .positiveZero
            case .positiveSubnormal: .subnormal(cls.representative, maxULP: 1)
            case .positiveNormal: .finite(Foundation.tanh(cls.representative), maxULP: 2)
            case .positiveInfinity: .exact(1.0)
            case .quietNaN, .signalingNaN: .nan
            }
        },
        oracle: { Foundation.tanh($0) },
        exponentSweepEligible: { $0.isFinite }
    )

    static let asinhSpec = UnaryTestSpec(
        maxULP: 2,
        homogeneousInputs: [-1.0e10, -10.0, -1.0, -1.0e-8, -0.0, 0.0, 1.0e-8, 1.0, 10.0, 1.0e10],
        heterogeneousLanes: [
            [-1.0e30, -1.0, -1.0e-12, 0.0, 1.0e-12, 1.0, 0x1.0p28, 1.0e200],
            [
                2.0, .nan, -.infinity, .infinity, -0.0, Double.greatestFiniteMagnitude, -Double.greatestFiniteMagnitude,
                0.5
            ]
        ],
        stabilityTransitions: [
            -Double.greatestFiniteMagnitude, -1.0e200, -0x1.0p28.nextUp, -0x1.0p28, -0x1.0p28.nextDown,
            -2.0, -1.0, -1.0e-10, -Double.leastNonzeroMagnitude, -0.0, 0.0,
            Double.leastNonzeroMagnitude, 1.0e-10, 1.0, 2.0,
            0x1.0p28.nextDown, 0x1.0p28, 0x1.0p28.nextUp, 1.0e200, Double.greatestFiniteMagnitude
        ],
        classExpectation: { cls in
            switch cls {
            case .negativeInfinity: .negativeInfinity
            case .negativeNormal: .finite(Foundation.asinh(cls.representative), maxULP: 2)
            case .negativeSubnormal: .subnormal(cls.representative, maxULP: 1)
            case .negativeZero: .negativeZero
            case .positiveZero: .positiveZero
            case .positiveSubnormal: .subnormal(cls.representative, maxULP: 1)
            case .positiveNormal: .finite(Foundation.asinh(cls.representative), maxULP: 2)
            case .positiveInfinity: .positiveInfinity
            case .quietNaN, .signalingNaN: .nan
            }
        },
        oracle: { Foundation.asinh($0) },
        exponentSweepEligible: { $0.isFinite }
    )

    static let acoshSpec = UnaryTestSpec(
        maxULP: 2,
        homogeneousInputs: [1.0, 1.0001, 1.5, 2.0, 10.0, 1000.0, 1.0e10],
        heterogeneousLanes: [
            [1.0, 1.001, 1.5, 2.0, 10.0, 0x1.0p28, 1.0e100, Double.greatestFiniteMagnitude],
            [2.0, 0.5, 0.0, -1.0, .infinity, -.infinity, .nan, 1.0.nextUp]
        ],
        stabilityTransitions: [
            1.0, 1.0.nextUp, 1.0 + 1.0e-12, 1.0 + 1.0e-6, 1.5, 2.0,
            0x1.0p28.nextDown, 0x1.0p28, 0x1.0p28.nextUp, 1.0e100, 1.0e300, Double.greatestFiniteMagnitude
        ],
        classExpectation: { cls in
            switch cls {
            case .negativeInfinity, .negativeNormal, .negativeSubnormal,
                .negativeZero, .positiveZero, .positiveSubnormal, .quietNaN, .signalingNaN:
                .nan

            case .positiveNormal:
                .finite(Foundation.acosh(cls.representative), maxULP: 2)

            case .positiveInfinity:
                .positiveInfinity
            }
        },
        oracle: { Foundation.acosh($0) },
        exponentSweepEligible: { $0 >= 1.0 && $0.isFinite }
    )

    static let atanhSpec = UnaryTestSpec(
        maxULP: 2,
        homogeneousInputs: [-0.999, -0.5, -0.1, -1.0e-10, -0.0, 0.0, 1.0e-10, 0.1, 0.5, 0.999],
        heterogeneousLanes: [
            [-0.99, -0.5, -1.0e-12, 0.0, 1.0e-12, 0.5, 0.99, 1.0.nextDown],
            [0.5, 1.0, -1.0, 2.0, -2.0, .infinity, -.infinity, .nan]
        ],
        stabilityTransitions: [
            -1.0.nextDown, -0.999999, -0.5, -1.0e-10, -Double.leastNonzeroMagnitude, -0.0, 0.0,
            Double.leastNonzeroMagnitude, 1.0e-10, 0.5, 0.999999, 1.0.nextDown
        ],
        classExpectation: { cls in
            switch cls {
            case .negativeInfinity, .negativeNormal, .positiveNormal, .positiveInfinity, .quietNaN, .signalingNaN:
                .nan

            case .negativeSubnormal:
                .subnormal(cls.representative, maxULP: 1)

            case .negativeZero:
                .negativeZero

            case .positiveZero:
                .positiveZero

            case .positiveSubnormal:
                .subnormal(cls.representative, maxULP: 1)
            }
        },
        oracle: { Foundation.atanh($0) },
        exponentSweepEligible: { Swift.abs($0) < 1.0 }
    )
}
