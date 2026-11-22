// MARK: - Pure-Swift Vectorized Cold Paths for exp (Overflow, Subnormals, Underflow, NaN)

extension SIMDMath {
    /// Vectorized split-scale `exp(x)` exact across overflow, all 52 subnormal exponents,
    /// underflow to `+0.0`, `±Inf`, and quiet/signaling `NaN`.
    @usableFromInline
    @inline(never)
    static func expCold(_ x: SIMD2<Double>) -> SIMD2<Double> {
        let isNaN = x .!= x
        let isOverflow = x .> SIMD2<Double>(repeating: 715.0)
        let isUnderflow = x .< SIMD2<Double>(repeating: -750.0)
        let safeX = x.replacing(with: 0.0, where: isNaN .| isOverflow .| isUnderflow)

        let invLn2 = SIMD2<Double>(repeating: 1.4426950408889634)
        let ln2Hi = SIMD2<Double>(repeating: 6.93147180559945286e-01)
        let ln2Lo = SIMD2<Double>(repeating: 2.31904681384629956e-17)

        let k = (safeX * invLn2).rounded(.toNearestOrAwayFromZero)
        let r = safeX.addingProduct(-k, ln2Hi).addingProduct(-k, ln2Lo)
        let expR = expPoly(r)

        let k1 = (k * 0.5).rounded(.toNearestOrAwayFromZero)
        let k2 = k - k1
        let magic = SIMD2<Double>(repeating: 6_755_399_441_055_744.0)
        let bits1 = unsafeBitCast(k1 + magic, to: SIMD2<Int64>.self)
        let bits2 = unsafeBitCast(k2 + magic, to: SIMD2<Int64>.self)
        let scale1 = unsafeBitCast((bits1 &<< 52) &+ (1023 << 52), to: SIMD2<Double>.self)
        let scale2 = unsafeBitCast((bits2 &<< 52) &+ (1023 << 52), to: SIMD2<Double>.self)

        var result = (expR * scale1) * scale2
        result = result.replacing(with: SIMD2<Double>(repeating: .infinity), where: isOverflow)
        result = result.replacing(with: 0.0, where: isUnderflow)
        result = result.replacing(with: x + x, where: isNaN)
        return result
    }

    /// Vectorized split-scale `exp(x)` on `SIMD4<Double>`.
    @usableFromInline
    @inline(never)
    static func expCold(_ x: SIMD4<Double>) -> SIMD4<Double> {
        let isNaN = x .!= x
        let isOverflow = x .> SIMD4<Double>(repeating: 715.0)
        let isUnderflow = x .< SIMD4<Double>(repeating: -750.0)
        let safeX = x.replacing(with: 0.0, where: isNaN .| isOverflow .| isUnderflow)

        let invLn2 = SIMD4<Double>(repeating: 1.4426950408889634)
        let ln2Hi = SIMD4<Double>(repeating: 6.93147180559945286e-01)
        let ln2Lo = SIMD4<Double>(repeating: 2.31904681384629956e-17)

        let k = (safeX * invLn2).rounded(.toNearestOrAwayFromZero)
        let r = safeX.addingProduct(-k, ln2Hi).addingProduct(-k, ln2Lo)
        let expR = expPoly(r)

        let k1 = (k * 0.5).rounded(.toNearestOrAwayFromZero)
        let k2 = k - k1
        let magic = SIMD4<Double>(repeating: 6_755_399_441_055_744.0)
        let bits1 = unsafeBitCast(k1 + magic, to: SIMD4<Int64>.self)
        let bits2 = unsafeBitCast(k2 + magic, to: SIMD4<Int64>.self)
        let scale1 = unsafeBitCast((bits1 &<< 52) &+ (1023 << 52), to: SIMD4<Double>.self)
        let scale2 = unsafeBitCast((bits2 &<< 52) &+ (1023 << 52), to: SIMD4<Double>.self)

        var result = (expR * scale1) * scale2
        result = result.replacing(with: SIMD4<Double>(repeating: .infinity), where: isOverflow)
        result = result.replacing(with: 0.0, where: isUnderflow)
        result = result.replacing(with: x + x, where: isNaN)
        return result
    }
}
