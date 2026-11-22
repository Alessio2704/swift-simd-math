// MARK: - Minimax Polynomials for lgamma and tgamma (< 1 ULP, Pure NEON Estrin)

extension SIMDMath {
    /// Evaluates `lgamma(2 + s)` on `s in [-0.5, 0.5]` as a compensated `(hi, lo)` pair.
    @inlinable
    @inline(__always)
    static func lgammaPoly2HiLo(_ s: SIMD2<Double>) -> (SIMD2<Double>, SIMD2<Double>) {
        let s2 = s * s
        let s4 = s2 * s2
        let s8 = s4 * s4
        let p23 = SIMD2<Double>(repeating: -6.73523010531980881e-02)
            .addingProduct(s, SIMD2<Double>(repeating: 2.05808084277845464e-02))
        let p45 = SIMD2<Double>(repeating: -7.38555102867411144e-03)
            .addingProduct(s, SIMD2<Double>(repeating: 2.89051033074158364e-03))
        let p67 = SIMD2<Double>(repeating: -1.19275391169541812e-03)
            .addingProduct(s, SIMD2<Double>(repeating: 5.09669524739280485e-04))
        let p89 = SIMD2<Double>(repeating: -2.23154758703673548e-04)
            .addingProduct(s, SIMD2<Double>(repeating: 9.94575129017688877e-05))
        let p1011 = SIMD2<Double>(repeating: -4.49262320936051683e-05)
            .addingProduct(s, SIMD2<Double>(repeating: 2.05072105479096009e-05))
        let p1213 = SIMD2<Double>(repeating: -9.43954192102471465e-06)
            .addingProduct(s, SIMD2<Double>(repeating: 4.37489252063603133e-06))
        let p1415 = SIMD2<Double>(repeating: -2.03881924845642223e-06)
            .addingProduct(s, SIMD2<Double>(repeating: 9.54951039295953227e-07))
        let p1617 = SIMD2<Double>(repeating: -4.51118119101630916e-07)
            .addingProduct(s, SIMD2<Double>(repeating: 2.12969272731522813e-07))
        let p1819 = SIMD2<Double>(repeating: -9.50141642542338478e-08)
            .addingProduct(s, SIMD2<Double>(repeating: 4.50998356752180815e-08))
        let p2021 = SIMD2<Double>(repeating: -3.13142853608867052e-08)
            .addingProduct(s, SIMD2<Double>(repeating: 1.49635731911920026e-08))
        let t0 = p23.addingProduct(s2, p45).addingProduct(s4, p67.addingProduct(s2, p89))
        let t1 = p1011.addingProduct(s2, p1213).addingProduct(s4, p1415.addingProduct(s2, p1617))
        let tail = t0.addingProduct(s8, t1.addingProduct(s8, p1819.addingProduct(s2, p2021)))
        let c1Tail = SIMD2<Double>(repeating: 3.22467033424113203e-01).addingProduct(s, tail)
        let c0 = SIMD2<Double>(repeating: 4.22784335098467134e-01)
        let hi0 = s * c0
        let lo0 = (-hi0).addingProduct(s, c0).addingProduct(s2, c1Tail)
        let hi = hi0 + lo0
        let lo = (hi0 - hi) + lo0
        return (hi, lo)
    }

    /// Evaluates `lgamma(3.5 + t)` on `t in [-1.0, 1.0]` (`x in [2.5, 4.5]`).
    @inlinable
    @inline(__always)
    static func lgammaPoly3(_ t: SIMD2<Double>) -> SIMD2<Double> {
        let t2 = t * t
        let t4 = t2 * t2
        let t8 = t4 * t4
        let p01 = SIMD2<Double>(repeating: 1.20097360234707429e+00)
            .addingProduct(t, SIMD2<Double>(repeating: 1.10315664064524288e+00))
        let p23 = SIMD2<Double>(repeating: 1.65178878050117495e-01)
            .addingProduct(t, SIMD2<Double>(repeating: -1.80340086069393571e-02))
        let p45 = SIMD2<Double>(repeating: 2.92941036738137393e-03)
            .addingProduct(t, SIMD2<Double>(repeating: -5.66633329489634884e-04))
        let p67 = SIMD2<Double>(repeating: 1.20901636971305034e-04)
            .addingProduct(t, SIMD2<Double>(repeating: -2.74520033420161584e-05))
        let p89 = SIMD2<Double>(repeating: 6.50352007130936114e-06)
            .addingProduct(t, SIMD2<Double>(repeating: -1.58837071837474875e-06))
        let p1011 = SIMD2<Double>(repeating: 3.96826685901338009e-07)
            .addingProduct(t, SIMD2<Double>(repeating: -1.00854176489073476e-07))
        let p1213 = SIMD2<Double>(repeating: 2.59896980619607176e-08)
            .addingProduct(t, SIMD2<Double>(repeating: -6.80721128452258438e-09))
        let p1415 = SIMD2<Double>(repeating: 1.78951422635828253e-09)
            .addingProduct(t, SIMD2<Double>(repeating: -4.40617025997081036e-10))
        let p1618 = SIMD2<Double>(repeating: 1.17227182914134207e-10)
            .addingProduct(t, SIMD2<Double>(repeating: -4.79872043878836545e-11))
            .addingProduct(t2, SIMD2<Double>(repeating: 1.29395990195360857e-11))
        let lo = p01.addingProduct(t2, p23).addingProduct(t4, p45.addingProduct(t2, p67))
        let mid = p89.addingProduct(t2, p1011).addingProduct(t4, p1213.addingProduct(t2, p1415))
        return lo.addingProduct(t8, mid.addingProduct(t8, p1618))
    }

