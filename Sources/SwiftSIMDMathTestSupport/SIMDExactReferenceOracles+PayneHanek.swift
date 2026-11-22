// MARK: - Independent 1536-Bit Payne-Hanek Double-Double Trigonometric Reference Oracle

extension SIMDExactReferenceOracles {
    struct DoubleDoublePair: Sendable {
        let hi: Double
        let lo: Double
    }

    struct TrigReferenceTriplet: Sendable {
        let sin: Double
        let cos: Double
        let tan: Double
    }

    // 1536 fractional bits of 2/pi in big-endian 32-bit limbs (computed via 500-digit Machin pi).
    private static let twoOverPiWords32: [UInt32] = [
        0xA2F9_836E, 0x4E44_1529, 0xFC27_57D1, 0xF534_DDC0, 0xDB62_9599, 0x3C43_9041,
        0xFE51_63AB, 0xDEBB_C561, 0xB724_6E3A, 0x424D_D2E0, 0x0649_2EEA, 0x09D1_921C,
        0xFE1D_EB1C, 0xB129_A73E, 0xE882_35F5, 0x2EBB_4484, 0xE99C_7026, 0xB45F_7E41,
        0x3991_D639, 0x8353_39F4, 0x9C84_5F8B, 0xBDF9_283B, 0x1FF8_97FF, 0xDE05_980F,
        0xEF2F_118B, 0x5A0A_6D1F, 0x6D36_7ECF, 0x27CB_09B7, 0x4F46_3F66, 0x9E5F_EA2D,
        0x7527_BAC7, 0xEBE5_F17B, 0x3D07_39F7, 0x8A52_92EA, 0x6BFB_5FB1, 0x1F8D_5D08,
        0x5603_3046, 0xFC7B_6BAB, 0xF0CF_BC20, 0x9AF4_361D, 0xA9E3_9161, 0x5EE6_1B08,
        0x6599_855F, 0x14A0_6840, 0x8DFF_D880, 0x4D73_2731, 0x0606_1556, 0xCA73_A8C9
    ]

    private static let piHalfDoubleDouble = DoubleDoublePair(
        hi: 0x1.921fb54442d18p+0,
        lo: 0x1.1a62633145c07p-54
    )

    static func payneHanekTrig(_ x: Double) -> TrigReferenceTriplet {
        let isNegative = x < 0.0
        let bits = Swift.abs(x).bitPattern
        let exp = Int(bits >> 52) - 1023
        let mantissa = (bits & 0x000F_FFFF_FFFF_FFFF) | 0x0010_0000_0000_0000
        let shiftExp = exp - 52
        let startWord = Swift.max(0, (shiftExp - 2) >> 5)

        let productLimbs = Self.multiplyNineLimbs(startWord: startWord, mantissa: mantissa)
        let binaryPoint = -(shiftExp - 32 * (startWord + 9))

        var quadrant =
            (Self.bit(in: productLimbs, at: binaryPoint + 1) << 1)
            | Self.bit(in: productLimbs, at: binaryPoint)
        var fracLimbs = (0..<6).map { index in
            Self.extractWord32(in: productLimbs, topBit: binaryPoint - 1 - 32 * index)
        }

        var reducedIsNegative = false
        if (fracLimbs[0] & 0x8000_0000) != 0 {
            quadrant = (quadrant + 1) & 3
            reducedIsNegative = true
            var borrow: UInt64 = 0
            for index in stride(from: 5, through: 0, by: -1) {
                let limb = UInt64(fracLimbs[index])
                let diff = (0 &- limb &- borrow) & 0xFFFF_FFFF
                borrow = (limb + borrow) > 0 ? 1 : 0
                fracLimbs[index] = UInt32(diff)
            }
        }

        let reducedAngle = Self.normalizedAngle(fracLimbs: fracLimbs, isNegative: reducedIsNegative)
        let (sinBase, cosBase) = Self.evaluateTaylorSinCos(reducedAngle)
        var sinDD: DoubleDoublePair
        let cosDD: DoubleDoublePair
        switch quadrant {
        case 0:
            sinDD = sinBase
            cosDD = cosBase

        case 1:
            sinDD = cosBase
            cosDD = DoubleDoublePair(hi: -sinBase.hi, lo: -sinBase.lo)

        case 2:
            sinDD = DoubleDoublePair(hi: -sinBase.hi, lo: -sinBase.lo)
            cosDD = DoubleDoublePair(hi: -cosBase.hi, lo: -cosBase.lo)

        default:
            sinDD = DoubleDoublePair(hi: -cosBase.hi, lo: -cosBase.lo)
            cosDD = sinBase
        }
        if isNegative {
            sinDD = DoubleDoublePair(hi: -sinDD.hi, lo: -sinDD.lo)
        }
        let tanDD = Self.ddDivide(sinDD, cosDD)
        return TrigReferenceTriplet(
            sin: sinDD.hi + sinDD.lo,
            cos: cosDD.hi + cosDD.lo,
            tan: tanDD.hi + tanDD.lo
        )
    }

    private static func multiplyNineLimbs(startWord: Int, mantissa: UInt64) -> [UInt32] {
        let mLo = mantissa & 0xFFFF_FFFF
        let mHi = mantissa >> 32
        var limbs = [UInt32](repeating: 0, count: 11)
        var carry: UInt64 = 0
        for index in stride(from: 8, through: 0, by: -1) {
            let prod = UInt64(Self.twoOverPiWords32[startWord + index]) * mLo + carry
            limbs[index + 2] = UInt32(prod & 0xFFFF_FFFF)
            carry = prod >> 32
        }
        limbs[1] = UInt32(carry)
        carry = 0
        for index in stride(from: 8, through: 0, by: -1) {
            let prod = UInt64(Self.twoOverPiWords32[startWord + index]) * mHi + UInt64(limbs[index + 1]) + carry
            limbs[index + 1] = UInt32(prod & 0xFFFF_FFFF)
            carry = prod >> 32
        }
        limbs[0] = UInt32(carry)
        return limbs
    }

