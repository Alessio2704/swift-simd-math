import CMPFRBridge
import Foundation
import Testing

@Suite("CMPFRBridge C Library: IEEE-754 Binary64 Rounding, Subnormals & Exact Identities")
struct CMPFRBridgeIEEE754Tests {
    @Test("C bridge links GNU MPFR >= 4.x and reports a valid version string")
    func verifyMPFRVersion() {
        let version = String(cString: mpfr_ieee754_version())
        #expect(!version.isEmpty, "MPFR version string must be non-empty")
        let parts = version.split(separator: ".")
        let major = parts.first.flatMap { Int($0) } ?? 0
        #expect(major >= 4, "Expected GNU MPFR major version >= 4, got \(version)")
    }

    @Test("IEEE-754 emin=-1073, emax=1024, and mpfr_subnormalize round subnormals and ties-to-even accurately")
    func verifySubnormalAndExponentBoundaries() {
        // Exact smallest subnormal 2^-1074 and exact halfway tie 2^-1075 -> round-to-even (+0.0)
        #expect(mpfr_ieee754_exp2(-1074.0).bitPattern == Double.leastNonzeroMagnitude.bitPattern)
        #expect(mpfr_ieee754_exp2(-1074.99).bitPattern == Double.leastNonzeroMagnitude.bitPattern)
        #expect(mpfr_ieee754_exp2(-1075.0).bitPattern == (0.0).bitPattern)
        #expect(mpfr_ieee754_exp2(-1075.01).bitPattern == (0.0).bitPattern)

        // Subnormal -> normal boundary (2^-1022) and max exponent overflow (2^1024 -> +inf)
        #expect(mpfr_ieee754_exp2(-1022.0).bitPattern == Double.leastNormalMagnitude.bitPattern)
        #expect(mpfr_ieee754_exp2(1023.0) == Double(sign: .plus, exponent: 1023, significand: 1.0))
        #expect(mpfr_ieee754_exp2(1024.0) == .infinity)

        // Subnormal pow & hypot exactness (3-4-5 Pythagorean triple at ULP of subnormal scale)
        #expect(mpfr_ieee754_pow(2.0, -1074.0).bitPattern == Double.leastNonzeroMagnitude.bitPattern)
        #expect(mpfr_ieee754_pow(2.0, -1075.0).bitPattern == (0.0).bitPattern)
        let threeSub = Double.leastNonzeroMagnitude * 3.0
        let fourSub = Double.leastNonzeroMagnitude * 4.0
        let fiveSub = Double.leastNonzeroMagnitude * 5.0
        #expect(mpfr_ieee754_hypot(threeSub, fourSub).bitPattern == fiveSub.bitPattern)

        // Exact 1-ULP subnormal exp boundary around -1075 * ln(2) = -745.1332191019412076...
        let expCutoffDown = -745.1332191019412
        #expect(mpfr_ieee754_exp(expCutoffDown).bitPattern == (0.0).bitPattern)
        #expect(mpfr_ieee754_exp(expCutoffDown.nextUp).bitPattern == Double.leastNonzeroMagnitude.bitPattern)
        #expect(mpfr_ieee754_exp(-746.0).bitPattern == (0.0).bitPattern)
    }

    @Test("All unary exponential and logarithmic C bridge functions satisfy exact identities and special values")
    func verifyExpLogBridgeFunctions() {
        #expect(mpfr_ieee754_exp(0.0) == 1.0)
        #expect(mpfr_ieee754_exp(-.infinity).bitPattern == (0.0).bitPattern)
        #expect(mpfr_ieee754_exp(.infinity) == .infinity)
        #expect(mpfr_ieee754_exp(.nan).isNaN)

        #expect(mpfr_ieee754_exp2(0.0) == 1.0)
        #expect(mpfr_ieee754_exp2(10.0) == 1024.0)
        #expect(mpfr_ieee754_exp10(0.0) == 1.0)
        #expect(mpfr_ieee754_exp10(6.0) == 1_000_000.0)
        #expect(mpfr_ieee754_exp10(309.0) == .infinity)

        #expect(mpfr_ieee754_expm1(0.0).bitPattern == (0.0).bitPattern)
        #expect(mpfr_ieee754_expm1(-0.0).bitPattern == (-0.0).bitPattern)
        #expect(mpfr_ieee754_expm1(-.infinity) == -1.0)

        #expect(mpfr_ieee754_log(1.0).bitPattern == (0.0).bitPattern)
        #expect(mpfr_ieee754_log(0.0) == -.infinity)
        #expect(mpfr_ieee754_log(-1.0).isNaN)
        #expect(mpfr_ieee754_log2(1024.0) == 10.0)
        #expect(mpfr_ieee754_log10(1_000_000.0) == 6.0)
        #expect(mpfr_ieee754_log1p(0.0).bitPattern == (0.0).bitPattern)
        #expect(mpfr_ieee754_log1p(-0.0).bitPattern == (-0.0).bitPattern)
        #expect(mpfr_ieee754_log1p(-1.0) == -.infinity)
        #expect(mpfr_ieee754_log1p(-2.0).isNaN)
    }

