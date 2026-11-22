import Foundation
import SwiftSIMDMathTestSupport

// MARK: - Geometric & Shaping Adversarial Specs (atan2, hypot, step, clamp, mix, smoothstep)

extension SIMDBinaryOperation {
    static let atan2Adversarial = BinaryAdversarialSpec(
        isCommutative: false,
        fuzzPairs: {
            var rng = SeededSplitMix64(seed: 0xA7A2_2026)
            var pairs: [BinaryInput] = []
            pairs.reserveCapacity(4000)
            for _ in 0..<2500 {
                let y = (rng.nextUnit() * 2.0 - 1.0) * 10.0
                let x = (rng.nextUnit() * 2.0 - 1.0) * 10.0
                pairs.append(BinaryInput(a: y, b: x))
            }
            for _ in 0..<1500 {
                let ey = Int(rng.next() % 2098) - 1074
                let ex = Int(rng.next() % 2098) - 1074
                let y = scalbn(1.0 + rng.nextUnit(), ey)
                let x = scalbn(1.0 + rng.nextUnit(), ex)
                pairs.append(
                    BinaryInput(a: (rng.next() & 1) == 0 ? y : -y, b: (rng.next() & 1) == 0 ? x : -x))
            }
            return pairs
        },
        algebraicChecks: {
            var checks: [(BinaryInput, ExpectedIEEE754Result)] = []
            for v in [Double.leastNonzeroMagnitude, 1.0e-100, 0.5, 1.0, 42.0, 1.0e100, Double.greatestFiniteMagnitude] {
                checks.append((BinaryInput(a: v, b: v), .finite(Double.pi * 0.25, maxULP: 1)))
                checks.append((BinaryInput(a: -v, b: v), .finite(-Double.pi * 0.25, maxULP: 1)))
                checks.append((BinaryInput(a: v, b: -v), .finite(3.0 * Double.pi * 0.25, maxULP: 1)))
                checks.append((BinaryInput(a: -v, b: -v), .finite(-3.0 * Double.pi * 0.25, maxULP: 1)))
            }
            return checks
        }
    )

    static let hypotAdversarial = BinaryAdversarialSpec(
        isCommutative: true,
        fuzzPairs: {
            var rng = SeededSplitMix64(seed: 0x1149_2026)
            var pairs: [BinaryInput] = []
            pairs.reserveCapacity(3500)
            for _ in 0..<2000 {
                let a = (rng.nextUnit() * 2.0 - 1.0) * 100.0
                let b = (rng.nextUnit() * 2.0 - 1.0) * 100.0
                pairs.append(BinaryInput(a: a, b: b))
            }
            for _ in 0..<1500 {
                let ea = Int(rng.next() % 2098) - 1074
                let eb = Int(rng.next() % 2098) - 1074
                let a = scalbn(1.0 + rng.nextUnit(), ea)
                let b = scalbn(1.0 + rng.nextUnit(), eb)
                pairs.append(
                    BinaryInput(a: (rng.next() & 1) == 0 ? a : -a, b: (rng.next() & 1) == 0 ? b : -b))
            }
            return pairs
        },
        algebraicChecks: {
            var checks: [(BinaryInput, ExpectedIEEE754Result)] = []
            for scale in [0x1.0p-1000, 0x1.0p-500, 1.0, 0x1.0p500, 0x1.0p1000] {
                checks.append((BinaryInput(a: 3.0 * scale, b: 4.0 * scale), .finite(5.0 * scale, maxULP: 1)))
                checks.append((BinaryInput(a: 5.0 * scale, b: 12.0 * scale), .finite(13.0 * scale, maxULP: 1)))
            }
            return checks
        }
    )

    static let stepAdversarial = BinaryAdversarialSpec(
        isCommutative: false,
        fuzzPairs: {
            var rng = SeededSplitMix64(seed: 0x57E9_2026)
            return (0..<2000).map { idx in
                let edge = (rng.nextUnit() * 2.0 - 1.0) * 100.0
                let x: Double =
                    switch idx % 4 {
                    case 0: edge.nextDown
                    case 1: edge
                    case 2: edge.nextUp
                    default: (rng.nextUnit() * 2.0 - 1.0) * 100.0
                    }
                return BinaryInput(a: x, b: edge)
            }
        },
        algebraicChecks: { [] }
    )
}

extension SIMDTernaryOperation {
    /// Compile-time exhaustive adversarial & invariant spec (zero `default:` branches).
    var adversarialSpec: TernaryAdversarialSpec {
        switch self {
        case .clamp:
            TernaryAdversarialSpec(checkIdempotenceAndBounds: true) {
                var rng = SeededSplitMix64(seed: 0xC1A0_2026)
                return (0..<2000).map { _ in
                    let x = (rng.nextUnit() * 2.0 - 1.0) * 1e6
                    let a = (rng.nextUnit() * 2.0 - 1.0) * 1e6
                    let b = (rng.nextUnit() * 2.0 - 1.0) * 1e6
                    let swap = (rng.next() & 3) == 0
                    let lo = swap ? Swift.max(a, b) : Swift.min(a, b)
                    let hi = swap ? Swift.min(a, b) : Swift.max(a, b)
                    return TernaryInput(x: x, lower: lo, upper: hi)
                }
            }

        case .mix:
            TernaryAdversarialSpec(checkIdempotenceAndBounds: false) {
                var rng = SeededSplitMix64(seed: 0x4110_2026)
                return (0..<2000).map { idx in
                    let a = (rng.nextUnit() * 2.0 - 1.0) * 1e4
                    let b = (rng.nextUnit() * 2.0 - 1.0) * 1e4
                    let t: Double =
                        switch idx % 5 {
                        case 0: 0.0
                        case 1: 1.0
                        case 2: 0.5
                        default: rng.nextUnit() * 3.0 - 1.0
                        }
                    return TernaryInput(x: a, lower: b, upper: t)
                }
            }

        case .smoothstep:
            TernaryAdversarialSpec(checkIdempotenceAndBounds: false) {
                var rng = SeededSplitMix64(seed: 0x5400_2026)
                return (0..<2000).map { _ in
                    let e0 = (rng.nextUnit() * 2.0 - 1.0) * 100.0
                    let e1 = (rng.nextUnit() * 2.0 - 1.0) * 100.0
                    let x = (rng.nextUnit() * 2.0 - 1.0) * 150.0
                    return TernaryInput(x: x, lower: e0, upper: e1)
                }
            }
        }
    }
}
