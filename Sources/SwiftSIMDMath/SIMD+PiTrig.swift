// MARK: - SIMD Pi-Scaled Trigonometric Math: sinpi, cospi, tanpi, sincospi (<= 2 ULP)

extension SIMDMath {
    // MARK: - Public API: sinpi, cospi, tanpi, sincospi

    /// Evaluates IEEE-754 `sin(pi * x)` on `SIMD2<Double>` (`<= 2 ULP`).
    @inlinable
    @inline(__always)
    public static func sinpi(_ x: SIMD2<Double>) -> SIMD2<Double> {
        sinpi(SIMD4<Double>(lowHalf: x, highHalf: x)).lowHalf
    }

    /// Evaluates IEEE-754 `sin(pi * x)` on `SIMD4<Double>` (`<= 2 ULP`).
    @inlinable
    @inline(__always)
    public static func sinpi(_ x: SIMD4<Double>) -> SIMD4<Double> {
        let absBits = unsafeBitCast(x, to: SIMD4<UInt64>.self) & 0x7FFF_FFFF_FFFF_FFFF
        if _slowPath(any(absBits .>= 0x4320_0000_0000_0000)) {
            return sinpiCold(x)
        }
        return sinpiFast(x)
    }

    /// Evaluates IEEE-754 `sin(pi * x)` on `SIMD8<Double>` (`<= 2 ULP`).
    @inlinable
    @inline(__always)
    public static func sinpi(_ x: SIMD8<Double>) -> SIMD8<Double> {
        SIMD8<Double>(lowHalf: sinpi(x.lowHalf), highHalf: sinpi(x.highHalf))
    }

    /// Evaluates IEEE-754 `cos(pi * x)` on `SIMD2<Double>` (`<= 2 ULP`).
    @inlinable
    @inline(__always)
    public static func cospi(_ x: SIMD2<Double>) -> SIMD2<Double> {
        cospi(SIMD4<Double>(lowHalf: x, highHalf: x)).lowHalf
    }

    /// Evaluates IEEE-754 `cos(pi * x)` on `SIMD4<Double>` (`<= 2 ULP`).
    @inlinable
    @inline(__always)
    public static func cospi(_ x: SIMD4<Double>) -> SIMD4<Double> {
        let absBits = unsafeBitCast(x, to: SIMD4<UInt64>.self) & 0x7FFF_FFFF_FFFF_FFFF
        if _slowPath(any(absBits .>= 0x4320_0000_0000_0000)) {
            return cospiCold(x)
        }
        return cospiFast(x)
    }

    /// Evaluates IEEE-754 `cos(pi * x)` on `SIMD8<Double>` (`<= 2 ULP`).
    @inlinable
    @inline(__always)
    public static func cospi(_ x: SIMD8<Double>) -> SIMD8<Double> {
        SIMD8<Double>(lowHalf: cospi(x.lowHalf), highHalf: cospi(x.highHalf))
    }

    /// Evaluates IEEE-754 `tan(pi * x)` on `SIMD2<Double>` (`<= 2 ULP`).
    @inlinable
    @inline(__always)
    public static func tanpi(_ x: SIMD2<Double>) -> SIMD2<Double> {
        tanpi(SIMD4<Double>(lowHalf: x, highHalf: x)).lowHalf
    }

    /// Evaluates IEEE-754 `tan(pi * x)` on `SIMD4<Double>` (`<= 2 ULP`).
    @inlinable
    @inline(__always)
    public static func tanpi(_ x: SIMD4<Double>) -> SIMD4<Double> {
        let absBits = unsafeBitCast(x, to: SIMD4<UInt64>.self) & 0x7FFF_FFFF_FFFF_FFFF
        if _slowPath(any(absBits .>= 0x4310_0000_0000_0000)) {
            return tanpiCold(x)
        }
        return tanpiFast(x)
    }

    /// Evaluates IEEE-754 `tan(pi * x)` on `SIMD8<Double>` (`<= 2 ULP`).
    @inlinable
    @inline(__always)
    public static func tanpi(_ x: SIMD8<Double>) -> SIMD8<Double> {
        SIMD8<Double>(lowHalf: tanpi(x.lowHalf), highHalf: tanpi(x.highHalf))
    }

