// MARK: - SIMD Pi-Scaled Trig: Dual sincospi Kernel & Large-Argument Cold Paths

extension SIMDMath {
    @inlinable
    @inline(__always)
    static func sincospiFast(_ x: SIMD4<Double>) -> (sin: SIMD4<Double>, cos: SIMD4<Double>) {
        let y = x + x
        let q = y.rounded(.toNearestOrAwayFromZero)
        let f = y - q
        let (sinR, cosR) = evalPiQuarterSinCos(f)

        let magic = SIMD4<Double>(repeating: 6_755_399_441_055_744.0)
        let qInt = unsafeBitCast(q + magic, to: SIMD4<Int64>.self)
        let swapMask = (qInt & SIMD4<Int64>(repeating: 1)) .!= .zero

        let rawSin = sinR.replacing(with: cosR, where: swapMask)
        let rawCos = cosR.replacing(with: sinR, where: swapMask)

        let two = SIMD4<Int64>(repeating: 2)
        let sinSign = (qInt & two) &<< 62
        let cosSign = ((qInt &+ 1) & two) &<< 62

        let zero = SIMD4<Double>.zero
        let sinOut = unsafeBitCast(unsafeBitCast(rawSin, to: SIMD4<Int64>.self) ^ sinSign, to: SIMD4<Double>.self)
            .replacing(with: x * zero, where: rawSin .== 0.0)
        let cosOut =
            unsafeBitCast(unsafeBitCast(rawCos, to: SIMD4<Int64>.self) ^ cosSign, to: SIMD4<Double>.self)
            + zero
        return (sinOut, cosOut)
    }

    @inlinable
    @inline(__always)
    static func evalPiQuarterSinCos(_ f: SIMD4<Double>) -> (SIMD4<Double>, SIMD4<Double>) {
        let f2 = f * f
        let f4 = f2 * f2

        let halfPiHi = SIMD4<Double>(repeating: 1.57079632679489656e+00)
        let halfPiLo = SIMD4<Double>(repeating: 6.12323399573676604e-17)
        let s01 = SIMD4<Double>(repeating: -6.45964097506246171e-01)
            .addingProduct(f2, SIMD4<Double>(repeating: 7.96926262461442325e-02))
        let s23 = SIMD4<Double>(repeating: -4.68175413425420735e-03)
            .addingProduct(f2, SIMD4<Double>(repeating: 1.60441166614094230e-04))
        let s45 = SIMD4<Double>(repeating: -3.59870295097351049e-06)
            .addingProduct(f2, SIMD4<Double>(repeating: 5.64222536916352820e-08))
        let ps = s01.addingProduct(f4, s23.addingProduct(f4, s45))
        let sinTail = f * halfPiLo.addingProduct(f2, ps)
        let sinR = sinTail.addingProduct(f, halfPiHi)

        let c01 = SIMD4<Double>(repeating: -1.23370055013616975e+00)
            .addingProduct(f2, SIMD4<Double>(repeating: 2.53669507901047808e-01))
        let c23 = SIMD4<Double>(repeating: -2.08634807633407728e-02)
            .addingProduct(f2, SIMD4<Double>(repeating: 9.19260274546844654e-04))
        let c46 = SIMD4<Double>(repeating: -2.52020390280291777e-05)
            .addingProduct(f2, SIMD4<Double>(repeating: 4.71067840550522707e-07))
            .addingProduct(f4, SIMD4<Double>(repeating: -6.32939634496742380e-09))
        let cosR = SIMD4<Double>(repeating: 1.0).addingProduct(f2, c01.addingProduct(f4, c23.addingProduct(f4, c46)))
        return (sinR, cosR)
    }

    // MARK: - Cold Paths (|x| >= 2^50 / 2^51, +/-Infinity, NaN)

    @usableFromInline
    @inline(never)
    static func sinpiCold(_ x: SIMD4<Double>) -> SIMD4<Double> {
        let absBits = unsafeBitCast(x, to: SIMD4<UInt64>.self) & 0x7FFF_FFFF_FFFF_FFFF
        let isFast = absBits .< 0x4320_0000_0000_0000
        let safeX = x.replacing(with: 0.0, where: .!isFast)
        var out = sinpiFast(safeX)
        for lane in 0..<4 where !isFast[lane] {
            let v = x[lane]
            if !v.isFinite {
                out[lane] = v - v
            } else if Swift.abs(v) >= 0x1.0p53 {
                out[lane] = v * 0.0
            } else {
                out[lane] = sincospiLargeExact(v).0
            }
        }
        return out
    }

