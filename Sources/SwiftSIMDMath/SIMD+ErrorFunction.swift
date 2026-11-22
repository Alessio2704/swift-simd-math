// MARK: - SIMD Error Functions: erf & erfc (<= 2 ULP, Exact Split-Exponent exp(-a^2))

extension SIMDMath {
    // MARK: - Public API: erf, erfc

    /// Evaluates IEEE-754 `erf(x)` on `SIMD2<Double>` (`<= 2 ULP`).
    @inlinable
    @inline(__always)
    public static func erf(_ x: SIMD2<Double>) -> SIMD2<Double> {
        erf(SIMD4<Double>(lowHalf: x, highHalf: x)).lowHalf
    }

    /// Evaluates IEEE-754 `erf(x)` on `SIMD4<Double>` (`<= 2 ULP`).
    @inlinable
    @inline(__always)
    public static func erf(_ x: SIMD4<Double>) -> SIMD4<Double> {
        let bits = unsafeBitCast(x, to: SIMD4<UInt64>.self)
        let signBit = bits & 0x8000_0000_0000_0000
        let absBits = bits & 0x7FFF_FFFF_FFFF_FFFF
        let ax = unsafeBitCast(absBits, to: SIMD4<Double>.self)
        let isNaN = x .!= x
        let isSmall = ax .< SIMD4<Double>(repeating: 0.84375)
        let isMid = (ax .>= SIMD4<Double>(repeating: 0.84375)) .& (ax .< SIMD4<Double>(repeating: 6.0))

        var mag = SIMD4<Double>(repeating: 1.0)
        if any(isSmall) {
            let safeSmall = ax.replacing(with: 0.0, where: .!isSmall)
            let t = safeSmall * safeSmall
            let c0Hi = SIMD4<Double>(repeating: 1.28379167095512586e-01)
            let c0Lo = SIMD4<Double>(repeating: -1.22634870615046910e-17)
            let valSmall =
                safeSmall
                .addingProduct(safeSmall, c0Hi)
                .addingProduct(safeSmall, c0Lo.addingProduct(t, erfSmallTailPoly(t)))
            mag = mag.replacing(with: valSmall, where: isSmall)
        }
        if any(isMid) {
            let safeMid = ax.replacing(with: SIMD4<Double>(repeating: 1.0), where: .!isMid)
            let tail = evalErfcPositive(safeMid, allowSubnormal: false)
            mag = mag.replacing(with: SIMD4<Double>(repeating: 1.0) - tail, where: isMid)
        }
        let signed = unsafeBitCast(unsafeBitCast(mag, to: SIMD4<UInt64>.self) | signBit, to: SIMD4<Double>.self)
        return signed.replacing(with: x + x, where: isNaN)
    }

    /// Evaluates IEEE-754 `erf(x)` on `SIMD8<Double>` (`<= 2 ULP`).
    @inlinable
    @inline(__always)
    public static func erf(_ x: SIMD8<Double>) -> SIMD8<Double> {
        SIMD8<Double>(lowHalf: erf(x.lowHalf), highHalf: erf(x.highHalf))
    }

    /// Evaluates IEEE-754 `erfc(x) = 1 - erf(x)` on `SIMD2<Double>` (`<= 2 ULP`).
    @inlinable
    @inline(__always)
    public static func erfc(_ x: SIMD2<Double>) -> SIMD2<Double> {
        erfc(SIMD4<Double>(lowHalf: x, highHalf: x)).lowHalf
    }

