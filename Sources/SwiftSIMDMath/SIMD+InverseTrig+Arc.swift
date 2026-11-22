// MARK: - SIMD Inverse Sine & Cosine Math: asin, acos (<= 2 ULP, Pure Swift IEEE-754)

extension SIMDMath {
    // MARK: - Public API: asin, acos

    /// Evaluates IEEE-754 `asin(x)` on `SIMD2<Double>` (`<= 2 ULP`).
    @inlinable
    @inline(__always)
    public static func asin(_ x: SIMD2<Double>) -> SIMD2<Double> {
        asin(SIMD4<Double>(lowHalf: x, highHalf: x)).lowHalf
    }

    /// Evaluates IEEE-754 `asin(x)` on `SIMD4<Double>` (`<= 2 ULP`).
    @inlinable
    @inline(__always)
    public static func asin(_ x: SIMD4<Double>) -> SIMD4<Double> {
        let bits = unsafeBitCast(x, to: SIMD4<UInt64>.self)
        let signBit = bits & 0x8000_0000_0000_0000
        let a = unsafeBitCast(bits & 0x7FFF_FFFF_FFFF_FFFF, to: SIMD4<Double>.self)

        let isHigh = a .> SIMD4<Double>(repeating: 0.5)
        let t = (a * a).replacing(
            with: SIMD4<Double>(repeating: 0.5) * (SIMD4<Double>(repeating: 1.0) - a), where: isHigh)
        let q = asinPoly(t)
        let s = t.squareRoot()
        let u = a.replacing(with: s, where: isHigh)
        let tail = u * t * q

        let lowVal = u + tail
        let twoS = s + s
        let twoTail = tail + tail
        let highVal =
            (SIMD4<Double>(repeating: 1.57079632679489656e+00) - twoS)
            + (SIMD4<Double>(repeating: 6.12323399573676604e-17) - twoTail)
        let mag = lowVal.replacing(with: highVal, where: isHigh)
        return unsafeBitCast(unsafeBitCast(mag, to: SIMD4<UInt64>.self) | signBit, to: SIMD4<Double>.self)
    }

    /// Evaluates IEEE-754 `asin(x)` on `SIMD8<Double>` (`<= 2 ULP`).
    @inlinable
    @inline(__always)
    public static func asin(_ x: SIMD8<Double>) -> SIMD8<Double> {
        SIMD8<Double>(lowHalf: asin(x.lowHalf), highHalf: asin(x.highHalf))
    }

    /// Evaluates IEEE-754 `acos(x)` on `SIMD2<Double>` (`<= 2 ULP`).
    @inlinable
    @inline(__always)
    public static func acos(_ x: SIMD2<Double>) -> SIMD2<Double> {
        acos(SIMD4<Double>(lowHalf: x, highHalf: x)).lowHalf
    }

    /// Evaluates IEEE-754 `acos(x)` on `SIMD4<Double>` (`<= 2 ULP`).
    @inlinable
    @inline(__always)
    public static func acos(_ x: SIMD4<Double>) -> SIMD4<Double> {
        let bits = unsafeBitCast(x, to: SIMD4<UInt64>.self)
        let a = unsafeBitCast(bits & 0x7FFF_FFFF_FFFF_FFFF, to: SIMD4<Double>.self)

        let isHigh = a .> SIMD4<Double>(repeating: 0.5)
        let isNeg = x .< SIMD4<Double>.zero
        let t = (a * a).replacing(
            with: SIMD4<Double>(repeating: 0.5) * (SIMD4<Double>(repeating: 1.0) - a), where: isHigh)
        let q = asinPoly(t)
        let s = t.squareRoot()

        let halfPiHi = SIMD4<Double>(repeating: 1.57079632679489656e+00)
        let halfPiLo = SIMD4<Double>(repeating: 6.12323399573676604e-17)
        let lowVal = (halfPiHi - x) + (halfPiLo - x * t * q)

        let twoS = s + s
        let twoTail = (s + s) * t * q
        let highPos = twoS + twoTail
        let highNeg =
            (SIMD4<Double>(repeating: 3.14159265358979312e+00) - twoS)
            + (SIMD4<Double>(repeating: 1.22464679914735321e-16) - twoTail)
        let highVal = highPos.replacing(with: highNeg, where: isNeg)
        return lowVal.replacing(with: highVal, where: isHigh)
    }

    /// Evaluates IEEE-754 `acos(x)` on `SIMD8<Double>` (`<= 2 ULP`).
    @inlinable
    @inline(__always)
    public static func acos(_ x: SIMD8<Double>) -> SIMD8<Double> {
        SIMD8<Double>(lowHalf: acos(x.lowHalf), highHalf: acos(x.highHalf))
    }

    // MARK: - Shared Degree-12 Estrin Polynomial for (asin(u) - u) / u^3 on t = u^2 in [0, 0.25]

    @inlinable
    @inline(__always)
    static func asinPoly(_ t: SIMD4<Double>) -> SIMD4<Double> {
        let t2 = t * t
        let t4 = t2 * t2
        let p01 = SIMD4<Double>(repeating: 1.66666666666666685e-01)
            .addingProduct(t, SIMD4<Double>(repeating: 7.49999999999843292e-02))
        let p23 = SIMD4<Double>(repeating: 4.46428571463554288e-02)
            .addingProduct(t, SIMD4<Double>(repeating: 3.03819441385312465e-02))
        let p45 = SIMD4<Double>(repeating: 2.23721729421498886e-02)
            .addingProduct(t, SIMD4<Double>(repeating: 1.73523927208699726e-02))
        let p67 = SIMD4<Double>(repeating: 1.39712129735529329e-02)
            .addingProduct(t, SIMD4<Double>(repeating: 1.14791774151849057e-02))
        let p89 = SIMD4<Double>(repeating: 1.03228143501857793e-02)
            .addingProduct(t, SIMD4<Double>(repeating: 5.45750671864035815e-03))
        let p1012 = SIMD4<Double>(repeating: 1.74008794426940214e-02)
            .addingProduct(t, SIMD4<Double>(repeating: -1.48518870712472037e-02))
            .addingProduct(t2, SIMD4<Double>(repeating: 2.87578513674215663e-02))
        let lo = p01.addingProduct(t2, p23)
        let mid = p45.addingProduct(t2, p67)
        let hi = p89.addingProduct(t2, p1012)
        return lo.addingProduct(t4, mid.addingProduct(t4, hi))
    }
}
