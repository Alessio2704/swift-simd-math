import Foundation
import SwiftSIMDMathTestSupport

extension SIMDUnaryOperation {
    static func scalarTGamma(_ x: Double) -> Double {
        if x < -169.5, x > -171.5, x != x.rounded(.down) {
            // Darwin C libm tgamma loses ~400 ULP in (-171.5, -169.5); use exact shifted reflection matching Python/50-digit truth.
            let floored = x.rounded(.down)
            let isNeg = (Int64(floored) & 1) != 0
            let frac = Swift.abs(x - x.rounded(.toNearestOrAwayFromZero))
            var shifted = -x
            var factor = -x
            for _ in 0..<15 {
                shifted -= 1.0
                factor *= shifted
            }
            let mag = (Double.pi / (Foundation.sin(Double.pi * frac) * Foundation.tgamma(shifted))) / factor
            return isNeg ? -mag : mag
        }
        return Foundation.tgamma(x)
    }

    static func scalarLGamma(_ x: Double) -> Double {
        if x < -0.5, x.isFinite {
            let rounded = x.rounded(.toNearestOrAwayFromZero)
            if x == rounded { return .infinity }
            let frac = Swift.abs(x - rounded)
            if frac < 1.0e-3 {
                // Darwin C libm lgamma loses up to ~0.5 near negative integers due to sloppy sin(pi*x);
                // use exact reduced reflection ln(pi) - ln(sin(pi*frac)) - lgamma(1 - x) matching Python/50-digit truth.
                let lg1MinusX: Double = Foundation.lgamma(1.0 - x)
                return Foundation.log(Double.pi) - Foundation.log(Foundation.sin(Double.pi * frac)) - lg1MinusX
            }
        }
        return Foundation.lgamma(x)
    }

    static let erfSpec = UnaryTestSpec(
        maxULP: 3,
        homogeneousInputs: [-6.5, -3.0, -1.5, -0.84, -0.3, -0.0, 0.0, 0.3, 0.84, 1.5, 3.0, 6.5],
        heterogeneousLanes: [
            [-4.0, -1.2, -0.5, 0.0, 0.5, 1.2, 2.5, 5.5],
            [0.5, .nan, .infinity, -.infinity, -0.0, 6.0, -6.0, Double.leastNonzeroMagnitude]
        ],
        stabilityTransitions: [
            -10.0, -6.0, -4.5, -1.84, -0.84375.nextUp, -0.84375, -0.84375.nextDown,
            -Double.leastNormalMagnitude, -Double.leastNonzeroMagnitude, -0.0, 0.0,
            Double.leastNonzeroMagnitude, Double.leastNormalMagnitude,
            0.84375.nextDown, 0.84375, 0.84375.nextUp, 1.84, 4.5, 6.0, 10.0
        ],
        classExpectation: { cls in
            switch cls {
            case .negativeInfinity: .exact(-1.0)
            case .negativeNormal: .finite(Foundation.erf(cls.representative), maxULP: 3)
            case .negativeSubnormal: .subnormal(Foundation.erf(cls.representative), maxULP: 2)
            case .negativeZero: .negativeZero
            case .positiveZero: .positiveZero
            case .positiveSubnormal: .subnormal(Foundation.erf(cls.representative), maxULP: 2)
            case .positiveNormal: .finite(Foundation.erf(cls.representative), maxULP: 3)
            case .positiveInfinity: .exact(1.0)
            case .quietNaN, .signalingNaN: .nan
            }
        },
        oracle: { Foundation.erf($0) },
        exponentSweepEligible: { $0.isFinite }
    )

    static let erfcSpec = UnaryTestSpec(
        maxULP: 6,
        homogeneousInputs: [-6.5, -2.0, -0.5, 0.0, 0.5, 1.0, 2.0, 5.0, 15.0, 26.5, 27.0],
        heterogeneousLanes: [
            [-5.0, -0.5, 0.0, 0.84, 1.84, 4.5, 10.0, 26.8],
            [0.5, .nan, .infinity, -.infinity, -6.5, 27.35, -0.0, 27.1]
        ],
        stabilityTransitions: [
            -10.0, -6.0, -1.84, -0.84375, -0.0, 0.0, 0.84375.nextDown, 0.84375, 0.84375.nextUp,
            1.84.nextDown, 1.84, 1.84.nextUp, 4.5.nextDown, 4.5, 4.5.nextUp,
            10.0, 26.0, 26.54, 26.8, 27.0, 27.15, 27.35, 30.0
        ],
        classExpectation: { cls in
            switch cls {
            case .negativeInfinity: .exact(2.0)
            case .negativeNormal: .finite(Foundation.erfc(cls.representative), maxULP: 4)
            case .negativeSubnormal, .negativeZero, .positiveZero, .positiveSubnormal: .exact(1.0)
            case .positiveNormal: .finite(Foundation.erfc(cls.representative), maxULP: 4)
            case .positiveInfinity: .positiveZero
            case .quietNaN, .signalingNaN: .nan
            }
        },
        oracle: { Foundation.erfc($0) },
        // Exclude (27.15, 27.35) where Darwin C libm erfc flushes valid subnormals (e.g. erfc(27.2)=1e-323) early to 0.0.
        exponentSweepEligible: { $0.isFinite && ($0 <= 27.15 || $0 >= 27.35) }
    )

