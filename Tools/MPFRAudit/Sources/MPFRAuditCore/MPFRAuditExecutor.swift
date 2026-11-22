public import SwiftSIMDMathTestSupport

// MARK: - Parallel Multi-Width SIMD2 / SIMD4 / SIMD8 MPFR Audit Executor (Unary & Binary)

public enum MPFRAuditExecutor: Sendable {
    public static var totalCatalogOperationCount: Int {
        SIMDOperationCategory.totalOperationCount
    }

    public static func auditUnary(_ operation: SIMDUnaryOperation, samplesPerOp: Int) -> MPFRAuditOperationScorecard {
        let profile = operation.mpfrAuditProfile
        let samples = profile.sampleGenerator(samplesPerOp)
        guard !profile.goldenAnchors.isEmpty, samples.count >= samplesPerOp else {
            return Self.invalidProfileScorecard(operationName: operation.rawValue, contractMaxULP: profile.maxULP)
        }
        return Self.auditUnaryWithEvaluators(
            operationName: operation.rawValue,
            inputs: profile.goldenAnchors + samples,
            profile: profile,
            eval2: { operation.evaluate($0) },
            eval4: { operation.evaluate($0) },
            eval8: { operation.evaluate($0) }
        )
    }

    static func auditUnaryWithEvaluators(
        operationName: String,
        inputs: [Double],
        profile: MPFRUnaryAuditProfile,
        eval2: (SIMD2<Double>) -> SIMD2<Double>,
        eval4: (SIMD4<Double>) -> SIMD4<Double>,
        eval8: (SIMD8<Double>) -> SIMD8<Double>
    ) -> MPFRAuditOperationScorecard {
        var maxULP: UInt64 = 0
        var exactCount = 0
        var crossWidthErrors = 0
        var specialErrors = 0
        var worstDesc = "-"
        var worstBits: [UInt64] = []
        var regimeTracker = MPFRRegimeWorstTracker(arity: 1)

        for base in stride(from: 0, to: inputs.count, by: 8) {
            let v8 = SIMD8((0..<8).map { inputs[(base + $0) % inputs.count] })
            let out8 = eval8(v8)
            let lanes = Swift.min(8, inputs.count - base)
            crossWidthErrors += Self.countUnaryCrossWidthErrors(
                v8: v8, out8: out8, lanes: lanes, eval2: eval2, eval4: eval4
            )
            for lane in 0..<lanes {
                let x = v8[lane]
                let actual = out8[lane]
                let expected = profile.referenceEvaluator(x)
                let check = matchesIEEE754SpecialOrFinite(actual: actual, expected: expected)
                if check.isSpecialMismatch {
                    specialErrors += 1
                    if worstBits.isEmpty {
                        worstDesc = "SPECIAL x=\(x) (\(formatHexBits(x.bitPattern))) got=\(actual) exp=\(expected)"
                        worstBits = [x.bitPattern]
                    }
                } else if let absThreshold = profile.nearZeroAbsThreshold,
                    let absTol = profile.nearZeroAbsTolerance,
                    x < 0.0, expected.isFinite, Swift.abs(expected) < absThreshold
                {
                    if Swift.abs(actual - expected) > absTol {
                        specialErrors += 1
                        worstDesc = "ABSERR x=\(x) absErr=\(Swift.abs(actual - expected))"
                        worstBits = [x.bitPattern]
                    } else if check.ulp == 0 {
                        exactCount += 1
                    }
                } else {
                    if check.ulp == 0 { exactCount += 1 }
                    if check.ulp >= regimeTracker.minThreshold {
                        let bits = x.bitPattern
                        regimeTracker.record(
                            ulp: check.ulp, regimeKey: MPFRRegimeWorstTracker.unaryRegimeKey(bits), b0: bits
                        )
                    }
                    if check.ulp > maxULP || worstBits.isEmpty {
                        maxULP = Swift.max(maxULP, check.ulp)
                        worstDesc = "x=\(x) (\(formatHexBits(x.bitPattern)))"
                        worstBits = [x.bitPattern]
                    }
                }
            }
        }
        return MPFRAuditOperationScorecard(
            operationName: operationName,
            contractMaxULP: profile.maxULP,
            totalEvaluations: inputs.count,
            observedMaxULP: maxULP,
            exactZeroULPCount: exactCount,
            crossWidthMismatchCount: crossWidthErrors,
            specialValueMismatchCount: specialErrors,
            worstInputDescription: worstDesc,
            worstInputBitPatterns: worstBits,
            topWorstInputBitPatterns: regimeTracker.topBitPatterns(includingPrimary: worstBits)
        )
    }

