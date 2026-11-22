// MARK: - SIMD Base-2, Base-10, and High-Precision exp(x) - 1 (<= 1-2 ULP, Pure Swift IEEE-754)

extension SIMDMath {
    // MARK: - Public API: exp2, exp10, expm1

    /// Evaluates IEEE-754 `exp2(x) = 2^x` on `SIMD2<Double>` (`<= 1 ULP`).
    @inlinable
    @inline(__always)
    public static func exp2(_ x: SIMD2<Double>) -> SIMD2<Double> {
        exp2(SIMD4<Double>(lowHalf: x, highHalf: x)).lowHalf
    }

    /// Evaluates IEEE-754 `exp2(x) = 2^x` on `SIMD4<Double>` (`<= 1 ULP`).
    @inlinable
    @inline(__always)
    public static func exp2(_ x: SIMD4<Double>) -> SIMD4<Double> {
        let absBits = unsafeBitCast(x, to: SIMD4<UInt64>.self) & 0x7FFF_FFFF_FFFF_FFFF
        if _slowPath(any(absBits .>= 0x408F_F000_0000_0000)) {
            return exp2Cold(x)
        }
        return exp2Fast(x)
    }

    /// Evaluates IEEE-754 `exp2(x) = 2^x` on `SIMD8<Double>` (`<= 1 ULP`).
    @inlinable
    @inline(__always)
    public static func exp2(_ x: SIMD8<Double>) -> SIMD8<Double> {
        SIMD8<Double>(lowHalf: exp2(x.lowHalf), highHalf: exp2(x.highHalf))
    }

    /// Evaluates IEEE-754 `exp10(x) = 10^x` on `SIMD2<Double>` (`<= 1 ULP`).
    @inlinable
    @inline(__always)
    public static func exp10(_ x: SIMD2<Double>) -> SIMD2<Double> {
        exp10(SIMD4<Double>(lowHalf: x, highHalf: x)).lowHalf
    }

    /// Evaluates IEEE-754 `exp10(x) = 10^x` on `SIMD4<Double>` (`<= 1 ULP`).
    @inlinable
    @inline(__always)
    public static func exp10(_ x: SIMD4<Double>) -> SIMD4<Double> {
        let absBits = unsafeBitCast(x, to: SIMD4<UInt64>.self) & 0x7FFF_FFFF_FFFF_FFFF
        if _slowPath(any(absBits .>= 0x4073_3000_0000_0000)) {
            return exp10Cold(x)
        }
        return exp10Fast(x)
    }

    /// Evaluates IEEE-754 `exp10(x) = 10^x` on `SIMD8<Double>` (`<= 1 ULP`).
    @inlinable
    @inline(__always)
    public static func exp10(_ x: SIMD8<Double>) -> SIMD8<Double> {
        SIMD8<Double>(lowHalf: exp10(x.lowHalf), highHalf: exp10(x.highHalf))
    }

    /// Evaluates IEEE-754 `expm1(x) = e^x - 1` on `SIMD2<Double>` (`<= 2 ULP`).
    @inlinable
    @inline(__always)
    public static func expm1(_ x: SIMD2<Double>) -> SIMD2<Double> {
        expm1(SIMD4<Double>(lowHalf: x, highHalf: x)).lowHalf
    }

    /// Evaluates IEEE-754 `expm1(x) = e^x - 1` on `SIMD4<Double>` (`<= 2 ULP`).
    @inlinable
    @inline(__always)
    public static func expm1(_ x: SIMD4<Double>) -> SIMD4<Double> {
        let absBits = unsafeBitCast(x, to: SIMD4<UInt64>.self) & 0x7FFF_FFFF_FFFF_FFFF
        if _slowPath(any(absBits .>= 0x4086_2000_0000_0000)) {
            return expm1Cold(x)
        }
        return expm1Fast(x)
    }

    /// Evaluates IEEE-754 `expm1(x) = e^x - 1` on `SIMD8<Double>` (`<= 2 ULP`).
    @inlinable
    @inline(__always)
    public static func expm1(_ x: SIMD8<Double>) -> SIMD8<Double> {
        SIMD8<Double>(lowHalf: expm1(x.lowHalf), highHalf: expm1(x.highHalf))
    }