    // glibc 2.34 aarch64 tgamma drifts up to 4-5 ULP on negative reflection (triangle inequality with <=4 ULP SIMD -> 8);
    // strict <= 4 ULP against exact 0-ULP truth is enforced by Layer 5 MPFR golden corpus and Tools/MPFRAudit.
    static let tgammaSpec = UnaryTestSpec(
        maxULP: 8,
        homogeneousInputs: [0.5, 1.0, 1.5, 2.0, 3.5, 5.0, 8.0, 15.0, 50.0, 150.0, -0.5, -3.5],
        heterogeneousLanes: [
            [0.25, 0.5, 1.0, 1.5, 4.5, 8.0, 50.0, 170.0],
            [1.5, 0.0, -0.0, -1.0, -2.5, .infinity, -.infinity, .nan]
        ],
        stabilityTransitions: [
            -185.0, -176.5, -171.5, -10.5, -3.5, -0.5, 0.001, 0.499, 0.5, 1.0, 1.5, 2.0,
            7.999, 8.0, 8.001, 50.0, 170.0, 171.6, 171.624, 172.0
        ],
        classExpectation: { cls in
            switch cls {
            case .negativeInfinity, .quietNaN, .signalingNaN: .nan
            case .negativeNormal: .finite(Foundation.tgamma(cls.representative), maxULP: 4)
            case .negativeSubnormal: .negativeInfinity
            case .negativeZero: .negativeInfinity
            case .positiveZero: .positiveInfinity
            case .positiveSubnormal: .positiveInfinity
            case .positiveNormal: .finite(Foundation.tgamma(cls.representative), maxULP: 4)
            case .positiveInfinity: .positiveInfinity
            }
        },
        oracle: { Self.scalarTGamma($0) },
        exponentSweepEligible: { x in
            x.isFinite && (x > 0.0 || (x != x.rounded(.down) && x > -176.0))
        }
    )

    static let lgammaSpec = UnaryTestSpec(
        maxULP: 32,
        homogeneousInputs: [0.25, 0.5, 1.0, 1.5, 2.0, 3.5, 6.0, 8.0, 50.0, 1000.0, -0.5, -3.5],
        heterogeneousLanes: [
            [0.1, 0.75, 1.25, 2.0, 3.5, 6.0, 12.0, 1000.0],
            [1.5, 0.0, -0.0, -2.0, -2.5, .infinity, -.infinity, .nan]
        ],
        stabilityTransitions: [
            -100.5, -10.5, -4.5, -3.5, -2.5, -1.5, -0.5, 1.0e-10, 0.5,
            1.0.nextDown, 1.0, 1.0.nextUp, 1.5, 2.0.nextDown, 2.0, 2.0.nextUp,
            2.5, 4.5, 8.0, 100.0, 1.0e10, 1.0e100, 1.0e300
        ],
        classExpectation: { cls in
            switch cls {
            case .negativeInfinity, .positiveInfinity, .negativeZero, .positiveZero: .positiveInfinity
            case .negativeNormal: .finite(Self.scalarLGamma(cls.representative), maxULP: 16)
            case .negativeSubnormal, .positiveSubnormal: .finite(Self.scalarLGamma(cls.representative), maxULP: 4)
            case .positiveNormal: .finite(Self.scalarLGamma(cls.representative), maxULP: 4)
            case .quietNaN, .signalingNaN: .nan
            }
        },
        oracle: { Self.scalarLGamma($0) },
        exponentSweepEligible: { x in
            // Exclude poles (non-positive integers) and tiny neighborhoods around irrational negative zeros where |lgamma| < 1e-12
            guard x.isFinite else { return false }
            if x > 0.0 { return true }
            if x == x.rounded(.down) { return false }
            return Swift.abs(Self.scalarLGamma(x)) > 1.0e-6
        }
    )
}
