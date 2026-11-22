import Foundation
import SwiftSIMDMathTestSupport

extension SIMDUnaryOperation {
    static let exp2Adversarial = UnaryAdversarialSpec(
        regimeAnchors: [0.0, -1074.0, -1022.0, 1022.0, 1023.9999999999999],
        monotonicity: .nonDecreasing,
        parity: nil
    ) {
        var rng = SeededSplitMix64(seed: 0xE200_2026)
        var xs = (0..<2500).map { _ in (rng.nextUnit() * 2.0 - 1.0) * 1023.0 }
        for k in stride(from: -1075, through: 1024, by: 3) { xs.append(Double(k)) }
        return xs
    }

    static let exp10Adversarial = UnaryAdversarialSpec(
        regimeAnchors: [0.0, -323.3, -307.0, 1.0, 22.0, 307.0, 308.2547],
        monotonicity: .nonDecreasing,
        parity: nil
    ) {
        var rng = SeededSplitMix64(seed: 0xE100_2026)
        var xs = (0..<2500).map { _ in (rng.nextUnit() * 2.0 - 1.0) * 308.0 }
        for k in -324...308 { xs.append(Double(k)) }
        return xs
    }

    static let expm1Adversarial = UnaryAdversarialSpec(
        regimeAnchors: [0.0, -37.0, -0.34657359, 0.34657359, 0.69314718, 708.0],
        monotonicity: .nonDecreasing,
        parity: nil
    ) {
        var rng = SeededSplitMix64(seed: 0xE111_2026)
        var xs = (0..<2000).map { _ in (rng.nextUnit() * 2.0 - 1.0) * 50.0 }
        for exp in stride(from: -1074, through: 9, by: 3) {
            let v = scalbn(1.0 + rng.nextUnit(), exp)
            xs.append(v)
            xs.append(-v)
        }
        return xs
    }

    static let log1pAdversarial = UnaryAdversarialSpec(
        regimeAnchors: [-1.0.nextUp, -0.5, -0.29289322, 0.0, 0.41421356, 1.0],
        monotonicity: .nonDecreasing,
        parity: nil
    ) {
        var rng = SeededSplitMix64(seed: 0x1091_2026)
        var xs = (0..<1500).map { _ in -0.999999 + rng.nextUnit() * 20.0 }
        for exp in stride(from: -1074, through: 1020, by: 4) {
            let v = scalbn(1.0 + rng.nextUnit(), exp)
            if v.isFinite { xs.append(v) }
            if -v > -1.0 { xs.append(-v) }
        }
        return xs
    }
}
