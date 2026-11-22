// MARK: - SIMD Gamma Functions: lgamma & tgamma (<= 2-3 ULP, Pure Swift IEEE-754)

extension SIMDMath {
    // MARK: - Public API: lgamma, tgamma

    /// Evaluates IEEE-754 `lgamma(x) = ln|Gamma(x)|` on `SIMD2<Double>` (`<= 4 ULP`).
    @inlinable
    @inline(__always)
    public static func lgamma(_ x: SIMD2<Double>) -> SIMD2<Double> {
        let valid = (x .>= SIMD2<Double>(repeating: 0.5)) .& (x .< SIMD2<Double>(repeating: 1.0e300))
        if _slowPath(any(.!valid)) {
            return lgammaCold(x)
        }
        return lgammaPositiveGeHalf(x)
    }

    /// Evaluates IEEE-754 `lgamma(x) = ln|Gamma(x)|` on `SIMD4<Double>` (`<= 4 ULP`).
    @inlinable
    @inline(__always)
    public static func lgamma(_ x: SIMD4<Double>) -> SIMD4<Double> {
        SIMD4<Double>(lowHalf: lgamma(x.lowHalf), highHalf: lgamma(x.highHalf))
    }

    /// Evaluates IEEE-754 `lgamma(x) = ln|Gamma(x)|` on `SIMD8<Double>` (`<= 4 ULP`).
    @inlinable
    @inline(__always)
    public static func lgamma(_ x: SIMD8<Double>) -> SIMD8<Double> {
        SIMD8<Double>(lowHalf: lgamma(x.lowHalf), highHalf: lgamma(x.highHalf))
    }

    /// Evaluates IEEE-754 `tgamma(x) = Gamma(x)` on `SIMD2<Double>` (`<= 3 ULP`).
    @inlinable
    @inline(__always)
    public static func tgamma(_ x: SIMD2<Double>) -> SIMD2<Double> {
        tgamma(SIMD4<Double>(lowHalf: x, highHalf: x)).lowHalf
    }

    /// Evaluates IEEE-754 `tgamma(x) = Gamma(x)` on `SIMD4<Double>` (`<= 3 ULP`).
    @inlinable
    @inline(__always)
    public static func tgamma(_ x: SIMD4<Double>) -> SIMD4<Double> {
        let valid = (x .>= SIMD4<Double>(repeating: 0.5)) .& (x .<= SIMD4<Double>(repeating: 171.624))
        if _slowPath(any(.!valid)) {
            return tgammaCold(x)
        }
        return tgammaPositiveFast(x)
    }

    /// Evaluates IEEE-754 `tgamma(x) = Gamma(x)` on `SIMD8<Double>` (`<= 3 ULP`).
    @inlinable
    @inline(__always)
    public static func tgamma(_ x: SIMD8<Double>) -> SIMD8<Double> {
        SIMD8<Double>(lowHalf: tgamma(x.lowHalf), highHalf: tgamma(x.highHalf))
    }

    // MARK: - Positive Fast Kernels

    /// Vectorized `lgamma(x)` for `x in [0.5, 1e300)` on native 128-bit `SIMD2<Double>`.
    @inlinable
    @inline(__always)
    static func lgammaPositiveGeHalf(_ x: SIMD2<Double>) -> SIMD2<Double> {
        let inR12 = x .< SIMD2<Double>(repeating: 2.5)
        let inR3 = (x .>= SIMD2<Double>(repeating: 2.5)) .& (x .< SIMD2<Double>(repeating: 4.5))
        let inR4 = (x .>= SIMD2<Double>(repeating: 4.5)) .& (x .< SIMD2<Double>(repeating: 8.0))
        let inStirling = x .>= SIMD2<Double>(repeating: 8.0)

        var result = SIMD2<Double>.zero
        if any(inR12) {
            let safeX = x.replacing(with: SIMD2<Double>(repeating: 2.0), where: .!inR12)
            let isR1 = safeX .< SIMD2<Double>(repeating: 1.5)
            let s = safeX - SIMD2<Double>(repeating: 2.0).replacing(with: SIMD2<Double>(repeating: 1.0), where: isR1)
            let (valHi, valLo) = lgammaPoly2HiLo(s)
            var val = valHi + valLo
            if any(isR1) {
                let safeR1 = safeX.replacing(with: SIMD2<Double>(repeating: 1.0), where: .!isR1)
                let (lnHi, lnLo) = lgammaLnR1HiLo(safeR1)
                let diffHi = valHi - lnHi
                let v = diffHi - valHi
                let diffErr = (valHi - (diffHi - v)) - (lnHi + v)
                val = val.replacing(with: diffHi + (diffErr + valLo - lnLo), where: isR1)
            }
            result = result.replacing(with: val, where: inR12)
        }
        if any(inR3) {
            let t = x.replacing(with: SIMD2<Double>(repeating: 3.5), where: .!inR3) - SIMD2<Double>(repeating: 3.5)
            result = result.replacing(with: lgammaPoly3(t), where: inR3)
        }
        if any(inR4) {
            let t = x.replacing(with: SIMD2<Double>(repeating: 6.25), where: .!inR4) - SIMD2<Double>(repeating: 6.25)
            result = result.replacing(with: lgammaPoly4(t), where: inR4)
        }
        if any(inStirling) {
            let safeS = x.replacing(with: SIMD2<Double>(repeating: 10.0), where: .!inStirling)
            let invX = SIMD2<Double>(repeating: 1.0) / safeS
            let rem = stirlingPoly(invX * invX) * invX
            let (lnM, expInt) = mantissaLog(safeS)
            let lnX = combineNaturalLog(lnM: lnM, expInt: expInt)
            let ln2PiHalf = SIMD2<Double>(repeating: 9.18938533204672742e-01)
            let val = (safeS - SIMD2<Double>(repeating: 0.5)) * lnX - safeS + ln2PiHalf + rem
            result = result.replacing(with: val, where: inStirling)
        }
        return result
    }

