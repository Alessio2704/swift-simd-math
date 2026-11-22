import Foundation
import SwiftSIMDMathTestSupport
import Testing

@Suite("SIMDMath Layer 4: Parametric Adversarial Stress & Algebraic Invariants")
struct SIMDMathAdversarialTests {
    // MARK: - Unary Dense Regime Neighborhoods, Seeded Fuzz, Monotonicity & Parity

    @Test(
        "Unary dense regime neighborhoods, seeded fuzz, monotonicity, and parity",
        arguments: SIMDUnaryOperation.allCases
    )
    func verifyUnaryAdversarial(op: SIMDUnaryOperation) {
        let spec = op.spec
        let adv = op.adversarialSpec
        #expect(!adv.regimeAnchors.isEmpty, "\(op) must declare regimeAnchors")

        for anchor in adv.regimeAnchors {
            let window = denseULPNeighborhood(around: anchor, eligible: spec.exponentSweepEligible)
            verifyUnaryAllWidths(op, inputs: window, oracle: spec.oracle, maxULP: spec.maxULP)
            if let mono = adv.monotonicity {
                verifyUnaryMonotonic(op, sortedInputs: window.sorted(), direction: mono)
            }
        }

        let fuzz = adv.fuzzInputs()
        #expect(!fuzz.isEmpty, "\(op) fuzzInputs() must not be empty")
        verifyUnaryAllWidths(op, inputs: fuzz, oracle: spec.oracle, maxULP: spec.maxULP)

        if let mono = adv.monotonicity {
            verifyUnaryMonotonic(op, sortedInputs: fuzz.filter { $0.isFinite }.sorted(), direction: mono)
        }
        if let parity = adv.parity {
            verifyUnaryParity(op, inputs: fuzz, parity: parity)
        }
    }

    // MARK: - Binary 2D Exponent Fuzz, Table Midpoints, Commutativity & Algebraic Identities

    @Test(
        "Binary 2D adversarial fuzz, commutativity, and algebraic identities",
        arguments: SIMDBinaryOperation.allCases
    )
    func verifyBinaryAdversarial(op: SIMDBinaryOperation) {
        let spec = op.spec
        let adv = op.adversarialSpec

        let pairs = adv.fuzzPairs()
        #expect(!pairs.isEmpty, "\(op) fuzzPairs() must not be empty")
        let expected = pairs.map { ExpectedIEEE754Result.fromOracle(spec.oracle($0.a, $0.b), maxULP: spec.maxULP) }
        verifyBinaryAllWidths(op, pairs: pairs, expected: expected)

        let algebraic = adv.algebraicChecks()
        if !algebraic.isEmpty {
            verifyBinaryAllWidths(op, pairs: algebraic.map(\.0), expected: algebraic.map(\.1))
        }

        if adv.isCommutative {
            for base in stride(from: 0, to: pairs.count, by: 4) {
                let va = SIMD4((0..<4).map { pairs[(base + $0) % pairs.count].a })
                let vb = SIMD4((0..<4).map { pairs[(base + $0) % pairs.count].b })
                let ab = op.evaluate(va, vb)
                let ba = op.evaluate(vb, va)
                for lane in 0..<4 {
                    #expect(ab[lane] == ba[lane], "\(op) commutativity failed for (\(va[lane]), \(vb[lane]))")
                }
            }
        }
    }

    // MARK: - Ternary Bounds & Idempotence Invariants

    @Test(
        "Ternary adversarial fuzz, bounds invariant, and idempotence",
        arguments: SIMDTernaryOperation.allCases
    )
    func verifyTernaryAdversarial(op: SIMDTernaryOperation) {
        let spec = op.spec
        let adv = op.adversarialSpec
        let triplets = adv.fuzzTriplets()
        #expect(!triplets.isEmpty, "\(op) fuzzTriplets() must not be empty")
        let count = triplets.count

        for base in stride(from: 0, to: count, by: 4) {
            let vx = SIMD4((0..<4).map { triplets[(base + $0) % count].x })
            let vl = SIMD4((0..<4).map { triplets[(base + $0) % count].lower })
            let vu = SIMD4((0..<4).map { triplets[(base + $0) % count].upper })
            let out = op.evaluate(vx, vl, vu)
            let idem = op.evaluate(out, vl, vu)
            for lane in 0..<4 {
                let ref = spec.oracle(vx[lane], vl[lane], vu[lane])
                #expect(ExpectedIEEE754Result.fromOracle(ref, maxULP: spec.maxULP).matches(out[lane]))
                if adv.checkIdempotenceAndBounds {
                    #expect(idem[lane] == out[lane], "\(op) idempotence failed")
                    if vl[lane] <= vu[lane] {
                        #expect(out[lane] >= vl[lane] && out[lane] <= vu[lane], "\(op) bounds failed")
                    }
                }
            }
        }
    }

