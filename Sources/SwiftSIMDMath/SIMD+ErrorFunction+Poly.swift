// MARK: - Minimax Polynomials for erf and erfc (< 1 ULP, Pure NEON Estrin Evaluation)

extension SIMDMath {
    /// Evaluates `(erf(x)/x - 2/sqrt(pi)) / x^2` on `t = x^2 in [0, 0.7225]` (`|x| <= 0.85`).
    @inlinable
    @inline(__always)
    static func erfSmallTailPoly(_ t: SIMD4<Double>) -> SIMD4<Double> {
        let t2 = t * t
        let t4 = t2 * t2
        let t8 = t4 * t4
        let p01 = SIMD4<Double>(repeating: -3.76126389031837538e-01)
            .addingProduct(t, SIMD4<Double>(repeating: 1.12837916709551261e-01))
        let p23 = SIMD4<Double>(repeating: -2.68661706451312071e-02)
            .addingProduct(t, SIMD4<Double>(repeating: 5.22397762544136394e-03))
        let p45 = SIMD4<Double>(repeating: -8.54832702335943232e-04)
            .addingProduct(t, SIMD4<Double>(repeating: 1.20553329752123891e-04))
        let p67 = SIMD4<Double>(repeating: -1.49256500369329878e-05)
            .addingProduct(t, SIMD4<Double>(repeating: 1.64621034022745104e-06))
        let p89 = SIMD4<Double>(repeating: -1.63655807724181546e-07)
            .addingProduct(t, SIMD4<Double>(repeating: 1.48027201139796389e-08))
        let p1012 = SIMD4<Double>(repeating: -1.22381919397535095e-09)
            .addingProduct(t, SIMD4<Double>(repeating: 9.01704398822338495e-11))
            .addingProduct(t2, SIMD4<Double>(repeating: -4.80486355655308336e-12))
        let lo = p01.addingProduct(t2, p23).addingProduct(t4, p45.addingProduct(t2, p67))
        let hi = p89.addingProduct(t2, p1012)
        return lo.addingProduct(t8, hi)
    }

    /// Evaluates `exp(a^2) * erfc(a)` for `a in [0.84, 1.84]` via `t = a - 1.34 in [-0.5, 0.5]`.
    @inlinable
    @inline(__always)
    static func erfcPolyA(_ t: SIMD4<Double>) -> SIMD4<Double> {
        let t2 = t * t
        let t4 = t2 * t2
        let t8 = t4 * t4
        let p01 = SIMD4<Double>(repeating: 3.49858774988974996e-01)
            .addingProduct(t, SIMD4<Double>(repeating: -1.90757650125059519e-01))
        let p23 = SIMD4<Double>(repeating: 9.42435238213951976e-02)
            .addingProduct(t, SIMD4<Double>(repeating: -4.29808854695989048e-02))
        let p45 = SIMD4<Double>(repeating: 1.83245686460715498e-02)
            .addingProduct(t, SIMD4<Double>(repeating: -7.37038539323112227e-03))
        let p67 = SIMD4<Double>(repeating: 2.81608407282499511e-03)
            .addingProduct(t, SIMD4<Double>(repeating: -1.02766650380568250e-03))
        let p89 = SIMD4<Double>(repeating: 3.59752744143948739e-04)
            .addingProduct(t, SIMD4<Double>(repeating: -1.21243855942848762e-04))
        let p1011 = SIMD4<Double>(repeating: 3.94571396029350861e-05)
            .addingProduct(t, SIMD4<Double>(repeating: -1.24319423706653856e-05))
        let p1213 = SIMD4<Double>(repeating: 3.80010984837278427e-06)
            .addingProduct(t, SIMD4<Double>(repeating: -1.12575504802008852e-06))
        let p1416 = SIMD4<Double>(repeating: 3.25812220624146322e-07)
            .addingProduct(t, SIMD4<Double>(repeating: -9.97666272664356623e-08))
            .addingProduct(t2, SIMD4<Double>(repeating: 2.73934812474970420e-08))
        let lo = p01.addingProduct(t2, p23).addingProduct(t4, p45.addingProduct(t2, p67))
        let hi = p89.addingProduct(t2, p1011).addingProduct(t4, p1213.addingProduct(t2, p1416))
        return lo.addingProduct(t8, hi)
    }

