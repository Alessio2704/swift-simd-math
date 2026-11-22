import Foundation
import SwiftSIMDMathTestSupport
import Testing

extension SIMDMathAdversarialTests {
    func verifyUnaryAllWidths(
        _ op: SIMDUnaryOperation,
        inputs: [Double],
        oracle: (Double) -> Double,
        maxULP: UInt64
    ) {
        guard !inputs.isEmpty else { return }
        let count = inputs.count
        for base in stride(from: 0, to: count, by: 8) {
            let v8 = SIMD8((0..<8).map { inputs[(base + $0) % count] })
            let r8 = op.evaluate(v8)
            for width in SIMDVectorWidth.allCases {
                switch width {
                case .lanes2:
                    let r2 = SIMD8<Double>(
                        lowHalf: SIMD4(
                            lowHalf: op.evaluate(v8.lowHalf.lowHalf), highHalf: op.evaluate(v8.lowHalf.highHalf)),
                        highHalf: SIMD4(
                            lowHalf: op.evaluate(v8.highHalf.lowHalf), highHalf: op.evaluate(v8.highHalf.highHalf))
                    )
                    for lane in 0..<8 {
                        #expect(r2[lane].bitPattern == r8[lane].bitPattern, "\(op) SIMD2/SIMD8 mismatch at \(v8[lane])")
                    }

                case .lanes4:
                    let r4 = SIMD8<Double>(lowHalf: op.evaluate(v8.lowHalf), highHalf: op.evaluate(v8.highHalf))
                    for lane in 0..<8 {
                        #expect(r4[lane].bitPattern == r8[lane].bitPattern, "\(op) SIMD4/SIMD8 mismatch at \(v8[lane])")
                    }

                case .lanes8:
                    for lane in 0..<8 {
                        let expected = ExpectedIEEE754Result.fromOracle(oracle(v8[lane]), maxULP: maxULP)
                        #expect(expected.matches(r8[lane]), "\(op) SIMD8(\(v8[lane])) -> \(r8[lane])")
                    }
                }
            }
        }
    }

    func verifyUnaryMonotonic(
        _ op: SIMDUnaryOperation,
        sortedInputs: [Double],
        direction: MonotonicityInvariant
    ) {
        guard sortedInputs.count >= 2 else { return }
        var outputs: [Double] = []
        outputs.reserveCapacity(sortedInputs.count)
        let count = sortedInputs.count
        for base in stride(from: 0, to: count, by: 4) {
            let v4 = SIMD4((0..<4).map { sortedInputs[min(base + $0, count - 1)] })
            let r4 = op.evaluate(v4)
            for lane in 0..<4 where base + lane < count {
                outputs.append(r4[lane])
            }
        }
        for idx in 1..<outputs.count {
            let ok =
                direction == .nonDecreasing
                ? outputs[idx - 1] <= outputs[idx]
                : outputs[idx - 1] >= outputs[idx]
            #expect(
                ok,
                "\(op) monotonicity violated: f(\(sortedInputs[idx - 1]))=\(outputs[idx - 1]) vs f(\(sortedInputs[idx]))=\(outputs[idx])"
            )
        }
    }

    func verifyUnaryParity(_ op: SIMDUnaryOperation, inputs: [Double], parity: ParityInvariant) {
        let count = inputs.count
        for base in stride(from: 0, to: count, by: 4) {
            let v = SIMD4((0..<4).map { inputs[(base + $0) % count] })
            let pos = op.evaluate(v)
            let neg = op.evaluate(-v)
            for lane in 0..<4 {
                if parity == .odd {
                    #expect(neg[lane] == -pos[lane], "\(op) odd parity failed at x=\(v[lane])")
                } else if parity == .even {
                    #expect(neg[lane] == pos[lane], "\(op) even parity failed at x=\(v[lane])")
                }
            }
        }
    }

    func verifyBinaryAllWidths(
        _ op: SIMDBinaryOperation,
        pairs: [BinaryInput],
        expected: [ExpectedIEEE754Result]
    ) {
        let count = pairs.count
        for base in stride(from: 0, to: count, by: 8) {
            let va8 = SIMD8((0..<8).map { pairs[(base + $0) % count].a })
            let vb8 = SIMD8((0..<8).map { pairs[(base + $0) % count].b })
            let r8 = op.evaluate(va8, vb8)
            for width in SIMDVectorWidth.allCases {
                switch width {
                case .lanes2:
                    let r2 = SIMD8<Double>(
                        lowHalf: SIMD4(
                            lowHalf: op.evaluate(va8.lowHalf.lowHalf, vb8.lowHalf.lowHalf),
                            highHalf: op.evaluate(va8.lowHalf.highHalf, vb8.lowHalf.highHalf)),
                        highHalf: SIMD4(
                            lowHalf: op.evaluate(va8.highHalf.lowHalf, vb8.highHalf.lowHalf),
                            highHalf: op.evaluate(va8.highHalf.highHalf, vb8.highHalf.highHalf))
                    )
                    for lane in 0..<8 {
                        #expect(r2[lane].bitPattern == r8[lane].bitPattern, "\(op) SIMD2/SIMD8 mismatch")
                    }

                case .lanes4:
                    let r4 = SIMD8<Double>(
                        lowHalf: op.evaluate(va8.lowHalf, vb8.lowHalf),
                        highHalf: op.evaluate(va8.highHalf, vb8.highHalf)
                    )
                    for lane in 0..<8 {
                        #expect(r4[lane].bitPattern == r8[lane].bitPattern, "\(op) SIMD4/SIMD8 mismatch")
                    }

                case .lanes8:
                    for lane in 0..<8 {
                        let idx = (base + lane) % count
                        #expect(
                            expected[idx].matches(r8[lane]), "\(op) SIMD8(\(va8[lane]), \(vb8[lane])) -> \(r8[lane])")
                    }
                }
            }
        }
    }
}