    /// Evaluates `lgamma(6.25 + t)` on `t in [-1.75, 1.75]` (`x in [4.5, 8.0]`).
    @inlinable
    @inline(__always)
    static func lgammaPoly4(_ t: SIMD2<Double>) -> SIMD2<Double> {
        let t2 = t * t
        let t4 = t2 * t2
        let t8 = t4 * t4
        let p01 = SIMD2<Double>(repeating: 5.21960398699022932e+00)
            .addingProduct(t, SIMD2<Double>(repeating: 1.75045352688373601e+00))
        let p23 = SIMD2<Double>(repeating: 8.67396165794623586e-02)
            .addingProduct(t, SIMD2<Double>(repeating: -5.00349204919906324e-03))
        let p45 = SIMD2<Double>(repeating: 4.31883233279843127e-04)
            .addingProduct(t, SIMD2<Double>(repeating: -4.46278363667133041e-05))
        let p67 = SIMD2<Double>(repeating: 5.11197689097427779e-06)
            .addingProduct(t, SIMD2<Double>(repeating: -6.25956215030556405e-07))
        let p89 = SIMD2<Double>(repeating: 8.03012496071533379e-08)
            .addingProduct(t, SIMD2<Double>(repeating: -1.06598837814317062e-08))
        let p1011 = SIMD2<Double>(repeating: 1.45228017195729028e-09)
            .addingProduct(t, SIMD2<Double>(repeating: -2.01960967706236818e-10))
        let p1213 = SIMD2<Double>(repeating: 2.86445704787762120e-11)
            .addingProduct(t, SIMD2<Double>(repeating: -4.10429465084644400e-12))
        let p1415 = SIMD2<Double>(repeating: 5.63793642135317440e-13)
            .addingProduct(t, SIMD2<Double>(repeating: -8.23103470156009793e-14))
        let p1617 = SIMD2<Double>(repeating: 1.74788611240579715e-14)
            .addingProduct(t, SIMD2<Double>(repeating: -2.60164370981203568e-15))
        let lo = p01.addingProduct(t2, p23).addingProduct(t4, p45.addingProduct(t2, p67))
        let mid = p89.addingProduct(t2, p1011).addingProduct(t4, p1213.addingProduct(t2, p1415))
        return lo.addingProduct(t8, mid.addingProduct(t8, p1617))
    }

    /// Evaluates Stirling remainder `x * R(x)` on `w = 1/x^2 in [0, 1/64]` (`x >= 8`).
    @inlinable
    @inline(__always)
    static func stirlingPoly(_ w: SIMD2<Double>) -> SIMD2<Double> {
        let w2 = w * w
        let w4 = w2 * w2
        let p01 = SIMD2<Double>(repeating: 8.33333333333333287e-02)
            .addingProduct(w, SIMD2<Double>(repeating: -2.77777777777398795e-03))
        let p23 = SIMD2<Double>(repeating: 7.93650789752405853e-04)
            .addingProduct(w, SIMD2<Double>(repeating: -5.95236584505704869e-04))
        let p46 = SIMD2<Double>(repeating: 8.41470085250314707e-04)
            .addingProduct(w, SIMD2<Double>(repeating: -1.89038299388771510e-03))
            .addingProduct(w2, SIMD2<Double>(repeating: 5.06590536015613224e-03))
        return p01.addingProduct(w2, p23).addingProduct(w4, p46)
    }

