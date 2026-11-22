// MARK: - SIMD Hyperbolic Math: sinh, cosh, tanh (<= 2 ULP, Pure Swift IEEE-754)

extension SIMDMath {
    // MARK: - Public API: sinh, cosh, tanh

    /// Evaluates IEEE-754 `sinh(x)` on `SIMD2<Double>` (`<= 2 ULP`).
    @inlinable
    @inline(__always)
    public static func sinh(_ x: SIMD2<Double>) -> SIMD2<Double> {
        sinh(SIMD4<Double>(lowHalf: x, highHalf: x)).lowHalf
    }

    /// Evaluates IEEE-754 `sinh(x)` on `SIMD4<Double>` (`<= 2 ULP`).
    @inlinable
    @inline(__always)
    public static func sinh(_ x: SIMD4<Double>) -> SIMD4<Double> {
        let bits = unsafeBitCast(x, to: SIMD4<UInt64>.self)
        let absBits = bits & 0x7FFF_FFFF_FFFF_FFFF
        if _slowPath(any(absBits .>= 0x4086_2000_0000_0000)) {
            return sinhCold(x)
        }
        let signBit = bits & 0x8000_0000_0000_0000
        let ax = unsafeBitCast(absBits, to: SIMD4<Double>.self)
        let mag = sinhPositiveFast(ax, absBits: absBits)
        return unsafeBitCast(unsafeBitCast(mag, to: SIMD4<UInt64>.self) | signBit, to: SIMD4<Double>.self)
    }

    /// Evaluates IEEE-754 `sinh(x)` on `SIMD8<Double>` (`<= 2 ULP`).
    @inlinable
    @inline(__always)
    public static func sinh(_ x: SIMD8<Double>) -> SIMD8<Double> {
        SIMD8<Double>(lowHalf: sinh(x.lowHalf), highHalf: sinh(x.highHalf))
    }

    /// Evaluates IEEE-754 `cosh(x)` on `SIMD2<Double>` (`<= 2 ULP`).
    @inlinable
    @inline(__always)
    public static func cosh(_ x: SIMD2<Double>) -> SIMD2<Double> {
        cosh(SIMD4<Double>(lowHalf: x, highHalf: x)).lowHalf
    }

    /// Evaluates IEEE-754 `cosh(x)` on `SIMD4<Double>` (`<= 2 ULP`).
    @inlinable
    @inline(__always)
    public static func cosh(_ x: SIMD4<Double>) -> SIMD4<Double> {
        let absBits = unsafeBitCast(x, to: SIMD4<UInt64>.self) & 0x7FFF_FFFF_FFFF_FFFF
        if _slowPath(any(absBits .>= 0x4086_2000_0000_0000)) {
            return coshCold(x)
        }
        let ax = unsafeBitCast(absBits, to: SIMD4<Double>.self)
        let e = expFast(ax)
        return SIMD4<Double>(repeating: 0.5) * (e + SIMD4<Double>(repeating: 1.0) / e)
    }

    /// Evaluates IEEE-754 `cosh(x)` on `SIMD8<Double>` (`<= 2 ULP`).
    @inlinable
    @inline(__always)
    public static func cosh(_ x: SIMD8<Double>) -> SIMD8<Double> {
        SIMD8<Double>(lowHalf: cosh(x.lowHalf), highHalf: cosh(x.highHalf))
    }

    /// Evaluates IEEE-754 `tanh(x)` on `SIMD2<Double>` (`<= 2 ULP`).
    @inlinable
    @inline(__always)
    public static func tanh(_ x: SIMD2<Double>) -> SIMD2<Double> {
        tanh(SIMD4<Double>(lowHalf: x, highHalf: x)).lowHalf
    }

    /// Evaluates IEEE-754 `tanh(x)` on `SIMD4<Double>` (`<= 2 ULP`).
    @inlinable
    @inline(__always)
    public static func tanh(_ x: SIMD4<Double>) -> SIMD4<Double> {
        let bits = unsafeBitCast(x, to: SIMD4<UInt64>.self)
        let absBits = bits & 0x7FFF_FFFF_FFFF_FFFF
        if _slowPath(any(absBits .>= 0x4076_0000_0000_0000)) {
            return tanhCold(x)
        }
        let signBit = bits & 0x8000_0000_0000_0000
        let ax = unsafeBitCast(absBits, to: SIMD4<Double>.self)
        let mag = tanhPositiveFast(ax, absBits: absBits)
        return unsafeBitCast(unsafeBitCast(mag, to: SIMD4<UInt64>.self) | signBit, to: SIMD4<Double>.self)
    }