    // MARK: - Fast Vectorized Kernels & Estrin Minimax Polynomials

    @inlinable
    @inline(__always)
    static func exp2Poly(_ f: SIMD4<Double>) -> SIMD4<Double> {
        let f2 = f * f
        let f4 = f2 * f2
        let p01 = SIMD4<Double>(repeating: 6.93147180559945286e-01)
            .addingProduct(f, SIMD4<Double>(repeating: 2.40226506959100972e-01))
        let p23 = SIMD4<Double>(repeating: 5.55041086648215970e-02)
            .addingProduct(f, SIMD4<Double>(repeating: 9.61812910760688825e-03))
        let p45 = SIMD4<Double>(repeating: 1.33335581464169356e-03)
            .addingProduct(f, SIMD4<Double>(repeating: 1.54035304417360499e-04))
        let p67 = SIMD4<Double>(repeating: 1.52527338298361192e-05)
            .addingProduct(f, SIMD4<Double>(repeating: 1.32154425879216893e-06))
        let p89 = SIMD4<Double>(repeating: 1.01780624458457737e-07)
            .addingProduct(f, SIMD4<Double>(repeating: 7.07258594926922339e-09))
            .addingProduct(f2, SIMD4<Double>(repeating: 4.45496059818651856e-10))
        let q0 = p01.addingProduct(f2, p23)
        let q1 = p45.addingProduct(f2, p67).addingProduct(f4, p89)
        return SIMD4<Double>(repeating: 1.0).addingProduct(f, q0.addingProduct(f4, q1))
    }

    @inlinable
    @inline(__always)
    static func exp10Poly(_ f: SIMD4<Double>, fLo: SIMD4<Double>) -> SIMD4<Double> {
        let f2 = f * f
        let f4 = f2 * f2
        let p01 = SIMD4<Double>(repeating: 2.65094905523919921e+00)
            .addingProduct(f, SIMD4<Double>(repeating: 2.03467859229347692e+00))
        let p23 = SIMD4<Double>(repeating: 1.17125514891226712e+00)
            .addingProduct(f, SIMD4<Double>(repeating: 5.39382929195115879e-01))
        let p45 = SIMD4<Double>(repeating: 2.06995848696791551e-01)
            .addingProduct(f, SIMD4<Double>(repeating: 6.80893651895043417e-02))
        let p67 = SIMD4<Double>(repeating: 1.95976946454002009e-02)
            .addingProduct(f, SIMD4<Double>(repeating: 5.01391722597541428e-03))
        let p810 = SIMD4<Double>(repeating: 1.15449787017496593e-03)
            .addingProduct(f, SIMD4<Double>(repeating: 2.42178938615900699e-04))
            .addingProduct(f2, SIMD4<Double>(repeating: 4.64557499711101455e-05))
        let q0 = p01.addingProduct(f2, p23)
        let q1 = p45.addingProduct(f2, p67).addingProduct(f4, p810)
        let tail = q0.addingProduct(f4, q1)

        let ln10Hi = SIMD4<Double>(repeating: 0x1.26bb1bbb55516p+1)
        let ln10Lo = SIMD4<Double>(repeating: -0x1.f48ad494ea3e9p-53)
        let sHi = f * ln10Hi
        let sErr = (-sHi).addingProduct(f, ln10Hi)
        let linTail = sErr.addingProduct(f, ln10Lo).addingProduct(fLo, ln10Hi)
        let one = SIMD4<Double>(repeating: 1.0)
        let u = one + sHi
        let uErr = (one - u) + sHi
        return u + (uErr + linTail).addingProduct(f2, tail)
    }

