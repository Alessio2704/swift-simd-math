import SwiftSIMDMathTestSupport
import Testing

@testable import MPFRAuditCore

@Suite("MPFRAuditExecutor: IEEE-754 Matching, Fault Injection & Cross-Width Detection")
struct MPFRAuditScoringAndFaultInjectionTests {
    @Test("matchesIEEE754SpecialOrFinite detects signed-zero flips, NaN/Inf mismatches, and exact ULP distances")
    func verifyIEEE754MatcherSemantics() {
        // Exact matches
        let zeroExact = matchesIEEE754SpecialOrFinite(actual: 0.0, expected: 0.0)
        #expect(!zeroExact.isSpecialMismatch && zeroExact.ulp == 0)
        let negZeroExact = matchesIEEE754SpecialOrFinite(actual: -0.0, expected: -0.0)
        #expect(!negZeroExact.isSpecialMismatch && negZeroExact.ulp == 0)
        let nanMatch = matchesIEEE754SpecialOrFinite(actual: .nan, expected: .nan)
        #expect(!nanMatch.isSpecialMismatch && nanMatch.ulp == 0)
        let posInfMatch = matchesIEEE754SpecialOrFinite(actual: .infinity, expected: .infinity)
        #expect(!posInfMatch.isSpecialMismatch && posInfMatch.ulp == 0)

        // Signed-zero flip MUST be flagged as a special mismatch
        let signedZeroFlip = matchesIEEE754SpecialOrFinite(actual: 0.0, expected: -0.0)
        #expect(signedZeroFlip.isSpecialMismatch)
        let reverseZeroFlip = matchesIEEE754SpecialOrFinite(actual: -0.0, expected: 0.0)
        #expect(reverseZeroFlip.isSpecialMismatch)

        // Special-value mismatches
        #expect(matchesIEEE754SpecialOrFinite(actual: 1.0, expected: .nan).isSpecialMismatch)
        #expect(matchesIEEE754SpecialOrFinite(actual: .nan, expected: 1.0).isSpecialMismatch)
        #expect(matchesIEEE754SpecialOrFinite(actual: -.infinity, expected: .infinity).isSpecialMismatch)
        #expect(matchesIEEE754SpecialOrFinite(actual: .infinity, expected: 1.0).isSpecialMismatch)

        // Exact ULP distances including 1-ULP, 3-ULP, and crossing zero
        let oneULP = matchesIEEE754SpecialOrFinite(actual: (1.0).nextUp, expected: 1.0)
        #expect(!oneULP.isSpecialMismatch && oneULP.ulp == 1)
        let threeULP = matchesIEEE754SpecialOrFinite(actual: (1.0).nextUp.nextUp.nextUp, expected: 1.0)
        #expect(!threeULP.isSpecialMismatch && threeULP.ulp == 3)
        let crossZero = matchesIEEE754SpecialOrFinite(
            actual: Double.leastNonzeroMagnitude,
            expected: -Double.leastNonzeroMagnitude
        )
        #expect(!crossZero.isSpecialMismatch && crossZero.ulp == 2)
    }

