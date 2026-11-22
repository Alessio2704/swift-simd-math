import Foundation
import SwiftSIMDMathTestSupport

// MARK: - Compile-Time Exhaustive Binary Specs (Zero default: Branches)

extension SIMDBinaryOperation {
    var spec: BinaryTestSpec {
        switch self {
        case .pow: Self.powSpec
        case .atan2: Self.atan2Spec
        case .hypot: Self.hypotSpec
        case .min: Self.minSpec
        case .max: Self.maxSpec
        case .step: Self.stepSpec
        }
    }

    private static let powSpec = BinaryTestSpec(
        maxULP: 2,
        homogeneousPairs: [
            BinaryInput(a: 1.5, b: 0.5), BinaryInput(a: 2.0, b: 1.5), BinaryInput(a: 3.0, b: 2.0),
            BinaryInput(a: 4.0, b: -2.5), BinaryInput(a: 0.5, b: 3.0), BinaryInput(a: 7.0, b: 1.0)
        ],
        heterogeneousPairs: [
            [
                BinaryInput(a: 2.0, b: 3.0), BinaryInput(a: -2.0, b: 3.0),
                BinaryInput(a: -2.0, b: 2.0), BinaryInput(a: -2.0, b: 0.5),
                BinaryInput(a: .nan, b: 0.0), BinaryInput(a: 1.0, b: .nan),
                BinaryInput(a: -1.0, b: .infinity), BinaryInput(a: Double.leastNonzeroMagnitude * 4.0, b: -0.5)
            ]
        ],
        stabilityTransitions: [
            BinaryInput(a: 2.0, b: 1023.0), BinaryInput(a: 2.0, b: 1023.9999999999999),
            BinaryInput(a: 2.0, b: 1024.0), BinaryInput(a: 2.0, b: -1022.0),
            BinaryInput(a: 2.0, b: -1050.0), BinaryInput(a: 2.0, b: -1074.0),
            BinaryInput(a: 2.0, b: -1075.0), BinaryInput(a: 1.4, b: 2000.0),
            BinaryInput(a: 1.015, b: 45_000.0), BinaryInput(a: 1.0001, b: 1_000_000.0),
            BinaryInput(a: 1.0.nextUp, b: 1.0e18), BinaryInput(a: 1.0.nextDown, b: 1.0e18),
            BinaryInput(a: Double.greatestFiniteMagnitude, b: 0.5),
            BinaryInput(a: Double.leastNonzeroMagnitude, b: -0.5),
            BinaryInput(a: -1.0, b: 9_007_199_254_740_991.0),
            BinaryInput(a: -1.0, b: 9_007_199_254_740_992.0),
            BinaryInput(a: -2.0, b: -3.0), BinaryInput(a: -2.0, b: -2.0),
            BinaryInput(a: -1.0e200, b: 3.0), BinaryInput(a: -1.0e200, b: -3.0),
            BinaryInput(a: -1.0e200, b: -2.0)
        ]
    ) { SIMDExactReferenceOracles.ieeePower($0, $1) }

    private static let minSpec = BinaryTestSpec(
        maxULP: 0,
        homogeneousPairs: [
            BinaryInput(a: -5.0, b: 0.0), BinaryInput(a: 10.0, b: 5.0),
            BinaryInput(a: -0.0, b: 0.0), BinaryInput(a: 0.0, b: -0.0)
        ],
        heterogeneousPairs: [
            [
                BinaryInput(a: -5.0, b: 0.0), BinaryInput(a: 10.0, b: 5.0),
                BinaryInput(a: .nan, b: 3.0), BinaryInput(a: 3.0, b: .nan),
                BinaryInput(a: -0.0, b: 0.0), BinaryInput(a: 0.0, b: -0.0),
                BinaryInput(a: -.infinity, b: .nan), BinaryInput(a: .nan, b: .nan)
            ]
        ],
        stabilityTransitions: [
            BinaryInput(a: -Double.greatestFiniteMagnitude, b: Double.greatestFiniteMagnitude),
            BinaryInput(a: Double.leastNonzeroMagnitude, b: 0.0)
        ]
    ) { SIMDExactReferenceOracles.ieeeMinimumNumber($0, $1) }

    private static let maxSpec = BinaryTestSpec(
        maxULP: 0,
        homogeneousPairs: [
            BinaryInput(a: -5.0, b: 0.0), BinaryInput(a: 10.0, b: 5.0),
            BinaryInput(a: -0.0, b: 0.0), BinaryInput(a: 0.0, b: -0.0)
        ],
        heterogeneousPairs: [
            [
                BinaryInput(a: -5.0, b: 0.0), BinaryInput(a: 10.0, b: 5.0),
                BinaryInput(a: .nan, b: 3.0), BinaryInput(a: 3.0, b: .nan),
                BinaryInput(a: -0.0, b: 0.0), BinaryInput(a: 0.0, b: -0.0),
                BinaryInput(a: .infinity, b: .nan), BinaryInput(a: .nan, b: .nan)
            ]
        ],
        stabilityTransitions: [
            BinaryInput(a: -Double.greatestFiniteMagnitude, b: Double.greatestFiniteMagnitude),
            BinaryInput(a: -Double.leastNonzeroMagnitude, b: -0.0)
        ]
    ) { SIMDExactReferenceOracles.ieeeMaximumNumber($0, $1) }

    /// Full IEEE-754 class-pair Cartesian expectation matrix (361 pairs for `pow`, 100 pairs for others).
    func classMatrixCases() -> [(BinaryInput, ExpectedIEEE754Result)] {
        switch self {
        case .pow:
            return PowIEEE754Class.allCases.flatMap { xCls in
                PowIEEE754Class.allCases.map { yCls in
                    let input = BinaryInput(a: xCls.representative, b: yCls.representative)
                    let ref = Self.powSpec.oracle(input.a, input.b)
                    return (input, ExpectedIEEE754Result.fromOracle(ref, maxULP: 2))
                }
            }

        case .atan2, .hypot, .min, .max, .step:
            let opSpec = spec
            return IEEE754Class.allCases.flatMap { aCls in
                IEEE754Class.allCases.map { bCls in
                    let input = BinaryInput(a: aCls.representative, b: bCls.representative)
                    let ref = opSpec.oracle(input.a, input.b)
                    return (input, ExpectedIEEE754Result.fromOracle(ref, maxULP: opSpec.maxULP))
                }
            }
        }
    }
}
