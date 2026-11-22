// MARK: - SIMD Natural & Base-N Logarithmic Math (Degree-15 Minimax, <= 2 ULP, Pure Swift IEEE-754)

extension SIMDMath {
    // MARK: - Public Logarithmic API

    /// Evaluates IEEE-754 natural logarithm `ln(x)` on `SIMD2<Double>` (`<= 2 ULP`).
    @inlinable
    @inline(__always)
    public static func log(_ x: SIMD2<Double>) -> SIMD2<Double> {
        let u = unsafeBitCast(x, to: SIMD2<UInt64>.self)
        if _slowPath(any((u &- 0x0010_0000_0000_0000) .>= 0x7FE0_0000_0000_0000)) {
            return logCold(x)
        }
        let (lnM, expInt) = mantissaLog(x)
        return combineNaturalLog(lnM: lnM, expInt: expInt)
    }

    /// Evaluates IEEE-754 natural logarithm `ln(x)` on `SIMD4<Double>` (`<= 2 ULP`).
    @inlinable
    @inline(__always)
    public static func log(_ x: SIMD4<Double>) -> SIMD4<Double> {
        let u = unsafeBitCast(x, to: SIMD4<UInt64>.self)
        if _slowPath(any((u &- 0x0010_0000_0000_0000) .>= 0x7FE0_0000_0000_0000)) {
            return logCold(x)
        }
        let (lnM, expInt) = mantissaLog(x)
        return combineNaturalLog(lnM: lnM, expInt: expInt)
    }

    /// Evaluates IEEE-754 natural logarithm `ln(x)` on `SIMD8<Double>` (`<= 2 ULP`).
    @inlinable
    @inline(__always)
    public static func log(_ x: SIMD8<Double>) -> SIMD8<Double> {
        SIMD8<Double>(lowHalf: log(x.lowHalf), highHalf: log(x.highHalf))
    }

    /// Evaluates IEEE-754 base-2 logarithm `log2(x)` on `SIMD2<Double>` (`<= 2 ULP`).
    @inlinable
    @inline(__always)
    public static func log2(_ x: SIMD2<Double>) -> SIMD2<Double> {
        let u = unsafeBitCast(x, to: SIMD2<UInt64>.self)
        if _slowPath(any((u &- 0x0010_0000_0000_0000) .>= 0x7FE0_0000_0000_0000)) {
            return log2Cold(x)
        }
        let (lnM, expInt) = mantissaLog(x)
        return combineLog2(lnM: lnM, expInt: expInt)
    }

    /// Evaluates IEEE-754 base-2 logarithm `log2(x)` on `SIMD4<Double>` (`<= 2 ULP`).
    @inlinable
    @inline(__always)
    public static func log2(_ x: SIMD4<Double>) -> SIMD4<Double> {
        let u = unsafeBitCast(x, to: SIMD4<UInt64>.self)
        if _slowPath(any((u &- 0x0010_0000_0000_0000) .>= 0x7FE0_0000_0000_0000)) {
            return log2Cold(x)
        }
        let (lnM, expInt) = mantissaLog(x)
        return combineLog2(lnM: lnM, expInt: expInt)
    }

    /// Evaluates IEEE-754 base-2 logarithm `log2(x)` on `SIMD8<Double>` (`<= 2 ULP`).
    @inlinable
    @inline(__always)
    public static func log2(_ x: SIMD8<Double>) -> SIMD8<Double> {
        SIMD8<Double>(lowHalf: log2(x.lowHalf), highHalf: log2(x.highHalf))
    }

    /// Evaluates IEEE-754 base-10 logarithm `log10(x)` on `SIMD2<Double>` (`<= 2 ULP`).
    @inlinable
    @inline(__always)
    public static func log10(_ x: SIMD2<Double>) -> SIMD2<Double> {
        let u = unsafeBitCast(x, to: SIMD2<UInt64>.self)
        if _slowPath(any((u &- 0x0010_0000_0000_0000) .>= 0x7FE0_0000_0000_0000)) {
            return log10Cold(x)
        }
        let (lnM, expInt) = mantissaLog(x)
        return combineLog10(lnM: lnM, expInt: expInt)
    }

