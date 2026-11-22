// MARK: - SIMD High-Precision log1p(x) = ln(1 + x) (<= 2 ULP, Exact TwoSum Reduction)

extension SIMDMath {
    /// Evaluates IEEE-754 `log1p(x) = ln(1 + x)` on `SIMD2<Double>` (`<= 2 ULP`).
    @inlinable
    @inline(__always)
    public static func log1p(_ x: SIMD2<Double>) -> SIMD2<Double> {
        log1p(SIMD4<Double>(lowHalf: x, highHalf: x)).lowHalf
    }

    /// Evaluates IEEE-754 `log1p(x) = ln(1 + x)` on `SIMD4<Double>` (`<= 2 ULP`).
    @inlinable
    @inline(__always)
    public static func log1p(_ x: SIMD4<Double>) -> SIMD4<Double> {
        let isValid = (x .> SIMD4<Double>(repeating: -1.0)) .& (x .< SIMD4<Double>(repeating: .infinity))
        if _slowPath(any(.!isValid)) {
            return log1pCold(x)
        }
        return log1pFast(x)
    }

    /// Evaluates IEEE-754 `log1p(x) = ln(1 + x)` on `SIMD8<Double>` (`<= 2 ULP`).
    @inlinable
    @inline(__always)
    public static func log1p(_ x: SIMD8<Double>) -> SIMD8<Double> {
        SIMD8<Double>(lowHalf: log1p(x.lowHalf), highHalf: log1p(x.highHalf))
    }

    // MARK: - Exact Knuth/TwoSum Fast Path & Cold Special-Value Path

    @inlinable
    @inline(__always)
    static func log1pFast(_ x: SIMD4<Double>) -> SIMD4<Double> {
        let one = SIMD4<Double>(repeating: 1.0)
        let u = one + x
        let large = x .>= one
        let cSmall = x - (u - one)
        let cLarge = one - (u - x)
        let c = cSmall.replacing(with: cLarge, where: large)

        // When u == 1.0 (|x| <= 2^-54, including -0.0 and subnormals), log1p(x) == x bit-exact.
        // When u == +inf (x near greatestFiniteMagnitude), evaluate log(x) directly.
        let (lnM, expInt) = mantissaLog(u)
        let lnU = combineNaturalLog(lnM: lnM + c / u, expInt: expInt)
        return lnU.replacing(with: x, where: u .== one)
    }

    @usableFromInline
    @inline(never)
    static func log1pCold(_ x: SIMD4<Double>) -> SIMD4<Double> {
        let one = SIMD4<Double>(repeating: 1.0)
        let isNegOne = x .== SIMD4<Double>(repeating: -1.0)
        let isLess = x .< SIMD4<Double>(repeating: -1.0)
        let isPosInf = x .== SIMD4<Double>(repeating: .infinity)
        let isNaN = x .!= x
        let isHuge = x .> SIMD4<Double>(repeating: 0x1.0p1020)

        let safeX = x.replacing(with: 0.0, where: isNegOne .| isLess .| isPosInf .| isNaN .| isHuge)
        var result = log1pFast(safeX)
        if any(isHuge) {
            let hugeLog = log(x.replacing(with: one, where: .!isHuge))
            result = result.replacing(with: hugeLog, where: isHuge)
        }
        result = result.replacing(with: SIMD4<Double>(repeating: -.infinity), where: isNegOne)
        result = result.replacing(with: SIMD4<Double>(repeating: .nan), where: isLess)
        result = result.replacing(with: SIMD4<Double>(repeating: .infinity), where: isPosInf)
        result = result.replacing(with: x + x, where: isNaN)
        return result
    }
}
