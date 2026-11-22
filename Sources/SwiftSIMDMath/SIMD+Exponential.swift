// MARK: - SIMD Exponential Math (Degree-11 Minimax, <= 1 ULP, Pure Swift IEEE-754)

extension SIMDMath {
    // MARK: - Public Exponential API

    /// Evaluates IEEE-754 `exp(x)` on `SIMD2<Double>` (`<= 1 ULP`).
    @inlinable
    @inline(__always)
    public static func exp(_ x: SIMD2<Double>) -> SIMD2<Double> {
        let absBits = unsafeBitCast(x, to: SIMD2<UInt64>.self) & 0x7FFF_FFFF_FFFF_FFFF
        if _slowPath(any(absBits .>= 0x4086_2000_0000_0000)) {
            return expCold(x)
        }
        return expFast(x)
    }

    /// Evaluates IEEE-754 `exp(x)` on `SIMD4<Double>` (`<= 1 ULP`).
    @inlinable
    @inline(__always)
    public static func exp(_ x: SIMD4<Double>) -> SIMD4<Double> {
        let absBits = unsafeBitCast(x, to: SIMD4<UInt64>.self) & 0x7FFF_FFFF_FFFF_FFFF
        if _slowPath(any(absBits .>= 0x4086_2000_0000_0000)) {
            return expCold(x)
        }
        return expFast(x)
    }

    /// Evaluates IEEE-754 `exp(x)` on `SIMD8<Double>` (`<= 1 ULP`).
    @inlinable
    @inline(__always)
    public static func exp(_ x: SIMD8<Double>) -> SIMD8<Double> {
        SIMD8<Double>(lowHalf: exp(x.lowHalf), highHalf: exp(x.highHalf))
    }

    // MARK: - Core Degree-11 Minimax Polynomial & Fast Kernels

    @inlinable
    @inline(__always)
    static func expPoly(_ r: SIMD2<Double>) -> SIMD2<Double> {
        let r2 = r * r
        let r4 = r2 * r2
        let p01 = SIMD2<Double>(repeating: 0.5)
            .addingProduct(r, SIMD2<Double>(repeating: 1.66666666666619584e-01))
        let p23 = SIMD2<Double>(repeating: 4.16666666666199725e-02)
            .addingProduct(r, SIMD2<Double>(repeating: 8.33333333652807630e-03))
        let p45 = SIMD2<Double>(repeating: 1.38888889205114434e-03)
            .addingProduct(r, SIMD2<Double>(repeating: 1.98412626727496882e-04))
        let p67 = SIMD2<Double>(repeating: 2.48015163475950065e-05)
            .addingProduct(r, SIMD2<Double>(repeating: 2.75638576672777052e-06))
        let p89 = SIMD2<Double>(repeating: 2.76222258049990938e-07)
            .addingProduct(r, SIMD2<Double>(repeating: 2.29762871188039997e-08))
        let q0 = p01.addingProduct(r2, p23)
        let q1 = p45.addingProduct(r2, p67).addingProduct(r4, p89)
        return (SIMD2<Double>(repeating: 1.0) + r).addingProduct(r2, q0.addingProduct(r4, q1))
    }

    @inlinable
    @inline(__always)
    static func expPoly(_ r: SIMD4<Double>) -> SIMD4<Double> {
        let r2 = r * r
        let r4 = r2 * r2
        let p01 = SIMD4<Double>(repeating: 0.5)
            .addingProduct(r, SIMD4<Double>(repeating: 1.66666666666619584e-01))
        let p23 = SIMD4<Double>(repeating: 4.16666666666199725e-02)
            .addingProduct(r, SIMD4<Double>(repeating: 8.33333333652807630e-03))
        let p45 = SIMD4<Double>(repeating: 1.38888889205114434e-03)
            .addingProduct(r, SIMD4<Double>(repeating: 1.98412626727496882e-04))
        let p67 = SIMD4<Double>(repeating: 2.48015163475950065e-05)
            .addingProduct(r, SIMD4<Double>(repeating: 2.75638576672777052e-06))
        let p89 = SIMD4<Double>(repeating: 2.76222258049990938e-07)
            .addingProduct(r, SIMD4<Double>(repeating: 2.29762871188039997e-08))
        let q0 = p01.addingProduct(r2, p23)
        let q1 = p45.addingProduct(r2, p67).addingProduct(r4, p89)
        return (SIMD4<Double>(repeating: 1.0) + r).addingProduct(r2, q0.addingProduct(r4, q1))
    }

    @inlinable
    @inline(__always)
    static func expFast(_ x: SIMD2<Double>) -> SIMD2<Double> {
        let invLn2 = SIMD2<Double>(repeating: 1.4426950408889634)
        let ln2Hi = SIMD2<Double>(repeating: 6.93147180559945286e-01)
        let ln2Lo = SIMD2<Double>(repeating: 2.31904681384629956e-17)

        let k = (x * invLn2).rounded(.toNearestOrAwayFromZero)
        let r = x.addingProduct(-k, ln2Hi).addingProduct(-k, ln2Lo)
        let expR = expPoly(r)

        let magic = SIMD2<Double>(repeating: 6_755_399_441_055_744.0)
        let bits = unsafeBitCast(k + magic, to: SIMD2<Int64>.self)
        let scale = unsafeBitCast((bits &<< 52) &+ (1023 << 52), to: SIMD2<Double>.self)
        return expR * scale
    }

    @inlinable
    @inline(__always)
    static func expFast(_ x: SIMD4<Double>) -> SIMD4<Double> {
        let invLn2 = SIMD4<Double>(repeating: 1.4426950408889634)
        let ln2Hi = SIMD4<Double>(repeating: 6.93147180559945286e-01)
        let ln2Lo = SIMD4<Double>(repeating: 2.31904681384629956e-17)

        let k = (x * invLn2).rounded(.toNearestOrAwayFromZero)
        let r = x.addingProduct(-k, ln2Hi).addingProduct(-k, ln2Lo)
        let expR = expPoly(r)

        let magic = SIMD4<Double>(repeating: 6_755_399_441_055_744.0)
        let bits = unsafeBitCast(k + magic, to: SIMD4<Int64>.self)
        let scale = unsafeBitCast((bits &<< 52) &+ (1023 << 52), to: SIMD4<Double>.self)
        return expR * scale
    }
}
