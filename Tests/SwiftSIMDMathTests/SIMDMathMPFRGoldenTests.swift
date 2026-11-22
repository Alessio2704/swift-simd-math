import SwiftSIMDMathTestSupport
import Testing

@Suite("SIMDMath Layer 5: GNU MPFR-Certified Exact Bit-Pattern Golden Corpus")
struct SIMDMathMPFRGoldenTests {
    @Test("Unary MPFR-certified exact bit-pattern golden vectors", arguments: SIMDUnaryOperation.allCases)
    func verifyUnaryMPFRGoldenVectors(op: SIMDUnaryOperation) {
        let vectors = op.mpfrGoldenVectors
        #expect(!vectors.isEmpty, "Operation \(op.rawValue) must declare MPFR-certified golden vectors")

        for vector in vectors {
            let x = vector.input
            for width in SIMDVectorWidth.allCases {
                let actual: Double =
                    switch width {
                    case .lanes2: op.evaluate(SIMD2<Double>(repeating: x))[0]
                    case .lanes4: op.evaluate(SIMD4<Double>(repeating: x))[0]
                    case .lanes8: op.evaluate(SIMD8<Double>(repeating: x))[0]
                    }
                #expect(
                    ieee754MatchesReference(actual, expectedBits: vector.expectedBits, maxULP: vector.maxULP),
                    "\(op.rawValue) \(width.swiftTypeName) failed golden \(vector.label) at x=\(x): got \(actual) exp \(vector.expected)"
                )
            }
        }

        for base in stride(from: 0, to: vectors.count, by: 8) {
            let v8 = SIMD8((0..<8).map { vectors[(base + $0) % vectors.count].input })
            let out8 = op.evaluate(v8)
            let out4Lo = op.evaluate(v8.lowHalf)
            let out4Hi = op.evaluate(v8.highHalf)
            for lane in 0..<Swift.min(8, vectors.count - base) {
                let vector = vectors[base + lane]
                let lane4 = lane < 4 ? out4Lo[lane] : out4Hi[lane - 4]
                #expect(ieee754MatchesReference(out8[lane], expectedBits: vector.expectedBits, maxULP: vector.maxULP))
                #expect(ieee754MatchesReference(lane4, expectedBits: vector.expectedBits, maxULP: vector.maxULP))
            }
        }
    }

    @Test("Binary MPFR-certified exact bit-pattern golden vectors", arguments: SIMDBinaryOperation.allCases)
    func verifyBinaryMPFRGoldenVectors(op: SIMDBinaryOperation) {
        let vectors = op.mpfrGoldenVectors
        #expect(!vectors.isEmpty, "Operation \(op.rawValue) must declare MPFR-certified golden vectors")

        for vector in vectors {
            let a = vector.firstInput
            let b = vector.secondInput
            for width in SIMDVectorWidth.allCases {
                let actual: Double =
                    switch width {
                    case .lanes2: op.evaluate(SIMD2<Double>(repeating: a), SIMD2<Double>(repeating: b))[0]
                    case .lanes4: op.evaluate(SIMD4<Double>(repeating: a), SIMD4<Double>(repeating: b))[0]
                    case .lanes8: op.evaluate(SIMD8<Double>(repeating: a), SIMD8<Double>(repeating: b))[0]
                    }
                #expect(
                    ieee754MatchesReference(actual, expectedBits: vector.expectedBits, maxULP: vector.maxULP),
                    "\(op.rawValue) \(width.swiftTypeName) failed golden \(vector.label): got \(actual) exp \(vector.expected)"
                )
            }
        }
    }

    @Test("Ternary exact bit-pattern golden vectors", arguments: SIMDTernaryOperation.allCases)
    func verifyTernaryMPFRGoldenVectors(op: SIMDTernaryOperation) {
        let vectors = op.mpfrGoldenVectors
        #expect(!vectors.isEmpty, "Operation \(op.rawValue) must declare exact golden vectors")

        for vector in vectors {
            let a = vector.firstInput
            let b = vector.secondInput
            let c = vector.thirdInput
            for width in SIMDVectorWidth.allCases {
                let actual: Double =
                    switch width {
                    case .lanes2:
                        op.evaluate(
                            SIMD2<Double>(repeating: a), SIMD2<Double>(repeating: b), SIMD2<Double>(repeating: c))[0]

                    case .lanes4:
                        op.evaluate(
                            SIMD4<Double>(repeating: a), SIMD4<Double>(repeating: b), SIMD4<Double>(repeating: c))[0]

                    case .lanes8:
                        op.evaluate(
                            SIMD8<Double>(repeating: a), SIMD8<Double>(repeating: b), SIMD8<Double>(repeating: c))[0]
                    }
                #expect(ieee754MatchesReference(actual, expectedBits: vector.expectedBits, maxULP: vector.maxULP))
            }
        }
    }

    @Test("Dual-unary MPFR-certified exact bit-pattern golden vectors", arguments: SIMDDualUnaryOperation.allCases)
    func verifyDualUnaryMPFRGoldenVectors(op: SIMDDualUnaryOperation) {
        let vectors = op.mpfrGoldenVectors
        #expect(!vectors.isEmpty, "Operation \(op.rawValue) must declare MPFR-certified golden vectors")

        for vector in vectors {
            let x = vector.input
            for width in SIMDVectorWidth.allCases {
                let pair: (first: Double, second: Double) =
                    switch width {
                    case .lanes2:
                        {
                            let r = op.evaluate(SIMD2<Double>(repeating: x))
                            return (r.first[0], r.second[0])
                        }()

                    case .lanes4:
                        {
                            let r = op.evaluate(SIMD4<Double>(repeating: x))
                            return (r.first[0], r.second[0])
                        }()

                    case .lanes8:
                        {
                            let r = op.evaluate(SIMD8<Double>(repeating: x))
                            return (r.first[0], r.second[0])
                        }()
                    }
                #expect(
                    ieee754MatchesReference(pair.first, expectedBits: vector.expectedFirstBits, maxULP: vector.maxULP))
                #expect(
                    ieee754MatchesReference(pair.second, expectedBits: vector.expectedSecondBits, maxULP: vector.maxULP)
                )
            }
        }
    }

    // MARK: - Compile-Time Exhaustive Category Coverage Gate (Zero default: Branches)

    @Test(
        "Every operation category declares non-empty Layer 5 MPFR golden vectors",
        arguments: SIMDOperationCategory.allCases)
    func verifyCategoryGoldenCoverage(category: SIMDOperationCategory) {
        let verifiedOps = Self.validatedGoldenOperations(for: category)
        #expect(verifiedOps == category.operationNames, "Category \(category.rawValue) golden coverage mismatch")
    }

    private static func validatedGoldenOperations(for category: SIMDOperationCategory) -> [String] {
        switch category {
        case .unary: SIMDUnaryOperation.allCases.filter { !$0.mpfrGoldenVectors.isEmpty }.map(\.rawValue)
        case .binary: SIMDBinaryOperation.allCases.filter { !$0.mpfrGoldenVectors.isEmpty }.map(\.rawValue)
        case .ternary: SIMDTernaryOperation.allCases.filter { !$0.mpfrGoldenVectors.isEmpty }.map(\.rawValue)
        case .dualUnary: SIMDDualUnaryOperation.allCases.filter { !$0.mpfrGoldenVectors.isEmpty }.map(\.rawValue)
        }
    }
}
