#if canImport(simd)
    import Dispatch
    import Foundation
    import Testing
    import simd

    import SwiftSIMDMath
    import SwiftSIMDMathTestSupport

    @Suite("SIMDMath vs Apple Native <simd/simd.h> Head-to-Head Performance", .serialized)
    struct SIMDPerformanceTests {
        struct BenchmarkOutcome: Sendable {
            let label: String
            let iters: Int
            let ratio: Double
        }

        static let minBenchmarkIterations = 100_000
        static let expInput = SIMD8<Double>(-8.5, -3.2, -0.7, 0.1, 0.9, 2.4, 5.1, 11.3)
        static let logInput = SIMD8<Double>(0.01, 0.3, 0.9, 1.3, 1.7, 4.2, 18.5, 250.0)
        static let trigInput = SIMD8<Double>(-3.0, -1.2, -0.3, 0.4, 1.1, 2.3, 3.8, 5.5)
        static let unitTurns = SIMD8<Double>(0.05, 0.18, 0.31, 0.44, 0.57, 0.69, 0.82, 0.94)
        static let powBase = SIMD8<Double>(0.25, 0.7, 1.3, 2.1, 3.5, 5.0, 8.2, 14.0)
        static let powExp = SIMD8<Double>(-2.3, -0.5, 0.25, 0.5, 1.5, 2.0, 2.5, 3.0)
        static let minMaxB = SIMD8<Double>(-4.0, 1.0, -1.0, 0.5, -0.5, 3.0, -2.0, 8.0)

        @Test("Unary parity benchmark", .serialized, arguments: SIMDUnaryOperation.allCases)
        func benchmarkUnary(op: SIMDUnaryOperation) {
            let outcome = runUnaryBenchmark(op)
            #expect(outcome.label == op.rawValue && outcome.iters >= Self.minBenchmarkIterations)
        }

        @Test("Binary parity benchmark", .serialized, arguments: SIMDBinaryOperation.allCases)
        func benchmarkBinary(op: SIMDBinaryOperation) {
            let outcome = runBinaryBenchmark(op)
            #expect(outcome.label == op.rawValue && outcome.iters >= Self.minBenchmarkIterations)
        }

        @Test("Ternary parity benchmark", .serialized, arguments: SIMDTernaryOperation.allCases)
        func benchmarkTernary(op: SIMDTernaryOperation) {
            let outcome = runTernaryBenchmark(op)
            #expect(outcome.label == op.rawValue && outcome.iters >= Self.minBenchmarkIterations)
        }

        @Test("Dual-unary parity benchmark", .serialized, arguments: SIMDDualUnaryOperation.allCases)
        func benchmarkDualUnary(op: SIMDDualUnaryOperation) {
            let outcome = runDualUnaryBenchmark(op)
            #expect(outcome.label == op.rawValue && outcome.iters >= Self.minBenchmarkIterations)
        }

        func runBinaryBenchmark(_ op: SIMDBinaryOperation) -> BenchmarkOutcome {
            let b = Self.minMaxB
            switch op {
            case .pow:
                let expV = Self.powExp
                return runComparison(
                    label: op.rawValue, iters: 250_000, initV: Self.powBase,
                    swift: { SIMDMath.pow($0, expV) }, apple: { simd.pow($0, expV) })

            case .atan2:
                return runComparison(
                    label: op.rawValue, iters: 500_000, initV: Self.trigInput,
                    swift: { SIMDMath.atan2($0, b) }, apple: { simd.atan2($0, b) })

            case .hypot:
                return runComparison(
                    label: op.rawValue, iters: 1_000_000, initV: Self.expInput,
                    swift: { SIMDMath.hypot($0, b) }, apple: { simd.hypot($0, b) })

            case .min:
                return runComparison(
                    label: op.rawValue, iters: 5_000_000, initV: Self.expInput,
                    swift: { SIMDMath.min($0, b) }, apple: { Self.appleMin($0, b) })

            case .max:
                return runComparison(
                    label: op.rawValue, iters: 5_000_000, initV: Self.expInput,
                    swift: { SIMDMath.max($0, b) }, apple: { Self.appleMax($0, b) })

            case .step:
                return runComparison(
                    label: op.rawValue, iters: 5_000_000, initV: Self.expInput,
                    swift: { SIMDMath.step($0, edge: b) }, apple: { Self.appleStep($0, edge: b) })
            }
        }

        func runTernaryBenchmark(_ op: SIMDTernaryOperation) -> BenchmarkOutcome {
            let lo = SIMD8<Double>(repeating: -3.0)
            let hi = SIMD8<Double>(repeating: 4.0)
            let t = Self.unitTurns
            switch op {
            case .clamp:
                return runComparison(
                    label: op.rawValue, iters: 5_000_000, initV: Self.expInput,
                    swift: { SIMDMath.clamp($0, min: lo, max: hi) },
                    apple: { Self.appleClamp($0, lo: lo, hi: hi) })

            case .mix:
                return runComparison(
                    label: op.rawValue, iters: 5_000_000, initV: Self.expInput,
                    swift: { SIMDMath.mix($0, Self.minMaxB, t: t) },
                    apple: { Self.appleMix($0, Self.minMaxB, t: t) })

            case .smoothstep:
                return runComparison(
                    label: op.rawValue, iters: 2_000_000, initV: Self.expInput,
                    swift: { SIMDMath.smoothstep($0, edge0: lo, edge1: hi) },
                    apple: { Self.appleSmoothstep($0, edge0: lo, edge1: hi) })
            }
        }

        func runDualUnaryBenchmark(_ op: SIMDDualUnaryOperation) -> BenchmarkOutcome {
            switch op {
            case .sincos:
                return runComparison(
                    label: op.rawValue, iters: 500_000, initV: Self.trigInput,
                    swift: { x in
                        let (s, c) = SIMDMath.sincos(x)
                        return s + c
                    },
                    apple: { x in
                        let r = simd.sincos(x)
                        return r.sin + r.cos
                    })

            case .sincospi:
                return runComparison(
                    label: op.rawValue, iters: 500_000, initV: Self.trigInput,
                    swift: { x in
                        let (s, c) = SIMDMath.sincospi(x)
                        return s + c
                    },
                    apple: { x in
                        let r = simd.sincospi(x)
                        return r.sin + r.cos
                    })
            }
        }

        // MARK: - Interleaved Best-of-3 Timing Harness

        @inline(__always)
        func runComparison(
            label: String,
            iters: Int,
            initV: SIMD8<Double>,
            swift: (SIMD8<Double>) -> SIMD8<Double>,
            apple: (SIMD8<Double>) -> SIMD8<Double>
        ) -> BenchmarkOutcome {
            #expect(
                iters >= Self.minBenchmarkIterations,
                "Benchmark \(label) must run >= \(Self.minBenchmarkIterations) iters")
            #if DEBUG
                let effectiveIters = Swift.min(iters, 1000)
                let warmup = 100
                let trials = 1
            #else
                let effectiveIters = iters
                let warmup = Swift.max(iters / 10, 10_000)
                let trials = 3
            #endif
            _ = measure(iters: warmup, initV: initV, body: swift)
            _ = measure(iters: warmup, initV: initV, body: apple)

            var bestSwiftSec = Double.infinity
            var bestAppleSec = Double.infinity
            var swiftAcc = SIMD8<Double>.zero
            var appleAcc = SIMD8<Double>.zero
            for _ in 0..<trials {
                let (sa, ss) = measure(iters: effectiveIters, initV: initV, body: swift)
                let (aa, appleS) = measure(iters: effectiveIters, initV: initV, body: apple)
                swiftAcc += sa
                appleAcc += aa
                bestSwiftSec = Swift.min(bestSwiftSec, ss)
                bestAppleSec = Swift.min(bestAppleSec, appleS)
            }

            #expect(swiftAcc[0] != 999_999.0 && appleAcc[0] != 999_999.0)
            let totalEvals = Double(effectiveIters * 8)
            let swiftMOps = (totalEvals / bestSwiftSec) / 1.0e6
            let appleMOps = (totalEvals / bestAppleSec) / 1.0e6
            let ratio = swiftMOps / appleMOps

            let fmt = "BENCHMARK [%-10@] | Swift: %8.2f M ops/s | Apple simd: %8.2f M ops/s | Ratio: %.2fx"
            print(String(format: fmt, label, swiftMOps, appleMOps, ratio))

            #expect(swiftMOps > 0.0)
            #if !DEBUG
                #expect(swiftMOps > 0.5)
                #expect(ratio >= 0.90, "SIMDMath.\(label) fell below 0.90x Apple simd (\(ratio)x)")
            #endif
            return BenchmarkOutcome(label: label, iters: iters, ratio: ratio)
        }

        @inline(__always)
        private func measure(
            iters: Int,
            initV: SIMD8<Double>,
            body: (SIMD8<Double>) -> SIMD8<Double>
        ) -> (SIMD8<Double>, Double) {
            let delta = SIMD8<Double>(repeating: 1.0e-9)
            var cur = initV
            var accum = SIMD8<Double>.zero
            let start = DispatchTime.now().uptimeNanoseconds
            for _ in 0..<iters {
                accum += body(cur)
                cur += delta
            }
            let elapsed = Swift.max(Double(DispatchTime.now().uptimeNanoseconds - start) / 1.0e9, 1.0e-9)
            return (accum, elapsed)
        }
    }
#endif