    @usableFromInline
    @inline(never)
    static func cospiCold(_ x: SIMD4<Double>) -> SIMD4<Double> {
        let absBits = unsafeBitCast(x, to: SIMD4<UInt64>.self) & 0x7FFF_FFFF_FFFF_FFFF
        let isFast = absBits .< 0x4320_0000_0000_0000
        let safeX = x.replacing(with: 0.0, where: .!isFast)
        var out = cospiFast(safeX)
        for lane in 0..<4 where !isFast[lane] {
            let v = x[lane]
            if !v.isFinite {
                out[lane] = v - v
            } else if Swift.abs(v) >= 0x1.0p53 {
                out[lane] = 1.0
            } else {
                out[lane] = sincospiLargeExact(v).1
            }
        }
        return out
    }

    @usableFromInline
    @inline(never)
    static func sincospiCold(_ x: SIMD4<Double>) -> (sin: SIMD4<Double>, cos: SIMD4<Double>) {
        let absBits = unsafeBitCast(x, to: SIMD4<UInt64>.self) & 0x7FFF_FFFF_FFFF_FFFF
        let isFast = absBits .< 0x4310_0000_0000_0000
        let safeX = x.replacing(with: 0.0, where: .!isFast)
        var (sinOut, cosOut) = sincospiFast(safeX)
        for lane in 0..<4 where !isFast[lane] {
            let v = x[lane]
            if !v.isFinite {
                let nan = v - v
                sinOut[lane] = nan
                cosOut[lane] = nan
            } else if Swift.abs(v) >= 0x1.0p53 {
                sinOut[lane] = v * 0.0
                cosOut[lane] = 1.0
            } else {
                let (s, c) = sincospiLargeExact(v)
                sinOut[lane] = s
                cosOut[lane] = c
            }
        }
        return (sinOut, cosOut)
    }

    @usableFromInline
    @inline(never)
    static func tanpiCold(_ x: SIMD4<Double>) -> SIMD4<Double> {
        let absBits = unsafeBitCast(x, to: SIMD4<UInt64>.self) & 0x7FFF_FFFF_FFFF_FFFF
        let isFast = absBits .< 0x4310_0000_0000_0000
        let safeX = x.replacing(with: 0.0, where: .!isFast)
        var out = tanpiFast(safeX)
        for lane in 0..<4 where !isFast[lane] {
            let v = x[lane]
            if !v.isFinite {
                out[lane] = v - v
            } else if Swift.abs(v) >= 0x1.0p53 {
                out[lane] = v * 0.0
            } else {
                out[lane] = tanpiLargeExact(v)
            }
        }
        return out
    }

    private static func sincospiLargeExact(_ v: Double) -> (Double, Double) {
        let y = v * 2.0
        let qF = y.rounded(.toNearestOrAwayFromZero)
        let q = Int64(qF)
        let f = y - qF
        let (sinV, cosV) = evalPiQuarterSinCos(SIMD4<Double>(repeating: f))
        let swap = (q & 1) != 0
        let rawS = swap ? cosV[0] : sinV[0]
        let rawC = swap ? sinV[0] : cosV[0]
        let sSign = UInt64(bitPattern: (q & 2) << 62)
        let cSign = UInt64(bitPattern: ((q &+ 1) & 2) << 62)
        let s = Double(bitPattern: rawS.bitPattern ^ sSign)
        let c = Double(bitPattern: rawC.bitPattern ^ cSign)
        return (s == 0.0 ? v * 0.0 : s, c == 0.0 ? 0.0 : c)
    }

    private static func tanpiLargeExact(_ v: Double) -> Double {
        let y = v * 2.0
        let qF = y.rounded(.toNearestOrAwayFromZero)
        let q = Int64(qF)
        let f = y - qF
        let isOdd = (q & 1) != 0
        if f == 0.0 {
            let qSign = UInt64(bitPattern: (q & 2) << 62)
            if isOdd {
                return Double(bitPattern: 0x7FF0_0000_0000_0000 ^ qSign)
            }
            let xSign = v.bitPattern & 0x8000_0000_0000_0000
            return Double(bitPattern: xSign ^ qSign)
        }
        let (sinV, cosV) = evalPiQuarterSinCos(SIMD4<Double>(repeating: f))
        return isOdd ? (-cosV[0] / sinV[0]) : (sinV[0] / cosV[0])
    }
}
