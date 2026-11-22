// MARK: - Pure-Swift Vectorized Cold Paths for exp2, exp10, and expm1

extension SIMDMath {
    @usableFromInline
    @inline(never)
    static func exp2Cold(_ x: SIMD4<Double>) -> SIMD4<Double> {
        let isNaN = x .!= x
        let isOverflow = x .>= SIMD4<Double>(repeating: 1024.0)
        let isUnderflow = x .< SIMD4<Double>(repeating: -1076.0)
        let safeX = x.replacing(with: 0.0, where: isNaN .| isOverflow .| isUnderflow)

        let k = safeX.rounded(.toNearestOrAwayFromZero)
        let f = safeX - k
        let expF = exp2Poly(f)
        var result = splitScalePow2(expF, k: k)
        result = result.replacing(with: SIMD4<Double>(repeating: .infinity), where: isOverflow)
        result = result.replacing(with: 0.0, where: isUnderflow)
        result = result.replacing(with: x + x, where: isNaN)
        return result
    }

    @usableFromInline
    @inline(never)
    static func exp10Cold(_ x: SIMD4<Double>) -> SIMD4<Double> {
        let isNaN = x .!= x
        let isOverflow = x .> SIMD4<Double>(repeating: 309.0)
        let isUnderflow = x .< SIMD4<Double>(repeating: -325.0)
        let safeX = x.replacing(with: 0.0, where: isNaN .| isOverflow .| isUnderflow)

        let invLog10Of2 = SIMD4<Double>(repeating: 3.32192809488736218e+00)
        let log10Of2Hi = SIMD4<Double>(repeating: 0x1.34413509f6000p-2)
        let log10Of2Lo = SIMD4<Double>(repeating: 0x1.9fef311f12b36p-42)
        let log10Of2Tail = SIMD4<Double>(repeating: -0x1.fa41b743eca96p-96)
        let k = (safeX * invLog10Of2).rounded(.toNearestOrAwayFromZero)
        let t1 = safeX.addingProduct(-k, log10Of2Hi)
        let f = t1.addingProduct(-k, log10Of2Lo)
        let fLo = (t1 - f).addingProduct(-k, log10Of2Lo).addingProduct(-k, log10Of2Tail)
        let expF = exp10Poly(f, fLo: fLo)
        var result = splitScalePow2(expF, k: k)
        result = result.replacing(with: SIMD4<Double>(repeating: .infinity), where: isOverflow)
        result = result.replacing(with: 0.0, where: isUnderflow)
        result = result.replacing(with: x + x, where: isNaN)
        return result
    }

    @usableFromInline
    @inline(never)
    static func expm1Cold(_ x: SIMD4<Double>) -> SIMD4<Double> {
        let absBits = unsafeBitCast(x, to: SIMD4<UInt64>.self) & 0x7FFF_FFFF_FFFF_FFFF
        let isFastLane = absBits .< 0x4086_2000_0000_0000
        let fastResult = expm1Fast(x.replacing(with: 0.0, where: .!isFastLane))

        let isNaN = x .!= x
        let isOverflow = x .> SIMD4<Double>(repeating: 715.0)
        let isUnderflow = x .< SIMD4<Double>(repeating: -40.0)
        let safeX = x.replacing(with: 0.0, where: isNaN .| isOverflow .| isUnderflow .| isFastLane)

        let invLn2 = SIMD4<Double>(repeating: 1.4426950408889634)
        let ln2Hi = SIMD4<Double>(repeating: 6.93147180559945286e-01)
        let ln2Lo = SIMD4<Double>(repeating: 2.31904681384629956e-17)
        let k = (safeX * invLn2).rounded(.toNearestOrAwayFromZero)
        let r = safeX.addingProduct(-k, ln2Hi).addingProduct(-k, ln2Lo)
        let p = expm1Poly(r)

        let expScaled = splitScalePow2(SIMD4<Double>(repeating: 1.0) + p, k: k)
        var result = expScaled - SIMD4<Double>(repeating: 1.0)
        result = result.replacing(with: fastResult, where: isFastLane)
        result = result.replacing(with: SIMD4<Double>(repeating: .infinity), where: isOverflow)
        result = result.replacing(with: SIMD4<Double>(repeating: -1.0), where: isUnderflow)
        result = result.replacing(with: x + x, where: isNaN)
        return result
    }

    @inline(__always)
    static func splitScalePow2(_ value: SIMD4<Double>, k: SIMD4<Double>) -> SIMD4<Double> {
        let k1 = (k * 0.5).rounded(.toNearestOrAwayFromZero)
        let k2 = k - k1
        let magic = SIMD4<Double>(repeating: 6_755_399_441_055_744.0)
        let bits1 = unsafeBitCast(k1 + magic, to: SIMD4<Int64>.self)
        let bits2 = unsafeBitCast(k2 + magic, to: SIMD4<Int64>.self)
        let scale1 = unsafeBitCast((bits1 &<< 52) &+ (1023 << 52), to: SIMD4<Double>.self)
        let scale2 = unsafeBitCast((bits2 &<< 52) &+ (1023 << 52), to: SIMD4<Double>.self)
        return (value * scale1) * scale2
    }
}