    @Test("Unary fault injection catches ULP drift, signed-zero flips, abs-tolerance violations, and SIMD2/SIMD4 bugs")
    func verifyUnaryFaultInjectionCatchesAllFailureModes() {
        let identityProfile = MPFRUnaryAuditProfile(
            maxULP: 2,
            referenceEvaluator: { $0 },
            sampleGenerator: { _ in [] },
            goldenAnchors: []
        )

        // 1. 3-ULP drift exceeds contract maxULP=2
        let bumpTwo: (Double) -> Double = { value in value == 2.0 ? value.nextUp.nextUp.nextUp : value }
        let ulpFail = MPFRAuditExecutor.auditUnaryWithEvaluators(
            operationName: "fault_ulp",
            inputs: [1.0, 2.0, 4.0],
            profile: identityProfile,
            eval2: { vec in SIMD2(bumpTwo(vec[0]), bumpTwo(vec[1])) },
            eval4: { vec in SIMD4((0..<4).map { bumpTwo(vec[$0]) }) },
            eval8: { vec in SIMD8((0..<8).map { bumpTwo(vec[$0]) }) }
        )
        #expect(!ulpFail.passed && ulpFail.observedMaxULP == 3 && ulpFail.worstInputBitPatterns == [(2.0).bitPattern])

        // 2. Signed-zero flip (+0.0 returned for -0.0)
        let signFail = MPFRAuditExecutor.auditUnaryWithEvaluators(
            operationName: "fault_signed_zero",
            inputs: [-0.0, 1.0],
            profile: identityProfile,
            eval2: { SIMD2($0[0] == 0.0 ? 0.0 : $0[0], $0[1] == 0.0 ? 0.0 : $0[1]) },
            eval4: { v in SIMD4((0..<4).map { v[$0] == 0.0 ? 0.0 : v[$0] }) },
            eval8: { v in SIMD8((0..<8).map { v[$0] == 0.0 ? 0.0 : v[$0] }) }
        )
        #expect(!signFail.passed && signFail.specialValueMismatchCount == 1)

        // 3. SIMD2-only divergence (SIMD4 & SIMD8 agree, SIMD2 diverges)
        let simd2Fail = MPFRAuditExecutor.auditUnaryWithEvaluators(
            operationName: "fault_simd2",
            inputs: [1.0, 2.0, 3.0, 4.0],
            profile: identityProfile,
            eval2: { $0 + SIMD2(0.0, 1.0) },
            eval4: { $0 },
            eval8: { $0 }
        )
        #expect(!simd2Fail.passed && simd2Fail.crossWidthMismatchCount == 2)

        // 4. Near-zero absolute tolerance check (pass inside tolerance, fail outside)
        let absProfile = MPFRUnaryAuditProfile(
            maxULP: 1,
            nearZeroAbsThreshold: 1.0e-3,
            nearZeroAbsTolerance: 1.0e-12,
            referenceEvaluator: { _ in 1.0e-15 },
            sampleGenerator: { _ in [] },
            goldenAnchors: []
        )
        let absPass = MPFRAuditExecutor.auditUnaryWithEvaluators(
            operationName: "abs_pass",
            inputs: [-2.5],
            profile: absProfile,
            eval2: { _ in SIMD2(repeating: 1.0e-15 + 1.0e-13) },
            eval4: { _ in SIMD4(repeating: 1.0e-15 + 1.0e-13) },
            eval8: { _ in SIMD8(repeating: 1.0e-15 + 1.0e-13) }
        )
        #expect(absPass.passed)

        let absFail = MPFRAuditExecutor.auditUnaryWithEvaluators(
            operationName: "abs_fail",
            inputs: [-2.5],
            profile: absProfile,
            eval2: { _ in SIMD2(repeating: 1.0e-10) },
            eval4: { _ in SIMD4(repeating: 1.0e-10) },
            eval8: { _ in SIMD8(repeating: 1.0e-10) }
        )
        #expect(!absFail.passed && absFail.specialValueMismatchCount == 1)

        // 5. Anti-cheat: 0 evaluations and absurd maxULP ceilings MUST fail
        let zeroEvalFail = MPFRAuditExecutor.auditUnaryWithEvaluators(
            operationName: "cheat_zero_evals",
            inputs: [],
            profile: identityProfile,
            eval2: { $0 },
            eval4: { $0 },
            eval8: { $0 }
        )
        #expect(!zeroEvalFail.passed && zeroEvalFail.totalEvaluations == 0)

        let hugeULPProfile = MPFRUnaryAuditProfile(
            maxULP: 999_999,
            referenceEvaluator: { $0 },
            sampleGenerator: { _ in [] },
            goldenAnchors: []
        )
        let hugeULPFail = MPFRAuditExecutor.auditUnaryWithEvaluators(
            operationName: "cheat_huge_ulp",
            inputs: [1.0, 2.0],
            profile: hugeULPProfile,
            eval2: { $0 },
            eval4: { $0 },
            eval8: { $0 }
        )
        #expect(!hugeULPFail.passed)

        let invalidProfileFail = MPFRAuditExecutor.invalidProfileScorecard(
            operationName: "cheat_empty", contractMaxULP: 1)
        #expect(!invalidProfileFail.passed && invalidProfileFail.specialValueMismatchCount == 1)
    }

