// MARK: - SIMD Inverse Tangent Math: atan, atan2 (<= 1-2 ULP, Pure Swift IEEE-754)

extension SIMDMath {
    // MARK: - Public API: atan, atan2

    /// Evaluates IEEE-754 `atan(x)` on `SIMD2<Double>` (`<= 2 ULP`).
    @inlinable
    @inline(__always)
    public static func atan(_ x: SIMD2<Double>) -> SIMD2<Double> {
        atan(SIMD4<Double>(lowHalf: x, highHalf: x)).lowHalf
    }

    /// Evaluates IEEE-754 `atan(x)` on `SIMD4<Double>` (`<= 2 ULP`).
    @inlinable
    @inline(__always)
    public static func atan(_ x: SIMD4<Double>) -> SIMD4<Double> {
        let bits = unsafeBitCast(x, to: SIMD4<UInt64>.self)
        let signBit = bits & 0x8000_0000_0000_0000
        let a = unsafeBitCast(bits & 0x7FFF_FFFF_FFFF_FFFF, to: SIMD4<Double>.self)

        let isMid = a .> SIMD4<Double>(repeating: 4.14213562373095049e-01)
        let isHigh = a .> SIMD4<Double>(repeating: 2.41421356237309505e+00)

        var num = a.replacing(with: a - SIMD4<Double>(repeating: 1.0), where: isMid)
        var den = SIMD4<Double>(repeating: 1.0).replacing(with: a + SIMD4<Double>(repeating: 1.0), where: isMid)
        num = num.replacing(with: SIMD4<Double>(repeating: -1.0), where: isHigh)
        den = den.replacing(with: a, where: isHigh)

        var offHi = SIMD4<Double>.zero.replacing(with: SIMD4<Double>(repeating: 7.85398163397448279e-01), where: isMid)
        var offLo = SIMD4<Double>.zero.replacing(with: SIMD4<Double>(repeating: 3.06161699786838302e-17), where: isMid)
        offHi = offHi.replacing(with: SIMD4<Double>(repeating: 1.57079632679489656e+00), where: isHigh)
        offLo = offLo.replacing(with: SIMD4<Double>(repeating: 6.12323399573676604e-17), where: isHigh)

        let z = num / den
        let mag = offHi + (atanReducedPoly(z) + offLo)
        return unsafeBitCast(unsafeBitCast(mag, to: SIMD4<UInt64>.self) | signBit, to: SIMD4<Double>.self)
    }

    /// Evaluates IEEE-754 `atan(x)` on `SIMD8<Double>` (`<= 2 ULP`).
    @inlinable
    @inline(__always)
    public static func atan(_ x: SIMD8<Double>) -> SIMD8<Double> {
        SIMD8<Double>(lowHalf: atan(x.lowHalf), highHalf: atan(x.highHalf))
    }

    /// Evaluates IEEE-754 `atan2(y, x)` on `SIMD2<Double>` (`<= 2 ULP`).
    @inlinable
    @inline(__always)
    public static func atan2(_ y: SIMD2<Double>, _ x: SIMD2<Double>) -> SIMD2<Double> {
        atan2(SIMD4<Double>(lowHalf: y, highHalf: y), SIMD4<Double>(lowHalf: x, highHalf: x)).lowHalf
    }

    /// Evaluates IEEE-754 `atan2(y, x)` on `SIMD4<Double>` (`<= 2 ULP`).
    @inlinable
    @inline(__always)
    public static func atan2(_ y: SIMD4<Double>, _ x: SIMD4<Double>) -> SIMD4<Double> {
        let yAbs = unsafeBitCast(y, to: SIMD4<UInt64>.self) & 0x7FFF_FFFF_FFFF_FFFF
        let xAbs = unsafeBitCast(x, to: SIMD4<UInt64>.self) & 0x7FFF_FFFF_FFFF_FFFF
        let minNormal: UInt64 = 0x0010_0000_0000_0000
        let fastSpan: UInt64 = 0x7FC0_0000_0000_0000
        let coldMask = ((yAbs &- minNormal) .>= fastSpan) .| ((xAbs &- minNormal) .>= fastSpan)
        if _slowPath(any(coldMask)) {
            return atan2Cold(y, x)
        }
        return atan2Fast(y, x)
    }

