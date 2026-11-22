import Foundation
import SwiftSIMDMathTestSupport

// MARK: - Pi-Scaled Trigonometric Unary Grounding Specs (sinpi, cospi, tanpi)

extension SIMDUnaryOperation {
    static func scalarSinPi(_ x: Double) -> Double {
        #if canImport(Darwin)
            return __sinpi(x)
        #else
            if !x.isFinite { return .nan }
            if Swift.abs(x) >= 0x1.0p53 { return x * 0.0 }
            let y = x * 2.0
            let q = y.rounded(.toNearestOrAwayFromZero)
            let r = (y - q) * (Double.pi * 0.5)
            let val: Double =
                switch Int64(q) & 3 {
                case 0: Foundation.sin(r)
                case 1: Foundation.cos(r)
                case 2: -Foundation.sin(r)
                default: -Foundation.cos(r)
                }
            return val == 0.0 ? x * 0.0 : val
        #endif
    }

    static func scalarCosPi(_ x: Double) -> Double {
        #if canImport(Darwin)
            return __cospi(x)
        #else
            if !x.isFinite { return .nan }
            if Swift.abs(x) >= 0x1.0p53 { return 1.0 }
            let y = x * 2.0
            let q = y.rounded(.toNearestOrAwayFromZero)
            let r = (y - q) * (Double.pi * 0.5)
            let val: Double =
                switch Int64(q) & 3 {
                case 0: Foundation.cos(r)
                case 1: -Foundation.sin(r)
                case 2: -Foundation.cos(r)
                default: Foundation.sin(r)
                }
            return val == 0.0 ? 0.0 : val
        #endif
    }

    static func scalarTanPi(_ x: Double) -> Double {
        #if canImport(Darwin)
            let s = __sinpi(x)
            let c = __cospi(x)
            if !x.isFinite || s == 0.0 || c == 0.0 {
                return __tanpi(x)
            }
            return s / c
        #else
            if !x.isFinite { return .nan }
            if Swift.abs(x) >= 0x1.0p53 { return x * 0.0 }
            let y = x * 2.0
            let q = y.rounded(.toNearestOrAwayFromZero)
            let f = y - q
            let qi = Int64(q)
            let isOdd = (qi & 1) != 0
            if f == 0.0 {
                let qSign = UInt64(bitPattern: (qi & 2) << 62)
                if isOdd { return Double(bitPattern: 0x7FF0_0000_0000_0000 ^ qSign) }
                return Double(bitPattern: (x.bitPattern & 0x8000_0000_0000_0000) ^ qSign)
            }
            let r = f * (Double.pi * 0.5)
            return isOdd ? (-Foundation.cos(r) / Foundation.sin(r)) : Foundation.tan(r)
        #endif
    }

    static let piTrigTransitions: [Double] = [
        -Double.greatestFiniteMagnitude, -1.0e20, -0x1.0p53, -0x1.0p52 - 1.0, -0x1.0p52,
        -0x1.0p52 + 0.5, -0x1.0p50, -2.5, -2.0, -1.5, -1.0, -0.5, -0.25, -0.0, 0.0,
        Double.leastNonzeroMagnitude, 0.25, 0.5, 1.0, 1.5, 2.0, 2.5, 0x1.0p50.nextDown, 0x1.0p50,
        0x1.0p52 - 0.5, 0x1.0p52, 0x1.0p52 + 1.0, 0x1.0p53, 1.0e20, Double.greatestFiniteMagnitude
    ]

    static let sinpiSpec = UnaryTestSpec(
        maxULP: 2,
        homogeneousInputs: [-2.25, -1.5, -0.75, -0.25, 0.0, 0.25, 0.75, 1.5, 2.25],
        heterogeneousLanes: [
            [-1.7, -0.8, -0.3, 0.15, 0.65, 1.25, 2.4, 3.9],
            [0.5, 1.0, -1.0, -0.0, .infinity, -.infinity, .nan, 0x1.0p52 + 1.0]
        ],
        stabilityTransitions: piTrigTransitions,
        classExpectation: { cls in
            switch cls {
            case .negativeInfinity, .positiveInfinity, .quietNaN, .signalingNaN: .nan
            case .negativeZero: .negativeZero
            case .positiveZero: .positiveZero
            case .negativeSubnormal, .positiveSubnormal: .subnormal(scalarSinPi(cls.representative), maxULP: 1)
            case .negativeNormal, .positiveNormal: .finite(scalarSinPi(cls.representative), maxULP: 2)
            }
        },
        oracle: { scalarSinPi($0) },
        exponentSweepEligible: { $0.isFinite }
    )

    static let cospiSpec = UnaryTestSpec(
        maxULP: 2,
        homogeneousInputs: [-2.25, -1.5, -0.75, -0.25, 0.0, 0.25, 0.75, 1.5, 2.25],
        heterogeneousLanes: [
            [-1.7, -0.8, -0.3, 0.15, 0.65, 1.25, 2.4, 3.9],
            [0.5, 1.0, -1.0, -0.0, .infinity, -.infinity, .nan, 0x1.0p52 + 1.0]
        ],
        stabilityTransitions: piTrigTransitions,
        classExpectation: { cls in
            switch cls {
            case .negativeInfinity, .positiveInfinity, .quietNaN, .signalingNaN: .nan
            case .negativeSubnormal, .negativeZero, .positiveZero, .positiveSubnormal: .exact(1.0)
            case .negativeNormal, .positiveNormal: .finite(scalarCosPi(cls.representative), maxULP: 2)
            }
        },
        oracle: { scalarCosPi($0) },
        exponentSweepEligible: { $0.isFinite }
    )

    static let tanpiSpec = UnaryTestSpec(
        maxULP: 3,
        homogeneousInputs: [-2.25, -1.25, -0.75, -0.25, 0.0, 0.25, 0.75, 1.25, 2.25],
        heterogeneousLanes: [
            [-1.7, -0.8, -0.3, 0.15, 0.65, 1.25, 2.4, 3.9],
            [0.5, -0.5, 1.0, -1.0, .infinity, -.infinity, .nan, 0x1.0p52 + 1.0]
        ],
        stabilityTransitions: piTrigTransitions,
        classExpectation: { cls in
            switch cls {
            case .negativeInfinity, .positiveInfinity, .quietNaN, .signalingNaN:
                .nan

            case .negativeZero:
                .negativeZero

            case .positiveZero:
                .positiveZero

            case .negativeSubnormal, .positiveSubnormal:
                .subnormal(scalarTanPi(cls.representative), maxULP: 1)

            case .negativeNormal, .positiveNormal:
                ExpectedIEEE754Result.fromOracle(scalarTanPi(cls.representative), maxULP: 3)
            }
        },
        oracle: { scalarTanPi($0) },
        exponentSweepEligible: { $0.isFinite }
    )
}