    @Test("Binary, ternary, and dual-unary fault injection catches SIMD2, SIMD4, ULP, and special-value bugs")
    func verifyMultiArityFaultInjectionCatchesSIMD2AndULPBugs() {
        let binProfile = MPFRBinaryAuditProfile(
            maxULP: 0,
            referenceEvaluator: { $0 + $1 },
            sampleGenerator: { _ in [] },
            goldenAnchors: []
        )
        let binSIMD2Fail = MPFRAuditExecutor.auditBinaryWithEvaluators(
            operationName: "bin_simd2_fault",
            pairs: [(1.0, 2.0), (3.0, 4.0)],
            profile: binProfile,
            eval2: { a, b in a + b + SIMD2(1.0, 0.0) },
            eval4: { a, b in a + b },
            eval8: { a, b in a + b }
        )
        #expect(!binSIMD2Fail.passed && binSIMD2Fail.crossWidthMismatchCount == 1)

        let ternProfile = MPFRTernaryAuditProfile(
            maxULP: 0,
            referenceEvaluator: { $0 + $1 + $2 },
            sampleGenerator: { _ in [] },
            goldenAnchors: []
        )
        let ternSIMD2Fail = MPFRAuditExecutor.auditTernaryWithEvaluators(
            operationName: "tern_simd2_fault",
            triplets: [(1.0, 2.0, 3.0), (4.0, 5.0, 6.0)],
            profile: ternProfile,
            eval2: { x, lo, hi in x + lo + hi + SIMD2(0.0, 1.0) },
            eval4: { x, lo, hi in x + lo + hi },
            eval8: { x, lo, hi in x + lo + hi }
        )
        #expect(!ternSIMD2Fail.passed && ternSIMD2Fail.crossWidthMismatchCount == 1)

        let dualProfile = MPFRDualUnaryAuditProfile(
            maxULP: 0,
            referenceEvaluator: { (first: $0, second: -$0) },
            sampleGenerator: { _ in [] },
            goldenAnchors: []
        )
        let dualSIMD2Fail = MPFRAuditExecutor.auditDualUnaryWithEvaluators(
            operationName: "dual_simd2_fault",
            inputs: [1.0, 2.0],
            profile: dualProfile,
            eval2: { (first: $0, second: -$0 + SIMD2(0.0, 1.0)) },
            eval4: { (first: $0, second: -$0) },
            eval8: { (first: $0, second: -$0) }
        )
        #expect(!dualSIMD2Fail.passed && dualSIMD2Fail.crossWidthMismatchCount == 1)
    }

    @Test("Dynamic catalog count, category audit dispatch, reference oracles (0 ULP), and live MPFR audit pass cleanly")
    func verifyDynamicCountReferenceOraclesAndLiveEndToEndAudit() async {
        #expect(MPFRAuditExecutor.totalCatalogOperationCount == SIMDOperationCategory.totalOperationCount)

        let oracleReports = MPFRReferenceOracleAuditor.auditAllReferenceOracles(samplesPerOracle: 256)
        #expect(oracleReports.count == 5)
        for report in oracleReports {
            #expect(report.passed, "Reference oracle \(report.oracleName) failed: maxULP=\(report.observedMaxULP)")
        }

        var auditedCount = 0
        for category in SIMDOperationCategory.allCases {
            let cards = await MPFRAuditExecutor.auditCategory(category, samplesPerOp: 64)
            #expect(cards.count == category.operationCount)
            auditedCount += cards.count
            for card in cards {
                #expect(card.passed, "Operation \(card.operationName) failed MPFR audit: maxULP=\(card.observedMaxULP)")
            }
        }
        #expect(auditedCount == SIMDOperationCategory.totalOperationCount)
    }
}
