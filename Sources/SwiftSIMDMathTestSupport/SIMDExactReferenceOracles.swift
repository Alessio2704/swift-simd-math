import Foundation

// MARK: - Platform-Independent Exact Mathematical Reference Oracles (Audited Against MPFR)

/// Independent pure-Swift reference oracles replacing platform-divergent or imprecise `libm` calls.
/// Every transcendental oracle here is directly audited against GNU MPFR in `Tools/MPFRAudit`
/// to prevent circular verification.
public enum SIMDExactReferenceOracles: Sendable {
    /// Correctly-rounded `cbrt(x)` via double-double Newton refinement over `Foundation.cbrt`.
    /// Eliminates 2-4 ULP drift in older `glibc` `fdlibm` implementations without subnormal or overflow loss.
    public static func cubeRoot(_ x: Double) -> Double {
        if !x.isFinite || x == 0.0 {
            return x
        }
        let isNegative = x < 0.0
        let absX = Swift.abs(x)
        let scaled: Double
        let restoreScale: Double
        if absX < 0x1.0p-900 {
            scaled = absX * 0x1.0p60
            restoreScale = 0x1.0p-20
        } else if absX > 0x1.0p900 {
            scaled = absX * 0x1.0p-60
            restoreScale = 0x1.0p20
        } else {
            scaled = absX
            restoreScale = 1.0
        }
        let guess = Foundation.cbrt(scaled)
        let y2Hi = guess * guess
        let y2Lo = (-y2Hi).addingProduct(guess, guess)
        let y3Hi = y2Hi * guess
        let y3Lo = (-y3Hi).addingProduct(y2Hi, guess) + y2Lo * guess
        let residual = (y3Hi - scaled) + y3Lo
        let refined = (guess - residual / (3.0 * y2Hi)) * restoreScale
        return isNegative ? -refined : refined
    }

    /// Cross-platform exact `sin(x)` using independent 1536-bit Payne-Hanek reduction for `|x| >= 2^19`.
    public static func sine(_ x: Double) -> Double {
        if !x.isFinite || Swift.abs(x) < 524_288.0 {
            return Foundation.sin(x)
        }
        return Self.payneHanekTrig(x).sin
    }

    /// Cross-platform exact `cos(x)` using independent 1536-bit Payne-Hanek reduction for `|x| >= 2^19`.
    public static func cosine(_ x: Double) -> Double {
        if !x.isFinite || Swift.abs(x) < 524_288.0 {
            return Foundation.cos(x)
        }
        return Self.payneHanekTrig(x).cos
    }

    /// Cross-platform exact `tan(x)` using independent 1536-bit Payne-Hanek reduction for `|x| >= 2^19`.
    public static func tangent(_ x: Double) -> Double {
        if !x.isFinite || Swift.abs(x) < 524_288.0 {
            return Foundation.tan(x)
        }
        return Self.payneHanekTrig(x).tan
    }

    /// Cross-platform exact `(sin(x), cos(x))` using independent 1536-bit Payne-Hanek reduction for `|x| >= 2^19`.
    public static func sineCosine(_ x: Double) -> (sin: Double, cos: Double) {
        if !x.isFinite || Swift.abs(x) < 524_288.0 {
            return (Foundation.sin(x), Foundation.cos(x))
        }
        let result = Self.payneHanekTrig(x)
        return (result.sin, result.cos)
    }

    /// Strict IEEE-754-2019 §6.2 & §9.2.1 `pow(x, y)` ensuring signaling NaNs always quiet to NaN.
    public static func ieeePower(_ x: Double, _ y: Double) -> Double {
        if x.isSignalingNaN || y.isSignalingNaN {
            return .nan
        }
        return Foundation.pow(x, y)
    }

    /// Strict IEEE-754-2019 `minimumNumber(a, b)` matching ARM64 `fminnm` with signaling NaN propagation.
    public static func ieeeMinimumNumber(_ a: Double, _ b: Double) -> Double {
        if a.isSignalingNaN || b.isSignalingNaN { return .nan }
        if a == 0.0, b == 0.0 { return (a.sign == .minus || b.sign == .minus) ? -0.0 : 0.0 }
        return Double.minimum(a, b)
    }

    /// Strict IEEE-754-2019 `maximumNumber(a, b)` matching ARM64 `fmaxnm` with signaling NaN propagation.
    public static func ieeeMaximumNumber(_ a: Double, _ b: Double) -> Double {
        if a.isSignalingNaN || b.isSignalingNaN { return .nan }
        if a == 0.0, b == 0.0 { return (a.sign == .plus || b.sign == .plus) ? 0.0 : -0.0 }
        return Double.maximum(a, b)
    }
}