    public static func auditBinary(_ operation: SIMDBinaryOperation, samplesPerOp: Int) -> MPFRAuditOperationScorecard {
        let profile = operation.mpfrAuditProfile
        let samples = profile.sampleGenerator(samplesPerOp)
        guard !profile.goldenAnchors.isEmpty, samples.count >= samplesPerOp else {
            return Self.invalidProfileScorecard(operationName: operation.rawValue, contractMaxULP: profile.maxULP)
        }
        return Self.auditBinaryWithEvaluators(
            operationName: operation.rawValue,
            pairs: profile.goldenAnchors + samples,
            profile: profile,
            eval2: { operation.evaluate($0, $1) },
            eval4: { operation.evaluate($0, $1) },
            eval8: { operation.evaluate($0, $1) }
        )
    }

    static func auditBinaryWithEvaluators(
        operationName: String,
        pairs: [(Double, Double)],
        profile: MPFRBinaryAuditProfile,
        eval2: (SIMD2<Double>, SIMD2<Double>) -> SIMD2<Double>,
        eval4: (SIMD4<Double>, SIMD4<Double>) -> SIMD4<Double>,
        eval8: (SIMD8<Double>, SIMD8<Double>) -> SIMD8<Double>
    ) -> MPFRAuditOperationScorecard {
        var maxULP: UInt64 = 0
        var exactCount = 0
        var crossWidthErrors = 0
        var specialErrors = 0
        var worstDesc = "-"
        var worstBits: [UInt64] = []
        var regimeTracker = MPFRRegimeWorstTracker(arity: 2)

        for base in stride(from: 0, to: pairs.count, by: 8) {
            let va8 = SIMD8((0..<8).map { pairs[(base + $0) % pairs.count].0 })
            let vb8 = SIMD8((0..<8).map { pairs[(base + $0) % pairs.count].1 })
            let out8 = eval8(va8, vb8)
            let lanes = Swift.min(8, pairs.count - base)
            crossWidthErrors += Self.countBinaryCrossWidthErrors(
                va8: va8, vb8: vb8, out8: out8, lanes: lanes, eval2: eval2, eval4: eval4
            )
            for lane in 0..<lanes {
                let a = va8[lane]
                let b = vb8[lane]
                let expected = profile.referenceEvaluator(a, b)
                let check = matchesIEEE754SpecialOrFinite(actual: out8[lane], expected: expected)
                if check.isSpecialMismatch {
                    specialErrors += 1
                    if worstBits.isEmpty {
                        worstDesc = "SPECIAL (\(a), \(b)) got=\(out8[lane]) exp=\(expected)"
                        worstBits = [a.bitPattern, b.bitPattern]
                    }
                } else {
                    if check.ulp == 0 { exactCount += 1 }
                    if check.ulp >= regimeTracker.minThreshold {
                        let aBits = a.bitPattern
                        let bBits = b.bitPattern
                        regimeTracker.record(
                            ulp: check.ulp,
                            regimeKey: MPFRRegimeWorstTracker.binaryRegimeKey(aBits, bBits),
                            b0: aBits, b1: bBits
                        )
                    }
                    if check.ulp > maxULP || worstBits.isEmpty {
                        maxULP = Swift.max(maxULP, check.ulp)
                        worstDesc = "(\(formatHexBits(a.bitPattern)), \(formatHexBits(b.bitPattern)))"
                        worstBits = [a.bitPattern, b.bitPattern]
                    }
                }
            }
        }
        return MPFRAuditOperationScorecard(
            operationName: operationName,
            contractMaxULP: profile.maxULP,
            totalEvaluations: pairs.count,
            observedMaxULP: maxULP,
            exactZeroULPCount: exactCount,
            crossWidthMismatchCount: crossWidthErrors,
            specialValueMismatchCount: specialErrors,
            worstInputDescription: worstDesc,
            worstInputBitPatterns: worstBits,
            topWorstInputBitPatterns: regimeTracker.topBitPatterns(includingPrimary: worstBits)
        )
    }
}
