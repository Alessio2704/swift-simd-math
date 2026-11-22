import CMPFRBridge
import Testing

@Suite("CMPFRBridge C Library: Multi-Threaded Thread-Local Isolation & Determinism")
struct CMPFRBridgeConcurrencyTests {
    private static let stressInputs: [Double] = [
        -Double.greatestFiniteMagnitude, -1.0e200, -745.1332191019412, -10.5, -1.25, -0.5,
        -Double.leastNormalMagnitude, -Double.leastNonzeroMagnitude, -0.0, 0.0,
        Double.leastNonzeroMagnitude, Double.leastNormalMagnitude, 0.25, 0.5, 1.0, 1.5,
        3.141592653589793, 12.5, 709.782712893384, 1.0e200, Double.greatestFiniteMagnitude,
        .infinity, -.infinity, .nan
    ]

    @Test("16 concurrent TaskGroup workers produce bit-identical results with zero TLS state leakage")
    func verifyConcurrentThreadLocalDeterminism() async {
        let baseline = Self.evaluateFullBridgeFingerprint(inputs: Self.stressInputs)

        let workerResults = await withTaskGroup(of: [UInt64].self) { group in
            for _ in 0..<16 {
                group.addTask {
                    Self.evaluateFullBridgeFingerprint(inputs: Self.stressInputs)
                }
            }
            var collected: [[UInt64]] = []
            for await fingerprint in group {
                collected.append(fingerprint)
            }
            return collected
        }

        #expect(workerResults.count == 16)
        for (workerIdx, fingerprint) in workerResults.enumerated() {
            #expect(
                fingerprint.count == baseline.count,
                "Worker \(workerIdx) returned \(fingerprint.count) entries, expected \(baseline.count)"
            )
            for idx in 0..<baseline.count {
                let lhs = Double(bitPattern: fingerprint[idx])
                let rhs = Double(bitPattern: baseline[idx])
                let match = (lhs.isNaN && rhs.isNaN) || (fingerprint[idx] == baseline[idx])
                #expect(
                    match,
                    "TLS race or determinism mismatch at worker \(workerIdx), slot \(idx): \(fingerprint[idx]) vs \(baseline[idx])"
                )
            }
        }
    }

    private static func evaluateFullBridgeFingerprint(inputs: [Double]) -> [UInt64] {
        var bits: [UInt64] = []
        bits.reserveCapacity(inputs.count * 26)
        for x in inputs {
            bits.append(mpfr_ieee754_exp(x).bitPattern)
            bits.append(mpfr_ieee754_exp2(x).bitPattern)
            bits.append(mpfr_ieee754_exp10(x).bitPattern)
            bits.append(mpfr_ieee754_expm1(x).bitPattern)
            bits.append(mpfr_ieee754_log(x).bitPattern)
            bits.append(mpfr_ieee754_log2(x).bitPattern)
            bits.append(mpfr_ieee754_log10(x).bitPattern)
            bits.append(mpfr_ieee754_log1p(x).bitPattern)
            bits.append(mpfr_ieee754_sin(x).bitPattern)
            bits.append(mpfr_ieee754_cos(x).bitPattern)
            bits.append(mpfr_ieee754_tan(x).bitPattern)
            bits.append(mpfr_ieee754_asin(x).bitPattern)
            bits.append(mpfr_ieee754_acos(x).bitPattern)
            bits.append(mpfr_ieee754_atan(x).bitPattern)
            bits.append(mpfr_ieee754_sinpi(x).bitPattern)
            bits.append(mpfr_ieee754_cospi(x).bitPattern)
            bits.append(mpfr_ieee754_tanpi(x).bitPattern)
            bits.append(mpfr_ieee754_cbrt(x).bitPattern)
            bits.append(mpfr_ieee754_sinh(x).bitPattern)
            bits.append(mpfr_ieee754_cosh(x).bitPattern)
            bits.append(mpfr_ieee754_tanh(x).bitPattern)
            bits.append(mpfr_ieee754_asinh(x).bitPattern)
            bits.append(mpfr_ieee754_acosh(x).bitPattern)
            bits.append(mpfr_ieee754_atanh(x).bitPattern)
            bits.append(mpfr_ieee754_erf(x).bitPattern)
            bits.append(mpfr_ieee754_erfc(x).bitPattern)
            bits.append(mpfr_ieee754_tgamma(x).bitPattern)
            bits.append(mpfr_ieee754_lgamma(x).bitPattern)
            bits.append(mpfr_ieee754_pow(x, 1.5).bitPattern)
            bits.append(mpfr_ieee754_atan2(x, 1.25).bitPattern)
            bits.append(mpfr_ieee754_hypot(x, 1.25).bitPattern)
            var s = 0.0
            var c = 0.0
            mpfr_ieee754_sincos(x, &s, &c)
            bits.append(s.bitPattern)
            bits.append(c.bitPattern)
            mpfr_ieee754_sincospi(x, &s, &c)
            bits.append(s.bitPattern)
            bits.append(c.bitPattern)
        }
        return bits
    }
}
