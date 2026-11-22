public import SwiftSIMDMathTestSupport

// MARK: - Parallel Multi-Width SIMD2 / SIMD4 / SIMD8 MPFR Audit Executor (Ternary & Dual-Unary)

extension MPFRAuditExecutor {
    public static func auditTernary(
        _ operation: SIMDTernaryOperation,
        samplesPerOp: Int
    ) -> MPFRAuditOperationScorecard {
        let profile = operation.mpfrAuditProfile
        let samples = profile.sampleGenerator(samplesPerOp)
        guard !profile.goldenAnchors.isEmpty, samples.count >= samplesPerOp else {
            return Self.invalidProfileScorecard(operationName: operation.rawValue, contractMaxULP: profile.maxULP)
        }
        return Self.auditTernaryWithEvaluators(
            operationName: operation.rawValue,
            triplets: profile.goldenAnchors + samples,
            profile: profile,
            eval2: { operation.evaluate($0, $1, $2) },
            eval4: { operation.evaluate($0, $1, $2) },
            eval8: { operation.evaluate($0, $1, $2) }
        )
    }

    static func auditTernaryWithEvaluators(
        operationName: String,
        triplets: [(Double, Double, Double)],
        profile: MPFRTernaryAuditProfile,
        eval2: (SIMD2<Double>, SIMD2<Double>, SIMD2<Double>) -> SIMD2<Double>,
        eval4: (SIMD4<Double>, SIMD4<Double>, SIMD4<Double>) -> SIMD4<Double>,
        eval8: (SIMD8<Double>, SIMD8<Double>, SIMD8<Double>) -> SIMD8<Double>
    ) -> MPFRAuditOperationScorecard {
        var maxULP: UInt64 = 0
        var exactCount = 0
        var crossWidthErrors = 0
        var specialErrors = 0
        var worstDesc = "-"
        var worstBits: [UInt64] = []
        var regimeTracker = MPFRRegimeWorstTracker(arity: 3)

        for base in stride(from: 0, to: triplets.count, by: 8) {
            let vx8 = SIMD8((0..<8).map { triplets[(base + $0) % triplets.count].0 })
            let vl8 = SIMD8((0..<8).map { triplets[(base + $0) % triplets.count].1 })
            let vu8 = SIMD8((0..<8).map { triplets[(base + $0) % triplets.count].2 })
            let out8 = eval8(vx8, vl8, vu8)
            let lanes = Swift.min(8, triplets.count - base)
            crossWidthErrors += Self.countTernaryCrossWidthErrors(
                vx8: vx8, vl8: vl8, vu8: vu8, out8: out8, lanes: lanes, eval2: eval2, eval4: eval4
            )
            for lane in 0..<lanes {
                let x = vx8[lane]
                let lo = vl8[lane]
                let hi = vu8[lane]
                let expected = profile.referenceEvaluator(x, lo, hi)
                let check = matchesIEEE754SpecialOrFinite(actual: out8[lane], expected: expected)
                if check.isSpecialMismatch {
                    specialErrors += 1
                    if worstBits.isEmpty {
                        worstDesc = "SPECIAL (\(x), \(lo), \(hi)) got=\(out8[lane]) exp=\(expected)"
                        worstBits = [x.bitPattern, lo.bitPattern, hi.bitPattern]
                    }
                } else {
                    if check.ulp == 0 { exactCount += 1 }
                    if check.ulp >= regimeTracker.minThreshold {
                        let b0 = x.bitPattern
                        let b1 = lo.bitPattern
                        let b2 = hi.bitPattern
                        regimeTracker.record(
                            ulp: check.ulp,
                            regimeKey: MPFRRegimeWorstTracker.ternaryRegimeKey(b0, b1, b2),
                            b0: b0, b1: b1, b2: b2
                        )
                    }
                    if check.ulp > maxULP || worstBits.isEmpty {
                        maxULP = Swift.max(maxULP, check.ulp)
                        worstDesc = "(\(x), \(lo), \(hi))"
                        worstBits = [x.bitPattern, lo.bitPattern, hi.bitPattern]
                    }
                }
            }
        }
        return MPFRAuditOperationScorecard(
            operationName: operationName,
            contractMaxULP: profile.maxULP,
            totalEvaluations: triplets.count,
            observedMaxULP: maxULP,
            exactZeroULPCount: exactCount,
            crossWidthMismatchCount: crossWidthErrors,
            specialValueMismatchCount: specialErrors,
            worstInputDescription: worstDesc,
            worstInputBitPatterns: worstBits,
            topWorstInputBitPatterns: regimeTracker.topBitPatterns(includingPrimary: worstBits)
        )
    }

    public static func auditDualUnary(
        _ operation: SIMDDualUnaryOperation,
        samplesPerOp: Int
    ) -> MPFRAuditOperationScorecard {
        let profile = operation.mpfrAuditProfile
        let samples = profile.sampleGenerator(samplesPerOp)
        guard !profile.goldenAnchors.isEmpty, samples.count >= samplesPerOp else {
            return Self.invalidProfileScorecard(operationName: operation.rawValue, contractMaxULP: profile.maxULP)
        }
        return Self.auditDualUnaryWithEvaluators(
            operationName: operation.rawValue,
            inputs: profile.goldenAnchors + samples,
            profile: profile,
            eval2: { operation.evaluate($0) },
            eval4: { operation.evaluate($0) },
            eval8: { operation.evaluate($0) }
        )
    }

    static func auditDualUnaryWithEvaluators(
        operationName: String,
        inputs: [Double],
        profile: MPFRDualUnaryAuditProfile,
        eval2: (SIMD2<Double>) -> (first: SIMD2<Double>, second: SIMD2<Double>),
        eval4: (SIMD4<Double>) -> (first: SIMD4<Double>, second: SIMD4<Double>),
        eval8: (SIMD8<Double>) -> (first: SIMD8<Double>, second: SIMD8<Double>)
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
            let (f8, s8) = eval8(v8)
            let lanes = Swift.min(8, inputs.count - base)
            crossWidthErrors += Self.countDualCrossWidthErrors(
                v8: v8, f8: f8, s8: s8, lanes: lanes, eval2: eval2, eval4: eval4
            )
            for lane in 0..<lanes {
                let x = v8[lane]
                let expected = profile.referenceEvaluator(x)
                let checkFirst = matchesIEEE754SpecialOrFinite(actual: f8[lane], expected: expected.first)
                let checkSecond = matchesIEEE754SpecialOrFinite(actual: s8[lane], expected: expected.second)
                if checkFirst.isSpecialMismatch || checkSecond.isSpecialMismatch {
                    specialErrors += 1
                    if worstBits.isEmpty {
                        worstDesc = "SPECIAL x=\(x) (\(formatHexBits(x.bitPattern)))"
                        worstBits = [x.bitPattern]
                    }
                } else {
                    let worstPair = Swift.max(checkFirst.ulp, checkSecond.ulp)
                    if worstPair == 0 { exactCount += 1 }
                    if worstPair >= regimeTracker.minThreshold {
                        let bits = x.bitPattern
                        regimeTracker.record(
                            ulp: worstPair, regimeKey: MPFRRegimeWorstTracker.unaryRegimeKey(bits), b0: bits
                        )
                    }
                    if worstPair > maxULP || worstBits.isEmpty {
                        maxULP = Swift.max(maxULP, worstPair)
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
}
