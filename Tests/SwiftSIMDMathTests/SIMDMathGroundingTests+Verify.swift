import SwiftSIMDMathTestSupport
import Testing

// MARK: - Compile-Time Exhaustive SIMDVectorWidth Homogeneous & Packed Verification Helpers

extension SIMDMathGroundingTests {
    func dualExpected(_ ref: DualScalar, maxULP: UInt64) -> DualExpectedResult {
        DualExpectedResult(
            first: ExpectedIEEE754Result.fromOracle(ref.first, maxULP: maxULP),
            second: ExpectedIEEE754Result.fromOracle(ref.second, maxULP: maxULP)
        )
    }

    func verifyUnaryHomogeneous(_ op: SIMDUnaryOperation, x: Double, expected: ExpectedIEEE754Result) {
        for width in SIMDVectorWidth.allCases {
            switch width {
            case .lanes2:
                let r = op.evaluate(SIMD2(repeating: x))
                for i in 0..<2 { #expect(expected.matches(r[i]), "\(op) SIMD2(\(x)) -> \(r[i]) exp \(expected)") }

            case .lanes4:
                let r = op.evaluate(SIMD4(repeating: x))
                for i in 0..<4 { #expect(expected.matches(r[i]), "\(op) SIMD4(\(x)) -> \(r[i]) exp \(expected)") }

            case .lanes8:
                let r = op.evaluate(SIMD8(repeating: x))
                for i in 0..<8 { #expect(expected.matches(r[i]), "\(op) SIMD8(\(x)) -> \(r[i]) exp \(expected)") }
            }
        }
    }

    func verifyUnaryPacked(_ op: SIMDUnaryOperation, inputs: [Double], expected: [ExpectedIEEE754Result]) {
        let count = inputs.count
        for width in SIMDVectorWidth.allCases {
            switch width {
            case .lanes2:
                for base in stride(from: 0, to: count, by: 2) {
                    let v = SIMD2(inputs[base], inputs[(base + 1) % count])
                    let r = op.evaluate(v)
                    for i in 0..<2 {
                        let idx = (base + i) % count
                        #expect(expected[idx].matches(r[i]), "\(op) SIMD2 mixed x=\(v[i]) -> \(r[i])")
                    }
                }

            case .lanes4:
                for base in stride(from: 0, to: count, by: 4) {
                    let v = SIMD4((0..<4).map { inputs[(base + $0) % count] })
                    let r = op.evaluate(v)
                    for i in 0..<4 {
                        let idx = (base + i) % count
                        #expect(expected[idx].matches(r[i]), "\(op) SIMD4 mixed x=\(v[i]) -> \(r[i])")
                    }
                }

            case .lanes8:
                for base in stride(from: 0, to: count, by: 8) {
                    let v = SIMD8((0..<8).map { inputs[(base + $0) % count] })
                    let r = op.evaluate(v)
                    for i in 0..<8 {
                        let idx = (base + i) % count
                        #expect(expected[idx].matches(r[i]), "\(op) SIMD8 mixed x=\(v[i]) -> \(r[i])")
                    }
                }
            }
        }
    }

    func verifyBinaryHomogeneous(_ op: SIMDBinaryOperation, pair: BinaryInput, expected: ExpectedIEEE754Result) {
        for width in SIMDVectorWidth.allCases {
            switch width {
            case .lanes2:
                let r = op.evaluate(SIMD2(repeating: pair.a), SIMD2(repeating: pair.b))
                for i in 0..<2 { #expect(expected.matches(r[i]), "\(op) SIMD2(\(pair.a),\(pair.b)) -> \(r[i])") }

            case .lanes4:
                let r = op.evaluate(SIMD4(repeating: pair.a), SIMD4(repeating: pair.b))
                for i in 0..<4 { #expect(expected.matches(r[i]), "\(op) SIMD4(\(pair.a),\(pair.b)) -> \(r[i])") }

            case .lanes8:
                let r = op.evaluate(SIMD8(repeating: pair.a), SIMD8(repeating: pair.b))
                for i in 0..<8 { #expect(expected.matches(r[i]), "\(op) SIMD8(\(pair.a),\(pair.b)) -> \(r[i])") }
            }
        }
    }

    func verifyBinaryPacked(_ op: SIMDBinaryOperation, pairs: [BinaryInput], expected: [ExpectedIEEE754Result]) {
        let count = pairs.count
        for width in SIMDVectorWidth.allCases {
            switch width {
            case .lanes2:
                for base in stride(from: 0, to: count, by: 2) {
                    let va = SIMD2(pairs[base].a, pairs[(base + 1) % count].a)
                    let vb = SIMD2(pairs[base].b, pairs[(base + 1) % count].b)
                    let r = op.evaluate(va, vb)
                    for i in 0..<2 { #expect(expected[(base + i) % count].matches(r[i]), "\(op) SIMD2 mixed") }
                }

            case .lanes4:
                for base in stride(from: 0, to: count, by: 4) {
                    let va = SIMD4((0..<4).map { pairs[(base + $0) % count].a })
                    let vb = SIMD4((0..<4).map { pairs[(base + $0) % count].b })
                    let r = op.evaluate(va, vb)
                    for i in 0..<4 { #expect(expected[(base + i) % count].matches(r[i]), "\(op) SIMD4 mixed") }
                }

            case .lanes8:
                for base in stride(from: 0, to: count, by: 8) {
                    let va = SIMD8((0..<8).map { pairs[(base + $0) % count].a })
                    let vb = SIMD8((0..<8).map { pairs[(base + $0) % count].b })
                    let r = op.evaluate(va, vb)
                    for i in 0..<8 { #expect(expected[(base + i) % count].matches(r[i]), "\(op) SIMD8 mixed") }
                }
            }
        }
    }
}
