import SwiftSIMDMath

// MARK: - Single-Source-of-Truth Compile-Time Exhaustive SIMD Unary Operation Catalog

/// Exhaustive catalog of every unary operation exported by `SIMDMath`.
/// Adding a case forces compile-time updates across grounding, adversarial, golden-vector,
/// benchmark, and MPFR certification suites (zero `default:` branches anywhere).
public enum SIMDUnaryOperation: String, CaseIterable, Sendable {
    case exp
    case exp2
    case exp10
    case expm1
    case log
    case log2
    case log10
    case log1p
    case sin
    case cos
    case tan
    case asin
    case acos
    case atan
    case sinpi
    case cospi
    case tanpi
    case abs
    case cbrt
    case sign
    case fract
    case sinh
    case cosh
    case tanh
    case asinh
    case acosh
    case atanh
    case erf
    case erfc
    case tgamma
    case lgamma

    @inline(__always)
    public func evaluate(_ x: SIMD2<Double>) -> SIMD2<Double> {
        switch self {
        case .exp: SIMDMath.exp(x)
        case .exp2: SIMDMath.exp2(x)
        case .exp10: SIMDMath.exp10(x)
        case .expm1: SIMDMath.expm1(x)
        case .log: SIMDMath.log(x)
        case .log2: SIMDMath.log2(x)
        case .log10: SIMDMath.log10(x)
        case .log1p: SIMDMath.log1p(x)
        case .sin: SIMDMath.sin(x)
        case .cos: SIMDMath.cos(x)
        case .tan: SIMDMath.tan(x)
        case .asin: SIMDMath.asin(x)
        case .acos: SIMDMath.acos(x)
        case .atan: SIMDMath.atan(x)
        case .sinpi: SIMDMath.sinpi(x)
        case .cospi: SIMDMath.cospi(x)
        case .tanpi: SIMDMath.tanpi(x)
        case .abs: SIMDMath.abs(x)
        case .cbrt: SIMDMath.cbrt(x)
        case .sign: SIMDMath.sign(x)
        case .fract: SIMDMath.fract(x)
        case .sinh: SIMDMath.sinh(x)
        case .cosh: SIMDMath.cosh(x)
        case .tanh: SIMDMath.tanh(x)
        case .asinh: SIMDMath.asinh(x)
        case .acosh: SIMDMath.acosh(x)
        case .atanh: SIMDMath.atanh(x)
        case .erf: SIMDMath.erf(x)
        case .erfc: SIMDMath.erfc(x)
        case .tgamma: SIMDMath.tgamma(x)
        case .lgamma: SIMDMath.lgamma(x)
        }
    }

    @inline(__always)
    public func evaluate(_ x: SIMD4<Double>) -> SIMD4<Double> {
        switch self {
        case .exp: SIMDMath.exp(x)
        case .exp2: SIMDMath.exp2(x)
        case .exp10: SIMDMath.exp10(x)
        case .expm1: SIMDMath.expm1(x)
        case .log: SIMDMath.log(x)
        case .log2: SIMDMath.log2(x)
        case .log10: SIMDMath.log10(x)
        case .log1p: SIMDMath.log1p(x)
        case .sin: SIMDMath.sin(x)
        case .cos: SIMDMath.cos(x)
        case .tan: SIMDMath.tan(x)
        case .asin: SIMDMath.asin(x)
        case .acos: SIMDMath.acos(x)
        case .atan: SIMDMath.atan(x)
        case .sinpi: SIMDMath.sinpi(x)
        case .cospi: SIMDMath.cospi(x)
        case .tanpi: SIMDMath.tanpi(x)
        case .abs: SIMDMath.abs(x)
        case .cbrt: SIMDMath.cbrt(x)
        case .sign: SIMDMath.sign(x)
        case .fract: SIMDMath.fract(x)
        case .sinh: SIMDMath.sinh(x)
        case .cosh: SIMDMath.cosh(x)
        case .tanh: SIMDMath.tanh(x)
        case .asinh: SIMDMath.asinh(x)
        case .acosh: SIMDMath.acosh(x)
        case .atanh: SIMDMath.atanh(x)
        case .erf: SIMDMath.erf(x)
        case .erfc: SIMDMath.erfc(x)
        case .tgamma: SIMDMath.tgamma(x)
        case .lgamma: SIMDMath.lgamma(x)
        }
    }

    @inline(__always)
    public func evaluate(_ x: SIMD8<Double>) -> SIMD8<Double> {
        switch self {
        case .exp: SIMDMath.exp(x)
        case .exp2: SIMDMath.exp2(x)
        case .exp10: SIMDMath.exp10(x)
        case .expm1: SIMDMath.expm1(x)
        case .log: SIMDMath.log(x)
        case .log2: SIMDMath.log2(x)
        case .log10: SIMDMath.log10(x)
        case .log1p: SIMDMath.log1p(x)
        case .sin: SIMDMath.sin(x)
        case .cos: SIMDMath.cos(x)
        case .tan: SIMDMath.tan(x)
        case .asin: SIMDMath.asin(x)
        case .acos: SIMDMath.acos(x)
        case .atan: SIMDMath.atan(x)
        case .sinpi: SIMDMath.sinpi(x)
        case .cospi: SIMDMath.cospi(x)
        case .tanpi: SIMDMath.tanpi(x)
        case .abs: SIMDMath.abs(x)
        case .cbrt: SIMDMath.cbrt(x)
        case .sign: SIMDMath.sign(x)
        case .fract: SIMDMath.fract(x)
        case .sinh: SIMDMath.sinh(x)
        case .cosh: SIMDMath.cosh(x)
        case .tanh: SIMDMath.tanh(x)
        case .asinh: SIMDMath.asinh(x)
        case .acosh: SIMDMath.acosh(x)
        case .atanh: SIMDMath.atanh(x)
        case .erf: SIMDMath.erf(x)
        case .erfc: SIMDMath.erfc(x)
        case .tgamma: SIMDMath.tgamma(x)
        case .lgamma: SIMDMath.lgamma(x)
        }
    }
}
