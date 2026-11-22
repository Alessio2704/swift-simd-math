import Foundation
import SwiftSIMDMathTestSupport

// MARK: - Cube Root & Unary Shaping Adversarial Specs (cbrt, sign, fract)

extension SIMDUnaryOperation {
    static let cbrtAdversarial = UnaryAdversarialSpec(
        regimeAnchors: [
            -Double.leastNormalMagnitude, 0.0, Double.leastNormalMagnitude,
            1.0, 2.0, 4.0, 8.0, 27.0, 64.0, 0x1.0p300
        ],
        monotonicity: .nonDecreasing,
        parity: .odd
    ) {
        var rng = SeededSplitMix64(seed: 0xCB37_2026)
        var xs: [Double] = []
        xs.reserveCapacity(4000)
        for k in -20...20 {
            let cube = Double(k * k * k)
            xs.append(cube.nextDown)
            xs.append(cube)
            xs.append(cube.nextUp)
        }
        for exp in stride(from: -1074, through: 1023, by: 2) {
            let v = scalbn(1.0 + rng.nextUnit(), exp)
            if v.isFinite {
                xs.append(v)
                xs.append(-v)
            }
        }
        return xs
    }

    static let signAdversarial = UnaryAdversarialSpec(
        regimeAnchors: [
            -Double.leastNormalMagnitude, -Double.leastNonzeroMagnitude, 0.0,
            Double.leastNonzeroMagnitude, Double.leastNormalMagnitude
        ],
        monotonicity: .nonDecreasing,
        parity: .odd
    ) {
        var rng = SeededSplitMix64(seed: 0x5160_2026)
        return (0..<1500).map { _ in
            let exp = Int(rng.next() % 2098) - 1074
            let v = scalbn(1.0 + rng.nextUnit(), exp)
            return (rng.next() & 1) == 0 ? v : -v
        }
    }

    static let fractAdversarial = UnaryAdversarialSpec(
        regimeAnchors: [-2.0, -1.0, -Double.leastNonzeroMagnitude, 0.0, 1.0, 2.0, 0x1.0p52],
        monotonicity: nil,
        parity: nil
    ) {
        var rng = SeededSplitMix64(seed: 0xF4AC_2026)
        var xs: [Double] = []
        xs.reserveCapacity(3000)
        for k in -200...200 {
            let v = Double(k)
            xs.append(v.nextDown)
            xs.append(v)
            xs.append(v.nextUp)
        }
        for _ in 0..<2000 {
            let exp = Int(rng.next() % 115) - 60
            let v = scalbn(1.0 + rng.nextUnit(), exp)
            xs.append((rng.next() & 1) == 0 ? v : -v)
        }
        return xs
    }
}
