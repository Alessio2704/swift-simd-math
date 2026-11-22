// MARK: - SIMD4 & SIMD8 Trigonometric Math (Low-Pressure Horner + FMA Cody-Waite)

extension SIMDMath {
    /// Evaluates IEEE-754 simultaneous `sin(x), cos(x)` on `SIMD4<Double>` (`<= 1-2 ULP`).
    @inlinable
    @inline(__always)
    public static func sincos(_ x: SIMD4<Double>) -> (sin: SIMD4<Double>, cos: SIMD4<Double>) {
        let absBits = unsafeBitCast(x, to: SIMD4<UInt64>.self) & 0x7FFF_FFFF_FFFF_FFFF
        if _slowPath(any((absBits &- 1) .>= 0x411F_FFFF_FFFF_FFFF)) {
            return sincosCold(x)
        }
        return sincosFast(x)
    }

    /// Evaluates IEEE-754 simultaneous `sin(x), cos(x)` on `SIMD8<Double>` (`<= 1-2 ULP`).
    @inlinable
    @inline(__always)
    public static func sincos(_ x: SIMD8<Double>) -> (sin: SIMD8<Double>, cos: SIMD8<Double>) {
        let (s0, c0) = sincos(x.lowHalf)
        let (s1, c1) = sincos(x.highHalf)
        return (SIMD8<Double>(lowHalf: s0, highHalf: s1), SIMD8<Double>(lowHalf: c0, highHalf: c1))
    }

    /// Evaluates IEEE-754 `sin(x)` on `SIMD4<Double>` (`<= 1-2 ULP`).
    @inlinable
    @inline(__always)
    public static func sin(_ x: SIMD4<Double>) -> SIMD4<Double> { sincos(x).sin }

    /// Evaluates IEEE-754 `cos(x)` on `SIMD4<Double>` (`<= 1-2 ULP`).
    @inlinable
    @inline(__always)
    public static func cos(_ x: SIMD4<Double>) -> SIMD4<Double> { sincos(x).cos }

    /// Evaluates IEEE-754 `sin(x)` on `SIMD8<Double>` (`<= 1-2 ULP`).
    @inlinable
    @inline(__always)
    public static func sin(_ x: SIMD8<Double>) -> SIMD8<Double> { sincos(x).sin }

    /// Evaluates IEEE-754 `cos(x)` on `SIMD8<Double>` (`<= 1-2 ULP`).
    @inlinable
    @inline(__always)
    public static func cos(_ x: SIMD8<Double>) -> SIMD8<Double> { sincos(x).cos }

    // MARK: - Fast FMA Cody-Waite & Horner Kernels

    @inlinable
    @inline(__always)
    static func sincosFast(_ x: SIMD4<Double>) -> (sin: SIMD4<Double>, cos: SIMD4<Double>) {
        let invHalfPi = SIMD4<Double>(repeating: 6.36619772367581382e-01)
        let halfPi1 = SIMD4<Double>(repeating: 1.57079632679489656e+00)
        let halfPi2 = SIMD4<Double>(repeating: 6.12323399573676604e-17)
        let halfPi3 = SIMD4<Double>(repeating: -1.49738490485916983e-33)

        let y = x * invHalfPi
        let q = y.rounded(.toNearestOrAwayFromZero)
        let r = x.addingProduct(-q, halfPi1).addingProduct(-q, halfPi2).addingProduct(-q, halfPi3)
        return evaluateReducedSinCos(r: r, q: q)
    }

    @inlinable
    @inline(__always)
    static func evaluateReducedSinCos(
        r: SIMD4<Double>,
        q: SIMD4<Double>
    ) -> (sin: SIMD4<Double>, cos: SIMD4<Double>) {
        let r2 = r * r

        var ps = SIMD4<Double>(repeating: 1.58947432838633983e-10)
        ps = SIMD4<Double>(repeating: -2.50507351186882901e-08).addingProduct(r2, ps)
        ps = SIMD4<Double>(repeating: 2.75573136551872668e-06).addingProduct(r2, ps)
        ps = SIMD4<Double>(repeating: -1.98412698301532724e-04).addingProduct(r2, ps)
        ps = SIMD4<Double>(repeating: 8.33333333332367254e-03).addingProduct(r2, ps)
        ps = SIMD4<Double>(repeating: -1.66666666666666435e-01).addingProduct(r2, ps)
        let sinR = r.addingProduct(r * r2, ps)

        var pc = SIMD4<Double>(repeating: 2.06304656433169899e-09)
        pc = SIMD4<Double>(repeating: -2.75552610933629672e-07).addingProduct(r2, pc)
        pc = SIMD4<Double>(repeating: 2.48015789564113583e-05).addingProduct(r2, pc)
        pc = SIMD4<Double>(repeating: -1.38888888722309752e-03).addingProduct(r2, pc)
        pc = SIMD4<Double>(repeating: 4.16666666665218982e-02).addingProduct(r2, pc)
        pc = SIMD4<Double>(repeating: -4.99999999999996336e-01).addingProduct(r2, pc)
        let cosR = SIMD4<Double>(repeating: 1.0).addingProduct(r2, pc)

        let magic = SIMD4<Double>(repeating: 6_755_399_441_055_744.0)
        let qInt = unsafeBitCast(q + magic, to: SIMD4<Int64>.self)
        let swapMask = (qInt & SIMD4<Int64>(repeating: 1)) .!= .zero

        let rawSin = sinR.replacing(with: cosR, where: swapMask)
        let rawCos = cosR.replacing(with: sinR, where: swapMask)

        let two = SIMD4<Int64>(repeating: 2)
        let sinSign = (qInt & two) &<< 62
        let cosSign = ((qInt &+ 1) & two) &<< 62

        let sBits = unsafeBitCast(rawSin, to: SIMD4<Int64>.self) ^ sinSign
        let cBits = unsafeBitCast(rawCos, to: SIMD4<Int64>.self) ^ cosSign
        return (unsafeBitCast(sBits, to: SIMD4<Double>.self), unsafeBitCast(cBits, to: SIMD4<Double>.self))
    }
}
