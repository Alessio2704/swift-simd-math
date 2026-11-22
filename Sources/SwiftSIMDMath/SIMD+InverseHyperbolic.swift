// MARK: - SIMD Inverse Hyperbolic Math: asinh, acosh, atanh (<= 2 ULP, Pure Swift IEEE-754)

extension SIMDMath {
    // MARK: - Public API: asinh, acosh, atanh

    /// Evaluates IEEE-754 `asinh(x)` on `SIMD2<Double>` (`<= 2 ULP`).
    @inlinable
    @inline(__always)
    public static func asinh(_ x: SIMD2<Double>) -> SIMD2<Double> {
        asinh(SIMD4<Double>(lowHalf: x, highHalf: x)).lowHalf
    }

    /// Evaluates IEEE-754 `asinh(x)` on `SIMD4<Double>` (`<= 2 ULP`).
    @inlinable
    @inline(__always)
    public static func asinh(_ x: SIMD4<Double>) -> SIMD4<Double> {
        let bits = unsafeBitCast(x, to: SIMD4<UInt64>.self)
        let absBits = bits & 0x7FFF_FFFF_FFFF_FFFF
        // Threshold |x| >= 2^28 (0x41B0_0000_0000_0000) or Inf/NaN -> cold path
        if _slowPath(any(absBits .>= 0x41B0_0000_0000_0000)) {
            return asinhCold(x)
        }
        let signBit = bits & 0x8000_0000_0000_0000
        let ax = unsafeBitCast(absBits, to: SIMD4<Double>.self)
        let mag = asinhModerate(ax)
        return unsafeBitCast(unsafeBitCast(mag, to: SIMD4<UInt64>.self) | signBit, to: SIMD4<Double>.self)
    }

    @inlinable
    @inline(__always)
    static func asinhModerate(_ ax: SIMD4<Double>) -> SIMD4<Double> {
        let isTiny = ax .< SIMD4<Double>(repeating: 0.125)
        let one = SIMD4<Double>(repeating: 1.0)
        let a2 = ax * ax
        var mag = log1pFast(ax + a2 / (one + (one + a2).squareRoot()))
        if any(isTiny) {
            let safeT = ax.replacing(with: 0.0, where: .!isTiny)
            let t = safeT * safeT
            let t2 = t * t
            let p01 = SIMD4<Double>(repeating: -1.66666666666666574e-01)
                .addingProduct(t, SIMD4<Double>(repeating: 7.49999999995599881e-02))
            let p23 = SIMD4<Double>(repeating: -4.46428568140086329e-02)
                .addingProduct(t, SIMD4<Double>(repeating: 3.03818544743809718e-02))
            let p45 = SIMD4<Double>(repeating: -2.23610133962920017e-02)
                .addingProduct(t, SIMD4<Double>(repeating: 1.67137154220973749e-02))
            let q = p01.addingProduct(t2, p23).addingProduct(t2 * t2, p45)
            mag = mag.replacing(with: safeT.addingProduct(safeT * t, q), where: isTiny)
        }
        return mag
    }

    /// Evaluates IEEE-754 `asinh(x)` on `SIMD8<Double>` (`<= 2 ULP`).
    @inlinable
    @inline(__always)
    public static func asinh(_ x: SIMD8<Double>) -> SIMD8<Double> {
        SIMD8<Double>(lowHalf: asinh(x.lowHalf), highHalf: asinh(x.highHalf))
    }

    /// Evaluates IEEE-754 `acosh(x)` on `SIMD2<Double>` (`<= 2 ULP`).
    @inlinable
    @inline(__always)
    public static func acosh(_ x: SIMD2<Double>) -> SIMD2<Double> {
        acosh(SIMD4<Double>(lowHalf: x, highHalf: x)).lowHalf
    }

    /// Evaluates IEEE-754 `acosh(x)` on `SIMD4<Double>` (`<= 2 ULP`).
    @inlinable
    @inline(__always)
    public static func acosh(_ x: SIMD4<Double>) -> SIMD4<Double> {
        let valid = (x .>= SIMD4<Double>(repeating: 1.0)) .& (x .< SIMD4<Double>(repeating: 0x1.0p28))
        if _slowPath(any(.!valid)) {
            return acoshCold(x)
        }
        return acoshCore(x)
    }

    @inlinable
    @inline(__always)
    static func acoshCore(_ x: SIMD4<Double>) -> SIMD4<Double> {
        let one = SIMD4<Double>(repeating: 1.0)
        let t = x - one
        let t2 = t + t
        let tSq = t * t
        let tSqErr = (-tSq).addingProduct(t, t)
        let rad = t2 + tSq
        let v = rad - t2
        let radLo = ((t2 - (rad - v)) + (tSq - v)) + tSqErr
        let sq = rad.squareRoot()
        let sqDen = (sq + sq).replacing(with: one, where: sq .== .zero)
        let sqErr = (rad.addingProduct(-sq, sq) + radLo) / sqDen
        let arg = t + sq
        let argErr = (sq - arg) + t + sqErr
        return log1pFast(arg) + argErr / (one + arg)
    }

    /// Evaluates IEEE-754 `acosh(x)` on `SIMD8<Double>` (`<= 2 ULP`).
    @inlinable
    @inline(__always)
    public static func acosh(_ x: SIMD8<Double>) -> SIMD8<Double> {
        SIMD8<Double>(lowHalf: acosh(x.lowHalf), highHalf: acosh(x.highHalf))
    }

    /// Evaluates IEEE-754 `atanh(x)` on `SIMD2<Double>` (`<= 2 ULP`).
    @inlinable
    @inline(__always)
    public static func atanh(_ x: SIMD2<Double>) -> SIMD2<Double> {
        atanh(SIMD4<Double>(lowHalf: x, highHalf: x)).lowHalf
    }