    /// Evaluates IEEE-754 base-10 logarithm `log10(x)` on `SIMD4<Double>` (`<= 2 ULP`).
    @inlinable
    @inline(__always)
    public static func log10(_ x: SIMD4<Double>) -> SIMD4<Double> {
        let u = unsafeBitCast(x, to: SIMD4<UInt64>.self)
        if _slowPath(any((u &- 0x0010_0000_0000_0000) .>= 0x7FE0_0000_0000_0000)) {
            return log10Cold(x)
        }
        let (lnM, expInt) = mantissaLog(x)
        return combineLog10(lnM: lnM, expInt: expInt)
    }

    /// Evaluates IEEE-754 base-10 logarithm `log10(x)` on `SIMD8<Double>` (`<= 2 ULP`).
    @inlinable
    @inline(__always)
    public static func log10(_ x: SIMD8<Double>) -> SIMD8<Double> {
        SIMD8<Double>(lowHalf: log10(x.lowHalf), highHalf: log10(x.highHalf))
    }

    // MARK: - Core Mantissa Decomposition & Degree-15 Minimax Polynomial

    @inlinable
    @inline(__always)
    static func mantissaLog(_ x: SIMD2<Double>) -> (lnM: SIMD2<Double>, expInt: SIMD2<Double>) {
        let b = unsafeBitCast(x, to: SIMD2<Int64>.self)
        var expInt = SIMD2<Double>((b &>> 52) &- 1023)
        var m = unsafeBitCast((b & 0x000F_FFFF_FFFF_FFFF) | 0x3FF0_0000_0000_0000, to: SIMD2<Double>.self)

        let mask = m .> SIMD2<Double>(repeating: 1.4142135623730950488)
        m = m.replacing(with: m * 0.5, where: mask)
        expInt = expInt.replacing(with: expInt + SIMD2<Double>(repeating: 1.0), where: mask)

        let s = m - 1.0
        let z = s / (m + 1.0)
        let z2 = z * z
        let z4 = z2 * z2

        let p01 = SIMD2<Double>(repeating: 6.66666666666670960e-01)
            .addingProduct(z2, SIMD2<Double>(repeating: 3.99999999995201139e-01))
        let p23 = SIMD2<Double>(repeating: 2.85714287292042290e-01)
            .addingProduct(z2, SIMD2<Double>(repeating: 2.22221991003786201e-01))
        let p45 = SIMD2<Double>(repeating: 1.81835709984445926e-01)
            .addingProduct(z2, SIMD2<Double>(repeating: 1.53131792773929160e-01))
        let qHigh = p45.addingProduct(z4, SIMD2<Double>(repeating: 1.48103626398194216e-01))
        let q = p01.addingProduct(z4, p23).addingProduct(z4 * z4, qHigh)
        // Exact Sterbenz identity: 2z = s - s*z cuts division/addition rounding in z by ~5x.
        return (s.addingProduct(z, (-s).addingProduct(z2, q)), expInt)
    }

    @inlinable
    @inline(__always)
    static func mantissaLog(_ x: SIMD4<Double>) -> (lnM: SIMD4<Double>, expInt: SIMD4<Double>) {
        let b = unsafeBitCast(x, to: SIMD4<Int64>.self)
        var expInt = SIMD4<Double>((b &>> 52) &- 1023)
        var m = unsafeBitCast((b & 0x000F_FFFF_FFFF_FFFF) | 0x3FF0_0000_0000_0000, to: SIMD4<Double>.self)

        let mask = m .> SIMD4<Double>(repeating: 1.4142135623730950488)
        m = m.replacing(with: m * 0.5, where: mask)
        expInt = expInt.replacing(with: expInt + SIMD4<Double>(repeating: 1.0), where: mask)

        let s = m - 1.0
        let z = s / (m + 1.0)
        let z2 = z * z
        let z4 = z2 * z2

        let p01 = SIMD4<Double>(repeating: 6.66666666666670960e-01)
            .addingProduct(z2, SIMD4<Double>(repeating: 3.99999999995201139e-01))
        let p23 = SIMD4<Double>(repeating: 2.85714287292042290e-01)
            .addingProduct(z2, SIMD4<Double>(repeating: 2.22221991003786201e-01))
        let p45 = SIMD4<Double>(repeating: 1.81835709984445926e-01)
            .addingProduct(z2, SIMD4<Double>(repeating: 1.53131792773929160e-01))
        let qHigh = p45.addingProduct(z4, SIMD4<Double>(repeating: 1.48103626398194216e-01))
        let q = p01.addingProduct(z4, p23).addingProduct(z4 * z4, qHigh)
        // Exact Sterbenz identity: 2z = s - s*z cuts division/addition rounding in z by ~5x.
        return (s.addingProduct(z, (-s).addingProduct(z2, q)), expInt)
    }

