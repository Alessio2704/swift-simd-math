import CMPFRBridge
import Dispatch
import Foundation
import MPFRAuditCore
import SwiftSIMDMathTestSupport

#if canImport(Darwin)
    import Darwin
#elseif canImport(Glibc)
    import Glibc
#endif

// MARK: - Standalone GNU MPFR Mathematical Certification Entrypoint

@main
enum MPFRAuditMain {
    static func main() async throws {
        let args = CommandLine.arguments
        let isQuick = args.contains("--quick")
        let isDeep = args.contains("--deep")
        let isExhaustive = args.contains("--exhaustive")
        var samplesPerOp = isExhaustive ? 10_000_000 : (isDeep ? 1_000_000 : (isQuick ? 10_000 : 100_000))
        if let idx = args.firstIndex(of: "--samples"), idx + 1 < args.count, let parsed = Int(args[idx + 1]) {
            samplesPerOp = Swift.max(64, parsed)
        }
        var emitGoldenDir: String?
        if let idx = args.firstIndex(of: "--emit-golden"), idx + 1 < args.count {
            emitGoldenDir = args[idx + 1]
        }

        let mpfrVersion = String(cString: mpfr_ieee754_version())
        let totalOperationCount = MPFRAuditExecutor.totalCatalogOperationCount
        let startNs = DispatchTime.now().uptimeNanoseconds
        let modeLabel = isExhaustive ? "exhaustive" : (isDeep ? "deep" : (isQuick ? "quick" : "full"))
        print("=== SwiftSIMDMath GNU MPFR \(mpfrVersion) IEEE-754 Binary64 Certification ===")
        print("Mode: \(modeLabel) | Samples/op: \(samplesPerOp) | Operations: \(totalOperationCount)")

        // 1. Audit pure-Swift reference oracles first (zero circular verification!)
        let oracleBudget = isExhaustive ? 250_000 : (isDeep ? 100_000 : (isQuick ? 5000 : 25_000))
        let oracleReports = MPFRReferenceOracleAuditor.auditAllReferenceOracles(
            samplesPerOracle: Swift.min(samplesPerOp, oracleBudget)
        )
        print("\n--- Pure-Swift Reference Oracle Audit (Zero Circular Verification) ---")
        var allPassed = true
        for report in oracleReports {
            let status = report.passed ? "PASS" : "FAIL"
            if !report.passed { allPassed = false }
            let paddedName = Self.padRight(report.oracleName, to: 50)
            print(
                "[\(status)] \(paddedName) | evals: \(Self.padLeft("\(report.totalEvaluations)", to: 6))"
                    + " | maxULP: \(Self.padLeft("\(report.observedMaxULP)", to: 2)) (<= \(report.contractMaxULP))"
                    + " | specialErr: \(report.specialValueMismatchCount) | worst: \(report.worstInputDescription)"
            )
        }

        // 2. Parallel certification across every SIMDOperationCategory
        var orderedCards: [MPFRAuditOperationScorecard] = []
        orderedCards.reserveCapacity(totalOperationCount)
        for category in SIMDOperationCategory.allCases {
            let categoryCards = await MPFRAuditExecutor.auditCategory(category, samplesPerOp: samplesPerOp)
            orderedCards.append(contentsOf: categoryCards)
        }

        print("\n--- SwiftSIMDMath \(orderedCards.count)-Operation GNU MPFR ULP Certification Scorecard ---")
        var totalEvaluations = 0
        for card in orderedCards {
            totalEvaluations += card.totalEvaluations
            let status = card.passed ? "PASS" : "FAIL"
            if !card.passed { allPassed = false }
            let pct = String(format: "%6.2f%%", card.exactRoundedPercent)
            print(
                "[\(status)] \(Self.padRight(card.operationName, to: 10))"
                    + " | evals: \(Self.padLeft("\(card.totalEvaluations)", to: 7))"
                    + " | maxULP: \(Self.padLeft("\(card.observedMaxULP)", to: 3))"
                    + " (<= \(Self.padLeft("\(card.contractMaxULP)", to: 2)))"
                    + " | 0-ULP: \(pct) | wErr: \(card.crossWidthMismatchCount)"
                    + " | spErr: \(card.specialValueMismatchCount) | worst: \(card.worstInputDescription)"
            )
        }

        if let outDir = emitGoldenDir {
            let byName = Dictionary(uniqueKeysWithValues: orderedCards.map { ($0.operationName, $0) })
            try MPFRGoldenCorpusEmitter.emitGoldenCorpus(to: outDir, scorecardsByOperationName: byName)
            print("\nEmitted MPFR-certified golden vectors to \(outDir)")
        }

        let elapsedSec = Double(DispatchTime.now().uptimeNanoseconds - startNs) / 1.0e9
        let summaryState = allPassed ? "ALL CERTIFIED PASS" : "CERTIFICATION FAILED"
        print(
            "\nSummary: \(summaryState) | Total MPFR evaluations: \(totalEvaluations)"
                + " across \(orderedCards.count) ops + \(oracleReports.count) reference oracles"
                + " in \(String(format: "%.2f", elapsedSec)) s"
        )
        if !allPassed {
            #if canImport(Darwin)
                Darwin.exit(1)
            #elseif canImport(Glibc)
                Glibc.exit(1)
            #endif
        }
    }

    private static func padRight(_ text: String, to width: Int) -> String {
        text.count >= width ? text : text + String(repeating: " ", count: width - text.count)
    }

    private static func padLeft(_ text: String, to width: Int) -> String {
        text.count >= width ? text : String(repeating: " ", count: width - text.count) + text
    }
}
