import Foundation
import SwiftSIMDMathTestSupport

// MARK: - Inverse Trigonometric & Pi-Scaled Trigonometric Adversarial Specs

extension SIMDUnaryOperation {
    static let asinAdversarial = UnaryAdversarialSpec(
        regimeAnchors: [-1.0, -0.5, 0.0, 0.5, 1.0],
        monotonicity: .nonDecreasing,
        parity: .odd
    ) {
        var rng = SeededSplitMix64(seed: 0xA510_2026)
        var xs: [Double] = []
        xs.reserveCapacity(4000)
        for idx in 0..<2000 {
            xs.append(-1.0 + Double(idx) * (2.0 / 1999.0))
        }
        for _ in 0..<1500 {
            let v = scalbn(1.0 + rng.nextUnit(), -1 - Int(rng.next() % 60))
            xs.append((rng.next() & 1) == 0 ? v : -v)
        }
        for _ in 0..<500 {
            let eps = scalbn(1.0 + rng.nextUnit(), -1 - Int(rng.next() % 52))
            xs.append(1.0 - eps)
            xs.append(-(1.0 - eps))
        }
        return xs
    }

    static let acosAdversarial = UnaryAdversarialSpec(
        regimeAnchors: [-1.0, -0.5, 0.0, 0.5, 1.0],
        monotonicity: .nonIncreasing,
        parity: nil,
        fuzzInputs: asinAdversarial.fuzzInputs
    )

    static let atanAdversarial = UnaryAdversarialSpec(
        regimeAnchors: [
            -2.41421356237309505, -0.41421356237309505, 0.0,
            0.41421356237309505, 2.41421356237309505, 1.0e10
        ],
        monotonicity: .nonDecreasing,
        parity: .odd
    ) {
        var rng = SeededSplitMix64(seed: 0xA7A0_2026)
        var xs: [Double] = []
        xs.reserveCapacity(4000)
        for _ in 0..<2500 {
            let v = (rng.nextUnit() * 2.0 - 1.0) * 5.0
            xs.append(v)
        }
        for _ in 0..<1500 {
            let exp = Int(rng.next() % 2098) - 1074
            let v = scalbn(1.0 + rng.nextUnit(), exp)
            if v.isFinite {
                xs.append((rng.next() & 1) == 0 ? v : -v)
            }
        }
        return xs
    }

    static func piTrigAdversarial(parity: ParityInvariant) -> UnaryAdversarialSpec {
        UnaryAdversarialSpec(
            regimeAnchors: [0.0, 0.25, 0.5, 1.0, 1.5, 2.0, 0x1.0p50, 0x1.0p52, 0x1.0p53],
            monotonicity: nil,
            parity: parity
        ) {
            var rng = SeededSplitMix64(seed: 0x3141_2026)
            var xs: [Double] = []
            xs.reserveCapacity(4500)
            for k in -200...200 {
                let half = Double(k) * 0.5
                xs.append(half.nextDown)
                xs.append(half)
                xs.append(half.nextUp)
            }
            for _ in 0..<2000 {
                xs.append((rng.nextUnit() * 2.0 - 1.0) * 1000.0)
            }
            for _ in 0..<1000 {
                let exp = Int(rng.next() % 110) - 55
                let v = scalbn(1.0 + rng.nextUnit(), exp)
                xs.append((rng.next() & 1) == 0 ? v : -v)
            }
            return xs
        }
    }
}
