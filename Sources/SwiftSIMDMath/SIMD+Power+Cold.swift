// MARK: - Pure-Swift Vectorized Cold Path for IEEE-754-2019 §9.2.1 pow(x, y)

extension SIMDMath {
    @usableFromInline
    @inline(never)
    static func powCold(_ x: SIMD2<Double>, _ y: SIMD2<Double>) -> SIMD2<Double> {
        let absX = abs(x)
        let absY = abs(y)
        let isNaN = (x .!= x) .| (y .!= y)
        let isZeroY = y .== .zero
        let isOneX = x .== SIMD2<Double>(repeating: 1.0)
        let isNegOneX = x .== SIMD2<Double>(repeating: -1.0)
        let isZeroX = x .== .zero
        let isInfX = absX .== SIMD2<Double>(repeating: .infinity)
        let isInfY = absY .== SIMD2<Double>(repeating: .infinity)
        let isNegX = (unsafeBitCast(x, to: SIMD2<UInt64>.self) &>> 63) .!= 0

        let isIntY = (.!isInfY) .& (y .== y.rounded(.towardZero))
        let halfY = y * 0.5
        let isOddIntY =
            isIntY .& (absY .< SIMD2<Double>(repeating: 9_007_199_254_740_992.0))
            .& (halfY .!= halfY.rounded(.towardZero))

        let mag = powPositiveMagnitude(absX: absX, y: y)
        var result = flipSignBit(mag, where: isNegX .& isOddIntY)
        result = result.replacing(with: SIMD2<Double>(repeating: .nan), where: isNegX .& (.!isIntY))

        let infYPos = SIMD2<Double>(repeating: .infinity)
        let zeroPos = SIMD2<Double>.zero
        let gtOne = absX .> SIMD2<Double>(repeating: 1.0)
        let yPos = y .> .zero

        let yPosInfRes = zeroPos.replacing(with: infYPos, where: gtOne)
        let yNegInfRes = infYPos.replacing(with: zeroPos, where: gtOne)
        result = result.replacing(with: yPosInfRes, where: isInfY .& yPos)
        result = result.replacing(with: yNegInfRes, where: isInfY .& (.!yPos))
        result = result.replacing(with: SIMD2<Double>(repeating: 1.0), where: isNegOneX .& isInfY)

        let zeroXRes = flipSignBit(zeroPos.replacing(with: infYPos, where: .!yPos), where: isNegX .& isOddIntY)
        result = result.replacing(with: zeroXRes, where: isZeroX .& (.!isInfY))

        let infXRes = flipSignBit(zeroPos.replacing(with: infYPos, where: yPos), where: isNegX .& isOddIntY)
        result = result.replacing(with: infXRes, where: isInfX .& (.!isInfY))

        let xAbsBits = unsafeBitCast(x, to: SIMD2<UInt64>.self) & 0x7FFF_FFFF_FFFF_FFFF
        let yAbsBits = unsafeBitCast(y, to: SIMD2<UInt64>.self) & 0x7FFF_FFFF_FFFF_FFFF
        let isSignalingNaN =
            ((xAbsBits .> 0x7FF0_0000_0000_0000) .& ((xAbsBits & 0x0008_0000_0000_0000) .== 0))
            .| ((yAbsBits .> 0x7FF0_0000_0000_0000) .& ((yAbsBits & 0x0008_0000_0000_0000) .== 0))

        result = result.replacing(with: x + y, where: isNaN)
        result = result.replacing(with: SIMD2<Double>(repeating: 1.0), where: isOneX .| isZeroY)
        result = result.replacing(with: x + y, where: isSignalingNaN)
        return result
    }

