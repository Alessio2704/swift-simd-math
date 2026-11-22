import CMPFRBridge
import SwiftSIMDMathTestSupport

// MARK: - Zero-Circular-Verification Auditor for Pure-Swift Reference Oracles

/// Audits `SIMDExactReferenceOracles` directly against GNU MPFR so pure-Swift test oracles
/// used in zero-dependency `swift test` runs are mathematically proven exact (0 ULP on high-precision paths).
public enum MPFRReferenceOracleAuditor: Sendable {
    public static func auditAllReferenceOracles(samplesPerOracle: Int) -> [MPFRAuditOracleReport] {
        let cbrtSamples = MPFRDomainSamplers.stratifiedExponents(
            seed: 0xF001, count: samplesPerOracle, minExp: -1074, maxExp: 1023, signed: true,
            anchors: [
                -Double.greatestFiniteMagnitude, -Double.leastNormalMagnitude, -Double.leastNonzeroMagnitude,
                -0.0, 0.0, Double.leastNonzeroMagnitude, Double.leastNormalMagnitude,
                8.455e+266, 2.364e+284, 6.492e+298, Double.greatestFiniteMagnitude
            ]
        )
        let largeTrigSamples = MPFRDomainSamplers.stratifiedExponents(
            seed: 0xF002, count: samplesPerOracle, minExp: 19, maxExp: 1023, signed: true,
            anchors: MPFRDomainSamplers.trigCriticalAnchors.filter { Swift.abs($0) >= 524_288.0 }
        ).filter { Swift.abs($0) >= 524_288.0 }

        return [
            Self.auditUnaryOracle(
                name: "SIMDExactReferenceOracles.cubeRoot",
                inputs: cbrtSamples,
                contractMaxULP: 0,
                oracle: { SIMDExactReferenceOracles.cubeRoot($0) },
                mpfr: { mpfr_ieee754_cbrt($0) }
            ),
            Self.auditUnaryOracle(
                name: "SIMDExactReferenceOracles.sine(|x|>=2^19)",
                inputs: largeTrigSamples,
                contractMaxULP: 0,
                oracle: { SIMDExactReferenceOracles.sine($0) },
                mpfr: { mpfr_ieee754_sin($0) }
            ),
            Self.auditUnaryOracle(
                name: "SIMDExactReferenceOracles.cosine(|x|>=2^19)",
                inputs: largeTrigSamples,
                contractMaxULP: 0,
                oracle: { SIMDExactReferenceOracles.cosine($0) },
                mpfr: { mpfr_ieee754_cos($0) }
            ),
            Self.auditUnaryOracle(
                name: "SIMDExactReferenceOracles.tangent(|x|>=2^19)",
                inputs: largeTrigSamples,
                contractMaxULP: 0,
                oracle: { SIMDExactReferenceOracles.tangent($0) },
                mpfr: { mpfr_ieee754_tan($0) }
            ),
            Self.auditDualOracle(
                name: "SIMDExactReferenceOracles.sineCosine(|x|>=2^19)",
                inputs: largeTrigSamples,
                contractMaxULP: 0
            )
        ]
    }

    private static func auditUnaryOracle(
        name: String,
        inputs: [Double],
        contractMaxULP: UInt64,
        oracle: (Double) -> Double,
        mpfr: (Double) -> Double
    ) -> MPFRAuditOracleReport {
        var maxULP: UInt64 = 0
        var specialErrors = 0
        var worstDesc = "-"
        for x in inputs {
            let check = matchesIEEE754SpecialOrFinite(actual: oracle(x), expected: mpfr(x))
            if check.isSpecialMismatch {
                specialErrors += 1
                worstDesc = "SPECIAL x=\(x) (\(formatHexBits(x.bitPattern)))"
            } else if check.ulp > maxULP {
                maxULP = check.ulp
                worstDesc = "x=\(x) (\(formatHexBits(x.bitPattern)))"
            }
        }
        return MPFRAuditOracleReport(
            oracleName: name,
            contractMaxULP: contractMaxULP,
            totalEvaluations: inputs.count,
            observedMaxULP: maxULP,
            specialValueMismatchCount: specialErrors,
            worstInputDescription: worstDesc
        )
    }

    private static func auditDualOracle(
        name: String,
        inputs: [Double],
        contractMaxULP: UInt64
    ) -> MPFRAuditOracleReport {
        var maxULP: UInt64 = 0
        var specialErrors = 0
        var worstDesc = "-"
        for x in inputs {
            let actual = SIMDExactReferenceOracles.sineCosine(x)
            var refS = 0.0
            var refC = 0.0
            mpfr_ieee754_sincos(x, &refS, &refC)
            let checkS = matchesIEEE754SpecialOrFinite(actual: actual.sin, expected: refS)
            let checkC = matchesIEEE754SpecialOrFinite(actual: actual.cos, expected: refC)
            if checkS.isSpecialMismatch || checkC.isSpecialMismatch {
                specialErrors += 1
                worstDesc = "SPECIAL x=\(x) (\(formatHexBits(x.bitPattern)))"
            } else {
                let worstPair = Swift.max(checkS.ulp, checkC.ulp)
                if worstPair > maxULP {
                    maxULP = worstPair
                    worstDesc = "x=\(x) (\(formatHexBits(x.bitPattern)))"
                }
            }
        }
        return MPFRAuditOracleReport(
            oracleName: name,
            contractMaxULP: contractMaxULP,
            totalEvaluations: inputs.count,
            observedMaxULP: maxULP,
            specialValueMismatchCount: specialErrors,
            worstInputDescription: worstDesc
        )
    }
}