    /// Vectorized `tgamma(x)` for `x in [0.5, 171.624]`.
    @inlinable
    @inline(__always)
    static func tgammaPositiveFast(_ x: SIMD4<Double>) -> SIMD4<Double> {
        let inSmall = x .< SIMD4<Double>(repeating: 8.0)
        let inStirling = x .>= SIMD4<Double>(repeating: 8.0)

        var result = SIMD4<Double>.zero
        if any(inSmall) {
            let safeS = x.replacing(with: SIMD4<Double>(repeating: 1.5), where: .!inSmall)
            result = result.replacing(with: tgammaSmall(safeS), where: inSmall)
        }
        if any(inStirling) {
            let safeL = x.replacing(with: SIMD4<Double>(repeating: 10.0), where: .!inStirling)
            result = result.replacing(with: tgammaStirling(safeL), where: inStirling)
        }
        return result
    }

    /// Evaluates `tgamma(x)` on `[0.5, 8.0)` by shifting to `[1.0, 2.0)` with double-double accumulation.
    @inlinable
    @inline(__always)
    static func tgammaSmall(_ x: SIMD4<Double>) -> SIMD4<Double> {
        let one = SIMD4<Double>(repeating: 1.0)
        var u = x
        var multHi = one
        var multLo = SIMD4<Double>.zero
        var denom = one
        let ltOne = u .< one
        denom = denom.replacing(with: u, where: ltOne)
        u = u.replacing(with: u + one, where: ltOne)

        // Shift down from [2, 8) into [1, 2) (at most 6 steps) with exact double-double product accumulation
        for _ in 0..<6 {
            let geTwo = u .>= SIMD4<Double>(repeating: 2.0)
            if !any(geTwo) { break }
            let nextU = u - one
            let prod = multHi * nextU
            let err = (-prod).addingProduct(multHi, nextU).addingProduct(multLo, nextU)
            let nextHi = prod + err
            let nextLo = (prod - nextHi) + err
            multHi = multHi.replacing(with: nextHi, where: geTwo)
            multLo = multLo.replacing(with: nextLo, where: geTwo)
            u = u.replacing(with: nextU, where: geTwo)
        }
        let den = denom * rgamma12Poly(u - SIMD4<Double>(repeating: 1.5))
        let q = multHi / den
        return q + (multHi.addingProduct(-q, den) + multLo) / den
    }

    /// Evaluates `tgamma(x)` on `[8.0, 171.624]` via ~70-bit double-double log2 Stirling + `exp2TableFast`.
    @inlinable
    @inline(__always)
    static func tgammaStirling(_ x: SIMD4<Double>) -> SIMD4<Double> {
        let uX = unsafeBitCast(x, to: SIMD4<UInt64>.self)
        let (lHi, lLo) = log2HiLoTable(bits: uX)
        let h = x - SIMD4<Double>(repeating: 0.5)
        let pHi = h * lHi
        let pLo = (-pHi).addingProduct(h, lHi).addingProduct(h, lLo)

        let log2EHi = SIMD4<Double>(repeating: 0x1.71547652b82fep+0)
        let log2ELo = SIMD4<Double>(repeating: 0x1.777d0ffda0d24p-56)
        let qHi = x * log2EHi
        let qLo = (-qHi).addingProduct(x, log2EHi).addingProduct(x, log2ELo)

        // Exact TwoSum for pHi - qHi
        let sHi = pHi - qHi
        let v = sHi - pHi
        let sErr = (pHi - (sHi - v)) - (qHi + v)

        let invX = SIMD4<Double>(repeating: 1.0) / x
        let remLog2 = (stirlingPoly(invX * invX) * invX) * log2EHi
        let cHi = SIMD4<Double>(repeating: 0x1.536439a4c6efcp+0)
        let cLo = SIMD4<Double>(repeating: -0x1.49e49a361efebp-54)

        let eHi = sHi + cHi
        let eErr = (sHi - eHi) + cHi
        let loAll = eErr + sErr + (pLo - qLo) + cLo + remLog2
        let finalHi = eHi + loAll
        let finalLo = (eHi - finalHi) + loAll

        // Per-lane overflow-safe scaling (strict lane isolation: SIMD2 == SIMD4 == SIMD8 bit-for-bit).
        let nearOverflow = finalHi .>= SIMD4<Double>(repeating: 1020.0)
        let hiAdj = finalHi.replacing(with: finalHi - SIMD4<Double>(repeating: 512.0), where: nearOverflow)
        let scale = SIMD4<Double>(repeating: 1.0).replacing(
            with: SIMD4<Double>(repeating: 0x1.0p512), where: nearOverflow
        )
        return exp2TableFast(hi: hiAdj, lo: finalLo) * scale
    }
}