    // MARK: - Double-Double Base Recombination

    @inlinable
    @inline(__always)
    static func combineNaturalLog(lnM: SIMD2<Double>, expInt: SIMD2<Double>) -> SIMD2<Double> {
        let ln2Hi = SIMD2<Double>(repeating: 6.93147180559945286e-01)
        let ln2Lo = SIMD2<Double>(repeating: 2.31904681384629956e-17)
        return lnM.addingProduct(expInt, ln2Lo).addingProduct(expInt, ln2Hi)
    }

    @inlinable
    @inline(__always)
    static func combineNaturalLog(lnM: SIMD4<Double>, expInt: SIMD4<Double>) -> SIMD4<Double> {
        let ln2Hi = SIMD4<Double>(repeating: 6.93147180559945286e-01)
        let ln2Lo = SIMD4<Double>(repeating: 2.31904681384629956e-17)
        return lnM.addingProduct(expInt, ln2Lo).addingProduct(expInt, ln2Hi)
    }

    @inlinable
    @inline(__always)
    static func combineLog2(lnM: SIMD2<Double>, expInt: SIMD2<Double>) -> SIMD2<Double> {
        let invLn2Hi = SIMD2<Double>(repeating: 1.44269504088896339e+00)
        let invLn2Lo = SIMD2<Double>(repeating: 2.03552737409310331e-17)
        return expInt + (lnM * invLn2Lo).addingProduct(lnM, invLn2Hi)
    }

    @inlinable
    @inline(__always)
    static func combineLog2(lnM: SIMD4<Double>, expInt: SIMD4<Double>) -> SIMD4<Double> {
        let invLn2Hi = SIMD4<Double>(repeating: 1.44269504088896339e+00)
        let invLn2Lo = SIMD4<Double>(repeating: 2.03552737409310331e-17)
        return expInt + (lnM * invLn2Lo).addingProduct(lnM, invLn2Hi)
    }

    @inlinable
    @inline(__always)
    static func combineLog10(lnM: SIMD2<Double>, expInt: SIMD2<Double>) -> SIMD2<Double> {
        let log10Of2Hi = SIMD2<Double>(repeating: 3.01029995663981198e-01)
        let log10Of2Lo = SIMD2<Double>(repeating: -2.80372812778517039e-18)
        let invLn10Hi = SIMD2<Double>(repeating: 4.34294481903251817e-01)
        let invLn10Lo = SIMD2<Double>(repeating: 1.09831965021676507e-17)
        let eHi = expInt * log10Of2Hi
        let eLo = (-eHi).addingProduct(expInt, log10Of2Hi).addingProduct(expInt, log10Of2Lo)
        return eHi + eLo.addingProduct(lnM, invLn10Lo).addingProduct(lnM, invLn10Hi)
    }

    @inlinable
    @inline(__always)
    static func combineLog10(lnM: SIMD4<Double>, expInt: SIMD4<Double>) -> SIMD4<Double> {
        let log10Of2Hi = SIMD4<Double>(repeating: 3.01029995663981198e-01)
        let log10Of2Lo = SIMD4<Double>(repeating: -2.80372812778517039e-18)
        let invLn10Hi = SIMD4<Double>(repeating: 4.34294481903251817e-01)
        let invLn10Lo = SIMD4<Double>(repeating: 1.09831965021676507e-17)
        let eHi = expInt * log10Of2Hi
        let eLo = (-eHi).addingProduct(expInt, log10Of2Hi).addingProduct(expInt, log10Of2Lo)
        return eHi + eLo.addingProduct(lnM, invLn10Lo).addingProduct(lnM, invLn10Hi)
    }
}
