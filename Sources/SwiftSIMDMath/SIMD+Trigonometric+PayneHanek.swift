// MARK: - Pure-Swift 1280-Bit Payne-Hanek & Special-Value Cold Path for sincos

extension SIMDMath {
    /// First 1,280 fractional bits of `2 / pi` in big-endian `UInt64` limbs.
    private static let twoOverPiWords: [UInt64] = [
        0xA2F9_836E_4E44_1529, 0xFC27_57D1_F534_DDC0, 0xDB62_9599_3C43_9041, 0xFE51_63AB_DEBB_C561,
        0xB724_6E3A_424D_D2E0, 0x0649_2EEA_09D1_921C, 0xFE1D_EB1C_B129_A73E, 0xE882_35F5_2EBB_4484,
        0xE99C_7026_B45F_7E41, 0x3991_D639_8353_39F4, 0x9C84_5F8B_BDF9_283B, 0x1FF8_97FF_DE05_980F,
        0xEF2F_118B_5A0A_6D1F, 0x6D36_7ECF_27CB_09B7, 0x4F46_3F66_9E5F_EA2D, 0x7527_BAC7_EBE5_F17B,
        0x3D07_39F7_8A52_92EA, 0x6BFB_5FB1_1F8D_5D08, 0x5603_3046_FC7B_6BAB, 0xF0CF_BC20_9AF4_361D
    ]

    @usableFromInline
    @inline(never)
    static func sincosCold(_ x: SIMD2<Double>) -> (sin: SIMD2<Double>, cos: SIMD2<Double>) {
        let absBits = unsafeBitCast(x, to: SIMD2<UInt64>.self) & 0x7FFF_FFFF_FFFF_FFFF
        let isFast = (absBits &- 1) .< 0x411F_FFFF_FFFF_FFFF
        let safeX = x.replacing(with: SIMD2<Double>(repeating: 1.0), where: .!isFast)
        var (sinOut, cosOut) = sincosFast(safeX)

        for lane in 0..<2 where !isFast[lane] {
            let (s, c) = sincosColdScalar(x[lane])
            sinOut[lane] = s
            cosOut[lane] = c
        }
        return (sinOut, cosOut)
    }

    @usableFromInline
    @inline(never)
    static func sincosCold(_ x: SIMD4<Double>) -> (sin: SIMD4<Double>, cos: SIMD4<Double>) {
        let absBits = unsafeBitCast(x, to: SIMD4<UInt64>.self) & 0x7FFF_FFFF_FFFF_FFFF
        let isFast = (absBits &- 1) .< 0x411F_FFFF_FFFF_FFFF
        let safeX = x.replacing(with: SIMD4<Double>(repeating: 1.0), where: .!isFast)
        var (sinOut, cosOut) = sincosFast(safeX)

        for lane in 0..<4 where !isFast[lane] {
            let (s, c) = sincosColdScalar(x[lane])
            sinOut[lane] = s
            cosOut[lane] = c
        }
        return (sinOut, cosOut)
    }

    // MARK: - Scalar Cold Handler & 1280-Bit Payne-Hanek Reduction

    private static func sincosColdScalar(_ x: Double) -> (sin: Double, cos: Double) {
        if x == 0.0 {
            return (x, 1.0)
        }
        if !x.isFinite {
            let nan = x - x
            return (nan, nan)
        }
        let (rHi, rLo, q) = payneHanekReduceHiLo(x)
        return evaluateScalarSinCos(rHi: rHi, rLo: rLo, quadrant: q)
    }

    static func payneHanekReduceHiLo(_ x: Double) -> (rHi: Double, rLo: Double, quadrant: UInt64) {
        let bits = x.bitPattern
        let isNeg = (bits >> 63) != 0
        let exp = Int((bits >> 52) & 0x7FF) - 1023
        let mant = (bits & 0x000F_FFFF_FFFF_FFFF) | 0x0010_0000_0000_0000
        let p = exp - 52
        let j0 = p >= 2 ? (p - 2) >> 6 : 0

        let prod = multiplyMantissaByFourWords(mant: mant, startIndex: j0)
        let binaryPoint = 64 * (j0 + 4) - p

        var q = extract64(from: prod, at: binaryPoint) & 3
        let fracHi = extract64(from: prod, at: binaryPoint - 64)
        let fracLo = extract64(from: prod, at: binaryPoint - 128)

        let fracNeg = (fracHi >> 63) != 0
        let magHi: UInt64
        let magLo: UInt64
        if fracNeg {
            q = (q &+ 1) & 3
            let (negLo, borrow) = (0 as UInt64).subtractingReportingOverflow(fracLo)
            magLo = negLo
            magHi = (0 as UInt64) &- fracHi &- (borrow ? 1 : 0)
        } else {
            magHi = fracHi
            magLo = fracLo
        }

        var (rHi, rLo) = convertFractionToRadiansHiLo(magHi: magHi, magLo: magLo, isNegative: fracNeg)
        if isNeg {
            rHi = -rHi
            rLo = -rLo
            q = (0 &- q) & 3
        }
        return (rHi, rLo, q)
    }

