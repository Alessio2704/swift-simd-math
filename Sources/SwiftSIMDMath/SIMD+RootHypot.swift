// MARK: - SIMD Cube Root & Overflow-Safe Hypotenuse: cbrt, hypot (<= 1 ULP, Pure Swift IEEE-754)

extension SIMDMath {
    // MARK: - Public API: cbrt, hypot

    /// Evaluates IEEE-754 `cbrt(x)` on `SIMD2<Double>` (`<= 1 ULP`).
    @inlinable
    @inline(__always)
    public static func cbrt(_ x: SIMD2<Double>) -> SIMD2<Double> {
        cbrt(SIMD4<Double>(lowHalf: x, highHalf: x)).lowHalf
    }

    /// Evaluates IEEE-754 `cbrt(x)` on `SIMD4<Double>` (`<= 1 ULP`).
    @inlinable
    @inline(__always)
    public static func cbrt(_ x: SIMD4<Double>) -> SIMD4<Double> {
        let bits = unsafeBitCast(x, to: SIMD4<UInt64>.self)
        let absBits = bits & 0x7FFF_FFFF_FFFF_FFFF
        if _slowPath(any((absBits &- 0x0010_0000_0000_0000) .>= 0x7FE0_0000_0000_0000)) {
            return cbrtCold(x)
        }
        return cbrtFast(bits: bits, absBits: absBits)
    }

    /// Evaluates IEEE-754 `cbrt(x)` on `SIMD8<Double>` (`<= 1 ULP`).
    @inlinable
    @inline(__always)
    public static func cbrt(_ x: SIMD8<Double>) -> SIMD8<Double> {
        SIMD8<Double>(lowHalf: cbrt(x.lowHalf), highHalf: cbrt(x.highHalf))
    }

    /// Evaluates overflow/underflow-safe IEEE-754 `hypot(x, y)` on `SIMD2<Double>` (`<= 1 ULP`).
    @inlinable
    @inline(__always)
    public static func hypot(_ x: SIMD2<Double>, _ y: SIMD2<Double>) -> SIMD2<Double> {
        hypot(SIMD4<Double>(lowHalf: x, highHalf: x), SIMD4<Double>(lowHalf: y, highHalf: y)).lowHalf
    }

    /// Evaluates overflow/underflow-safe IEEE-754 `hypot(x, y)` on `SIMD4<Double>` (`<= 1 ULP`).
    @inlinable
    @inline(__always)
    public static func hypot(_ x: SIMD4<Double>, _ y: SIMD4<Double>) -> SIMD4<Double> {
        let axBits = unsafeBitCast(x, to: SIMD4<UInt64>.self) & 0x7FFF_FFFF_FFFF_FFFF
        let ayBits = unsafeBitCast(y, to: SIMD4<UInt64>.self) & 0x7FFF_FFFF_FFFF_FFFF
        let swap = ayBits .> axBits
        let maxBits = axBits.replacing(with: ayBits, where: swap)
        if _slowPath(any((maxBits &- 0x23D0_0000_0000_0000) .>= 0x3B60_0000_0000_0000)) {
            return hypotCold(x, y)
        }
        let minBits = ayBits.replacing(with: axBits, where: swap)
        let hi = unsafeBitCast(maxBits, to: SIMD4<Double>.self)
        let lo = unsafeBitCast(minBits, to: SIMD4<Double>.self)
        return (hi * hi).addingProduct(lo, lo).squareRoot()
    }

    /// Evaluates overflow/underflow-safe IEEE-754 `hypot(x, y)` on `SIMD8<Double>` (`<= 1 ULP`).
    @inlinable
    @inline(__always)
    public static func hypot(_ x: SIMD8<Double>, _ y: SIMD8<Double>) -> SIMD8<Double> {
        SIMD8<Double>(lowHalf: hypot(x.lowHalf, y.lowHalf), highHalf: hypot(x.highHalf, y.highHalf))
    }

    // MARK: - Fast cbrt Kernel (Deg-6 Estrin Initial Guess + 1 Residual Halley Iteration)