    /// Evaluates IEEE-754 simultaneous `sin(pi * x), cos(pi * x)` on `SIMD2<Double>` (`<= 2 ULP`).
    @inlinable
    @inline(__always)
    public static func sincospi(_ x: SIMD2<Double>) -> (sin: SIMD2<Double>, cos: SIMD2<Double>) {
        let (s, c) = sincospi(SIMD4<Double>(lowHalf: x, highHalf: x))
        return (s.lowHalf, c.lowHalf)
    }

    /// Evaluates IEEE-754 simultaneous `sin(pi * x), cos(pi * x)` on `SIMD4<Double>` (`<= 2 ULP`).
    @inlinable
    @inline(__always)
    public static func sincospi(_ x: SIMD4<Double>) -> (sin: SIMD4<Double>, cos: SIMD4<Double>) {
        let absBits = unsafeBitCast(x, to: SIMD4<UInt64>.self) & 0x7FFF_FFFF_FFFF_FFFF
        if _slowPath(any(absBits .>= 0x4310_0000_0000_0000)) {
            return sincospiCold(x)
        }
        return sincospiFast(x)
    }

    /// Evaluates IEEE-754 simultaneous `sin(pi * x), cos(pi * x)` on `SIMD8<Double>` (`<= 2 ULP`).
    @inlinable
    @inline(__always)
    public static func sincospi(_ x: SIMD8<Double>) -> (sin: SIMD8<Double>, cos: SIMD8<Double>) {
        let (s0, c0) = sincospi(x.lowHalf)
        let (s1, c1) = sincospi(x.highHalf)
        return (SIMD8<Double>(lowHalf: s0, highHalf: s1), SIMD8<Double>(lowHalf: c0, highHalf: c1))
    }

    // MARK: - Single-Polynomial sinpi / cospi Kernels (|x| < 2^51)

    /// Evaluates `sin(pi * f)` for `f in [-0.5, 0.5]` using an FMA-fused Estrin polynomial (`<= 2 ULP`).
    @inlinable
    @inline(__always)
    static func evalSinPiHalf(_ f: SIMD4<Double>) -> SIMD4<Double> {
        let f2 = f * f
        let f3 = f * f2
        let f4 = f2 * f2

        let piHi = SIMD4<Double>(repeating: 3.14159265358979312e+00)
        let piLo = SIMD4<Double>(repeating: 1.22464679914735321e-16)
        let c3Hi = SIMD4<Double>(repeating: -5.16771278004997026e+00)

        let sHi = f * piHi
        let sErr = (-sHi).addingProduct(f, piHi)
        let sumHi = sHi.addingProduct(f3, c3Hi)

        let r01 = SIMD4<Double>(repeating: 2.55016403987734508e+00)
            .addingProduct(f2, SIMD4<Double>(repeating: -5.99264529320726380e-01))
        let r23 = SIMD4<Double>(repeating: 8.21458866069244426e-02)
            .addingProduct(f2, SIMD4<Double>(repeating: -7.37043084476165806e-03))
        let r46 = SIMD4<Double>(repeating: 4.66301650775197856e-04)
            .addingProduct(f2, SIMD4<Double>(repeating: -2.19085642294756898e-05))
            .addingProduct(f4, SIMD4<Double>(repeating: 7.75374162400719320e-07))
        let remPoly = r01.addingProduct(f4, r23).addingProduct(f4 * f4, r46)
        let lowSum = sErr.addingProduct(f, piLo)
        return sumHi + lowSum.addingProduct(f * f4, remPoly)
    }

    @inlinable
    @inline(__always)
    static func sinpiFast(_ x: SIMD4<Double>) -> SIMD4<Double> {
        let k = x.rounded(.toNearestOrAwayFromZero)
        let f = x - k
        let s = evalSinPiHalf(f)
        let magic = SIMD4<Double>(repeating: 6_755_399_441_055_744.0)
        let kInt = unsafeBitCast(k + magic, to: SIMD4<Int64>.self)
        let sign = (kInt & SIMD4<Int64>(repeating: 1)) &<< 63
        let out = unsafeBitCast(unsafeBitCast(s, to: SIMD4<Int64>.self) ^ sign, to: SIMD4<Double>.self)
        return out.replacing(with: x * SIMD4<Double>.zero, where: f .== 0.0)
    }