    /// Evaluates IEEE-754 `tanh(x)` on `SIMD8<Double>` (`<= 2 ULP`).
    @inlinable
    @inline(__always)
    public static func tanh(_ x: SIMD8<Double>) -> SIMD8<Double> {
        SIMD8<Double>(lowHalf: tanh(x.lowHalf), highHalf: tanh(x.highHalf))
    }

    // MARK: - Fast Positive Kernels

    @inlinable
    @inline(__always)
    static func sinhPositiveFast(_ ax: SIMD4<Double>, absBits: SIMD4<UInt64>) -> SIMD4<Double> {
        let e = expFast(ax)
        var mag = SIMD4<Double>(repeating: 0.5) * (e - SIMD4<Double>(repeating: 1.0) / e)
        // Switch below 0.8828125 (sinh(0.8828125) > 1.0) so 0.5*(e - 1/e) never amplifies expFast ULP into a smaller binade.
        let isSmall = absBits .< 0x3FEC_4000_0000_0000
        if any(isSmall) {
            let t = ax * ax
            let t2 = t * t
            let t4 = t2 * t2
            let p01 = SIMD4<Double>(repeating: 1.66666666666666657e-01)
                .addingProduct(t, SIMD4<Double>(repeating: 8.33333333333333322e-03))
            let p23 = SIMD4<Double>(repeating: 1.98412698412698413e-04)
                .addingProduct(t, SIMD4<Double>(repeating: 2.75573192239858925e-06))
            let p45 = SIMD4<Double>(repeating: 2.50521083854417202e-08)
                .addingProduct(t, SIMD4<Double>(repeating: 1.60590438368216133e-10))
            let p67 = SIMD4<Double>(repeating: 7.64716373181981641e-13)
                .addingProduct(t, SIMD4<Double>(repeating: 2.81145725434552060e-15))
            let q = p01.addingProduct(t2, p23).addingProduct(t4, p45.addingProduct(t2, p67))
            mag = mag.replacing(with: ax.addingProduct(ax * t, q), where: isSmall)
        }
        return mag
    }

    @inlinable
    @inline(__always)
    static func tanhPositiveFast(_ ax: SIMD4<Double>, absBits: SIMD4<UInt64>) -> SIMD4<Double> {
        let e2 = expFast(ax + ax)
        var mag = SIMD4<Double>(repeating: 1.0) - SIMD4<Double>(repeating: 2.0) / (e2 + SIMD4<Double>(repeating: 1.0))
        // Switch below 0.5625 (tanh(0.5625) > 0.5) so 1 - 2/(e2 + 1) never loses a cancellation bit and stays monotonic.
        let isSmall = absBits .< 0x3FE2_0000_0000_0000
        if any(isSmall) {
            let t = ax * ax
            let t2 = t * t
            let t4 = t2 * t2
            let p01 = SIMD4<Double>(repeating: -3.33333333333333315e-01)
                .addingProduct(t, SIMD4<Double>(repeating: 1.33333333333332998e-01))
            let p23 = SIMD4<Double>(repeating: -5.39682539682039483e-02)
                .addingProduct(t, SIMD4<Double>(repeating: 2.18694885331814498e-02))
            let p45 = SIMD4<Double>(repeating: -8.86323543840872655e-03)
                .addingProduct(t, SIMD4<Double>(repeating: 3.59212637177144887e-03))
            let p67 = SIMD4<Double>(repeating: -1.45581511742611100e-03)
                .addingProduct(t, SIMD4<Double>(repeating: 5.89879842727136956e-04))
            let p89 = SIMD4<Double>(repeating: -2.38368466591282652e-04)
                .addingProduct(t, SIMD4<Double>(repeating: 9.42869008666269811e-05))
            let p1011 = SIMD4<Double>(repeating: -3.33427281963895338e-05)
                .addingProduct(t, SIMD4<Double>(repeating: 7.64136237747253556e-06))
            let q = p01.addingProduct(t2, p23)
                .addingProduct(t4, p45.addingProduct(t2, p67).addingProduct(t4, p89.addingProduct(t2, p1011)))
            mag = mag.replacing(with: ax.addingProduct(ax * t, q), where: isSmall)
        }
        return mag
    }

    // MARK: - Cold Paths