    /// Evaluates IEEE-754 `atan2(y, x)` on `SIMD8<Double>` (`<= 2 ULP`).
    @inlinable
    @inline(__always)
    public static func atan2(_ y: SIMD8<Double>, _ x: SIMD8<Double>) -> SIMD8<Double> {
        SIMD8<Double>(lowHalf: atan2(y.lowHalf, x.lowHalf), highHalf: atan2(y.highHalf, x.highHalf))
    }

    // MARK: - Single-Division Octant Kernel & Estrin Polynomial (|z| <= sqrt(2) - 1)

    @inlinable
    @inline(__always)
    static func atan2Fast(_ y: SIMD4<Double>, _ x: SIMD4<Double>) -> SIMD4<Double> {
        let yBits = unsafeBitCast(y, to: SIMD4<UInt64>.self)
        let xBits = unsafeBitCast(x, to: SIMD4<UInt64>.self)
        let ySign = yBits & 0x8000_0000_0000_0000
        let xNeg = (xBits & 0x8000_0000_0000_0000) .!= 0
        let ay = unsafeBitCast(yBits & 0x7FFF_FFFF_FFFF_FFFF, to: SIMD4<Double>.self)
        let ax = unsafeBitCast(xBits & 0x7FFF_FFFF_FFFF_FFFF, to: SIMD4<Double>.self)

        let swap = ay .> ax
        let hi = ax.replacing(with: ay, where: swap)
        let lo = ay.replacing(with: ax, where: swap)
        let useShift = lo .> hi * SIMD4<Double>(repeating: 4.14213562373095049e-01)

        let num = lo.replacing(with: lo - hi, where: useShift)
        let den = hi.replacing(with: lo + hi, where: useShift)
        let poly = atanReducedPoly(num / den)

        let negPoly = swap .!= xNeg
        let signedPoly = poly.replacing(with: -poly, where: negPoly)

        var offHi = SIMD4<Double>.zero.replacing(with: SIMD4<Double>(repeating: 3.14159265358979312e+00), where: xNeg)
        var offLo = SIMD4<Double>.zero.replacing(with: SIMD4<Double>(repeating: 1.22464679914735321e-16), where: xNeg)
        offHi = offHi.replacing(with: SIMD4<Double>(repeating: 1.57079632679489656e+00), where: swap)
        offLo = offLo.replacing(with: SIMD4<Double>(repeating: 6.12323399573676604e-17), where: swap)

        let shiftHi = SIMD4<Double>(repeating: 7.85398163397448279e-01)
            .replacing(with: SIMD4<Double>(repeating: 2.35619449019234484e+00), where: xNeg)
        let shiftLo = SIMD4<Double>(repeating: 3.06161699786838302e-17)
            .replacing(with: SIMD4<Double>(repeating: 9.18485099360514844e-17), where: xNeg)
        offHi = offHi.replacing(with: shiftHi, where: useShift)
        offLo = offLo.replacing(with: shiftLo, where: useShift)

        let mag = offHi + (signedPoly + offLo)
        return unsafeBitCast(unsafeBitCast(mag, to: SIMD4<UInt64>.self) | ySign, to: SIMD4<Double>.self)
    }

