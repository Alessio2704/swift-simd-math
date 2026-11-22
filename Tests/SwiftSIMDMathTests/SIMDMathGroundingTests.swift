import Foundation
import SwiftSIMDMathTestSupport
import Testing

@Suite("SIMDMath 3-Layer IEEE-754 Mathematical Grounding")
struct SIMDMathGroundingTests {
    // Upper bound for OS-libm grounding specs (lgamma negative zeros use 32; strict <= 8 ULP vs MPFR is enforced in MPFRAudit).
    private static let maxAllowedContractULP: UInt64 = 32

    // MARK: - Layer 1 & 2: Unary Operations (Exhaustive over SIMDUnaryOperation.allCases)

    @Test("Unary IEEE-754 class matrix, mixed lanes, and transitions", arguments: SIMDUnaryOperation.allCases)
    func verifyUnaryOp(op: SIMDUnaryOperation) {
        let spec = op.spec
        #expect(spec.maxULP <= Self.maxAllowedContractULP, "\(op) maxULP \(spec.maxULP) exceeds contract ceiling")
        #expect(!spec.homogeneousInputs.isEmpty, "\(op) must declare homogeneousInputs")
        #expect(!spec.heterogeneousLanes.isEmpty, "\(op) must declare heterogeneousLanes")
        #expect(!spec.stabilityTransitions.isEmpty, "\(op) must declare stabilityTransitions")

        for cls in IEEE754Class.allCases {
            verifyUnaryHomogeneous(op, x: cls.representative, expected: spec.classExpectation(cls))
        }
        let allClassInputs = IEEE754Class.allCases.map(\.representative)
        let allClassExpected = IEEE754Class.allCases.map { spec.classExpectation($0) }
        verifyUnaryPacked(op, inputs: allClassInputs, expected: allClassExpected)

        for laneBatch in spec.heterogeneousLanes {
            #expect(!laneBatch.isEmpty, "\(op) heterogeneous lane batch must not be empty")
            let expected = laneBatch.map { ExpectedIEEE754Result.fromOracle(spec.oracle($0), maxULP: spec.maxULP) }
            verifyUnaryPacked(op, inputs: laneBatch, expected: expected)
        }

        for x in spec.homogeneousInputs + spec.stabilityTransitions {
            let expected = ExpectedIEEE754Result.fromOracle(spec.oracle(x), maxULP: spec.maxULP)
            verifyUnaryHomogeneous(op, x: x, expected: expected)
        }
        let transExpected = spec.stabilityTransitions.map { value in
            ExpectedIEEE754Result.fromOracle(spec.oracle(value), maxULP: spec.maxULP)
        }
        verifyUnaryPacked(op, inputs: spec.stabilityTransitions, expected: transExpected)
    }

    // MARK: - Layer 3: All-2,098-Exponent Stratified Sweep (Unary)

    @Test("Unary all-2098-exponent heterogeneous sweep", arguments: SIMDUnaryOperation.allCases)
    func verifyUnaryAllExponents(op: SIMDUnaryOperation) {
        let spec = op.spec
        let mantissas: [UInt64] = [0x0000_0000_0000_0001, 0x0006_A09E_667F_3BCD, 0x000F_FFFF_FFFF_FFFF]
        var inputs: [Double] = []
        inputs.reserveCapacity(13_000)
        for biasedExp in UInt64(0)...UInt64(2046) {
            for mant in mantissas {
                let pos = Double(bitPattern: (biasedExp << 52) | mant)
                if spec.exponentSweepEligible(pos) { inputs.append(pos) }
                let neg = -pos
                if spec.exponentSweepEligible(neg) { inputs.append(neg) }
            }
        }
        #expect(!inputs.isEmpty, "\(op) exponentSweepEligible rejected all 2098 Binary64 exponents")
        let expected = inputs.map { ExpectedIEEE754Result.fromOracle(spec.oracle($0), maxULP: spec.maxULP) }
        verifyUnaryPacked(op, inputs: inputs, expected: expected)
    }

    // MARK: - Layer 1 & 2: Binary Operations (Exhaustive over SIMDBinaryOperation.allCases)

    @Test(
        "Binary IEEE-754 Cartesian class matrix, mixed lanes, and transitions", arguments: SIMDBinaryOperation.allCases)
    func verifyBinaryOp(op: SIMDBinaryOperation) {
        let spec = op.spec
        #expect(spec.maxULP <= Self.maxAllowedContractULP, "\(op) maxULP \(spec.maxULP) exceeds contract ceiling")
        #expect(!spec.homogeneousPairs.isEmpty, "\(op) must declare homogeneousPairs")
        #expect(!spec.heterogeneousPairs.isEmpty, "\(op) must declare heterogeneousPairs")
        #expect(!spec.stabilityTransitions.isEmpty, "\(op) must declare stabilityTransitions")
        let matrix = op.classMatrixCases()
        #expect(!matrix.isEmpty, "\(op) classMatrixCases must not be empty")

        for (pair, expected) in matrix {
            verifyBinaryHomogeneous(op, pair: pair, expected: expected)
        }
        verifyBinaryPacked(op, pairs: matrix.map(\.0), expected: matrix.map(\.1))

        for batch in spec.heterogeneousPairs {
            let expected = batch.map { ExpectedIEEE754Result.fromOracle(spec.oracle($0.a, $0.b), maxULP: spec.maxULP) }
            verifyBinaryPacked(op, pairs: batch, expected: expected)
        }
        for pair in spec.homogeneousPairs + spec.stabilityTransitions {
            let expected = ExpectedIEEE754Result.fromOracle(spec.oracle(pair.a, pair.b), maxULP: spec.maxULP)
            verifyBinaryHomogeneous(op, pair: pair, expected: expected)
        }
        let transExp = spec.stabilityTransitions.map { pair in
            ExpectedIEEE754Result.fromOracle(spec.oracle(pair.a, pair.b), maxULP: spec.maxULP)
        }
        verifyBinaryPacked(op, pairs: spec.stabilityTransitions, expected: transExp)
    }