    @inlinable
    @inline(__always)
    static func expm1Poly(_ r: SIMD4<Double>) -> SIMD4<Double> {
        let r2 = r * r
        let r4 = r2 * r2
        let p01 = SIMD4<Double>(repeating: 1.66666666666666657e-01)
            .addingProduct(r, SIMD4<Double>(repeating: 4.16666666666512184e-02))
        let p23 = SIMD4<Double>(repeating: 8.33333333333214493e-03)
            .addingProduct(r, SIMD4<Double>(repeating: 1.38888889059971595e-03))
        let p45 = SIMD4<Double>(repeating: 1.98412698544275237e-04)
            .addingProduct(r, SIMD4<Double>(repeating: 2.48015361579733741e-05))
        let p67 = SIMD4<Double>(repeating: 2.75572798895883074e-06)
            .addingProduct(r, SIMD4<Double>(repeating: 2.76139347503020042e-07))
            .addingProduct(r2, SIMD4<Double>(repeating: 2.50956530270867840e-08))
        let q0 = p01.addingProduct(r2, p23)
        let q1 = p45.addingProduct(r2, p67)
        let tail = SIMD4<Double>(repeating: 0.5).addingProduct(r, q0.addingProduct(r4, q1))
        return r.addingProduct(r2, tail).replacing(with: r, where: r .== 0.0)
    }

    @inlinable
    @inline(__always)
    static func exp2Fast(_ x: SIMD4<Double>) -> SIMD4<Double> {
        let k = x.rounded(.toNearestOrAwayFromZero)
        let f = x - k
        let expF = exp2Poly(f)
        let magic = SIMD4<Double>(repeating: 6_755_399_441_055_744.0)
        let bits = unsafeBitCast(k + magic, to: SIMD4<Int64>.self)
        let scale = unsafeBitCast((bits &<< 52) &+ (1023 << 52), to: SIMD4<Double>.self)
        return expF * scale
    }

    @inlinable
    @inline(__always)
    static func exp10Fast(_ x: SIMD4<Double>) -> SIMD4<Double> {
        let invLog10Of2 = SIMD4<Double>(repeating: 3.32192809488736218e+00)
        let log10Of2Hi = SIMD4<Double>(repeating: 0x1.34413509f6000p-2)
        let log10Of2Lo = SIMD4<Double>(repeating: 0x1.9fef311f12b36p-42)
        let log10Of2Tail = SIMD4<Double>(repeating: -0x1.fa41b743eca96p-96)
        let k = (x * invLog10Of2).rounded(.toNearestOrAwayFromZero)
        let t1 = x.addingProduct(-k, log10Of2Hi)
        let f = t1.addingProduct(-k, log10Of2Lo)
        let fLo = (t1 - f).addingProduct(-k, log10Of2Lo).addingProduct(-k, log10Of2Tail)
        let expF = exp10Poly(f, fLo: fLo)
        let magic = SIMD4<Double>(repeating: 6_755_399_441_055_744.0)
        let bits = unsafeBitCast(k + magic, to: SIMD4<Int64>.self)
        let scale = unsafeBitCast((bits &<< 52) &+ (1023 << 52), to: SIMD4<Double>.self)
        return expF * scale
    }

    @inlinable
    @inline(__always)
    static func expm1Fast(_ x: SIMD4<Double>) -> SIMD4<Double> {
        let invLn2 = SIMD4<Double>(repeating: 1.4426950408889634)
        let ln2Hi = SIMD4<Double>(repeating: 6.93147180559945286e-01)
        let ln2Lo = SIMD4<Double>(repeating: 2.31904681384629956e-17)

        let k = (x * invLn2).rounded(.toNearestOrAwayFromZero)
        let r = x.addingProduct(-k, ln2Hi).addingProduct(-k, ln2Lo)
        let p = expm1Poly(r)

        let magic = SIMD4<Double>(repeating: 6_755_399_441_055_744.0)
        let bits = unsafeBitCast(k + magic, to: SIMD4<Int64>.self)
        let scale = unsafeBitCast((bits &<< 52) &+ (1023 << 52), to: SIMD4<Double>.self)
        let scaled = (scale - SIMD4<Double>(repeating: 1.0)).addingProduct(scale, p)
        return scaled.replacing(with: p, where: k .== .zero).replacing(with: x, where: x .== 0.0)
    }
}