    private static func bit(in limbs: [UInt32], at bitIndex: Int) -> Int {
        if bitIndex < 0 { return 0 }
        let idx = 10 - (bitIndex >> 5)
        if idx < 0 || idx >= limbs.count { return 0 }
        return Int((limbs[idx] >> (bitIndex & 31)) & 1)
    }

    private static func extractWord32(in limbs: [UInt32], topBit: Int) -> UInt32 {
        var word: UInt32 = 0
        for offset in 0..<32 {
            word = (word << 1) | UInt32(Self.bit(in: limbs, at: topBit - offset))
        }
        return word
    }

    private static func normalizedAngle(fracLimbs: [UInt32], isNegative: Bool) -> DoubleDoublePair {
        var firstNonZeroBit = -1
        for wordIndex in 0..<6 where fracLimbs[wordIndex] != 0 {
            firstNonZeroBit = 32 * wordIndex + fracLimbs[wordIndex].leadingZeroBitCount
            break
        }
        if firstNonZeroBit < 0 { return DoubleDoublePair(hi: 0.0, lo: 0.0) }
        func fracBit(_ idx: Int) -> UInt64 {
            if idx >= 192 { return 0 }
            return UInt64((fracLimbs[idx >> 5] >> (31 - (idx & 31))) & 1)
        }
        var hi64: UInt64 = 0
        var lo64: UInt64 = 0
        for offset in 0..<64 {
            hi64 = (hi64 << 1) | fracBit(firstNonZeroBit + offset)
            lo64 = (lo64 << 1) | fracBit(firstNonZeroBit + 64 + offset)
        }
        let top53 = Double(hi64 >> 11) * Double(sign: .plus, exponent: -firstNonZeroBit - 53, significand: 1.0)
        let rem53 =
            Double(((hi64 & 0x7FF) << 42) | (lo64 >> 22))
            * Double(sign: .plus, exponent: -firstNonZeroBit - 106, significand: 1.0)
        let angle = Self.ddMultiply(Self.twoSum(top53, rem53), Self.piHalfDoubleDouble)
        return isNegative ? DoubleDoublePair(hi: -angle.hi, lo: -angle.lo) : angle
    }

    private static func evaluateTaylorSinCos(_ angle: DoubleDoublePair) -> (DoubleDoublePair, DoubleDoublePair) {
        let r2 = Self.ddMultiply(angle, angle)
        var sinPoly = DoubleDoublePair(hi: 0.0, lo: 0.0)
        var cosPoly = DoubleDoublePair(hi: 0.0, lo: 0.0)
        var sinDenom = 1.0
        var cosDenom = 1.0
        var sinDenoms: [Double] = []
        var cosDenoms: [Double] = []
        for term in 1...10 {
            cosDenom *= Double((2 * term - 1) * (2 * term))
            sinDenom *= Double((2 * term) * (2 * term + 1))
            cosDenoms.append(cosDenom)
            sinDenoms.append(sinDenom)
        }
        for term in stride(from: 10, through: 1, by: -1) {
            let sign = term.isMultiple(of: 2) ? 1.0 : -1.0
            let sinCoeff = Self.ddDivide(
                DoubleDoublePair(hi: sign, lo: 0.0), DoubleDoublePair(hi: sinDenoms[term - 1], lo: 0.0))
            let cosCoeff = Self.ddDivide(
                DoubleDoublePair(hi: sign, lo: 0.0), DoubleDoublePair(hi: cosDenoms[term - 1], lo: 0.0))
            sinPoly = Self.ddMultiply(r2, Self.ddAdd(sinCoeff, sinPoly))
            cosPoly = Self.ddMultiply(r2, Self.ddAdd(cosCoeff, cosPoly))
        }
        let one = DoubleDoublePair(hi: 1.0, lo: 0.0)
        return (Self.ddMultiply(angle, Self.ddAdd(one, sinPoly)), Self.ddAdd(one, cosPoly))
    }

    private static func twoSum(_ a: Double, _ b: Double) -> DoubleDoublePair {
        let s = a + b
        let v = s - a
        return DoubleDoublePair(hi: s, lo: (a - (s - v)) + (b - v))
    }

    private static func ddAdd(_ a: DoubleDoublePair, _ b: DoubleDoublePair) -> DoubleDoublePair {
        let s = Self.twoSum(a.hi, b.hi)
        return Self.twoSum(s.hi, s.lo + a.lo + b.lo)
    }

    private static func ddMultiply(_ a: DoubleDoublePair, _ b: DoubleDoublePair) -> DoubleDoublePair {
        let p = a.hi * b.hi
        let err = (-p).addingProduct(a.hi, b.hi) + a.hi * b.lo + a.lo * b.hi
        return Self.twoSum(p, err)
    }

    private static func ddDivide(_ a: DoubleDoublePair, _ b: DoubleDoublePair) -> DoubleDoublePair {
        let q1 = a.hi / b.hi
        let prod = Self.ddMultiply(DoubleDoublePair(hi: q1, lo: 0.0), b)
        let rem = Self.ddAdd(a, DoubleDoublePair(hi: -prod.hi, lo: -prod.lo))
        return Self.twoSum(q1, (rem.hi + rem.lo) / b.hi)
    }
}