    /// Evaluates Stirling remainder `x * R(x)` on `w = 1/x^2 in [0, 1/64]` (`x >= 8`).
    @inlinable
    @inline(__always)
    static func stirlingPoly(_ w: SIMD4<Double>) -> SIMD4<Double> {
        let w2 = w * w
        let w4 = w2 * w2
        let p01 = SIMD4<Double>(repeating: 8.33333333333333287e-02)
            .addingProduct(w, SIMD4<Double>(repeating: -2.77777777777398795e-03))
        let p23 = SIMD4<Double>(repeating: 7.93650789752405853e-04)
            .addingProduct(w, SIMD4<Double>(repeating: -5.95236584505704869e-04))
        let p46 = SIMD4<Double>(repeating: 8.41470085250314707e-04)
            .addingProduct(w, SIMD4<Double>(repeating: -1.89038299388771510e-03))
            .addingProduct(w2, SIMD4<Double>(repeating: 5.06590536015613224e-03))
        return p01.addingProduct(w2, p23).addingProduct(w4, p46)
    }

    /// Evaluates entire reciprocal `1 / Gamma(1.5 + t)` on `t in [-0.5, 0.5]` (`x in [1.0, 2.0]`, `0.074 ULP`).
    @inlinable
    @inline(__always)
    static func rgamma12Poly(_ t: SIMD4<Double>) -> SIMD4<Double> {
        let t2 = t * t
        let t4 = t2 * t2
        let t8 = t4 * t4
        let p01 = SIMD4<Double>(repeating: 1.12837916709551256e+00)
            .addingProduct(t, SIMD4<Double>(repeating: -4.11745264452830981e-02))
        let p23 = SIMD4<Double>(repeating: -5.26654435525544473e-01)
            .addingProduct(t, SIMD4<Double>(repeating: 1.75102026043934572e-01))
        let p45 = SIMD4<Double>(repeating: 5.09668602477062263e-02)
            .addingProduct(t, SIMD4<Double>(repeating: -4.21551693685356180e-02))
        let p67 = SIMD4<Double>(repeating: 6.61289782681797472e-03)
            .addingProduct(t, SIMD4<Double>(repeating: 2.12073144257358482e-03))
        let p89 = SIMD4<Double>(repeating: -1.11073025446831587e-03)
            .addingProduct(t, SIMD4<Double>(repeating: 1.52357620754171662e-04))
        let p1011 = SIMD4<Double>(repeating: 2.53552034610862564e-05)
            .addingProduct(t, SIMD4<Double>(repeating: -1.38968055640370449e-05))
        let p1213 = SIMD4<Double>(repeating: 2.15621322023480843e-06)
            .addingProduct(t, SIMD4<Double>(repeating: 5.79415946563359662e-08))
        let p1415 = SIMD4<Double>(repeating: -8.91747996362538821e-08)
            .addingProduct(t, SIMD4<Double>(repeating: 1.71076164952394848e-08))
        let p1617 = SIMD4<Double>(repeating: -8.47527852114779266e-10)
            .addingProduct(t, SIMD4<Double>(repeating: -2.76936022375561989e-10))
        let lo = p01.addingProduct(t2, p23).addingProduct(t4, p45.addingProduct(t2, p67))
        let hi = p89.addingProduct(t2, p1011).addingProduct(t4, p1213.addingProduct(t2, p1415))
        return lo.addingProduct(t8, hi.addingProduct(t8, p1617))
    }

    /// Pure-SIMD double-double `ln(x)` on `[0.5, 1.5)` for cancellation-safe `lgamma(x) = lgamma(x + 1) - ln(x)`.
    @inlinable
    @inline(__always)
    static func lgammaLnR1HiLo(_ x: SIMD2<Double>) -> (hi: SIMD2<Double>, lo: SIMD2<Double>) {
        let isLow = x .< SIMD2<Double>(repeating: 0.7071067811865476)
        let isHigh = x .> SIMD2<Double>(repeating: 1.4142135623730950488)
        let m = x.replacing(with: x * 2.0, where: isLow).replacing(with: x * 0.5, where: isHigh)
        let expInt = SIMD2<Double>.zero
            .replacing(with: SIMD2<Double>(repeating: -1.0), where: isLow)
            .replacing(with: SIMD2<Double>(repeating: 1.0), where: isHigh)
        let f = m - SIMD2<Double>(repeating: 1.0)
        let z = f / (m + SIMD2<Double>(repeating: 1.0))
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
        let lnTail = z * (-f).addingProduct(z2, q)
        let lnMHi = f + lnTail
        let lnMLo = (f - lnMHi) + lnTail
        let eHi = expInt * SIMD2<Double>(repeating: 6.93147180559945286e-01)
        let lnHi = eHi + lnMHi
        let v = lnHi - eHi
        let lnLo =
            ((eHi - (lnHi - v)) + (lnMHi - v))
            + lnMLo.addingProduct(expInt, SIMD2<Double>(repeating: 2.31904681384629956e-17))
        return (lnHi, lnLo)
    }
}
