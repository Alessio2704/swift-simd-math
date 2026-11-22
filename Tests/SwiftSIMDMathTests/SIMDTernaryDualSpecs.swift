import Foundation
import SwiftSIMDMathTestSupport

// MARK: - Compile-Time Exhaustive Ternary & Dual-Unary Specs (Zero default: Branches)

extension SIMDTernaryOperation {
    var spec: TernaryTestSpec {
        switch self {
        case .clamp:
            TernaryTestSpec(
                maxULP: 0,
                homogeneousTriplets: [
                    TernaryInput(x: -15.0, lower: -10.0, upper: 10.0),
                    TernaryInput(x: 0.0, lower: -10.0, upper: 10.0),
                    TernaryInput(x: 15.0, lower: -10.0, upper: 10.0)
                ],
                heterogeneousTriplets: [
                    [
                        TernaryInput(x: -15.0, lower: -10.0, upper: 10.0),
                        TernaryInput(x: 5.0, lower: -10.0, upper: 10.0),
                        TernaryInput(x: 15.0, lower: -10.0, upper: 10.0),
                        TernaryInput(x: .nan, lower: -1.0, upper: 1.0),
                        TernaryInput(x: -0.0, lower: 0.0, upper: 1.0),
                        TernaryInput(x: .infinity, lower: -1.0, upper: 1.0),
                        TernaryInput(x: -.infinity, lower: -1.0, upper: 1.0),
                        TernaryInput(x: .nan, lower: .nan, upper: .nan)
                    ]
                ]
            ) { x, lo, hi in
                SIMDExactReferenceOracles.ieeeMinimumNumber(
                    SIMDExactReferenceOracles.ieeeMaximumNumber(x, lo), hi)
            }

        case .mix:
            TernaryTestSpec(
                maxULP: 0,
                homogeneousTriplets: [
                    TernaryInput(x: 1.0, lower: 5.0, upper: 0.0),
                    TernaryInput(x: 1.0, lower: 5.0, upper: 0.5),
                    TernaryInput(x: 1.0, lower: 5.0, upper: 1.0),
                    TernaryInput(x: -10.0, lower: 20.0, upper: 0.25)
                ],
                heterogeneousTriplets: [
                    [
                        TernaryInput(x: 1.0, lower: 5.0, upper: 0.0),
                        TernaryInput(x: 1.0, lower: 5.0, upper: 1.0),
                        TernaryInput(x: 1.0, lower: .infinity, upper: 0.0),
                        TernaryInput(x: .infinity, lower: 1.0, upper: 1.0),
                        TernaryInput(x: -0.0, lower: -0.0, upper: 0.5),
                        TernaryInput(x: 1.0, lower: 5.0, upper: .nan),
                        TernaryInput(x: .nan, lower: 5.0, upper: 0.5),
                        TernaryInput(x: 1.0, lower: 5.0, upper: -0.5)
                    ]
                ]
            ) { a, b, t in a.addingProduct(t, b - a) }

        case .smoothstep:
            TernaryTestSpec(
                maxULP: 0,
                homogeneousTriplets: [
                    TernaryInput(x: -1.0, lower: 0.0, upper: 1.0),
                    TernaryInput(x: 0.25, lower: 0.0, upper: 1.0),
                    TernaryInput(x: 0.5, lower: 0.0, upper: 1.0),
                    TernaryInput(x: 2.0, lower: 0.0, upper: 1.0),
                    TernaryInput(x: 0.5, lower: 1.0, upper: 0.0)
                ],
                heterogeneousTriplets: [
                    [
                        TernaryInput(x: -1.0, lower: 0.0, upper: 1.0),
                        TernaryInput(x: 0.5, lower: 0.0, upper: 1.0),
                        TernaryInput(x: 2.0, lower: 0.0, upper: 1.0),
                        TernaryInput(x: 0.5, lower: 0.5, upper: 0.5),
                        TernaryInput(x: .nan, lower: 0.0, upper: 1.0),
                        TernaryInput(x: 0.5, lower: .nan, upper: 1.0),
                        TernaryInput(x: .infinity, lower: 0.0, upper: 1.0),
                        TernaryInput(x: 0.5, lower: -.infinity, upper: .infinity)
                    ]
                ]
            ) { x, e0, e1 in
                let raw = (x - e0) / (e1 - e0)
                let u = SIMDExactReferenceOracles.ieeeMinimumNumber(
                    SIMDExactReferenceOracles.ieeeMaximumNumber(raw, 0.0), 1.0)
                return u * u * 3.0.addingProduct(-2.0, u)
            }
        }
    }

    /// Full 10 x 10 x 10 = 1,000 IEEE-754 class-triplet Cartesian matrix.
    func classMatrixCases() -> [(TernaryInput, ExpectedIEEE754Result)] {
        let opSpec = spec
        var result: [(TernaryInput, ExpectedIEEE754Result)] = []
        result.reserveCapacity(1000)
        for xCls in IEEE754Class.allCases {
            for loCls in IEEE754Class.allCases {
                for hiCls in IEEE754Class.allCases {
                    let input = TernaryInput(
                        x: xCls.representative, lower: loCls.representative, upper: hiCls.representative)
                    let ref = opSpec.oracle(input.x, input.lower, input.upper)
                    result.append((input, ExpectedIEEE754Result.fromOracle(ref, maxULP: opSpec.maxULP)))
                }
            }
        }
        return result
    }
}

extension SIMDDualUnaryOperation {
    var spec: DualUnaryTestSpec {
        switch self {
        case .sincos:
            DualUnaryTestSpec(
                maxULP: 2,
                homogeneousInputs: [-10.5, -Double.pi, -1.0, -0.1, 0.0, 0.1, 1.0, Double.pi, 10.5],
                heterogeneousLanes: [
                    [-3.0, -1.2, -0.3, 0.4, 1.1, 2.3, 3.8, 5.5],
                    [0.5, -0.0, 0.0, .infinity, -.infinity, .nan, 1.0e22, -1.0e100]
                ],
                stabilityTransitions: SIMDUnaryOperation.trigTransitions,
                classExpectation: { cls in
                    DualExpectedResult(
                        first: SIMDUnaryOperation.sin.spec.classExpectation(cls),
                        second: SIMDUnaryOperation.cos.spec.classExpectation(cls)
                    )
                },
                oracle: { x in
                    let ref = SIMDExactReferenceOracles.sineCosine(x)
                    return DualScalar(first: ref.sin, second: ref.cos)
                }
            )

        case .sincospi:
            DualUnaryTestSpec(
                maxULP: 2,
                homogeneousInputs: [-2.25, -1.5, -0.75, -0.25, 0.0, 0.25, 0.75, 1.5, 2.25],
                heterogeneousLanes: [
                    [-1.7, -0.8, -0.3, 0.15, 0.65, 1.25, 2.4, 3.9],
                    [0.5, 1.0, -1.0, -0.0, .infinity, -.infinity, .nan, 0x1.0p52 + 1.0]
                ],
                stabilityTransitions: SIMDUnaryOperation.piTrigTransitions,
                classExpectation: { cls in
                    DualExpectedResult(
                        first: SIMDUnaryOperation.sinpi.spec.classExpectation(cls),
                        second: SIMDUnaryOperation.cospi.spec.classExpectation(cls)
                    )
                },
                oracle: { x in
                    DualScalar(first: SIMDUnaryOperation.scalarSinPi(x), second: SIMDUnaryOperation.scalarCosPi(x))
                }
            )
        }
    }
}
