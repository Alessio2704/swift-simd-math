import Foundation
import SwiftSIMDMathTestSupport

extension SIMDUnaryOperation {
    static let sinhAdversarial = UnaryAdversarialSpec(
        regimeAnchors: [0.0, 0.34657359, 0.5, 0.7982323160529248, 0.8828125, 1.0, 22.0, 708.0, 709.78, 710.475],
        monotonicity: .nonDecreasing,
        parity: .odd
    ) {
        var rng = SeededSplitMix64(seed: 0x5144_2026)
        var xs = (0..<2000).map { _ in (rng.nextUnit() * 2.0 - 1.0) * 710.4 }
        for exp in stride(from: -1074, through: 9, by: 4) {
            let v = scalbn(1.0 + rng.nextUnit(), exp)
            if v < 710.4 {
                xs.append(v)
                xs.append(-v)
            }
        }
        return xs
    }

    static let coshAdversarial = UnaryAdversarialSpec(
        regimeAnchors: [0.0, 22.0, 708.0, 709.78, 710.475],
        monotonicity: nil,
        parity: .even
    ) {
        var rng = SeededSplitMix64(seed: 0xC054_2026)
        return (0..<2500).map { _ in (rng.nextUnit() * 2.0 - 1.0) * 710.4 }
    }

    static let tanhAdversarial = UnaryAdversarialSpec(
        regimeAnchors: [0.0, 0.34657359, 0.5, 0.5625, 1.0, 19.5, 20.0, 25.0],
        monotonicity: .nonDecreasing,
        parity: .odd
    ) {
        var rng = SeededSplitMix64(seed: 0x7A44_2026)
        var xs = (0..<2000).map { _ in (rng.nextUnit() * 2.0 - 1.0) * 25.0 }
        for exp in stride(from: -1074, through: 10, by: 4) {
            let v = scalbn(1.0 + rng.nextUnit(), exp)
            xs.append(v)
            xs.append(-v)
        }
        return xs
    }

    static let asinhAdversarial = UnaryAdversarialSpec(
        regimeAnchors: [0.0, 0.125, 1.0, 0x1.0p28, 1.0e100],
        monotonicity: .nonDecreasing,
        parity: .odd
    ) {
        var rng = SeededSplitMix64(seed: 0xA514_2026)
        var xs: [Double] = []
        for exp in stride(from: -1074, through: 1022, by: 2) {
            let v = scalbn(1.0 + rng.nextUnit(), exp)
            if v.isFinite {
                xs.append(v)
                xs.append(-v)
            }
        }
        return xs
    }

    static let acoshAdversarial = UnaryAdversarialSpec(
        regimeAnchors: [1.0, 1.0.nextUp, 2.0, 0x1.0p28, 1.0e100],
        monotonicity: .nonDecreasing,
        parity: nil
    ) {
        var rng = SeededSplitMix64(seed: 0xAC05_2026)
        var xs = (0..<1000).map { _ in 1.0 + rng.nextUnit() * 10.0 }
        for exp in stride(from: 0, through: 1022, by: 1) {
            let v = scalbn(1.0 + rng.nextUnit(), exp)
            if v >= 1.0, v.isFinite { xs.append(v) }
        }
        return xs
    }

    static let atanhAdversarial = UnaryAdversarialSpec(
        regimeAnchors: [0.0, 0.5, 1.0.nextDown],
        monotonicity: .nonDecreasing,
        parity: .odd
    ) {
        var rng = SeededSplitMix64(seed: 0xA7A4_2026)
        var xs = (0..<2000).map { _ in (rng.nextUnit() * 2.0 - 1.0) * 0.999999 }
        for exp in stride(from: -1074, through: -1, by: 3) {
            let v = scalbn(1.0 + rng.nextUnit(), exp)
            if v < 1.0 {
                xs.append(v)
                xs.append(-v)
            }
        }
        return xs
    }
}