    // MARK: - Layer 1 & 2: Ternary Operations (Exhaustive over SIMDTernaryOperation.allCases)

    @Test("Ternary 1000-cell IEEE-754 Cartesian class matrix and mixed lanes", arguments: SIMDTernaryOperation.allCases)
    func verifyTernaryOp(op: SIMDTernaryOperation) {
        let spec = op.spec
        #expect(spec.maxULP <= Self.maxAllowedContractULP, "\(op) maxULP \(spec.maxULP) exceeds contract ceiling")
        #expect(!spec.homogeneousTriplets.isEmpty, "\(op) must declare homogeneousTriplets")
        #expect(!spec.heterogeneousTriplets.isEmpty, "\(op) must declare heterogeneousTriplets")
        let matrix = op.classMatrixCases()
        #expect(matrix.count == 1000, "\(op) ternary class matrix must contain all 1000 cells")
        verifyTernaryPacked(op, triplets: matrix.map(\.0), expected: matrix.map(\.1))

        for triplet in spec.homogeneousTriplets {
            let exp = ExpectedIEEE754Result.fromOracle(
                spec.oracle(triplet.x, triplet.lower, triplet.upper), maxULP: spec.maxULP)
            verifyTernaryHomogeneous(op, triplet: triplet, expected: exp)
        }
        for batch in spec.heterogeneousTriplets {
            let exp = batch.map { triplet in
                ExpectedIEEE754Result.fromOracle(
                    spec.oracle(triplet.x, triplet.lower, triplet.upper), maxULP: spec.maxULP)
            }
            verifyTernaryPacked(op, triplets: batch, expected: exp)
        }
    }

    // MARK: - Layer 1 & 2: Dual-Unary Operations (Exhaustive over SIMDDualUnaryOperation.allCases)

    @Test("Dual-unary IEEE-754 class matrix, mixed lanes, and transitions", arguments: SIMDDualUnaryOperation.allCases)
    func verifyDualUnaryOp(op: SIMDDualUnaryOperation) {
        let spec = op.spec
        #expect(spec.maxULP <= Self.maxAllowedContractULP, "\(op) maxULP \(spec.maxULP) exceeds contract ceiling")
        #expect(!spec.homogeneousInputs.isEmpty, "\(op) must declare homogeneousInputs")
        #expect(!spec.heterogeneousLanes.isEmpty, "\(op) must declare heterogeneousLanes")
        #expect(!spec.stabilityTransitions.isEmpty, "\(op) must declare stabilityTransitions")
        let inputs = IEEE754Class.allCases.map(\.representative)
        let expected = IEEE754Class.allCases.map { spec.classExpectation($0) }
        for (x, exp) in zip(inputs, expected) {
            verifyDualHomogeneous(op, x: x, expected: exp)
        }
        verifyDualPacked(op, inputs: inputs, expected: expected)

        for x in spec.homogeneousInputs + spec.stabilityTransitions {
            let exp = dualExpected(spec.oracle(x), maxULP: spec.maxULP)
            verifyDualHomogeneous(op, x: x, expected: exp)
        }
        for batch in spec.heterogeneousLanes {
            let exp = batch.map { dualExpected(spec.oracle($0), maxULP: spec.maxULP) }
            verifyDualPacked(op, inputs: batch, expected: exp)
        }
    }

    // MARK: - Compile-Time Exhaustive Category Coverage Gate (Zero default: Branches)

    @Test(
        "Every operation category executes real Layers 1–3 Grounding specs", arguments: SIMDOperationCategory.allCases)
    func verifyCategoryGroundingCoverage(category: SIMDOperationCategory) {
        let verifiedOps = Self.validatedGroundingOperations(for: category)
        #expect(verifiedOps == category.operationNames, "Category \(category.rawValue) grounding coverage mismatch")
    }

    private static func validatedGroundingOperations(for category: SIMDOperationCategory) -> [String] {
        switch category {
        case .unary:
            return SIMDUnaryOperation.allCases.filter { op in
                let s = op.spec
                return !s.homogeneousInputs.isEmpty && !s.heterogeneousLanes.isEmpty && !s.stabilityTransitions.isEmpty
            }.map(\.rawValue)

        case .binary:
            return SIMDBinaryOperation.allCases.filter { op in
                let s = op.spec
                return !s.homogeneousPairs.isEmpty && !s.heterogeneousPairs.isEmpty && !s.stabilityTransitions.isEmpty
            }.map(\.rawValue)

        case .ternary:
            return SIMDTernaryOperation.allCases.filter { op in
                let s = op.spec
                return !s.homogeneousTriplets.isEmpty && !s.heterogeneousTriplets.isEmpty
            }.map(\.rawValue)

        case .dualUnary:
            return SIMDDualUnaryOperation.allCases.filter { op in
                let s = op.spec
                return !s.homogeneousInputs.isEmpty && !s.heterogeneousLanes.isEmpty && !s.stabilityTransitions.isEmpty
            }.map(\.rawValue)
        }
    }
}