    @usableFromInline
    @inline(never)
    static func sinhCold(_ x: SIMD4<Double>) -> SIMD4<Double> {
        let bits = unsafeBitCast(x, to: SIMD4<UInt64>.self)
        let signBit = bits & 0x8000_0000_0000_0000
        let ax = unsafeBitCast(bits & 0x7FFF_FFFF_FFFF_FFFF, to: SIMD4<Double>.self)
        let isNaN = x .!= x
        let isOverflow = ax .> SIMD4<Double>(repeating: 711.0)
        let isLarge = (ax .>= SIMD4<Double>(repeating: 708.0)) .& .!isOverflow .& .!isNaN
        let safeSmall = ax.replacing(with: 0.0, where: isNaN .| isOverflow .| isLarge)

        var mag = sinhPositiveFast(safeSmall, absBits: unsafeBitCast(safeSmall, to: SIMD4<UInt64>.self))
        if any(isLarge) {
            let safeLarge = ax.replacing(with: SIMD4<Double>(repeating: 708.0), where: .!isLarge)
            mag = mag.replacing(with: halfExpLarge(safeLarge), where: isLarge)
        }
        mag = mag.replacing(with: SIMD4<Double>(repeating: .infinity), where: isOverflow)
        let signed = unsafeBitCast(unsafeBitCast(mag, to: SIMD4<UInt64>.self) | signBit, to: SIMD4<Double>.self)
        return signed.replacing(with: x + x, where: isNaN)
    }

    @usableFromInline
    @inline(never)
    static func coshCold(_ x: SIMD4<Double>) -> SIMD4<Double> {
        let bits = unsafeBitCast(x, to: SIMD4<UInt64>.self)
        let ax = unsafeBitCast(bits & 0x7FFF_FFFF_FFFF_FFFF, to: SIMD4<Double>.self)
        let isNaN = x .!= x
        let isOverflow = ax .> SIMD4<Double>(repeating: 711.0)
        let isLarge = (ax .>= SIMD4<Double>(repeating: 708.0)) .& .!isOverflow .& .!isNaN
        let safeSmall = ax.replacing(with: 0.0, where: isNaN .| isOverflow .| isLarge)

        let e = expFast(safeSmall)
        var mag = SIMD4<Double>(repeating: 0.5) * (e + SIMD4<Double>(repeating: 1.0) / e)
        if any(isLarge) {
            let safeLarge = ax.replacing(with: SIMD4<Double>(repeating: 708.0), where: .!isLarge)
            mag = mag.replacing(with: halfExpLarge(safeLarge), where: isLarge)
        }
        mag = mag.replacing(with: SIMD4<Double>(repeating: .infinity), where: isOverflow)
        return mag.replacing(with: x + x, where: isNaN)
    }

    @usableFromInline
    @inline(never)
    static func tanhCold(_ x: SIMD4<Double>) -> SIMD4<Double> {
        let bits = unsafeBitCast(x, to: SIMD4<UInt64>.self)
        let signBit = bits & 0x8000_0000_0000_0000
        let ax = unsafeBitCast(bits & 0x7FFF_FFFF_FFFF_FFFF, to: SIMD4<Double>.self)
        let isNaN = x .!= x
        let isSaturated = ax .>= SIMD4<Double>(repeating: 20.0)
        let safe = ax.replacing(with: 0.0, where: isNaN .| isSaturated)
        var mag = tanhPositiveFast(safe, absBits: unsafeBitCast(safe, to: SIMD4<UInt64>.self))
        mag = mag.replacing(with: SIMD4<Double>(repeating: 1.0), where: isSaturated)
        let signed = unsafeBitCast(unsafeBitCast(mag, to: SIMD4<UInt64>.self) | signBit, to: SIMD4<Double>.self)
        return signed.replacing(with: x + x, where: isNaN)
    }

    /// Computes `0.5 * exp(a)` accurately for `a in [708, 711]` without intermediate overflow.
    @inline(__always)
    private static func halfExpLarge(_ a: SIMD4<Double>) -> SIMD4<Double> {
        let invLn2 = SIMD4<Double>(repeating: 1.4426950408889634)
        let ln2Hi = SIMD4<Double>(repeating: 6.93147180559945286e-01)
        let ln2Lo = SIMD4<Double>(repeating: 2.31904681384629956e-17)
        let k = (a * invLn2).rounded(.toNearestOrAwayFromZero)
        let r = a.addingProduct(-k, ln2Hi).addingProduct(-k, ln2Lo)
        return splitScalePow2(expPoly(r), k: k - SIMD4<Double>(repeating: 1.0))
    }
}