    @usableFromInline
    @inline(never)
    static func powCold(_ x: SIMD4<Double>, _ y: SIMD4<Double>) -> SIMD4<Double> {
        let absX = abs(x)
        let absY = abs(y)
        let isNaN = (x .!= x) .| (y .!= y)
        let isZeroY = y .== .zero
        let isOneX = x .== SIMD4<Double>(repeating: 1.0)
        let isNegOneX = x .== SIMD4<Double>(repeating: -1.0)
        let isZeroX = x .== .zero
        let isInfX = absX .== SIMD4<Double>(repeating: .infinity)
        let isInfY = absY .== SIMD4<Double>(repeating: .infinity)
        let isNegX = (unsafeBitCast(x, to: SIMD4<UInt64>.self) &>> 63) .!= 0

        let isIntY = (.!isInfY) .& (y .== y.rounded(.towardZero))
        let halfY = y * 0.5
        let isOddIntY =
            isIntY .& (absY .< SIMD4<Double>(repeating: 9_007_199_254_740_992.0))
            .& (halfY .!= halfY.rounded(.towardZero))

        let mag = powPositiveMagnitude(absX: absX, y: y)
        var result = flipSignBit(mag, where: isNegX .& isOddIntY)
        result = result.replacing(with: SIMD4<Double>(repeating: .nan), where: isNegX .& (.!isIntY))

        let infYPos = SIMD4<Double>(repeating: .infinity)
        let zeroPos = SIMD4<Double>.zero
        let gtOne = absX .> SIMD4<Double>(repeating: 1.0)
        let yPos = y .> .zero

        let yPosInfRes = zeroPos.replacing(with: infYPos, where: gtOne)
        let yNegInfRes = infYPos.replacing(with: zeroPos, where: gtOne)
        result = result.replacing(with: yPosInfRes, where: isInfY .& yPos)
        result = result.replacing(with: yNegInfRes, where: isInfY .& (.!yPos))
        result = result.replacing(with: SIMD4<Double>(repeating: 1.0), where: isNegOneX .& isInfY)

        let zeroXRes = flipSignBit(zeroPos.replacing(with: infYPos, where: .!yPos), where: isNegX .& isOddIntY)
        result = result.replacing(with: zeroXRes, where: isZeroX .& (.!isInfY))

        let infXRes = flipSignBit(zeroPos.replacing(with: infYPos, where: yPos), where: isNegX .& isOddIntY)
        result = result.replacing(with: infXRes, where: isInfX .& (.!isInfY))

        let xAbsBits = unsafeBitCast(x, to: SIMD4<UInt64>.self) & 0x7FFF_FFFF_FFFF_FFFF
        let yAbsBits = unsafeBitCast(y, to: SIMD4<UInt64>.self) & 0x7FFF_FFFF_FFFF_FFFF
        let isSignalingNaN =
            ((xAbsBits .> 0x7FF0_0000_0000_0000) .& ((xAbsBits & 0x0008_0000_0000_0000) .== 0))
            .| ((yAbsBits .> 0x7FF0_0000_0000_0000) .& ((yAbsBits & 0x0008_0000_0000_0000) .== 0))

        result = result.replacing(with: x + y, where: isNaN)
        result = result.replacing(with: SIMD4<Double>(repeating: 1.0), where: isOneX .| isZeroY)
        result = result.replacing(with: x + y, where: isSignalingNaN)
        return result
    }

    // MARK: - Vectorized Subnormal Log2 + Split-Scale Exp2 Helpers

    @inline(__always)
    private static func powPositiveMagnitude(absX: SIMD2<Double>, y: SIMD2<Double>) -> SIMD2<Double> {
        let u = unsafeBitCast(absX, to: SIMD2<UInt64>.self)
        let isSubnormal = (u .> 0) .& (u .< 0x0010_0000_0000_0000)
        let isFinitePos = (u .> 0) .& (u .< 0x7FF0_0000_0000_0000)
        let scaled = absX.replacing(with: absX * SIMD2<Double>(repeating: 0x1.0p54), where: isSubnormal)
        let safeX = scaled.replacing(with: 1.0, where: .!isFinitePos)
        let adj = SIMD2<Double>.zero.replacing(with: -54.0, where: isSubnormal)

        let (log2Hi, log2Lo) = log2HiLoTable(bits: unsafeBitCast(safeX, to: SIMD2<UInt64>.self), expAdjust: adj)
        let safeY = y.replacing(with: 0.0, where: (abs(y) .== SIMD2<Double>(repeating: .infinity)) .| (y .!= y))
        let pHi = safeY * log2Hi
        let pLo = (-pHi).addingProduct(safeY, log2Hi).addingProduct(safeY, log2Lo)
        return exp2SplitScale(hi: pHi, lo: pLo)
    }

    @inline(__always)
    private static func powPositiveMagnitude(absX: SIMD4<Double>, y: SIMD4<Double>) -> SIMD4<Double> {
        let u = unsafeBitCast(absX, to: SIMD4<UInt64>.self)
        let isSubnormal = (u .> 0) .& (u .< 0x0010_0000_0000_0000)
        let isFinitePos = (u .> 0) .& (u .< 0x7FF0_0000_0000_0000)
        let scaled = absX.replacing(with: absX * SIMD4<Double>(repeating: 0x1.0p54), where: isSubnormal)
        let safeX = scaled.replacing(with: 1.0, where: .!isFinitePos)
        let adj = SIMD4<Double>.zero.replacing(with: -54.0, where: isSubnormal)

        let (log2Hi, log2Lo) = log2HiLoTable(bits: unsafeBitCast(safeX, to: SIMD4<UInt64>.self), expAdjust: adj)
        let safeY = y.replacing(with: 0.0, where: (abs(y) .== SIMD4<Double>(repeating: .infinity)) .| (y .!= y))
        let pHi = safeY * log2Hi
        let pLo = (-pHi).addingProduct(safeY, log2Hi).addingProduct(safeY, log2Lo)
        return exp2SplitScale(hi: pHi, lo: pLo)
    }