    @inlinable
    @inline(__always)
    static func cospiFast(_ x: SIMD4<Double>) -> SIMD4<Double> {
        let k = x.rounded(.toNearestOrAwayFromZero)
        let fAbsBits = unsafeBitCast(x - k, to: SIMD4<UInt64>.self) & 0x7FFF_FFFF_FFFF_FFFF
        let g = SIMD4<Double>(repeating: 0.5) - unsafeBitCast(fAbsBits, to: SIMD4<Double>.self)
        let c = evalSinPiHalf(g)
        let magic = SIMD4<Double>(repeating: 6_755_399_441_055_744.0)
        let kInt = unsafeBitCast(k + magic, to: SIMD4<Int64>.self)
        let sign = (kInt & SIMD4<Int64>(repeating: 1)) &<< 63
        let out = unsafeBitCast(unsafeBitCast(c, to: SIMD4<Int64>.self) ^ sign, to: SIMD4<Double>.self)
        return out.replacing(with: 0.0, where: g .== 0.0)
    }

    // MARK: - [4/3] Minimax Rational tanpi Kernel (|x| < 2^50)

    @inlinable
    @inline(__always)
    static func tanpiFast(_ x: SIMD4<Double>) -> SIMD4<Double> {
        let y = x + x
        let q = y.rounded(.toNearestOrAwayFromZero)
        let f = y - q
        let u = f * f
        let u2 = u * u

        let p12 = SIMD4<Double>(repeating: -5.07708173989868450e-01)
            .addingProduct(u, SIMD4<Double>(repeating: 2.98221559234535111e-02))
        let p34 = SIMD4<Double>(repeating: -2.63272600658293336e-04)
            .addingProduct(u, SIMD4<Double>(repeating: -1.04189930484432556e-06))
        let pTail = SIMD4<Double>(repeating: 6.12323399573676604e-17)
            .addingProduct(u, p12.addingProduct(u2, p34))
        let halfPiHi = SIMD4<Double>(repeating: 1.57079632679489656e+00)
        let pHi = f * halfPiHi
        let pErr = (-pHi).addingProduct(f, halfPiHi)
        let fp = pHi + pErr.addingProduct(f, pTail)

        let dTail = SIMD4<Double>(repeating: -1.14568409557870354e+00)
            .addingProduct(
                u,
                SIMD4<Double>(repeating: 1.49530348163951055e-01)
                    .addingProduct(u, SIMD4<Double>(repeating: -3.84625256963672590e-03))
            )
        let d = SIMD4<Double>(repeating: 1.0).addingProduct(u, dTail)

        let magic = SIMD4<Double>(repeating: 6_755_399_441_055_744.0)
        let qInt = unsafeBitCast(q + magic, to: SIMD4<Int64>.self)
        let isOdd = (qInt & SIMD4<Int64>(repeating: 1)) .!= .zero

        let num = fp.replacing(with: -d, where: isOdd)
        let den = d.replacing(with: fp, where: isOdd)
        var out = num / den

        let isExact = f .== 0.0
        if any(isExact) {
            let signMask = SIMD4<Int64>(repeating: Int64(bitPattern: 0x8000_0000_0000_0000))
            let xSign = unsafeBitCast(x, to: SIMD4<Int64>.self) & signMask
            let qSign = (qInt & SIMD4<Int64>(repeating: 2)) &<< 62
            let zeroVal = unsafeBitCast(xSign ^ qSign, to: SIMD4<Double>.self)
            let infBits = SIMD4<Int64>(repeating: Int64(bitPattern: 0x7FF0_0000_0000_0000))
            let infVal = unsafeBitCast(infBits ^ qSign, to: SIMD4<Double>.self)
            out = out.replacing(with: zeroVal.replacing(with: infVal, where: isOdd), where: isExact)
        }
        return out
    }
}
