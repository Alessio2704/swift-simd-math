// MARK: - SIMD Power Math (256-Entry 16-Byte Log2 + 128-Entry Exp2, <= 2 ULP, Pure Swift IEEE-754)

extension SIMDMath {
    // MARK: - Public Power API

    /// Evaluates IEEE-754 `pow(x, y)` on `SIMD2<Double>` (`<= 2 ULP`).
    @inlinable
    @inline(__always)
    public static func pow(_ x: SIMD2<Double>, _ y: SIMD2<Double>) -> SIMD2<Double> {
        let uX = unsafeBitCast(x, to: SIMD2<UInt64>.self)
        if _slowPath(any((uX &- 0x0010_0000_0000_0000) .>= 0x7FE0_0000_0000_0000)) {
            return powCold(x, y)
        }
        let (log2Hi, log2Lo) = log2HiLoTable(bits: uX)
        let pHi = y * log2Hi
        let absP = unsafeBitCast(pHi, to: SIMD2<UInt64>.self) & 0x7FFF_FFFF_FFFF_FFFF
        if _slowPath(any(absP .>= 0x408F_E800_0000_0000)) {
            return powCold(x, y)
        }
        let pLo = (-pHi).addingProduct(y, log2Hi).addingProduct(y, log2Lo)
        return exp2TableFast(hi: pHi, lo: pLo)
    }

    /// Evaluates IEEE-754 `pow(x, y)` on `SIMD4<Double>` (`<= 2 ULP`).
    @inlinable
    @inline(__always)
    public static func pow(_ x: SIMD4<Double>, _ y: SIMD4<Double>) -> SIMD4<Double> {
        let uX = unsafeBitCast(x, to: SIMD4<UInt64>.self)
        if _slowPath(any((uX &- 0x0010_0000_0000_0000) .>= 0x7FE0_0000_0000_0000)) {
            return powCold(x, y)
        }
        let (log2Hi, log2Lo) = log2HiLoTable(bits: uX)
        let pHi = y * log2Hi
        let absP = unsafeBitCast(pHi, to: SIMD4<UInt64>.self) & 0x7FFF_FFFF_FFFF_FFFF
        if _slowPath(any(absP .>= 0x408F_E800_0000_0000)) {
            return powCold(x, y)
        }
        let pLo = (-pHi).addingProduct(y, log2Hi).addingProduct(y, log2Lo)
        return exp2TableFast(hi: pHi, lo: pLo)
    }

    /// Evaluates IEEE-754 `pow(x, y)` on `SIMD8<Double>` (`<= 2 ULP`).
    @inlinable
    @inline(__always)
    public static func pow(_ x: SIMD8<Double>, _ y: SIMD8<Double>) -> SIMD8<Double> {
        SIMD8<Double>(lowHalf: pow(x.lowHalf, y.lowHalf), highHalf: pow(x.highHalf, y.highHalf))
    }

    // MARK: - 256-Entry 16-Byte Table Double-Double Log2 (>= 72-bit precision, zero fdiv)

    @inlinable
    @inline(__always)
    static func log2HiLoTable(
        bits uX: SIMD2<UInt64>,
        expAdjust: SIMD2<Double> = .zero
    ) -> (hi: SIMD2<Double>, lo: SIMD2<Double>) {
        let uRound = uX &+ 0x0000_0800_0000_0000
        let roundExp = uRound & 0x7FF0_0000_0000_0000
        let expInt = SIMD2<Double>(unsafeBitCast(uRound &>> 52, to: SIMD2<Int64>.self) &- 1023) + expAdjust
        let m = unsafeBitCast((uX &- roundExp) &+ 0x3FF0_0000_0000_0000, to: SIMD2<Double>.self)
        let idx = (uRound &>> 44) & 255
        let e0 = powerLogTable[Int(idx[0])]
        let e1 = powerLogTable[Int(idx[1])]
        return log2HiLoCore(
            m: m, expInt: expInt,
            invC: SIMD2(e0.invC, e1.invC),
            lcHi: SIMD2(e0.log2Hi, e1.log2Hi)
        )
    }

    @inlinable
    @inline(__always)
    static func log2HiLoTable(
        bits uX: SIMD4<UInt64>,
        expAdjust: SIMD4<Double> = .zero
    ) -> (hi: SIMD4<Double>, lo: SIMD4<Double>) {
        let uRound = uX &+ 0x0000_0800_0000_0000
        let roundExp = uRound & 0x7FF0_0000_0000_0000
        let expInt = SIMD4<Double>(unsafeBitCast(uRound &>> 52, to: SIMD4<Int64>.self) &- 1023) + expAdjust
        let m = unsafeBitCast((uX &- roundExp) &+ 0x3FF0_0000_0000_0000, to: SIMD4<Double>.self)
        let idx = (uRound &>> 44) & 255
        let e0 = powerLogTable[Int(idx[0])]
        let e1 = powerLogTable[Int(idx[1])]
        let e2 = powerLogTable[Int(idx[2])]
        let e3 = powerLogTable[Int(idx[3])]
        return log2HiLoCore(
            m: m, expInt: expInt,
            invC: SIMD4(e0.invC, e1.invC, e2.invC, e3.invC),
            lcHi: SIMD4(e0.log2Hi, e1.log2Hi, e2.log2Hi, e3.log2Hi)
        )
    }