    // MARK: - Dual-Unary Dense Windows, Pythagorean Identity & Parity

    @Test(
        "Dual-unary dense windows, seeded fuzz, Pythagorean identity, and parity",
        arguments: SIMDDualUnaryOperation.allCases
    )
    func verifyDualAdversarial(op: SIMDDualUnaryOperation) {
        let spec = op.spec
        let adv = op.adversarialSpec
        #expect(!adv.regimeAnchors.isEmpty, "\(op) must declare regimeAnchors")

        var inputs = adv.fuzzInputs()
        #expect(!inputs.isEmpty, "\(op) fuzzInputs() must not be empty")
        for anchor in adv.regimeAnchors {
            inputs.append(contentsOf: denseULPNeighborhood(around: anchor) { $0.isFinite })
        }

        let count = inputs.count
        for base in stride(from: 0, to: count, by: 4) {
            let v = SIMD4((0..<4).map { inputs[(base + $0) % count] })
            let (first4, second4) = op.evaluate(v)
            let (negFirst4, negSecond4) = adv.checkParity ? op.evaluate(-v) : (first4, second4)
            for lane in 0..<4 {
                let ref = spec.oracle(v[lane])
                let expFirst = ExpectedIEEE754Result.fromOracle(ref.first, maxULP: spec.maxULP)
                let expSecond = ExpectedIEEE754Result.fromOracle(ref.second, maxULP: spec.maxULP)
                #expect(expFirst.matches(first4[lane]), "\(op).first(\(v[lane])) -> \(first4[lane]) exp \(ref.first)")
                #expect(
                    expSecond.matches(second4[lane]), "\(op).second(\(v[lane])) -> \(second4[lane]) exp \(ref.second)")
                if adv.checkPythagorean {
                    let norm2 = first4[lane] * first4[lane] + second4[lane] * second4[lane]
                    #expect(ieee754ULPDistance(norm2, 1.0) <= 4, "\(op) first^2+second^2=\(norm2) at x=\(v[lane])")
                }
                if adv.checkParity {
                    #expect(negFirst4[lane] == -first4[lane], "\(op) first odd parity failed at x=\(v[lane])")
                    #expect(negSecond4[lane] == second4[lane], "\(op) second even parity failed at x=\(v[lane])")
                }
            }
        }
    }

    // MARK: - Compile-Time Exhaustive Category Coverage Gate (Zero default: Branches)

    @Test(
        "Every operation category executes non-empty Layer 4 Adversarial specs",
        arguments: SIMDOperationCategory.allCases)
    func verifyCategoryAdversarialCoverage(category: SIMDOperationCategory) {
        let verifiedOps = Self.validatedAdversarialOperations(for: category)
        #expect(verifiedOps == category.operationNames, "Category \(category.rawValue) adversarial coverage mismatch")
    }

    private static func validatedAdversarialOperations(for category: SIMDOperationCategory) -> [String] {
        switch category {
        case .unary:
            return SIMDUnaryOperation.allCases.filter { op in
                let adv = op.adversarialSpec
                return !adv.regimeAnchors.isEmpty && !adv.fuzzInputs().isEmpty
            }.map(\.rawValue)

        case .binary:
            return SIMDBinaryOperation.allCases.filter { !$0.adversarialSpec.fuzzPairs().isEmpty }.map(\.rawValue)

        case .ternary:
            return SIMDTernaryOperation.allCases.filter { !$0.adversarialSpec.fuzzTriplets().isEmpty }.map(\.rawValue)

        case .dualUnary:
            return SIMDDualUnaryOperation.allCases.filter { op in
                let adv = op.adversarialSpec
                return !adv.regimeAnchors.isEmpty && !adv.fuzzInputs().isEmpty
            }.map(\.rawValue)
        }
    }
}