    /// Evaluates IEEE-754 `erfc(x) = 1 - erf(x)` on `SIMD4<Double>` (`<= 2 ULP`).
    @inlinable
    @inline(__always)
    public static func erfc(_ x: SIMD4<Double>) -> SIMD4<Double> {
        let bits = unsafeBitCast(x, to: SIMD4<UInt64>.self)
        let absBits = bits & 0x7FFF_FFFF_FFFF_FFFF
        let ax = unsafeBitCast(absBits, to: SIMD4<Double>.self)
        let isNaN = x .!= x
        let isNeg = x .< .zero
        let isSmall = ax .< SIMD4<Double>(repeating: 0.84)
        let isPosTail = (.!isNeg) .& (ax .>= SIMD4<Double>(repeating: 0.84)) .& (ax .< SIMD4<Double>(repeating: 27.35))
        let isNegTail = isNeg .& (ax .>= SIMD4<Double>(repeating: 0.84)) .& (ax .< SIMD4<Double>(repeating: 6.0))
        let isTail = isPosTail .| isNegTail

        var result = SIMD4<Double>(repeating: 0.0).replacing(with: SIMD4<Double>(repeating: 2.0), where: isNeg)
        if any(isSmall) {
            let safeSmall = x.replacing(with: 0.0, where: .!isSmall)
            let t = safeSmall * safeSmall
            let c0Hi = SIMD4<Double>(repeating: 1.28379167095512586e-01)
            let c0Lo = SIMD4<Double>(repeating: -1.22634870615046910e-17)
            let tail = c0Lo.addingProduct(t, erfSmallTailPoly(t))
            let valPos = (SIMD4<Double>(repeating: 1.0) - safeSmall)
                .addingProduct(-safeSmall, c0Hi)
                .addingProduct(-safeSmall, tail)
            let valNeg =
                SIMD4<Double>(repeating: 1.0)
                - safeSmall.addingProduct(safeSmall, c0Hi).addingProduct(safeSmall, tail)
            let valSmall = valPos.replacing(with: valNeg, where: safeSmall .< 0.0)
            result = result.replacing(with: valSmall, where: isSmall)
        }
        if any(isTail) {
            let safeA = ax.replacing(with: SIMD4<Double>(repeating: 1.0), where: .!isTail)
            let needSubnormal = any(isPosTail .& (ax .>= SIMD4<Double>(repeating: 26.4)))
            let tail = evalErfcPositive(safeA, allowSubnormal: needSubnormal)
            result = result.replacing(with: tail, where: isPosTail)
            result = result.replacing(with: SIMD4<Double>(repeating: 2.0) - tail, where: isNegTail)
        }
        return result.replacing(with: x + x, where: isNaN)
    }

    /// Evaluates IEEE-754 `erfc(x) = 1 - erf(x)` on `SIMD8<Double>` (`<= 2 ULP`).
    @inlinable
    @inline(__always)
    public static func erfc(_ x: SIMD8<Double>) -> SIMD8<Double> {
        SIMD8<Double>(lowHalf: erfc(x.lowHalf), highHalf: erfc(x.highHalf))
    }

    // MARK: - Shared Exact Split-Exponent Positive Tail Kernel

    /// Evaluates `erfc(a)` for `a in [0.84, 27.35]` using exact 26-bit split `a = aHi + aLo`.
    @inlinable
    @inline(__always)
    static func evalErfcPositive(_ a: SIMD4<Double>, allowSubnormal: Bool) -> SIMD4<Double> {
        let one = SIMD4<Double>(repeating: 1.0)
        let inA = a .< SIMD4<Double>(repeating: 1.84)
        let inB = (a .>= SIMD4<Double>(repeating: 1.84)) .& (a .< SIMD4<Double>(repeating: 4.5))
        let inC = a .>= SIMD4<Double>(repeating: 4.5)

        var scaled = SIMD4<Double>.zero
        if any(inA) {
            let safeA = a.replacing(with: SIMD4<Double>(repeating: 1.34), where: .!inA)
            scaled = scaled.replacing(with: erfcPolyA(safeA - SIMD4<Double>(repeating: 1.34)), where: inA)
        }
        if any(inB) {
            let safeB = a.replacing(with: SIMD4<Double>(repeating: 2.5), where: .!inB)
            let invB = one / safeB
            let valB = erfcPolyB(invB - SIMD4<Double>(repeating: 0.383)) / safeB
            scaled = scaled.replacing(with: valB, where: inB)
        }
        if any(inC) {
            let safeC = a.replacing(with: SIMD4<Double>(repeating: 5.0), where: .!inC)
            let invC = one / safeC
            let valC = erfcPolyC(invC * invC) * invC
            scaled = scaled.replacing(with: valC, where: inC)
        }

        // Exact 26-bit split: aHi * aHi is exact in binary64; residual err <= 2.3e-5.
        let aHi = unsafeBitCast(
            unsafeBitCast(a, to: SIMD4<UInt64>.self) & 0xFFFF_FFFF_F800_0000, to: SIMD4<Double>.self)
        let err = (a + aHi) * (a - aHi)
        let negDelta =
            (-err)
            * one.addingProduct(
                -err,
                SIMD4<Double>(repeating: 0.5).addingProduct(-err, SIMD4<Double>(repeating: 1.0 / 6.0))
            )
        let negAHi2 = -(aHi * aHi)
        let expMain = allowSubnormal ? expCold(negAHi2) : expFast(negAHi2)
        let prod = expMain * scaled
        return prod.addingProduct(prod, negDelta)
    }
}
