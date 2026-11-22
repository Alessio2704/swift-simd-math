// MARK: - SIMD Branchless Shaping & Interpolation: sign, fract, step, mix, smoothstep

extension SIMDMath {
    // MARK: - sign (Branchless -1 / 0 / +1 matching Apple simd.sign)

    /// Returns `-1.0` for `x < 0`, `+1.0` for `x > 0`, and `+0.0` for `±0.0` or `NaN`.
    @inlinable
    @inline(__always)
    public static func sign(_ x: SIMD2<Double>) -> SIMD2<Double> {
        let pos = SIMD2<Double>.zero.replacing(with: SIMD2<Double>(repeating: 1.0), where: x .> 0.0)
        return pos.replacing(with: SIMD2<Double>(repeating: -1.0), where: x .< 0.0)
    }

    /// Returns `-1.0` for `x < 0`, `+1.0` for `x > 0`, and `+0.0` for `±0.0` or `NaN`.
    @inlinable
    @inline(__always)
    public static func sign(_ x: SIMD4<Double>) -> SIMD4<Double> {
        SIMD4<Double>(lowHalf: sign(x.lowHalf), highHalf: sign(x.highHalf))
    }

    /// Returns `-1.0` for `x < 0`, `+1.0` for `x > 0`, and `+0.0` for `±0.0` or `NaN`.
    @inlinable
    @inline(__always)
    public static func sign(_ x: SIMD8<Double>) -> SIMD8<Double> {
        SIMD8<Double>(lowHalf: sign(x.lowHalf), highHalf: sign(x.highHalf))
    }

    // MARK: - fract (Fractional part clamped strictly to [0, 1) matching Apple simd.fract)

    /// Returns `min(x - floor(x), 1.0.nextDown)` matching Apple `simd.fract`.
    @inlinable
    @inline(__always)
    public static func fract(_ x: SIMD2<Double>) -> SIMD2<Double> {
        Self.min(x - x.rounded(.down), SIMD2<Double>(repeating: 0x1.FFFF_FFFF_FFFF_Fp-1))
    }

    /// Returns `min(x - floor(x), 1.0.nextDown)` matching Apple `simd.fract`.
    @inlinable
    @inline(__always)
    public static func fract(_ x: SIMD4<Double>) -> SIMD4<Double> {
        SIMD4<Double>(lowHalf: fract(x.lowHalf), highHalf: fract(x.highHalf))
    }

    /// Returns `min(x - floor(x), 1.0.nextDown)` matching Apple `simd.fract`.
    @inlinable
    @inline(__always)
    public static func fract(_ x: SIMD8<Double>) -> SIMD8<Double> {
        SIMD8<Double>(lowHalf: fract(x.lowHalf), highHalf: fract(x.highHalf))
    }

    // MARK: - step (Branchless Heaviside threshold matching Apple simd.step)

    /// Returns `0.0` if `x < edge`, else `1.0` (matching Apple `simd.step(x, edge:)`).
    @inlinable
    @inline(__always)
    public static func step(_ x: SIMD2<Double>, edge: SIMD2<Double>) -> SIMD2<Double> {
        SIMD2<Double>(repeating: 1.0).replacing(with: 0.0, where: x .< edge)
    }

    /// Returns `0.0` if `x < edge`, else `1.0` (matching Apple `simd.step(x, edge:)`).
    @inlinable
    @inline(__always)
    public static func step(_ x: SIMD4<Double>, edge: SIMD4<Double>) -> SIMD4<Double> {
        SIMD4<Double>(
            lowHalf: step(x.lowHalf, edge: edge.lowHalf),
            highHalf: step(x.highHalf, edge: edge.highHalf)
        )
    }

    /// Returns `0.0` if `x < edge`, else `1.0` (matching Apple `simd.step(x, edge:)`).
    @inlinable
    @inline(__always)
    public static func step(_ x: SIMD8<Double>, edge: SIMD8<Double>) -> SIMD8<Double> {
        SIMD8<Double>(
            lowHalf: step(x.lowHalf, edge: edge.lowHalf),
            highHalf: step(x.highHalf, edge: edge.highHalf)
        )
    }

    // MARK: - mix (Fused linear interpolation a + t * (b - a) matching Apple simd.mix)

    /// Evaluates fused linear interpolation `a + t * (b - a)` on `SIMD2<Double>`.
    @inlinable
    @inline(__always)
    public static func mix(_ a: SIMD2<Double>, _ b: SIMD2<Double>, t: SIMD2<Double>) -> SIMD2<Double> {
        a.addingProduct(t, b - a)
    }

    /// Evaluates fused linear interpolation `a + t * (b - a)` on `SIMD4<Double>`.
    @inlinable
    @inline(__always)
    public static func mix(_ a: SIMD4<Double>, _ b: SIMD4<Double>, t: SIMD4<Double>) -> SIMD4<Double> {
        SIMD4<Double>(
            lowHalf: mix(a.lowHalf, b.lowHalf, t: t.lowHalf),
            highHalf: mix(a.highHalf, b.highHalf, t: t.highHalf)
        )
    }

    /// Evaluates fused linear interpolation `a + t * (b - a)` on `SIMD8<Double>`.
    @inlinable
    @inline(__always)
    public static func mix(_ a: SIMD8<Double>, _ b: SIMD8<Double>, t: SIMD8<Double>) -> SIMD8<Double> {
        SIMD8<Double>(
            lowHalf: mix(a.lowHalf, b.lowHalf, t: t.lowHalf),
            highHalf: mix(a.highHalf, b.highHalf, t: t.highHalf)
        )
    }

    // MARK: - smoothstep (Cubic Hermite S-curve matching Apple simd.smoothstep)

    /// Evaluates cubic Hermite `smoothstep` on `SIMD2<Double>` matching Apple `simd.smoothstep`.
    @inlinable
    @inline(__always)
    public static func smoothstep(
        _ x: SIMD2<Double>,
        edge0: SIMD2<Double>,
        edge1: SIMD2<Double>
    ) -> SIMD2<Double> {
        let u = Self.clamp((x - edge0) / (edge1 - edge0), min: .zero, max: SIMD2<Double>(repeating: 1.0))
        return u * u * SIMD2<Double>(repeating: 3.0).addingProduct(SIMD2<Double>(repeating: -2.0), u)
    }

    /// Evaluates cubic Hermite `smoothstep` on `SIMD4<Double>` matching Apple `simd.smoothstep`.
    @inlinable
    @inline(__always)
    public static func smoothstep(
        _ x: SIMD4<Double>,
        edge0: SIMD4<Double>,
        edge1: SIMD4<Double>
    ) -> SIMD4<Double> {
        SIMD4<Double>(
            lowHalf: smoothstep(x.lowHalf, edge0: edge0.lowHalf, edge1: edge1.lowHalf),
            highHalf: smoothstep(x.highHalf, edge0: edge0.highHalf, edge1: edge1.highHalf)
        )
    }

    /// Evaluates cubic Hermite `smoothstep` on `SIMD8<Double>` matching Apple `simd.smoothstep`.
    @inlinable
    @inline(__always)
    public static func smoothstep(
        _ x: SIMD8<Double>,
        edge0: SIMD8<Double>,
        edge1: SIMD8<Double>
    ) -> SIMD8<Double> {
        SIMD8<Double>(
            lowHalf: smoothstep(x.lowHalf, edge0: edge0.lowHalf, edge1: edge1.lowHalf),
            highHalf: smoothstep(x.highHalf, edge0: edge0.highHalf, edge1: edge1.highHalf)
        )
    }
}
