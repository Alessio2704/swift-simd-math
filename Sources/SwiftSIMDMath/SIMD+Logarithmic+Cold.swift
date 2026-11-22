// MARK: - Pure-Swift Vectorized Cold Paths for log/log2/log10 (Subnormals, <= 0, Inf, NaN)

extension SIMDMath {
    @usableFromInline
    @inline(never)
    static func logCold(_ x: SIMD2<Double>) -> SIMD2<Double> {
        let (lnM, expInt) = mantissaLogWithSubnormals(x)
        return finalizeLogCold(x: x, finiteResult: combineNaturalLog(lnM: lnM, expInt: expInt))
    }

    @usableFromInline
    @inline(never)
    static func logCold(_ x: SIMD4<Double>) -> SIMD4<Double> {
        let (lnM, expInt) = mantissaLogWithSubnormals(x)
        return finalizeLogCold(x: x, finiteResult: combineNaturalLog(lnM: lnM, expInt: expInt))
    }

    @usableFromInline
    @inline(never)
    static func log2Cold(_ x: SIMD2<Double>) -> SIMD2<Double> {
        let (lnM, expInt) = mantissaLogWithSubnormals(x)
        return finalizeLogCold(x: x, finiteResult: combineLog2(lnM: lnM, expInt: expInt))
    }

    @usableFromInline
    @inline(never)
    static func log2Cold(_ x: SIMD4<Double>) -> SIMD4<Double> {
        let (lnM, expInt) = mantissaLogWithSubnormals(x)
        return finalizeLogCold(x: x, finiteResult: combineLog2(lnM: lnM, expInt: expInt))
    }

    @usableFromInline
    @inline(never)
    static func log10Cold(_ x: SIMD2<Double>) -> SIMD2<Double> {
        let (lnM, expInt) = mantissaLogWithSubnormals(x)
        return finalizeLogCold(x: x, finiteResult: combineLog10(lnM: lnM, expInt: expInt))
    }

    @usableFromInline
    @inline(never)
    static func log10Cold(_ x: SIMD4<Double>) -> SIMD4<Double> {
        let (lnM, expInt) = mantissaLogWithSubnormals(x)
        return finalizeLogCold(x: x, finiteResult: combineLog10(lnM: lnM, expInt: expInt))
    }

    // MARK: - Vectorized Subnormal Normalization & Special-Value Masking

    @inline(__always)
    private static func mantissaLogWithSubnormals(_ x: SIMD2<Double>) -> (lnM: SIMD2<Double>, expInt: SIMD2<Double>) {
        let u = unsafeBitCast(x, to: SIMD2<UInt64>.self)
        let isSubnormal = (u .> 0) .& (u .< 0x0010_0000_0000_0000)
        let isPosFinite = (u .> 0) .& (u .< 0x7FF0_0000_0000_0000)
        let scaled = x.replacing(with: x * SIMD2<Double>(repeating: 0x1.0p54), where: isSubnormal)
        let safeX = scaled.replacing(with: SIMD2<Double>(repeating: 1.0), where: .!isPosFinite)
        let (lnM, rawExp) = mantissaLog(safeX)
        let expInt = rawExp.replacing(with: rawExp - SIMD2<Double>(repeating: 54.0), where: isSubnormal)
        return (lnM, expInt)
    }

    @inline(__always)
    private static func mantissaLogWithSubnormals(_ x: SIMD4<Double>) -> (lnM: SIMD4<Double>, expInt: SIMD4<Double>) {
        let u = unsafeBitCast(x, to: SIMD4<UInt64>.self)
        let isSubnormal = (u .> 0) .& (u .< 0x0010_0000_0000_0000)
        let isPosFinite = (u .> 0) .& (u .< 0x7FF0_0000_0000_0000)
        let scaled = x.replacing(with: x * SIMD4<Double>(repeating: 0x1.0p54), where: isSubnormal)
        let safeX = scaled.replacing(with: SIMD4<Double>(repeating: 1.0), where: .!isPosFinite)
        let (lnM, rawExp) = mantissaLog(safeX)
        let expInt = rawExp.replacing(with: rawExp - SIMD4<Double>(repeating: 54.0), where: isSubnormal)
        return (lnM, expInt)
    }

    @inline(__always)
    private static func finalizeLogCold(x: SIMD2<Double>, finiteResult: SIMD2<Double>) -> SIMD2<Double> {
        let isZero = x .== .zero
        let isNeg = x .< .zero
        let isPosInf = x .== SIMD2<Double>(repeating: .infinity)
        let isNaN = x .!= x

        var result = finiteResult
        result = result.replacing(with: SIMD2<Double>(repeating: -.infinity), where: isZero)
        result = result.replacing(with: SIMD2<Double>(repeating: .nan), where: isNeg)
        result = result.replacing(with: SIMD2<Double>(repeating: .infinity), where: isPosInf)
        result = result.replacing(with: x + x, where: isNaN)
        return result
    }

    @inline(__always)
    private static func finalizeLogCold(x: SIMD4<Double>, finiteResult: SIMD4<Double>) -> SIMD4<Double> {
        let isZero = x .== .zero
        let isNeg = x .< .zero
        let isPosInf = x .== SIMD4<Double>(repeating: .infinity)
        let isNaN = x .!= x

        var result = finiteResult
        result = result.replacing(with: SIMD4<Double>(repeating: -.infinity), where: isZero)
        result = result.replacing(with: SIMD4<Double>(repeating: .nan), where: isNeg)
        result = result.replacing(with: SIMD4<Double>(repeating: .infinity), where: isPosInf)
        result = result.replacing(with: x + x, where: isNaN)
        return result
    }
}
