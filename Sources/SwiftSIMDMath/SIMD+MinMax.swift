// MARK: - LLVM Vector Math Intrinsics (Direct Hardware Instructions)

@usableFromInline
@_silgen_name("llvm.minnum.v2f64")
func llvmMinnumV2F64(_: SIMD2<Double>, _: SIMD2<Double>) -> SIMD2<Double>

@usableFromInline
@_silgen_name("llvm.maxnum.v2f64")
func llvmMaxnumV2F64(_: SIMD2<Double>, _: SIMD2<Double>) -> SIMD2<Double>

@usableFromInline
@_silgen_name("llvm.fabs.v2f64")
func llvmFabsV2F64(_: SIMD2<Double>) -> SIMD2<Double>

// MARK: - SIMD Min / Max / Clamp / Abs Math

extension SIMDMath {
    // MARK: - Concrete Double Vector Overloads (Pure Hardware Instructions)

    @inlinable
    @inline(__always)
    public static func min(_ a: SIMD2<Double>, _ b: SIMD2<Double>) -> SIMD2<Double> {
        llvmMinnumV2F64(a, b)
    }

    @inlinable
    @inline(__always)
    public static func min(_ a: SIMD4<Double>, _ b: SIMD4<Double>) -> SIMD4<Double> {
        SIMD4<Double>(
            lowHalf: llvmMinnumV2F64(a.lowHalf, b.lowHalf),
            highHalf: llvmMinnumV2F64(a.highHalf, b.highHalf)
        )
    }

    @inlinable
    @inline(__always)
    public static func min(_ a: SIMD8<Double>, _ b: SIMD8<Double>) -> SIMD8<Double> {
        SIMD8<Double>(
            lowHalf: min(a.lowHalf, b.lowHalf),
            highHalf: min(a.highHalf, b.highHalf)
        )
    }

    @inlinable
    @inline(__always)
    public static func max(_ a: SIMD2<Double>, _ b: SIMD2<Double>) -> SIMD2<Double> {
        llvmMaxnumV2F64(a, b)
    }

    @inlinable
    @inline(__always)
    public static func max(_ a: SIMD4<Double>, _ b: SIMD4<Double>) -> SIMD4<Double> {
        SIMD4<Double>(
            lowHalf: llvmMaxnumV2F64(a.lowHalf, b.lowHalf),
            highHalf: llvmMaxnumV2F64(a.highHalf, b.highHalf)
        )
    }

    @inlinable
    @inline(__always)
    public static func max(_ a: SIMD8<Double>, _ b: SIMD8<Double>) -> SIMD8<Double> {
        SIMD8<Double>(
            lowHalf: max(a.lowHalf, b.lowHalf),
            highHalf: max(a.highHalf, b.highHalf)
        )
    }

    @inlinable
    @inline(__always)
    public static func clamp(
        _ x: SIMD2<Double>, min lower: SIMD2<Double>, max upper: SIMD2<Double>
    ) -> SIMD2<Double> {
        min(max(x, lower), upper)
    }

    @inlinable
    @inline(__always)
    public static func clamp(
        _ x: SIMD4<Double>, min lower: SIMD4<Double>, max upper: SIMD4<Double>
    ) -> SIMD4<Double> {
        SIMD4<Double>(
            lowHalf: clamp(x.lowHalf, min: lower.lowHalf, max: upper.lowHalf),
            highHalf: clamp(x.highHalf, min: lower.highHalf, max: upper.highHalf)
        )
    }

    @inlinable
    @inline(__always)
    public static func clamp(
        _ x: SIMD8<Double>, min lower: SIMD8<Double>, max upper: SIMD8<Double>
    ) -> SIMD8<Double> {
        SIMD8<Double>(
            lowHalf: clamp(x.lowHalf, min: lower.lowHalf, max: upper.lowHalf),
            highHalf: clamp(x.highHalf, min: lower.highHalf, max: upper.highHalf)
        )
    }

    @inlinable
    @inline(__always)
    public static func abs(_ x: SIMD2<Double>) -> SIMD2<Double> {
        llvmFabsV2F64(x)
    }

    @inlinable
    @inline(__always)
    public static func abs(_ x: SIMD4<Double>) -> SIMD4<Double> {
        SIMD4<Double>(
            lowHalf: llvmFabsV2F64(x.lowHalf),
            highHalf: llvmFabsV2F64(x.highHalf)
        )
    }

    @inlinable
    @inline(__always)
    public static func abs(_ x: SIMD8<Double>) -> SIMD8<Double> {
        SIMD8<Double>(
            lowHalf: abs(x.lowHalf),
            highHalf: abs(x.highHalf)
        )
    }
}