    /// Evaluates `a * exp(a^2) * erfc(a)` for `a in [1.835, 4.52]` via `t = 1/a - 0.383 in [-0.162, 0.162]`.
    @inlinable
    @inline(__always)
    static func erfcPolyB(_ t: SIMD4<Double>) -> SIMD4<Double> {
        let t2 = t * t
        let t4 = t2 * t2
        let t8 = t4 * t4
        let p01 = SIMD4<Double>(repeating: 5.29641864804922924e-01)
            .addingProduct(t, SIMD4<Double>(repeating: -1.53024372796568914e-01))
        let p23 = SIMD4<Double>(repeating: -8.78303888476505423e-02)
            .addingProduct(t, SIMD4<Double>(repeating: 1.73524788416375753e-01))
        let p45 = SIMD4<Double>(repeating: -1.17610399462996090e-01)
            .addingProduct(t, SIMD4<Double>(repeating: -2.87280973883279889e-02))
        let p67 = SIMD4<Double>(repeating: 1.82174779257770258e-01)
            .addingProduct(t, SIMD4<Double>(repeating: -2.46613809483072211e-01))
        let p89 = SIMD4<Double>(repeating: 1.46842453415654439e-01)
            .addingProduct(t, SIMD4<Double>(repeating: 1.28566106157046556e-01))
        let p1011 = SIMD4<Double>(repeating: -4.88648471505792548e-01)
            .addingProduct(t, SIMD4<Double>(repeating: 7.27939032614329462e-01))
        let p1213 = SIMD4<Double>(repeating: -5.69123085824482233e-01)
            .addingProduct(t, SIMD4<Double>(repeating: -2.20914016732930957e-01))
        let p1416 = SIMD4<Double>(repeating: 1.66498518789873740e+00)
            .addingProduct(t, SIMD4<Double>(repeating: -3.23314476240282467e+00))
            .addingProduct(t2, SIMD4<Double>(repeating: 3.02165573941598886e+00))
        let lo = p01.addingProduct(t2, p23).addingProduct(t4, p45.addingProduct(t2, p67))
        let hi = p89.addingProduct(t2, p1011).addingProduct(t4, p1213.addingProduct(t2, p1416))
        return lo.addingProduct(t8, hi)
    }

    /// Evaluates `a * exp(a^2) * erfc(a)` for `a >= 4.47` via `w = 1/a^2 in [0, 0.05]`.
    @inlinable
    @inline(__always)
    static func erfcPolyC(_ w: SIMD4<Double>) -> SIMD4<Double> {
        let w2 = w * w
        let w4 = w2 * w2
        let w8 = w4 * w4
        let p01 = SIMD4<Double>(repeating: 5.64189583547756279e-01)
            .addingProduct(w, SIMD4<Double>(repeating: -2.82094791773871589e-01))
        let p23 = SIMD4<Double>(repeating: 4.23142187652246371e-01)
            .addingProduct(w, SIMD4<Double>(repeating: -1.05785546470281000e+00))
        let p45 = SIMD4<Double>(repeating: 3.70249292818758402e+00)
            .addingProduct(w, SIMD4<Double>(repeating: -1.66610235361353922e+01))
        let p67 = SIMD4<Double>(repeating: 9.16151172033121100e+01)
            .addingProduct(w, SIMD4<Double>(repeating: -5.94029490832693000e+02))
        let p89 = SIMD4<Double>(repeating: 4.38187936014102615e+03)
            .addingProduct(w, SIMD4<Double>(repeating: -3.46649719425862495e+04))
        let p1011 = SIMD4<Double>(repeating: 2.65564965444318077e+05)
            .addingProduct(w, SIMD4<Double>(repeating: -1.70684899800283415e+06))
        let p1213 = SIMD4<Double>(repeating: 7.62807570857794955e+06)
            .addingProduct(w, SIMD4<Double>(repeating: -1.69417701287626550e+07))
        let lo = p01.addingProduct(w2, p23).addingProduct(w4, p45.addingProduct(w2, p67))
        let hi = p89.addingProduct(w2, p1011).addingProduct(w4, p1213)
        return lo.addingProduct(w8, hi)
    }
}