    /// Evaluates IEEE-754 `atanh(x)` on `SIMD4<Double>` (`<= 2 ULP`).
    @inlinable
    @inline(__always)
    public static func atanh(_ x: SIMD4<Double>) -> SIMD4<Double> {
        let bits = unsafeBitCast(x, to: SIMD4<UInt64>.self)
        let absBits = bits & 0x7FFF_FFFF_FFFF_FFFF
        // Threshold |x| >= 1.0 (0x3FF0_0000_0000_0000) or NaN -> cold path
        if _slowPath(any(absBits .>= 0x3FF0_0000_0000_0000)) {
            return atanhCold(x)
        }
        let signBit = bits & 0x8000_0000_0000_0000
        let ax = unsafeBitCast(absBits, to: SIMD4<Double>.self)
        let mag = SIMD4<Double>(repeating: 0.5) * log1pFast((ax + ax) / (SIMD4<Double>(repeating: 1.0) - ax))
        return unsafeBitCast(unsafeBitCast(mag, to: SIMD4<UInt64>.self) | signBit, to: SIMD4<Double>.self)
    }

    /// Evaluates IEEE-754 `atanh(x)` on `SIMD8<Double>` (`<= 2 ULP`).
    @inlinable
    @inline(__always)
    public static func atanh(_ x: SIMD8<Double>) -> SIMD8<Double> {
        SIMD8<Double>(lowHalf: atanh(x.lowHalf), highHalf: atanh(x.highHalf))
    }

    // MARK: - Cold Paths (Large Arguments >= 2^28, Domain Boundaries, Inf, NaN)

    @usableFromInline
    @inline(never)
    static func asinhCold(_ x: SIMD4<Double>) -> SIMD4<Double> {
        let bits = unsafeBitCast(x, to: SIMD4<UInt64>.self)
        let signBit = bits & 0x8000_0000_0000_0000
        let ax = unsafeBitCast(bits & 0x7FFF_FFFF_FFFF_FFFF, to: SIMD4<Double>.self)
        let isNaN = x .!= x
        let isInf = ax .== SIMD4<Double>(repeating: .infinity)
        let isHuge = (ax .>= SIMD4<Double>(repeating: 0x1.0p28)) .& .!isInf .& .!isNaN
        let safeSmall = ax.replacing(with: 0.0, where: isNaN .| isInf .| isHuge)

        let one = SIMD4<Double>(repeating: 1.0)
        var mag = asinhModerate(safeSmall)
        if any(isHuge) {
            let safeHuge = ax.replacing(with: one, where: .!isHuge)
            let (lnM, expInt) = mantissaLog(safeHuge)
            let hugeVal = combineNaturalLog(lnM: lnM, expInt: expInt + one)
            mag = mag.replacing(with: hugeVal, where: isHuge)
        }
        mag = mag.replacing(with: SIMD4<Double>(repeating: .infinity), where: isInf)
        let signed = unsafeBitCast(unsafeBitCast(mag, to: SIMD4<UInt64>.self) | signBit, to: SIMD4<Double>.self)
        return signed.replacing(with: x + x, where: isNaN)
    }

    @usableFromInline
    @inline(never)
    static func acoshCold(_ x: SIMD4<Double>) -> SIMD4<Double> {
        let one = SIMD4<Double>(repeating: 1.0)
        let isNaN = x .!= x
        let isDomainErr = x .< one
        let isInf = x .== SIMD4<Double>(repeating: .infinity)
        let isHuge = (x .>= SIMD4<Double>(repeating: 0x1.0p28)) .& .!isInf .& .!isNaN
        let safeMid = x.replacing(with: one, where: isNaN .| isDomainErr .| isInf .| isHuge)

        var result = acoshCore(safeMid)
        if any(isHuge) {
            let safeHuge = x.replacing(with: one, where: .!isHuge)
            let (lnM, expInt) = mantissaLog(safeHuge)
            let hugeVal = combineNaturalLog(lnM: lnM, expInt: expInt + one)
            result = result.replacing(with: hugeVal, where: isHuge)
        }
        result = result.replacing(with: SIMD4<Double>(repeating: .nan), where: isDomainErr)
        result = result.replacing(with: SIMD4<Double>(repeating: .infinity), where: isInf)
        return result.replacing(with: x + x, where: isNaN)
    }

    @usableFromInline
    @inline(never)
    static func atanhCold(_ x: SIMD4<Double>) -> SIMD4<Double> {
        let bits = unsafeBitCast(x, to: SIMD4<UInt64>.self)
        let signBit = bits & 0x8000_0000_0000_0000
        let ax = unsafeBitCast(bits & 0x7FFF_FFFF_FFFF_FFFF, to: SIMD4<Double>.self)
        let one = SIMD4<Double>(repeating: 1.0)
        let isNaN = x .!= x
        let isOne = ax .== one
        let isDomainErr = ax .> one
        let safe = ax.replacing(with: 0.0, where: isNaN .| isOne .| isDomainErr)

        var mag = SIMD4<Double>(repeating: 0.5) * log1pFast((safe + safe) / (one - safe))
        mag = mag.replacing(with: SIMD4<Double>(repeating: .infinity), where: isOne)
        let signed = unsafeBitCast(unsafeBitCast(mag, to: SIMD4<UInt64>.self) | signBit, to: SIMD4<Double>.self)
        return signed.replacing(with: SIMD4<Double>(repeating: .nan), where: isDomainErr)
            .replacing(with: x + x, where: isNaN)
    }
}
