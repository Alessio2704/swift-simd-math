// MARK: - Pure-Swift Cold Paths for lgamma & tgamma (x < 0.5, Negative Reflection, Poles, Overflow)

extension SIMDMath {
    @usableFromInline
    @inline(never)
    static func lgammaCold(_ x: SIMD2<Double>) -> SIMD2<Double> {
        SIMD2<Double>(lgammaColdLane(x[0]), lgammaColdLane(x[1]))
    }

    @usableFromInline
    @inline(never)
    static func tgammaCold(_ x: SIMD4<Double>) -> SIMD4<Double> {
        var out = SIMD4<Double>.zero
        for lane in 0..<4 {
            out[lane] = tgammaColdLane(x[lane])
        }
        return out
    }

    // MARK: - Exact Scalar Cold-Lane Implementations (Zero C-libm Dependency)

    private static func lgammaColdLane(_ x: Double) -> Double {
        if x.isNaN { return x + x }
        if x.isInfinite { return .infinity }
        if x >= 2.556348e305 { return .infinity }
        if x >= 0.5 {
            if x >= 1.0e300 {
                let lnX = log(SIMD4<Double>(repeating: x))[0]
                return x * (lnX - 1.0) - 0.5 * lnX + 9.18938533204672742e-01
            }
            return lgammaPositiveGeHalf(SIMD2<Double>(repeating: x))[0]
        }
        if x == 0.0 { return .infinity }
        if Swift.abs(x) < 1.0e-100 {
            return -log(SIMD2<Double>(repeating: Swift.abs(x)))[0]
        }
        if x > 0.0 {
            let lgNext = lgammaPositiveGeHalf(SIMD2<Double>(repeating: x + 1.0))[0]
            return lgNext - log(SIMD2<Double>(repeating: x))[0]
        }
        let rounded = x.rounded(.toNearestOrAwayFromZero)
        if x == rounded { return .infinity }

        let frac = Swift.abs(x - rounded)
        let absX = -x
        if absX < 160.0 {
            let (ratioHi, ratioLo) = gammaReflectionRatioHiLo(absX: absX, frac: frac)
            return log(SIMD2<Double>(repeating: ratioHi))[0] + ratioLo / ratioHi
        }
        let sinPiF = sinPiScalarHiLo(frac).hi
        let lgAbsX = lgammaPositiveGeHalf(SIMD2<Double>(repeating: absX))[0]
        let lnPi = 1.14472988584940017
        return lnPi - log(SIMD2<Double>(repeating: sinPiF))[0] - lgAbsX - log(SIMD2<Double>(repeating: absX))[0]
    }

    private static func tgammaColdLane(_ x: Double) -> Double {
        if x.isNaN { return x + x }
        if x == 0.0 { return x.sign == .minus ? -.infinity : .infinity }
        if Swift.abs(x) < 1.0e-100 { return 1.0 / x }
        if x == .infinity { return .infinity }
        if x == -.infinity { return .nan }
        if x > 171.62437695630272 { return .infinity }
        if x >= 0.5 { return tgammaPositiveFast(SIMD4<Double>(repeating: x))[0] }
        if x > 0.0 {
            return tgammaPositiveFast(SIMD4<Double>(repeating: x + 1.0))[0] / x
        }
        let floored = x.rounded(.down)
        if x == floored { return .nan }

        let isNegResult = (Int64(floored) & 1) != 0
        if x < -184.0 { return isNegResult ? -0.0 : 0.0 }

        let frac = Swift.abs(x - x.rounded(.toNearestOrAwayFromZero))
        let absX = -x
        let mag: Double
        if absX < 168.0 {
            mag = gammaReflectionRatioHiLo(absX: absX, frac: frac).hi
        } else if absX <= 170.0 {
            let sinPiF = sinPiScalarHiLo(frac).hi
            let gAbsX = tgammaExactPositiveScalarHiLo(absX).hi
            mag = ((Double.pi / sinPiF) / gAbsX) / absX
        } else {
            let sinPiF = sinPiScalarHiLo(frac).hi
            let piOverSinPiF = Double.pi / sinPiF
            var shifted = absX
            var factorHi = absX
            var factorLo = 0.0
            for _ in 0..<15 {
                shifted -= 1.0
                let p = factorHi * shifted
                let err = (-p).addingProduct(factorHi, shifted) + factorLo * shifted
                factorHi = p + err
                factorLo = (p - factorHi) + err
            }
            let gShifted = tgammaPositiveFast(SIMD4<Double>(repeating: shifted))[0]
            let q = piOverSinPiF / gShifted
            mag = (q / factorHi) * (1.0 - factorLo / factorHi)
        }
        return isNegResult ? -mag : mag
    }