    @inline(__always)
    private static func exp2SplitScale(hi: SIMD2<Double>, lo: SIMD2<Double>) -> SIMD2<Double> {
        let isNaN = hi .!= hi
        let isOverflow = hi .> SIMD2<Double>(repeating: 1030.0)
        let isUnderflow = hi .< SIMD2<Double>(repeating: -1080.0)
        let isSpecial = isNaN .| isOverflow .| isUnderflow

        let safeHi = hi.replacing(with: 0.0, where: isSpecial)
        let safeLo = lo.replacing(with: 0.0, where: isSpecial)
        let n = (safeHi * 128.0).rounded(.toNearestOrAwayFromZero)
        let f = safeHi.addingProduct(-n, SIMD2<Double>(repeating: 1.0 / 128.0)) + safeLo
        let poly = exp2PolyMinusOne(f)
        let nInt =
            unsafeBitCast(n + SIMD2<Double>(repeating: 6_755_399_441_055_744.0), to: SIMD2<Int64>.self)
            &- 0x4338_0000_0000_0000
        let j = nInt & 127
        let k = nInt &>> 7
        let k1 = k &>> 1
        let k2 = k &- k1
        let s = SIMD2(powerExpTable[Int(j[0])], powerExpTable[Int(j[1])])
        let scale1 = unsafeBitCast((k1 &<< 52) &+ (1023 << 52), to: SIMD2<Double>.self)
        let scale2 = unsafeBitCast((k2 &<< 52) &+ (1023 << 52), to: SIMD2<Double>.self)

        var result = (s.addingProduct(s, poly) * scale1) * scale2
        result = result.replacing(with: SIMD2<Double>(repeating: .infinity), where: isOverflow)
        result = result.replacing(with: 0.0, where: isUnderflow)
        result = result.replacing(with: hi + hi, where: isNaN)
        return result
    }

    @inline(__always)
    private static func exp2SplitScale(hi: SIMD4<Double>, lo: SIMD4<Double>) -> SIMD4<Double> {
        let isNaN = hi .!= hi
        let isOverflow = hi .> SIMD4<Double>(repeating: 1030.0)
        let isUnderflow = hi .< SIMD4<Double>(repeating: -1080.0)
        let isSpecial = isNaN .| isOverflow .| isUnderflow

        let safeHi = hi.replacing(with: 0.0, where: isSpecial)
        let safeLo = lo.replacing(with: 0.0, where: isSpecial)
        let n = (safeHi * 128.0).rounded(.toNearestOrAwayFromZero)
        let f = safeHi.addingProduct(-n, SIMD4<Double>(repeating: 1.0 / 128.0)) + safeLo
        let poly = exp2PolyMinusOne(f)
        let nInt =
            unsafeBitCast(n + SIMD4<Double>(repeating: 6_755_399_441_055_744.0), to: SIMD4<Int64>.self)
            &- 0x4338_0000_0000_0000
        let j = nInt & 127
        let k = nInt &>> 7
        let k1 = k &>> 1
        let k2 = k &- k1
        let s = SIMD4(
            powerExpTable[Int(j[0])], powerExpTable[Int(j[1])],
            powerExpTable[Int(j[2])], powerExpTable[Int(j[3])]
        )
        let scale1 = unsafeBitCast((k1 &<< 52) &+ (1023 << 52), to: SIMD4<Double>.self)
        let scale2 = unsafeBitCast((k2 &<< 52) &+ (1023 << 52), to: SIMD4<Double>.self)

        var result = (s.addingProduct(s, poly) * scale1) * scale2
        result = result.replacing(with: SIMD4<Double>(repeating: .infinity), where: isOverflow)
        result = result.replacing(with: 0.0, where: isUnderflow)
        result = result.replacing(with: hi + hi, where: isNaN)
        return result
    }

    @inline(__always)
    private static func flipSignBit(_ v: SIMD2<Double>, where mask: SIMDMask<SIMD2<Int64>>) -> SIMD2<Double> {
        let flipped = unsafeBitCast(
            unsafeBitCast(v, to: SIMD2<UInt64>.self) ^ 0x8000_0000_0000_0000, to: SIMD2<Double>.self)
        return v.replacing(with: flipped, where: mask)
    }

    @inline(__always)
    private static func flipSignBit(_ v: SIMD4<Double>, where mask: SIMDMask<SIMD4<Int64>>) -> SIMD4<Double> {
        let flipped = unsafeBitCast(
            unsafeBitCast(v, to: SIMD4<UInt64>.self) ^ 0x8000_0000_0000_0000, to: SIMD4<Double>.self)
        return v.replacing(with: flipped, where: mask)
    }
}
