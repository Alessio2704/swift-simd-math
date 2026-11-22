#if canImport(simd)
    import Foundation
    import Testing
    import simd

    import SwiftSIMDMath
    import SwiftSIMDMathTestSupport

    extension SIMDPerformanceTests {
        private static let unitSigned = SIMD8<Double>(-0.92, -0.63, -0.31, -0.08, 0.12, 0.37, 0.68, 0.91)
        private static let acoshInput = SIMD8<Double>(1.05, 1.3, 1.8, 2.7, 4.5, 9.2, 24.0, 110.0)
        private static let erfInput = SIMD8<Double>(-2.6, -1.3, -0.5, -0.1, 0.2, 0.6, 1.4, 2.9)
        private static let gammaInput = SIMD8<Double>(0.7, 1.2, 1.8, 2.6, 3.9, 5.4, 7.2, 12.5)

        @inline(__always)
        private func bench(
            _ op: SIMDUnaryOperation,
            iters: Int = 500_000,
            _ initV: SIMD8<Double>,
            _ swift: (SIMD8<Double>) -> SIMD8<Double>,
            _ apple: (SIMD8<Double>) -> SIMD8<Double>
        ) -> BenchmarkOutcome {
            runComparison(label: op.rawValue, iters: iters, initV: initV, swift: swift, apple: apple)
        }

        /// Compile-time exhaustive benchmark dispatcher (non-`Void`: `break` is a compile error!).
        func runUnaryBenchmark(_ op: SIMDUnaryOperation) -> BenchmarkOutcome {
            switch op {
            case .exp: bench(op, Self.expInput, { SIMDMath.exp($0) }, { simd.exp($0) })
            case .exp2: bench(op, Self.expInput, { SIMDMath.exp2($0) }, { simd.exp2($0) })
            case .exp10: bench(op, Self.expInput, { SIMDMath.exp10($0) }, { simd.exp10($0) })
            case .expm1: bench(op, Self.expInput, { SIMDMath.expm1($0) }, { simd.expm1($0) })
            case .log: bench(op, Self.logInput, { SIMDMath.log($0) }, { simd.log($0) })
            case .log2: bench(op, Self.logInput, { SIMDMath.log2($0) }, { simd.log2($0) })
            case .log10: bench(op, Self.logInput, { SIMDMath.log10($0) }, { simd.log10($0) })
            case .log1p: bench(op, Self.unitSigned, { SIMDMath.log1p($0) }, { simd.log1p($0) })
            case .sin: bench(op, Self.trigInput, { SIMDMath.sin($0) }, { simd.sin($0) })
            case .cos: bench(op, Self.trigInput, { SIMDMath.cos($0) }, { simd.cos($0) })
            case .tan: bench(op, Self.trigInput, { SIMDMath.tan($0) }, { simd.tan($0) })
            case .asin: bench(op, Self.unitSigned, { SIMDMath.asin($0) }, { simd.asin($0) })
            case .acos: bench(op, Self.unitSigned, { SIMDMath.acos($0) }, { simd.acos($0) })
            case .atan: bench(op, Self.expInput, { SIMDMath.atan($0) }, { simd.atan($0) })
            case .sinpi: bench(op, Self.trigInput, { SIMDMath.sinpi($0) }, { simd.sinpi($0) })
            case .cospi: bench(op, Self.trigInput, { SIMDMath.cospi($0) }, { simd.cospi($0) })
            case .tanpi: bench(op, Self.trigInput, { SIMDMath.tanpi($0) }, { simd.tanpi($0) })
            case .abs: bench(op, iters: 5_000_000, Self.expInput, { SIMDMath.abs($0) }, { Self.appleAbs($0) })
            case .cbrt: bench(op, Self.expInput, { SIMDMath.cbrt($0) }, { simd.cbrt($0) })
            case .sign: bench(op, iters: 5_000_000, Self.expInput, { SIMDMath.sign($0) }, { Self.appleSign($0) })
            case .fract: bench(op, iters: 5_000_000, Self.expInput, { SIMDMath.fract($0) }, { Self.appleFract($0) })
            case .sinh: bench(op, Self.expInput, { SIMDMath.sinh($0) }, { simd.sinh($0) })
            case .cosh: bench(op, Self.expInput, { SIMDMath.cosh($0) }, { simd.cosh($0) })
            case .tanh: bench(op, Self.expInput, { SIMDMath.tanh($0) }, { simd.tanh($0) })
            case .asinh: bench(op, Self.expInput, { SIMDMath.asinh($0) }, { simd.asinh($0) })
            case .acosh: bench(op, Self.acoshInput, { SIMDMath.acosh($0) }, { simd.acosh($0) })
            case .atanh: bench(op, Self.unitSigned, { SIMDMath.atanh($0) }, { simd.atanh($0) })
            case .erf: bench(op, Self.erfInput, { SIMDMath.erf($0) }, { simd.erf($0) })
            case .erfc: bench(op, Self.erfInput, { SIMDMath.erfc($0) }, { simd.erfc($0) })
            case .tgamma: bench(op, iters: 250_000, Self.gammaInput, { SIMDMath.tgamma($0) }, { simd.tgamma($0) })
            case .lgamma: bench(op, iters: 250_000, Self.gammaInput, { SIMDMath.lgamma($0) }, { simd.lgamma($0) })
            }
        }

        /// Compile-time exhaustive category gate verifying every category binds real benchmark dispatchers.
        @Test(
            "Every operation category is wired into performance parity benchmarks",
            arguments: SIMDOperationCategory.allCases
        )
        func verifyCategoryBenchmarkCoverage(category: SIMDOperationCategory) {
            let names = Self.benchmarkedOperationNames(for: category)
            #expect(names == category.operationNames, "Category \(category.rawValue) benchmark coverage mismatch")
        }

        private static func benchmarkedOperationNames(for category: SIMDOperationCategory) -> [String] {
            switch category {
            case .unary:
                let _: (SIMDPerformanceTests) -> (SIMDUnaryOperation) -> BenchmarkOutcome = Self.runUnaryBenchmark
                return SIMDUnaryOperation.allCases.map(\.rawValue)

            case .binary:
                let _: (SIMDPerformanceTests) -> (SIMDBinaryOperation) -> BenchmarkOutcome = Self.runBinaryBenchmark
                return SIMDBinaryOperation.allCases.map(\.rawValue)

            case .ternary:
                let _: (SIMDPerformanceTests) -> (SIMDTernaryOperation) -> BenchmarkOutcome = Self.runTernaryBenchmark
                return SIMDTernaryOperation.allCases.map(\.rawValue)

            case .dualUnary:
                let _: (SIMDPerformanceTests) -> (SIMDDualUnaryOperation) -> BenchmarkOutcome =
                    Self.runDualUnaryBenchmark
                return SIMDDualUnaryOperation.allCases.map(\.rawValue)
            }
        }
    }
#endif