    @Test("All trig, inverse trig, pi-trig, and dual C bridge functions satisfy exact identities and signed zeros")
    func verifyTrigAndPiTrigBridgeFunctions() {
        #expect(mpfr_ieee754_sin(0.0).bitPattern == (0.0).bitPattern)
        #expect(mpfr_ieee754_sin(-0.0).bitPattern == (-0.0).bitPattern)
        #expect(mpfr_ieee754_cos(0.0) == 1.0)
        #expect(mpfr_ieee754_tan(-0.0).bitPattern == (-0.0).bitPattern)
        #expect(mpfr_ieee754_sin(.infinity).isNaN)

        #expect(mpfr_ieee754_asin(0.0).bitPattern == (0.0).bitPattern)
        #expect(mpfr_ieee754_asin(-0.0).bitPattern == (-0.0).bitPattern)
        #expect(mpfr_ieee754_asin(2.0).isNaN)
        #expect(mpfr_ieee754_acos(1.0).bitPattern == (0.0).bitPattern)
        #expect(mpfr_ieee754_acos(-2.0).isNaN)
        #expect(mpfr_ieee754_atan(-0.0).bitPattern == (-0.0).bitPattern)

        // Exact pi-trig identities (both MPFR >= 4.2 native path and fallback semantics)
        #expect(mpfr_ieee754_sinpi(0.5) == 1.0)
        #expect(mpfr_ieee754_sinpi(-0.5) == -1.0)
        #expect(mpfr_ieee754_sinpi(1.0).bitPattern == (0.0).bitPattern)
        #expect(mpfr_ieee754_sinpi(-1.0).bitPattern == (-0.0).bitPattern)
        #expect(mpfr_ieee754_cospi(0.0) == 1.0)
        #expect(mpfr_ieee754_cospi(0.5).bitPattern == (0.0).bitPattern)
        #expect(mpfr_ieee754_cospi(1.0) == -1.0)
        #expect(mpfr_ieee754_tanpi(0.25) == 1.0)
        #expect(mpfr_ieee754_tanpi(-0.25) == -1.0)
        #expect(mpfr_ieee754_tanpi(0.5) == .infinity)
        #expect(mpfr_ieee754_tanpi(-0.5) == -.infinity)

        var sinOut = 0.0
        var cosOut = 0.0
        mpfr_ieee754_sincos(0.0, &sinOut, &cosOut)
        #expect(sinOut.bitPattern == (0.0).bitPattern && cosOut == 1.0)

        mpfr_ieee754_sincospi(0.5, &sinOut, &cosOut)
        #expect(sinOut == 1.0 && cosOut.bitPattern == (0.0).bitPattern)
    }

    @Test("All root, hyperbolic, special, and binary C bridge functions satisfy exact identities and special values")
    func verifyRootHyperbolicSpecialAndBinaryBridgeFunctions() {
        #expect(mpfr_ieee754_cbrt(27.0) == 3.0)
        #expect(mpfr_ieee754_cbrt(-8.0) == -2.0)
        #expect(mpfr_ieee754_cbrt(-0.0).bitPattern == (-0.0).bitPattern)

        #expect(mpfr_ieee754_sinh(-0.0).bitPattern == (-0.0).bitPattern)
        #expect(mpfr_ieee754_cosh(0.0) == 1.0)
        #expect(mpfr_ieee754_tanh(.infinity) == 1.0)
        #expect(mpfr_ieee754_tanh(-.infinity) == -1.0)
        #expect(mpfr_ieee754_asinh(-0.0).bitPattern == (-0.0).bitPattern)
        #expect(mpfr_ieee754_acosh(1.0).bitPattern == (0.0).bitPattern)
        #expect(mpfr_ieee754_acosh(0.5).isNaN)
        #expect(mpfr_ieee754_atanh(-0.0).bitPattern == (-0.0).bitPattern)
        #expect(mpfr_ieee754_atanh(1.0) == .infinity)
        #expect(mpfr_ieee754_atanh(2.0).isNaN)

        #expect(mpfr_ieee754_erf(0.0).bitPattern == (0.0).bitPattern)
        #expect(mpfr_ieee754_erf(.infinity) == 1.0)
        #expect(mpfr_ieee754_erfc(0.0) == 1.0)
        #expect(mpfr_ieee754_erfc(.infinity).bitPattern == (0.0).bitPattern)
        #expect(mpfr_ieee754_tgamma(5.0) == 24.0)
        #expect(mpfr_ieee754_tgamma(1.0) == 1.0)
        #expect(mpfr_ieee754_lgamma(1.0).bitPattern == (0.0).bitPattern)
        #expect(mpfr_ieee754_lgamma(2.0).bitPattern == (0.0).bitPattern)
        #expect(mpfr_ieee754_lgamma(0.0) == .infinity)

        #expect(mpfr_ieee754_pow(3.0, 4.0) == 81.0)
        #expect(mpfr_ieee754_atan2(1.0, 1.0) == Double.pi * 0.25)
        #expect(mpfr_ieee754_atan2(-0.0, 1.0).bitPattern == (-0.0).bitPattern)
        #expect(mpfr_ieee754_hypot(3.0, 4.0) == 5.0)
        #expect(mpfr_ieee754_hypot(.infinity, .nan) == .infinity)
    }
}
