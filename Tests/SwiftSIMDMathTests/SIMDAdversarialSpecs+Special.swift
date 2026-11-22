import Foundation
import SwiftSIMDMathTestSupport

extension SIMDUnaryOperation {
    static let erfAdversarial = UnaryAdversarialSpec(
        regimeAnchors: [0.0, 0.84375, 1.84, 4.5, 6.0],
        monotonicity: .nonDecreasing,
        parity: .odd
    ) {
        var rng = SeededSplitMix64(seed: 0xE2F0_2026)
        var xs = (0..<2500).map { _ in (rng.nextUnit() * 2.0 - 1.0) * 6.5 }
        for exp in stride(from: -1074, through: 3, by: 4) {
            let v = scalbn(1.0 + rng.nextUnit(), exp)
            xs.append(v)
            xs.append(-v)
        }
        return xs
    }

    static let erfcAdversarial = UnaryAdversarialSpec(
        regimeAnchors: [-6.0, -0.84375, 0.0, 0.84375, 1.84, 4.5, 26.54, 27.1],
        monotonicity: .nonIncreasing,
        parity: nil
    ) {
        var rng = SeededSplitMix64(seed: 0xE2FC_2026)
        var xs = (0..<2500).map { _ in -6.5 + rng.nextUnit() * 33.6 }
        for idx in 0..<400 { xs.append(26.4 + Double(idx) * (0.74 / 400.0)) }
        return xs
    }

    static let tgammaAdversarial = UnaryAdversarialSpec(
        regimeAnchors: [0.5, 1.0, 1.5, 2.0, 8.0, 171.6],
        monotonicity: nil,
        parity: nil
    ) {
        var rng = SeededSplitMix64(seed: 0x76A0_2026)
        var xs = (0..<2000).map { _ in 0.01 + rng.nextUnit() * 171.5 }
        for _ in 0..<500 {
            let x = -175.0 + rng.nextUnit() * 174.9
            if Swift.abs(x - x.rounded(.toNearestOrAwayFromZero)) > 1.0e-3 { xs.append(x) }
        }
        return xs
    }

    static let lgammaAdversarial = UnaryAdversarialSpec(
        regimeAnchors: [0.5, 1.0, 1.5, 2.0, 2.5, 4.5, 8.0, 1000.0],
        monotonicity: nil,
        parity: nil
    ) {
        var rng = SeededSplitMix64(seed: 0x16A0_2026)
        var xs = (0..<2000).map { _ in 0.01 + rng.nextUnit() * 50.0 }
        for exp in stride(from: -50, through: 990, by: 4) {
            xs.append(scalbn(1.0 + rng.nextUnit(), exp))
        }
        for _ in 0..<400 {
            let x = -50.0 + rng.nextUnit() * 49.9
            if Swift.abs(x - x.rounded(.toNearestOrAwayFromZero)) > 1.0e-2,
                Swift.abs(SIMDUnaryOperation.scalarLGamma(x)) > 1.0e-4
            {
                xs.append(x)
            }
        }
        return xs
    }
}
