import Foundation
import SwiftSIMDMathTestSupport

// MARK: - Single-Source-of-Truth Adversarial & Algebraic Invariant Specs (Binary & Dual)

struct BinaryAdversarialSpec: Sendable {
    let isCommutative: Bool
    let fuzzPairs: @Sendable () -> [BinaryInput]
    let algebraicChecks: @Sendable () -> [(BinaryInput, ExpectedIEEE754Result)]
}

struct TernaryAdversarialSpec: Sendable {
    let checkIdempotenceAndBounds: Bool
    let fuzzTriplets: @Sendable () -> [TernaryInput]
}

struct DualUnaryAdversarialSpec: Sendable {
    let regimeAnchors: [Double]
    let checkPythagorean: Bool
    let checkParity: Bool
    let fuzzInputs: @Sendable () -> [Double]
}

extension SIMDBinaryOperation {
    /// Compile-time exhaustive adversarial & algebraic spec (zero `default:` branches).
    var adversarialSpec: BinaryAdversarialSpec {
        switch self {
        case .pow: Self.powAdversarial
        case .atan2: Self.atan2Adversarial
        case .hypot: Self.hypotAdversarial
        case .min, .max: Self.minMaxAdversarial
        case .step: Self.stepAdversarial
        }
    }

    private static let powAdversarial = BinaryAdversarialSpec(
        isCommutative: false,
        fuzzPairs: {
            var rng = SeededSplitMix64(seed: 0x9040_2026)
            var pairs: [BinaryInput] = []
            pairs.reserveCapacity(6500)
            for idx in 0..<256 {
                let mid = 1.0 + (Double(idx) + 0.5) / 256.0
                let target = (rng.nextUnit() * 2.0 - 1.0) * 1018.0
                pairs.append(BinaryInput(a: mid, b: target / Foundation.log2(mid)))
                let carry = scalbn(2.0 - (1.0 / 512.0) * rng.nextUnit(), Int(rng.next() % 2046) - 1022)
                let lc = Foundation.log2(carry)
                if lc != 0.0 {
                    pairs.append(BinaryInput(a: carry, b: target / lc))
                }
            }
            for _ in 0..<2000 {
                let x = 1.0 + (rng.nextUnit() * 2.0 - 1.0) * 0.02
                if x <= 0.0 || x == 1.0 { continue }
                let target = (rng.nextUnit() * 2.0 - 1.0) * 1076.0
                pairs.append(BinaryInput(a: x, b: target / Foundation.log2(x)))
            }
            for _ in 0..<1500 {
                let x = 0.01 + rng.nextUnit() * 100.0
                if x == 1.0 { continue }
                let target =
                    (rng.next() & 1) == 0
                    ? (1018.0 + rng.nextUnit() * 8.0)
                    : (-1076.0 + rng.nextUnit() * 58.0)
                pairs.append(BinaryInput(a: x, b: target / Foundation.log2(x)))
            }
            for _ in 0..<1500 {
                switch rng.next() % 4 {
                case 0:
                    let x = scalbn(1.0 + rng.nextUnit(), -1074 + Int(rng.next() % 52))
                    pairs.append(BinaryInput(a: x, b: (rng.nextUnit() * 2.0 - 1.0) * 2.0))

                case 1:
                    let x = -(0.01 + rng.nextUnit() * 10.0)
                    pairs.append(BinaryInput(a: x, b: Double(Int64(rng.next() % 2000) - 1000)))

                case 2:
                    let x = -(0.9999999999999 + rng.nextUnit() * 2e-13)
                    pairs.append(BinaryInput(a: x, b: Double((1 << 52) + Int64(rng.next() % 1000))))

                default:
                    let x = -(0.01 + rng.nextUnit() * 10.0)
                    pairs.append(BinaryInput(a: x, b: Double(Int64(rng.next() % 100) - 50) + 0.25))
                }
            }
            return pairs
        },
        algebraicChecks: {
            var checks: [(BinaryInput, ExpectedIEEE754Result)] = []
            for exp in stride(from: -1074, through: 1023, by: 7) {
                let exact = scalbn(1.0, exp)
                checks.append((BinaryInput(a: 2.0, b: Double(exp)), .exact(exact)))
            }
            checks.append((BinaryInput(a: 2.0, b: -1074.0), .exact(Double.leastNonzeroMagnitude)))
            checks.append((BinaryInput(a: 2.0, b: 1023.0), .exact(scalbn(1.0, 1023))))
            for x in [0.125, 0.7, 1.0, 1.5, 3.141592653589793, 42.5, 1e100] {
                checks.append((BinaryInput(a: x, b: 1.0), .finite(x, maxULP: 1)))
                checks.append((BinaryInput(a: x, b: 2.0), .finite(x * x, maxULP: 1)))
                checks.append((BinaryInput(a: x, b: 0.5), .finite(x.squareRoot(), maxULP: 1)))
            }
            return checks
        }
    )

    private static let minMaxAdversarial = BinaryAdversarialSpec(
        isCommutative: true,
        fuzzPairs: {
            var rng = SeededSplitMix64(seed: 0x0110_2026)
            return (0..<2000).map { _ in
                let a = scalbn(1.0 + rng.nextUnit(), Int(rng.next() % 2098) - 1074)
                let b = scalbn(1.0 + rng.nextUnit(), Int(rng.next() % 2098) - 1074)
                return BinaryInput(
                    a: (rng.next() & 1) == 0 ? a : -a,
                    b: (rng.next() & 1) == 0 ? b : -b
                )
            }
        },
        algebraicChecks: { [] }
    )
}

extension SIMDDualUnaryOperation {
    /// Compile-time exhaustive adversarial & invariant spec (zero `default:` branches).
    var adversarialSpec: DualUnaryAdversarialSpec {
        switch self {
        case .sincos:
            let trigSpec = SIMDUnaryOperation.sin.adversarialSpec
            return DualUnaryAdversarialSpec(
                regimeAnchors: trigSpec.regimeAnchors,
                checkPythagorean: true,
                checkParity: true,
                fuzzInputs: trigSpec.fuzzInputs
            )

        case .sincospi:
            let piSpec = SIMDUnaryOperation.sinpi.adversarialSpec
            return DualUnaryAdversarialSpec(
                regimeAnchors: piSpec.regimeAnchors,
                checkPythagorean: true,
                checkParity: true,
                fuzzInputs: piSpec.fuzzInputs
            )
        }
    }
}
