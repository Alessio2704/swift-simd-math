import Foundation
import SwiftSIMDMathTestSupport
import Testing

@Suite("SIMDMath Test Harness Self-Tests: IEEE-754 Matchers, Catalog Parser & Metadata")
struct SIMDMathTestHarnessSelfTests {
    @Test("ieee754ULPDistance and ieee754MatchesReference enforce ULP bounds, signed zeros, NaNs, and infinities")
    func verifyGoldenReferenceMatchers() {
        // Exact, 1-ULP, k-ULP, and cross-zero ULP distances
        #expect(ieee754ULPDistance(1.0, 1.0) == 0)
        #expect(ieee754ULPDistance(0.0, -0.0) == 0)
        #expect(ieee754ULPDistance(1.0, (1.0).nextUp) == 1)
        #expect(ieee754ULPDistance(1.0, (1.0).nextDown) == 1)
        #expect(ieee754ULPDistance(0.0, Double.leastNonzeroMagnitude) == 1)
        #expect(ieee754ULPDistance(Double.leastNormalMagnitude.nextDown, Double.leastNormalMagnitude) == 1)
        #expect(ieee754ULPDistance(-Double.leastNonzeroMagnitude, Double.leastNonzeroMagnitude) == 2)

        // ULP threshold boundary (accept <= maxULP, reject maxULP + 1)
        let refBits = (1.0).bitPattern
        #expect(ieee754MatchesReference((1.0).nextUp.nextUp, expectedBits: refBits, maxULP: 2))
        #expect(!ieee754MatchesReference((1.0).nextUp.nextUp.nextUp, expectedBits: refBits, maxULP: 2))

        // Signed zeros MUST match sign bit strictly
        #expect(ieee754MatchesReference(0.0, expectedBits: (0.0).bitPattern, maxULP: 0))
        #expect(ieee754MatchesReference(-0.0, expectedBits: (-0.0).bitPattern, maxULP: 0))
        #expect(!ieee754MatchesReference(0.0, expectedBits: (-0.0).bitPattern, maxULP: 4))
        #expect(!ieee754MatchesReference(-0.0, expectedBits: (0.0).bitPattern, maxULP: 4))

        // NaN (quiet & signaling) and signed infinities
        let qNaNBits: UInt64 = 0x7FF8_0000_0000_0000
        let sNaN = Double(bitPattern: 0x7FF0_0000_0000_0001)
        #expect(ieee754MatchesReference(.nan, expectedBits: qNaNBits, maxULP: 0))
        #expect(ieee754MatchesReference(sNaN, expectedBits: qNaNBits, maxULP: 0))
        #expect(!ieee754MatchesReference(1.0, expectedBits: qNaNBits, maxULP: 4))
        #expect(!ieee754MatchesReference(.nan, expectedBits: refBits, maxULP: 4))
        #expect(ieee754MatchesReference(.infinity, expectedBits: Double.infinity.bitPattern, maxULP: 0))
        #expect(!ieee754MatchesReference(-.infinity, expectedBits: Double.infinity.bitPattern, maxULP: 4))
        #expect(!ieee754MatchesReference(.infinity, expectedBits: refBits, maxULP: 4))
    }

    @Test("ExpectedIEEE754Result.fromOracle and matches enforce all 8 semantic IEEE-754 result cases")
    func verifyExpectedIEEE754ResultMatcher() {
        #expect(ExpectedIEEE754Result.fromOracle(.nan, maxULP: 2).matches(.nan))
        #expect(!ExpectedIEEE754Result.fromOracle(.nan, maxULP: 2).matches(0.0))

        #expect(ExpectedIEEE754Result.fromOracle(.infinity, maxULP: 2).matches(.infinity))
        #expect(!ExpectedIEEE754Result.fromOracle(.infinity, maxULP: 2).matches(-.infinity))
        #expect(ExpectedIEEE754Result.fromOracle(-.infinity, maxULP: 2).matches(-.infinity))
        #expect(!ExpectedIEEE754Result.fromOracle(-.infinity, maxULP: 2).matches(.infinity))

        #expect(ExpectedIEEE754Result.fromOracle(0.0, maxULP: 2).matches(0.0))
        #expect(!ExpectedIEEE754Result.fromOracle(0.0, maxULP: 2).matches(-0.0))
        #expect(ExpectedIEEE754Result.fromOracle(-0.0, maxULP: 2).matches(-0.0))
        #expect(!ExpectedIEEE754Result.fromOracle(-0.0, maxULP: 2).matches(0.0))

        // Exact zero checks sign bit; exact finite rejects 1-ULP drift
        #expect(ExpectedIEEE754Result.exact(-0.0).matches(-0.0))
        #expect(!ExpectedIEEE754Result.exact(-0.0).matches(0.0))
        #expect(ExpectedIEEE754Result.exact(2.0).matches(2.0))
        #expect(!ExpectedIEEE754Result.exact(2.0).matches((2.0).nextUp))

        // Finite ULP bound rejects non-finite and > maxULP
        let fin = ExpectedIEEE754Result.fromOracle(3.0, maxULP: 1)
        #expect(fin.matches((3.0).nextUp))
        #expect(!fin.matches((3.0).nextUp.nextUp))
        #expect(!fin.matches(.infinity))
        #expect(!fin.matches(.nan))

        // Subnormal case requires actual.isSubnormal AND <= maxULP
        let sub = Double.leastNonzeroMagnitude * 4.0
        let subExpected = ExpectedIEEE754Result.fromOracle(sub, maxULP: 1)
        #expect(subExpected.matches(sub))
        #expect(subExpected.matches(sub.nextUp))
        #expect(!subExpected.matches(sub.nextUp.nextUp))
        #expect(!subExpected.matches(0.0))
        #expect(!subExpected.matches(Double.leastNormalMagnitude))
    }

