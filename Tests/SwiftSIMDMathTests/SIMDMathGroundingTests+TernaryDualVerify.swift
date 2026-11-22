import SwiftSIMDMathTestSupport
import Testing

// MARK: - Compile-Time Exhaustive SIMDVectorWidth Ternary & Dual-Unary Verification Helpers

extension SIMDMathGroundingTests {
    func verifyTernaryHomogeneous(_ op: SIMDTernaryOperation, triplet: TernaryInput, expected: ExpectedIEEE754Result) {
        for width in SIMDVectorWidth.allCases {
            switch width {
            case .lanes2:
                let r = op.evaluate(
                    SIMD2(repeating: triplet.x), SIMD2(repeating: triplet.lower), SIMD2(repeating: triplet.upper))
                for i in 0..<2 { #expect(expected.matches(r[i])) }

            case .lanes4:
                let r = op.evaluate(
                    SIMD4(repeating: triplet.x), SIMD4(repeating: triplet.lower), SIMD4(repeating: triplet.upper))
                for i in 0..<4 { #expect(expected.matches(r[i])) }

            case .lanes8:
                let r = op.evaluate(
                    SIMD8(repeating: triplet.x), SIMD8(repeating: triplet.lower), SIMD8(repeating: triplet.upper))
                for i in 0..<8 { #expect(expected.matches(r[i])) }
            }
        }
    }

    func verifyTernaryPacked(_ op: SIMDTernaryOperation, triplets: [TernaryInput], expected: [ExpectedIEEE754Result]) {
        let count = triplets.count
        for width in SIMDVectorWidth.allCases {
            switch width {
            case .lanes2:
                for base in stride(from: 0, to: count, by: 2) {
                    let vx = SIMD2(triplets[base].x, triplets[(base + 1) % count].x)
                    let vl = SIMD2(triplets[base].lower, triplets[(base + 1) % count].lower)
                    let vu = SIMD2(triplets[base].upper, triplets[(base + 1) % count].upper)
                    let r = op.evaluate(vx, vl, vu)
                    for i in 0..<2 { #expect(expected[(base + i) % count].matches(r[i])) }
                }

            case .lanes4:
                for base in stride(from: 0, to: count, by: 4) {
                    let vx = SIMD4((0..<4).map { triplets[(base + $0) % count].x })
                    let vl = SIMD4((0..<4).map { triplets[(base + $0) % count].lower })
                    let vu = SIMD4((0..<4).map { triplets[(base + $0) % count].upper })
                    let r = op.evaluate(vx, vl, vu)
                    for i in 0..<4 { #expect(expected[(base + i) % count].matches(r[i])) }
                }

            case .lanes8:
                for base in stride(from: 0, to: count, by: 8) {
                    let vx = SIMD8((0..<8).map { triplets[(base + $0) % count].x })
                    let vl = SIMD8((0..<8).map { triplets[(base + $0) % count].lower })
                    let vu = SIMD8((0..<8).map { triplets[(base + $0) % count].upper })
                    let r = op.evaluate(vx, vl, vu)
                    for i in 0..<8 { #expect(expected[(base + i) % count].matches(r[i])) }
                }
            }
        }
    }

    func verifyDualHomogeneous(_ op: SIMDDualUnaryOperation, x: Double, expected: DualExpectedResult) {
        for width in SIMDVectorWidth.allCases {
            switch width {
            case .lanes2:
                let (first, second) = op.evaluate(SIMD2(repeating: x))
                for i in 0..<2 {
                    #expect(expected.first.matches(first[i]) && expected.second.matches(second[i]), "\(op) SIMD2(\(x))")
                }

            case .lanes4:
                let (first, second) = op.evaluate(SIMD4(repeating: x))
                for i in 0..<4 {
                    #expect(expected.first.matches(first[i]) && expected.second.matches(second[i]), "\(op) SIMD4(\(x))")
                }

            case .lanes8:
                let (first, second) = op.evaluate(SIMD8(repeating: x))
                for i in 0..<8 {
                    #expect(expected.first.matches(first[i]) && expected.second.matches(second[i]), "\(op) SIMD8(\(x))")
                }
            }
        }
    }

    func verifyDualPacked(_ op: SIMDDualUnaryOperation, inputs: [Double], expected: [DualExpectedResult]) {
        let count = inputs.count
        for width in SIMDVectorWidth.allCases {
            switch width {
            case .lanes2:
                for base in stride(from: 0, to: count, by: 2) {
                    let v = SIMD2(inputs[base], inputs[(base + 1) % count])
                    let (first, second) = op.evaluate(v)
                    for i in 0..<2 {
                        let idx = (base + i) % count
                        #expect(expected[idx].first.matches(first[i]) && expected[idx].second.matches(second[i]))
                    }
                }

            case .lanes4:
                for base in stride(from: 0, to: count, by: 4) {
                    let v = SIMD4((0..<4).map { inputs[(base + $0) % count] })
                    let (first, second) = op.evaluate(v)
                    for i in 0..<4 {
                        let idx = (base + i) % count
                        #expect(expected[idx].first.matches(first[i]) && expected[idx].second.matches(second[i]))
                    }
                }

            case .lanes8:
                for base in stride(from: 0, to: count, by: 8) {
                    let v = SIMD8((0..<8).map { inputs[(base + $0) % count] })
                    let (first, second) = op.evaluate(v)
                    for i in 0..<8 {
                        let idx = (base + i) % count
                        #expect(expected[idx].first.matches(first[i]) && expected[idx].second.matches(second[i]))
                    }
                }
            }
        }
    }
}