    @inlinable
    @inline(__always)
    static func cbrtFast(bits: SIMD4<UInt64>, absBits: SIMD4<UInt64>) -> SIMD4<Double> {
        let signBit = bits & 0x8000_0000_0000_0000
        let expBiased = absBits &>> 52
        // Exact integer division by 3 for all normal biased exponents [1, 2046] (1023 = 3 * 341).
        let q = (expBiased &* 21_846) &>> 16
        let rem = expBiased &- (q &* 3)

        let mBits = (absBits & 0x000F_FFFF_FFFF_FFFF) | 0x3FF0_0000_0000_0000
        let m = unsafeBitCast(mBits, to: SIMD4<Double>.self)
        let m2 = m * m
        let m4 = m2 * m2

        let p01 = SIMD4<Double>(repeating: 4.48642630804157450e-01)
            .addingProduct(m, SIMD4<Double>(repeating: 9.43733811755257501e-01))
        let p23 = SIMD4<Double>(repeating: -6.55068561722187970e-01)
            .addingProduct(m, SIMD4<Double>(repeating: 3.75147530142035612e-01))
        let p46 = SIMD4<Double>(repeating: -1.39248531710316176e-01)
            .addingProduct(m, SIMD4<Double>(repeating: 2.94967042519149458e-02))
            .addingProduct(m2, SIMD4<Double>(repeating: -2.70333387041206104e-03))
        let poly = p01.addingProduct(m2, p23).addingProduct(m4, p46)

        let isRem1 = rem .== 1
        let isRem2 = rem .== 2
        let uScale = SIMD4<Double>(repeating: 1.0)
            .replacing(with: SIMD4<Double>(repeating: 2.0), where: isRem1)
            .replacing(with: SIMD4<Double>(repeating: 4.0), where: isRem2)
        let yScale = SIMD4<Double>(repeating: 1.0)
            .replacing(with: SIMD4<Double>(repeating: 1.25992104989487319e+00), where: isRem1)
            .replacing(with: SIMD4<Double>(repeating: 1.58740105196819958e+00), where: isRem2)

        let u = m * uScale
        let y = poly * yScale
        let y2 = y * y
        let y2Err = (-y2).addingProduct(y, y)
        let y3 = y * y2
        let residual = u.addingProduct(-y, y2).addingProduct(-y, y2Err)
        let refined = y.addingProduct(y, residual / u.addingProduct(SIMD4<Double>(repeating: 2.0), y3))

        let pow2 = unsafeBitCast((q &+ 682) &<< 52, to: SIMD4<Double>.self)
        let mag = refined * pow2
        return unsafeBitCast(unsafeBitCast(mag, to: SIMD4<UInt64>.self) | signBit, to: SIMD4<Double>.self)
    }

    // MARK: - Cold Paths (Subnormals, Zero, +/-Infinity, NaN, Extreme Exponents)

    @usableFromInline
    @inline(never)
    static func cbrtCold(_ x: SIMD4<Double>) -> SIMD4<Double> {
        let bits = unsafeBitCast(x, to: SIMD4<UInt64>.self)
        let absBits = bits & 0x7FFF_FFFF_FFFF_FFFF
        let isSpecial = (absBits .== 0) .| (absBits .>= 0x7FF0_0000_0000_0000)
        let isSubnormal = (absBits .< 0x0010_0000_0000_0000) .& .!isSpecial

        let scaled = x.replacing(with: x * SIMD4<Double>(repeating: 0x1.0p60), where: isSubnormal)
        let safe = scaled.replacing(with: SIMD4<Double>(repeating: 1.0), where: isSpecial)
        let safeBits = unsafeBitCast(safe, to: SIMD4<UInt64>.self)
        var out = cbrtFast(bits: safeBits, absBits: safeBits & 0x7FFF_FFFF_FFFF_FFFF)
        out = out.replacing(with: out * SIMD4<Double>(repeating: 0x1.0p-20), where: isSubnormal)
        return out.replacing(with: x + x, where: isSpecial)
    }

    @usableFromInline
    @inline(never)
    static func hypotCold(_ x: SIMD4<Double>, _ y: SIMD4<Double>) -> SIMD4<Double> {
        var out = SIMD4<Double>.zero
        for lane in 0..<4 {
            let a = x[lane]
            let b = y[lane]
            // IEEE-754-2019: sNaN quiets first, then +/-inf dominates qNaN.
            if a.isSignalingNaN || b.isSignalingNaN {
                out[lane] = a + b
            } else if a.isInfinite || b.isInfinite {
                out[lane] = .infinity
            } else if a.isNaN || b.isNaN {
                out[lane] = a + b
            } else {
                let ax = Swift.abs(a)
                let ay = Swift.abs(b)
                let hi = Swift.max(ax, ay)
                let lo = Swift.min(ax, ay)
                if hi == 0.0 {
                    out[lane] = 0.0
                } else if hi >= 0x1.0p500 {
                    let hs = hi * 0x1.0p-600
                    let ls = lo * 0x1.0p-600
                    out[lane] = (hs * hs).addingProduct(ls, ls).squareRoot() * 0x1.0p600
                } else if hi < 0x1.0p-450 {
                    let hs = hi * 0x1.0p600
                    let ls = lo * 0x1.0p600
                    out[lane] = (hs * hs).addingProduct(ls, ls).squareRoot() * 0x1.0p-600
                } else {
                    out[lane] = (hi * hi).addingProduct(lo, lo).squareRoot()
                }
            }
        }
        return out
    }
}
