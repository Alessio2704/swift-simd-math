// MARK: - SIMD Tangent Math: tan (<= 2 ULP, Cody-Waite + 1280-Bit Payne-Hanek)

extension SIMDMath {
    /// Evaluates IEEE-754 `tan(x)` on `SIMD2<Double>` (`<= 2 ULP`).
    @inlinable
    @inline(__always)
    public static func tan(_ x: SIMD2<Double>) -> SIMD2<Double> {
        tan(SIMD4<Double>(lowHalf: x, highHalf: x)).lowHalf
    }

    /// Evaluates IEEE-754 `tan(x)` on `SIMD4<Double>` (`<= 2 ULP`).
    @inlinable
    @inline(__always)
    public static func tan(_ x: SIMD4<Double>) -> SIMD4<Double> {
        let absBits = unsafeBitCast(x, to: SIMD4<UInt64>.self) & 0x7FFF_FFFF_FFFF_FFFF
        if _slowPath(any((absBits &- 1) .>= 0x411F_FFFF_FFFF_FFFF)) {
            return tanCold(x)
        }
        return tanFast(x)
    }

    /// Evaluates IEEE-754 `tan(x)` on `SIMD8<Double>` (`<= 2 ULP`).
    @inlinable
    @inline(__always)
    public static func tan(_ x: SIMD8<Double>) -> SIMD8<Double> {
        SIMD8<Double>(lowHalf: tan(x.lowHalf), highHalf: tan(x.highHalf))
    }

    // MARK: - Fast FMA Cody-Waite & Estrin Rational Kernel

    @inlinable
    @inline(__always)
    static func tanFast(_ x: SIMD4<Double>) -> SIMD4<Double> {
        let invHalfPi = SIMD4<Double>(repeating: 6.36619772367581382e-01)
        let halfPi1 = SIMD4<Double>(repeating: 0x1.921fb54400000p+0)
        let halfPi2 = SIMD4<Double>(repeating: 0x1.0b4611a600000p-34)
        let halfPi3 = SIMD4<Double>(repeating: 0x1.3198a2e037073p-69)

        let q = (x * invHalfPi).rounded(.toNearestOrAwayFromZero)
        let t1 = x.addingProduct(-q, halfPi1)
        let qp2 = -q * halfPi2
        let r = t1 + qp2
        let v = r - t1
        let rLo = ((t1 - (r - v)) + (qp2 - v)).addingProduct(-q, halfPi3)

        let u = r * r
        let u2 = u * u
        let p12 = SIMD4<Double>(repeating: -1.37284832991073746e-01)
            .addingProduct(u, SIMD4<Double>(repeating: 3.92540701293497395e-03))
        let p34 = SIMD4<Double>(repeating: -2.88132830683390867e-05)
            .addingProduct(u, SIMD4<Double>(repeating: 2.92422691276773040e-08))
        let pTail = p12.addingProduct(u2, p34)

        let d12 = SIMD4<Double>(repeating: -4.70618166324407061e-01)
            .addingProduct(u, SIMD4<Double>(repeating: 2.74647957877373304e-02))
        let d34 = SIMD4<Double>(repeating: -4.02910337313807938e-04)
            .addingProduct(u, SIMD4<Double>(repeating: 1.31210245646881571e-06))
        let dTail = d12.addingProduct(u2, d34)

        let one = SIMD4<Double>(repeating: 1.0)
        let d0 = one.addingProduct(u, dTail)
        let numR = r + (rLo * d0).addingProduct(r * u, pTail)
        let denR = d0.addingProduct(-rLo, numR)

        let magic = SIMD4<Double>(repeating: 6_755_399_441_055_744.0)
        let qInt = unsafeBitCast(q + magic, to: SIMD4<Int64>.self)
        let isOdd = (qInt & SIMD4<Int64>(repeating: 1)) .!= .zero

        let num = numR.replacing(with: -denR, where: isOdd)
        let den = denR.replacing(with: numR, where: isOdd)
        return num / den
    }

    // MARK: - Cold Path (Zero, Infinity, NaN, and 1280-Bit Payne-Hanek for |x| >= 2^19)

    @usableFromInline
    @inline(never)
    static func tanCold(_ x: SIMD4<Double>) -> SIMD4<Double> {
        let absBits = unsafeBitCast(x, to: SIMD4<UInt64>.self) & 0x7FFF_FFFF_FFFF_FFFF
        let isFast = (absBits &- 1) .< 0x411F_FFFF_FFFF_FFFF
        let safeX = x.replacing(with: SIMD4<Double>(repeating: 1.0), where: .!isFast)
        var out = tanFast(safeX)

        for lane in 0..<4 where !isFast[lane] {
            out[lane] = tanColdScalar(x[lane])
        }
        return out
    }

    private static func tanColdScalar(_ x: Double) -> Double {
        if x == 0.0 {
            return x
        }
        if !x.isFinite {
            return x - x
        }
        let (r, rLo, q) = payneHanekReduceHiLo(x)
        let r2 = r * r
        var ps = -7.58669711770691831e-13
        ps = (1.60585316189861469e-10).addingProduct(r2, ps)
        ps = (-2.50521062324475780e-08).addingProduct(r2, ps)
        ps = (2.75573192193391672e-06).addingProduct(r2, ps)
        ps = (-1.98412698412650653e-04).addingProduct(r2, ps)
        ps = (8.33333333333333148e-03).addingProduct(r2, ps)
        ps = (-1.66666666666666657e-01).addingProduct(r2, ps)
        let sinTerm = (r * r2) * ps
        let sHi0 = r + sinTerm
        let sLo0 = (r - sHi0) + sinTerm

        var pc = -1.13679986540224937e-11
        pc = (2.08758867380470521e-09).addingProduct(r2, pc)
        pc = (-2.75573155663418950e-07).addingProduct(r2, pc)
        pc = (2.48015872936934593e-05).addingProduct(r2, pc)
        pc = (-1.38888888888807752e-03).addingProduct(r2, pc)
        pc = (4.16666666666666366e-02).addingProduct(r2, pc)
        pc = (-5.00000000000000000e-01).addingProduct(r2, pc)
        let cosTerm = r2 * pc
        let cHi0 = 1.0 + cosTerm
        let cLo0 = (1.0 - cHi0) + cosTerm

        let sLo = sLo0.addingProduct(rLo, cHi0)
        let sHi = sHi0 + sLo
        let sRem = (sHi0 - sHi) + sLo

        let cLo = cLo0.addingProduct(-rLo, sHi0)
        let cHi = cHi0 + cLo
        let cRem = (cHi0 - cHi) + cLo

        let (numHi, numLo, denHi, denLo) =
            (q & 1) == 0 ? (sHi, sRem, cHi, cRem) : (-cHi, -cRem, sHi, sRem)
        let quotient = numHi / denHi
        let residual = numHi.addingProduct(-quotient, denHi) + numLo.addingProduct(-quotient, denLo)
        return quotient + residual / denHi
    }
}