    @Test("Catalog parser strips comments, classifies all categories, and catches missing/unknown widths & arities")
    func verifyCatalogParserOnSyntheticSwiftSources() throws {
        let syntheticSource = """
            // public static func commentedLine(_ x: SIMD2<Double>) -> SIMD2<Double> { x }
            /*
               public static func commentedBlock(_ x: SIMD2<Double>) -> SIMD2<Double> { x }
            */
            extension SIMDMath {
                public static func myUnary(_ x: SIMD2<Double>) -> SIMD2<Double> { x }
                public static func myUnary(_ x: SIMD4<Double>) -> SIMD4<Double> { x }
                public static func myUnary(_ x: SIMD8<Double>) -> SIMD8<Double> { x }

                public static func myBinary(_ a: SIMD2<Double>, _ b: SIMD2<Double>) -> SIMD2<Double> { a + b }
                public static func myBinary(_ a: SIMD4<Double>, _ b: SIMD4<Double>) -> SIMD4<Double> { a + b }

                public static func myTernary(
                    _ a: SIMD2<Double>,
                    _ b: SIMD2<Double>,
                    _ c: SIMD2<Double>
                ) -> SIMD2<Double> { a + b + c }

                public static func myDual(_ x: SIMD4<Double>) -> (first: SIMD4<Double>, second: SIMD4<Double>) { (x, x) }

                public static func myWide(_ x: SIMD16<Double>) -> SIMD16<Double> { x }
                public static func myFloat(_ x: SIMD4<Float>) -> SIMD4<Float> { x }
                public static func myQuat(
                    _ a: SIMD2<Double>, _ b: SIMD2<Double>, _ c: SIMD2<Double>, _ d: SIMD2<Double>
                ) -> SIMD2<Double> { a + b + c + d }
            }
            """

        let discovered = try SIMDMathCatalogCoverageTests.discoverPublicOperations(
            inSources: [(fileName: "Synthetic.swift", source: syntheticSource)]
        )

        // Comments must not produce phantom operations
        #expect(discovered["commentedLine"] == nil)
        #expect(discovered["commentedBlock"] == nil)

        // Complete unary op: 1 category, all 3 widths, 0 unknown widths
        let unary = try #require(discovered["myUnary"])
        #expect(unary.categories == [.unary])
        #expect(unary.widths == SIMDMathCatalogCoverageTests.requiredSIMDWidths)
        #expect(unary.unknownWidths.isEmpty && !unary.hasUnsupportedSignature)

        // Missing SIMD8 overload detected cleanly
        let binary = try #require(discovered["myBinary"])
        #expect(binary.categories == [.binary])
        #expect(binary.widths == ["SIMD2<Double>", "SIMD4<Double>"])
        #expect(binary.widths != SIMDMathCatalogCoverageTests.requiredSIMDWidths)

        // Multi-line ternary and tuple-return dual-unary classified accurately
        let ternary = try #require(discovered["myTernary"])
        #expect(ternary.categories == [.ternary] && ternary.widths == ["SIMD2<Double>"])
        let dual = try #require(discovered["myDual"])
        #expect(dual.categories == [.dualUnary] && dual.widths == ["SIMD4<Double>"])

        // Uncataloged lane width (SIMD16<Double>) and scalar element type (SIMD4<Float>) flagged in unknownWidths
        let wide = try #require(discovered["myWide"])
        #expect(wide.unknownWidths == ["SIMD16<Double>"])
        let floatOp = try #require(discovered["myFloat"])
        #expect(floatOp.unknownWidths == ["SIMD4<Float>"])

        // Unsupported 4-input quaternary signature flagged cleanly
        let quat = try #require(discovered["myQuat"])
        #expect(quat.hasUnsupportedSignature && quat.categories.isEmpty)
    }

    @Test("SIMDOperationCategory, SIMDVectorWidth, and IEEE754Class metadata catalogs are self-consistent")
    func verifyMetadataCatalogInvariants() {
        let sumCount = SIMDOperationCategory.allCases.reduce(0) { $0 + $1.operationCount }
        #expect(sumCount == SIMDOperationCategory.totalOperationCount)
        for category in SIMDOperationCategory.allCases {
            #expect(category.operationNames.count == category.operationCount)
            #expect(Set(category.operationNames).count == category.operationCount)
        }

        let laneCounts = SIMDVectorWidth.allCases.map(\.laneCount)
        #expect(Set(laneCounts).count == SIMDVectorWidth.allCases.count)
        for width in SIMDVectorWidth.allCases {
            #expect(width.laneCount > 0)
            #expect(width.swiftTypeName == "SIMD\(width.laneCount)<Double>")
        }

        // Verify IEEE-754 10-class representatives truly belong to their stated classes
        #expect(IEEE754Class.negativeInfinity.representative == -.infinity)
        #expect(IEEE754Class.positiveInfinity.representative == .infinity)
        #expect(IEEE754Class.negativeZero.representative.bitPattern == (-0.0).bitPattern)
        #expect(IEEE754Class.positiveZero.representative.bitPattern == (0.0).bitPattern)
        #expect(IEEE754Class.negativeSubnormal.representative.isSubnormal)
        #expect(IEEE754Class.positiveSubnormal.representative.isSubnormal)
        #expect(IEEE754Class.quietNaN.representative.isNaN && !IEEE754Class.quietNaN.representative.isSignalingNaN)
        #expect(IEEE754Class.signalingNaN.representative.isSignalingNaN)
    }
}
