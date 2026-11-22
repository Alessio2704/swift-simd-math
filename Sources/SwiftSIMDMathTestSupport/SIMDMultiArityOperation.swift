import SwiftSIMDMath

// MARK: - Single-Source-of-Truth Compile-Time Exhaustive Multi-Arity SIMD Operation Catalogs

/// Exhaustive catalog of every binary operation exported by `SIMDMath`.
public enum SIMDBinaryOperation: String, CaseIterable, Sendable {
    case pow
    case atan2
    case hypot
    case min
    case max
    case step

    @inline(__always)
    public func evaluate(_ a: SIMD2<Double>, _ b: SIMD2<Double>) -> SIMD2<Double> {
        switch self {
        case .pow: SIMDMath.pow(a, b)
        case .atan2: SIMDMath.atan2(a, b)
        case .hypot: SIMDMath.hypot(a, b)
        case .min: SIMDMath.min(a, b)
        case .max: SIMDMath.max(a, b)
        case .step: SIMDMath.step(a, edge: b)
        }
    }

    @inline(__always)
    public func evaluate(_ a: SIMD4<Double>, _ b: SIMD4<Double>) -> SIMD4<Double> {
        switch self {
        case .pow: SIMDMath.pow(a, b)
        case .atan2: SIMDMath.atan2(a, b)
        case .hypot: SIMDMath.hypot(a, b)
        case .min: SIMDMath.min(a, b)
        case .max: SIMDMath.max(a, b)
        case .step: SIMDMath.step(a, edge: b)
        }
    }

    @inline(__always)
    public func evaluate(_ a: SIMD8<Double>, _ b: SIMD8<Double>) -> SIMD8<Double> {
        switch self {
        case .pow: SIMDMath.pow(a, b)
        case .atan2: SIMDMath.atan2(a, b)
        case .hypot: SIMDMath.hypot(a, b)
        case .min: SIMDMath.min(a, b)
        case .max: SIMDMath.max(a, b)
        case .step: SIMDMath.step(a, edge: b)
        }
    }
}

/// Exhaustive catalog of every ternary operation exported by `SIMDMath`.
public enum SIMDTernaryOperation: String, CaseIterable, Sendable {
    case clamp
    case mix
    case smoothstep

    @inline(__always)
    public func evaluate(_ x: SIMD2<Double>, _ lo: SIMD2<Double>, _ hi: SIMD2<Double>) -> SIMD2<Double> {
        switch self {
        case .clamp: SIMDMath.clamp(x, min: lo, max: hi)
        case .mix: SIMDMath.mix(x, lo, t: hi)
        case .smoothstep: SIMDMath.smoothstep(x, edge0: lo, edge1: hi)
        }
    }

    @inline(__always)
    public func evaluate(_ x: SIMD4<Double>, _ lo: SIMD4<Double>, _ hi: SIMD4<Double>) -> SIMD4<Double> {
        switch self {
        case .clamp: SIMDMath.clamp(x, min: lo, max: hi)
        case .mix: SIMDMath.mix(x, lo, t: hi)
        case .smoothstep: SIMDMath.smoothstep(x, edge0: lo, edge1: hi)
        }
    }

    @inline(__always)
    public func evaluate(_ x: SIMD8<Double>, _ lo: SIMD8<Double>, _ hi: SIMD8<Double>) -> SIMD8<Double> {
        switch self {
        case .clamp: SIMDMath.clamp(x, min: lo, max: hi)
        case .mix: SIMDMath.mix(x, lo, t: hi)
        case .smoothstep: SIMDMath.smoothstep(x, edge0: lo, edge1: hi)
        }
    }
}

/// Exhaustive catalog of every dual-output unary operation exported by `SIMDMath`.
public enum SIMDDualUnaryOperation: String, CaseIterable, Sendable {
    case sincos
    case sincospi

    @inline(__always)
    public func evaluate(_ x: SIMD2<Double>) -> (first: SIMD2<Double>, second: SIMD2<Double>) {
        switch self {
        case .sincos:
            let pair = SIMDMath.sincos(x)
            return (first: pair.sin, second: pair.cos)

        case .sincospi:
            let pair = SIMDMath.sincospi(x)
            return (first: pair.sin, second: pair.cos)
        }
    }

    @inline(__always)
    public func evaluate(_ x: SIMD4<Double>) -> (first: SIMD4<Double>, second: SIMD4<Double>) {
        switch self {
        case .sincos:
            let pair = SIMDMath.sincos(x)
            return (first: pair.sin, second: pair.cos)

        case .sincospi:
            let pair = SIMDMath.sincospi(x)
            return (first: pair.sin, second: pair.cos)
        }
    }

    @inline(__always)
    public func evaluate(_ x: SIMD8<Double>) -> (first: SIMD8<Double>, second: SIMD8<Double>) {
        switch self {
        case .sincos:
            let pair = SIMDMath.sincos(x)
            return (first: pair.sin, second: pair.cos)

        case .sincospi:
            let pair = SIMDMath.sincospi(x)
            return (first: pair.sin, second: pair.cos)
        }
    }
}