    @inlinable
    @inline(__always)
    static func log2HiLoCore(
        m: SIMD2<Double>,
        expInt: SIMD2<Double>,
        invC: SIMD2<Double>,
        lcHi: SIMD2<Double>
    ) -> (hi: SIMD2<Double>, lo: SIMD2<Double>) {
        let p = m * invC
        let rawUHi = p - 1.0
        let rawULo = (-p).addingProduct(m, invC)
        let u = rawUHi + rawULo
        let uLo = rawULo - (u - rawUHi)

        let eHi = expInt + lcHi
        let eLo = lcHi - (eHi - expInt)

        let u2 = u * u
        let p23 = SIMD2<Double>(repeating: -0x1.71547652b82fep-1)
            .addingProduct(u, SIMD2<Double>(repeating: 0x1.ec709dc3a03fdp-2))
        let p45 = SIMD2<Double>(repeating: -0x1.71547652b82fep-2)
            .addingProduct(u, SIMD2<Double>(repeating: 0x1.2776c50ef9bfep-2))
        let p67 = SIMD2<Double>(repeating: -0x1.ec709dc3a03fdp-3)
            .addingProduct(u, SIMD2<Double>(repeating: 0x1.a61762a7aded9p-3))
        let poly = p23.addingProduct(u2, p45.addingProduct(u2, p67))

        let c1Hi = SIMD2<Double>(repeating: 0x1.71547652b82fep+0)
        let c1Lo = SIMD2<Double>(repeating: 0x1.777d0ffda0d24p-56)
        let sHi = eHi.addingProduct(c1Hi, u)
        let sLo =
            (-(sHi - eHi))
            .addingProduct(c1Hi, u)
            .addingProduct(c1Hi, uLo)
            .addingProduct(u, c1Lo)
            .addingProduct(u2, poly)
            + eLo
        let hi = sHi + sLo
        return (hi, (sHi - hi) + sLo)
    }

    @inlinable
    @inline(__always)
    static func log2HiLoCore(
        m: SIMD4<Double>,
        expInt: SIMD4<Double>,
        invC: SIMD4<Double>,
        lcHi: SIMD4<Double>
    ) -> (hi: SIMD4<Double>, lo: SIMD4<Double>) {
        let p = m * invC
        let rawUHi = p - 1.0
        let rawULo = (-p).addingProduct(m, invC)
        let u = rawUHi + rawULo
        let uLo = rawULo - (u - rawUHi)

        let eHi = expInt + lcHi
        let eLo = lcHi - (eHi - expInt)

        let u2 = u * u
        let p23 = SIMD4<Double>(repeating: -0x1.71547652b82fep-1)
            .addingProduct(u, SIMD4<Double>(repeating: 0x1.ec709dc3a03fdp-2))
        let p45 = SIMD4<Double>(repeating: -0x1.71547652b82fep-2)
            .addingProduct(u, SIMD4<Double>(repeating: 0x1.2776c50ef9bfep-2))
        let p67 = SIMD4<Double>(repeating: -0x1.ec709dc3a03fdp-3)
            .addingProduct(u, SIMD4<Double>(repeating: 0x1.a61762a7aded9p-3))
        let poly = p23.addingProduct(u2, p45.addingProduct(u2, p67))

        let c1Hi = SIMD4<Double>(repeating: 0x1.71547652b82fep+0)
        let c1Lo = SIMD4<Double>(repeating: 0x1.777d0ffda0d24p-56)
        let sHi = eHi.addingProduct(c1Hi, u)
        let sLo =
            (-(sHi - eHi))
            .addingProduct(c1Hi, u)
            .addingProduct(c1Hi, uLo)
            .addingProduct(u, c1Lo)
            .addingProduct(u2, poly)
            + eLo
        let hi = sHi + sLo
        return (hi, (sHi - hi) + sLo)
    }

    // MARK: - 128-Entry Table Exp2 Fast Path (Magic Rounding + Exponent-Bit Scaling)

    @inlinable
    @inline(__always)
    static func exp2TableFast(hi: SIMD2<Double>, lo: SIMD2<Double>) -> SIMD2<Double> {
        let magic = SIMD2<Double>(repeating: 6_755_399_441_055_744.0)
        let shifted = magic.addingProduct(hi, SIMD2<Double>(repeating: 128.0))
        let n = shifted - magic
        let f = hi.addingProduct(-n, SIMD2<Double>(repeating: 1.0 / 128.0)) + lo
        let poly = exp2PolyMinusOne(f)
        let bits = unsafeBitCast(shifted, to: SIMD2<UInt64>.self)
        let j = bits & 127
        let s = SIMD2(powerExpTable[Int(j[0])], powerExpTable[Int(j[1])])
        let base = s.addingProduct(s, poly)
        let kShift = (bits &<< 45) & 0xFFF0_0000_0000_0000
        return unsafeBitCast(unsafeBitCast(base, to: SIMD2<UInt64>.self) &+ kShift, to: SIMD2<Double>.self)
    }

    @inlinable
    @inline(__always)
    static func exp2TableFast(hi: SIMD4<Double>, lo: SIMD4<Double>) -> SIMD4<Double> {
        let magic = SIMD4<Double>(repeating: 6_755_399_441_055_744.0)
        let shifted = magic.addingProduct(hi, SIMD4<Double>(repeating: 128.0))
        let n = shifted - magic
        let f = hi.addingProduct(-n, SIMD4<Double>(repeating: 1.0 / 128.0)) + lo
        let poly = exp2PolyMinusOne(f)
        let bits = unsafeBitCast(shifted, to: SIMD4<UInt64>.self)
        let j = bits & 127
        let s = SIMD4(
            powerExpTable[Int(j[0])], powerExpTable[Int(j[1])],
            powerExpTable[Int(j[2])], powerExpTable[Int(j[3])]
        )
        let base = s.addingProduct(s, poly)
        let kShift = (bits &<< 45) & 0xFFF0_0000_0000_0000
        return unsafeBitCast(unsafeBitCast(base, to: SIMD4<UInt64>.self) &+ kShift, to: SIMD4<Double>.self)
    }
}