    /// Evaluates `atan(z)` on `|z| <= sqrt(2) - 1` (`< 6e-18` relative error).
    @inlinable
    @inline(__always)
    static func atanReducedPoly(_ z: SIMD4<Double>) -> SIMD4<Double> {
        let t = z * z
        let t2 = t * t
        let t4 = t2 * t2
        let p01 = SIMD4<Double>(repeating: -3.33333333333333315e-01)
            .addingProduct(t, SIMD4<Double>(repeating: 1.99999999999955214e-01))
        let p23 = SIMD4<Double>(repeating: -1.42857142846665425e-01)
            .addingProduct(t, SIMD4<Double>(repeating: 1.11111110152563614e-01))
        let p45 = SIMD4<Double>(repeating: -9.09090457812390118e-02)
            .addingProduct(t, SIMD4<Double>(repeating: 7.69218319082608237e-02))
        let p67 = SIMD4<Double>(repeating: -6.66451144738189477e-02)
            .addingProduct(t, SIMD4<Double>(repeating: 5.85814891280174305e-02))
        let p810 = SIMD4<Double>(repeating: -5.08544973793781802e-02)
            .addingProduct(t, SIMD4<Double>(repeating: 3.92316582955166346e-02))
            .addingProduct(t2, SIMD4<Double>(repeating: -1.91768871189758536e-02))
        let q = p01.addingProduct(t2, p23).addingProduct(t4, p45.addingProduct(t2, p67).addingProduct(t4, p810))
        return z.addingProduct(z * t, q)
    }

    // MARK: - Cold Path (Zero, Infinity, NaN, and Near-Overflow Scaling)

    @usableFromInline
    @inline(never)
    static func atan2Cold(_ y: SIMD4<Double>, _ x: SIMD4<Double>) -> SIMD4<Double> {
        let yAbs = unsafeBitCast(y, to: SIMD4<UInt64>.self) & 0x7FFF_FFFF_FFFF_FFFF
        let xAbs = unsafeBitCast(x, to: SIMD4<UInt64>.self) & 0x7FFF_FFFF_FFFF_FFFF
        let minNormal: UInt64 = 0x0010_0000_0000_0000
        let fastSpan: UInt64 = 0x7FC0_0000_0000_0000
        let isFast = ((yAbs &- minNormal) .< fastSpan) .& ((xAbs &- minNormal) .< fastSpan)
        let safeY = y.replacing(with: SIMD4<Double>(repeating: 1.0), where: .!isFast)
        let safeX = x.replacing(with: SIMD4<Double>(repeating: 1.0), where: .!isFast)
        var out = atan2Fast(safeY, safeX)

        for lane in 0..<4 where !isFast[lane] {
            out[lane] = atan2ColdScalar(y[lane], x[lane])
        }
        return out
    }

    private static func atan2ColdScalar(_ y: Double, _ x: Double) -> Double {
        if y.isNaN || x.isNaN {
            return y + x
        }
        let ySign = y.bitPattern & 0x8000_0000_0000_0000
        let xNeg = (x.bitPattern & 0x8000_0000_0000_0000) != 0
        if y == 0.0 {
            return Double(bitPattern: (xNeg ? Double.pi.bitPattern : 0) | ySign)
        }
        if x == 0.0 {
            return Double(bitPattern: (Double.pi * 0.5).bitPattern | ySign)
        }
        if y.isInfinite {
            if x.isInfinite {
                let mag = xNeg ? (3.0 * Double.pi * 0.25) : (Double.pi * 0.25)
                return Double(bitPattern: mag.bitPattern | ySign)
            }
            return Double(bitPattern: (Double.pi * 0.5).bitPattern | ySign)
        }
        if x.isInfinite {
            return Double(bitPattern: (xNeg ? Double.pi.bitPattern : 0) | ySign)
        }
        let maxMag = Swift.max(Swift.abs(y), Swift.abs(x))
        let scale = maxMag < 0x1.0p-512 ? 0x1.0p512 : (maxMag >= 0x1.0p512 ? 0x1.0p-512 : 1.0)
        return atan2Fast(SIMD4<Double>(repeating: y * scale), SIMD4<Double>(repeating: x * scale))[0]
    }
}