    private struct Limb5 {
        let p0: UInt64
        let p1: UInt64
        let p2: UInt64
        let p3: UInt64
        let p4: UInt64

        func limb(_ idx: Int) -> UInt64 {
            switch idx {
            case 0: p0
            case 1: p1
            case 2: p2
            case 3: p3
            case 4: p4
            default: 0
            }
        }
    }

    private static func multiplyMantissaByFourWords(mant: UInt64, startIndex j0: Int) -> Limb5 {
        let w0 = twoOverPiWords[j0]
        let w1 = twoOverPiWords[j0 + 1]
        let w2 = twoOverPiWords[j0 + 2]
        let w3 = twoOverPiWords[j0 + 3]

        let m3 = mant.multipliedFullWidth(by: w3)
        let m2 = mant.multipliedFullWidth(by: w2)
        let (p1, c1) = m2.low.addingReportingOverflow(m3.high)
        let carry2 = m2.high &+ (c1 ? 1 : 0)

        let m1 = mant.multipliedFullWidth(by: w1)
        let (p2, c2) = m1.low.addingReportingOverflow(carry2)
        let carry1 = m1.high &+ (c2 ? 1 : 0)

        let m0 = mant.multipliedFullWidth(by: w0)
        let (p3, c3) = m0.low.addingReportingOverflow(carry1)
        let p4 = m0.high &+ (c3 ? 1 : 0)
        return Limb5(p0: m3.low, p1: p1, p2: p2, p3: p3, p4: p4)
    }

    private static func extract64(from prod: Limb5, at bitIndex: Int) -> UInt64 {
        let word = bitIndex >> 6
        let shift = bitIndex & 63
        let lo = prod.limb(word) >> shift
        if shift == 0 {
            return lo
        }
        return lo | (prod.limb(word + 1) << (64 - shift))
    }

    private static func convertFractionToRadiansHiLo(
        magHi: UInt64,
        magLo: UInt64,
        isNegative: Bool
    ) -> (Double, Double) {
        if magHi == 0, magLo == 0 {
            return (0.0, 0.0)
        }
        let lz: Int
        let normHi: UInt64
        let normLo: UInt64
        if magHi != 0 {
            lz = magHi.leadingZeroBitCount
            normHi = lz == 0 ? magHi : (magHi << lz) | (magLo >> (64 - lz))
            normLo = magLo << lz
        } else {
            let subLz = magLo.leadingZeroBitCount
            lz = 64 + subLz
            normHi = magLo << subLz
            normLo = 0
        }

        let hi53 = normHi >> 11
        let lo53 = ((normHi & 0x7FF) << 42) | (normLo >> 22)
        let scaleHi = Double(bitPattern: UInt64(1023 - lz - 53) << 52)
        let scaleLo = Double(bitPattern: UInt64(1023 - lz - 106) << 52)

        var fHi = Double(hi53) * scaleHi
        var fLo = Double(lo53) * scaleLo
        if isNegative {
            fHi = -fHi
            fLo = -fLo
        }

        let hpHi = 1.57079632679489656e+00
        let hpLo = 6.12323399573676604e-17
        let prodHi = fHi * hpHi
        let prodLo = (-prodHi).addingProduct(fHi, hpHi).addingProduct(fHi, hpLo).addingProduct(fLo, hpHi)
        let rHi = prodHi + prodLo
        let rLo = (prodHi - rHi) + prodLo
        return (rHi, rLo)
    }

    private static func evaluateScalarSinCos(rHi r: Double, rLo: Double, quadrant q: UInt64) -> (
        sin: Double, cos: Double
    ) {
        let r2 = r * r
        var ps = 1.58947432838633983e-10
        ps = (-2.50507351186882901e-08).addingProduct(r2, ps)
        ps = (2.75573136551872668e-06).addingProduct(r2, ps)
        ps = (-1.98412698301532724e-04).addingProduct(r2, ps)
        ps = (8.33333333332367254e-03).addingProduct(r2, ps)
        ps = (-1.66666666666666435e-01).addingProduct(r2, ps)
        let rawSin = r.addingProduct(r * r2, ps)

        var pc = 2.06304656433169899e-09
        pc = (-2.75552610933629672e-07).addingProduct(r2, pc)
        pc = (2.48015789564113583e-05).addingProduct(r2, pc)
        pc = (-1.38888888722309752e-03).addingProduct(r2, pc)
        pc = (4.16666666665218982e-02).addingProduct(r2, pc)
        pc = (-4.99999999999996336e-01).addingProduct(r2, pc)
        let rawCos = 1.0.addingProduct(r2, pc)

        let sinR = rawSin.addingProduct(rLo, rawCos)
        let cosR = rawCos.addingProduct(-rLo, rawSin)

        let swap = (q & 1) != 0
        let outSin = swap ? cosR : sinR
        let outCos = swap ? sinR : cosR
        let sinSign = (q & 2) << 62
        let cosSign = ((q &+ 1) & 2) << 62
        return (Double(bitPattern: outSin.bitPattern ^ sinSign), Double(bitPattern: outCos.bitPattern ^ cosSign))
    }
}