    /// Evaluates reflection magnitude `pi / (sin(pi * frac) * Gamma(1 + absX))` as a compensated `(hi, lo)` pair.
    private static func gammaReflectionRatioHiLo(absX: Double, frac: Double) -> (hi: Double, lo: Double) {
        let piHi = 3.14159265358979312e+00
        let piLo = 1.22464679914735321e-16
        let (sinHi, sinLo) = sinPiScalarHiLo(frac)
        let (prodHi, prodLo): (Double, Double)
        if absX >= 1.0 {
            let (gHi, gLo) = tgammaExactPositiveScalarHiLo(absX)
            let dHi = sinHi * absX
            let dLo = (-dHi).addingProduct(sinHi, absX) + sinLo * absX
            let p0 = dHi * gHi
            let pErr = (-p0).addingProduct(dHi, gHi) + dHi * gLo + dLo * gHi
            prodHi = p0 + pErr
            prodLo = (p0 - prodHi) + pErr
        } else {
            let (gHi, gLo) = tgammaExactPositiveScalarHiLo(1.0 + absX)
            let p0 = sinHi * gHi
            let pErr = (-p0).addingProduct(sinHi, gHi) + sinHi * gLo + sinLo * gHi
            prodHi = p0 + pErr
            prodLo = (p0 - prodHi) + pErr
        }
        let qHi = piHi / prodHi
        let qLo = (piHi.addingProduct(-qHi, prodHi) + piLo.addingProduct(-qHi, prodLo)) / prodHi
        let hi = qHi + qLo
        return (hi, (qHi - hi) + qLo)
    }

    /// High-precision scalar `sin(pi * f)` on `f in [0, 0.5]` returning a compensated `(hi, lo)` pair.
    private static func sinPiScalarHiLo(_ f: Double) -> (hi: Double, lo: Double) {
        let f2 = f * f
        let f3 = f * f2
        let f4 = f2 * f2
        let piHi = 3.14159265358979312e+00
        let piLo = 1.22464679914735321e-16
        let c3Hi = -5.16771278004997026e+00
        let c3Lo = 2.26656228257894474e-16

        let sHi = f * piHi
        let sErr = (-sHi).addingProduct(f, piHi)
        let t3Hi = f3 * c3Hi
        let t3Err = (-t3Hi).addingProduct(f3, c3Hi)
        let sumHi = sHi + t3Hi
        let sumErr = (sHi - sumHi) + t3Hi

        let r01 = (2.55016403987734508e+00).addingProduct(f2, -5.99264529320726380e-01)
        let r23 = (8.21458866069244426e-02).addingProduct(f2, -7.37043084476165806e-03)
        let r46 = (4.66301650775197856e-04)
            .addingProduct(f2, -2.19085642294756898e-05)
            .addingProduct(f4, 7.75374162400719320e-07)
        let remPoly = r01.addingProduct(f4, r23).addingProduct(f4 * f4, r46)
        let lo0 = (sErr + t3Err + sumErr).addingProduct(f, piLo).addingProduct(f3, c3Lo.addingProduct(f2, remPoly))
        let hi = sumHi + lo0
        return (hi, (sumHi - hi) + lo0)
    }

    /// High-accuracy scalar `Gamma(a)` for `a in [0.5, 170]` returning a compensated `(hi, lo)` pair.
    private static func tgammaExactPositiveScalarHiLo(_ a: Double) -> (hi: Double, lo: Double) {
        if a >= 8.0 {
            return (tgammaStirling(SIMD4<Double>(repeating: a))[0], 0.0)
        }
        var u = a
        var denom = 1.0
        if u < 1.0 {
            denom = u
            u += 1.0
        }
        var multHi = 1.0
        var multLo = 0.0
        while u >= 2.0 {
            u -= 1.0
            let p = multHi * u
            let err = (-p).addingProduct(multHi, u) + multLo * u
            multHi = p + err
            multLo = (p - multHi) + err
        }
        let invGammaU = rgamma12Poly(SIMD4<Double>(repeating: u - 1.5))[0]
        let denHi = denom * invGammaU
        let denLo = (-denHi).addingProduct(denom, invGammaU)
        let qHi = multHi / denHi
        let qLo = (multHi.addingProduct(-qHi, denHi) + multLo.addingProduct(-qHi, denLo)) / denHi
        let hi = qHi + qLo
        return (hi, (qHi - hi) + qLo)
    }
}
