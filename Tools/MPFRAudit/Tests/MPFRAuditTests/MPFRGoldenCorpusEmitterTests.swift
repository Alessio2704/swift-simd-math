import Foundation
import SwiftSIMDMathTestSupport
import Testing

@testable import MPFRAuditCore

@Suite("MPFRGoldenCorpusEmitter: All-4-Bucket Completeness, Scalability & Formatting")
struct MPFRGoldenCorpusEmitterTests {
    @Test("All operation categories are emitted 1-to-1 with zero drops, zero duplicates, and <= 200 lines per file")
    func verifyAllCategoriesEmittedCompletelyAndWithinLineCap() async {
        var scorecardsByName: [String: MPFRAuditOperationScorecard] = [:]
        for category in SIMDOperationCategory.allCases {
            let cards = await MPFRAuditExecutor.auditCategory(category, samplesPerOp: 128)
            for card in cards { scorecardsByName[card.operationName] = card }
        }

        let files = MPFRGoldenCorpusEmitter.renderAllGoldenFiles(scorecardsByOperationName: scorecardsByName)

        // 1. Unique file names and SwiftLint <= 200-line guarantee on every emitted file
        let fileNames = files.map(\.fileName)
        #expect(Set(fileNames).count == fileNames.count, "Duplicate emitted golden file names detected")
        for (name, contents) in files {
            let lineCount = contents.split(separator: "\n", omittingEmptySubsequences: false).count - 1
            #expect(lineCount <= 200, "Emitted file \(name) has \(lineCount) lines, exceeding 200-line SwiftLint cap")
        }

        // 2. Dispatch file covers every case across all SIMDOperationCategory cases with zero `default:` branches
        guard let dispatch = files.first(where: { $0.fileName == "SIMDMPFRGoldenVectors.swift" })?.contents else {
            Issue.record("Missing SIMDMPFRGoldenVectors.swift dispatch file")
            return
        }
        let codeLines = dispatch.split(separator: "\n").filter { line in
            !line.trimmingCharacters(in: .whitespaces).hasPrefix("//")
        }
        #expect(
            !codeLines.contains { $0.contains("default:") },
            "Dispatch file must never contain a default: branch"
        )

        let sliceBodies = files.filter { $0.fileName != "SIMDMPFRGoldenVectors.swift" }.map(\.contents)
        let allExpectedNames = SIMDOperationCategory.allCases.flatMap(\.operationNames)
        #expect(allExpectedNames.count == SIMDOperationCategory.totalOperationCount)

        // 3. Every single op across unary/binary/ternary/dual appears in dispatch AND exactly once in slice files
        for opName in allExpectedNames {
            #expect(
                dispatch.contains("case .\(opName): Self.\(opName)GoldenVectors"),
                "Dispatch file missing case .\(opName)"
            )
            let declToken = "static let \(opName)GoldenVectors:"
            let definitionCount = sliceBodies.reduce(0) { count, body in
                count + body.components(separatedBy: declToken).count - 1
            }
            #expect(
                definitionCount == 1,
                "Expected exactly 1 golden vector definition for '\(opName)', found \(definitionCount)"
            )
            // Ensure no operation emits an empty golden vector array
            let emptyPattern = "\(declToken) ["
            let matchingSlice = sliceBodies.first { $0.contains(declToken) } ?? ""
            #expect(
                !matchingSlice.contains("\(emptyPattern)\n    ]"),
                "Emitted golden vector array for '\(opName)' must not be empty"
            )
        }
    }

    @Test("Unary and sequential bucket partitioners never drop or duplicate elements for any catalog size 0...100")
    func verifyPartitionersNeverDropOrDuplicateAtAnyScale() {
        let testSizes = [0, 1, 7, 8, 12, 17, 27, 31, 32, 39, 40, 50, 100]
        for size in testSizes {
            let syntheticOps = (0..<size).map { "op_\($0)" }

            let unaryGroups = MPFRGoldenCorpusEmitter.partitionUnaryOperations(syntheticOps)
            let flattenedUnary = unaryGroups.flatMap(\.operations)
            #expect(flattenedUnary == syntheticOps, "Unary partitioner dropped or reordered ops at size=\(size)")
            let unaryNames = unaryGroups.map(\.fileName)
            #expect(Set(unaryNames).count == unaryNames.count, "Unary partitioner produced duplicate file names")
            for group in unaryGroups {
                #expect(
                    group.operations.count <= MPFRGoldenCorpusEmitter.maxOpsPerGeneratedFile,
                    "Unary slice \(group.fileName) exceeded max ops per file at size=\(size)"
                )
            }

            let seqGroups = MPFRGoldenCorpusEmitter.partitionSequential(
                syntheticOps,
                baseFileStem: "SIMDMPFRGoldenVectors+Binary",
                title: "Synthetic Binary"
            )
            let flattenedSeq = seqGroups.flatMap(\.operations)
            #expect(flattenedSeq == syntheticOps, "Sequential partitioner dropped or reordered ops at size=\(size)")
            let seqNames = seqGroups.map(\.fileName)
            #expect(Set(seqNames).count == seqNames.count, "Sequential partitioner produced duplicate file names")
            for group in seqGroups {
                #expect(
                    group.operations.count <= MPFRGoldenCorpusEmitter.maxOpsPerGeneratedFile,
                    "Sequential slice \(group.fileName) exceeded max ops per file at size=\(size)"
                )
            }
        }
    }

    @Test("Hex formatting and bit-pattern deduplication preserve signed zeros and 64-bit alignment")
    func verifyHexFormattingAndSignedZeroDeduplication() {
        #expect(MPFRGoldenCorpusEmitter.swiftHex(0x0000_0000_0000_0000) == "0x0000_0000_0000_0000")
        #expect(MPFRGoldenCorpusEmitter.swiftHex(0x0000_0000_0000_0001) == "0x0000_0000_0000_0001")
        #expect(MPFRGoldenCorpusEmitter.swiftHex(0x8000_0000_0000_0000) == "0x8000_0000_0000_0000")
        #expect(MPFRGoldenCorpusEmitter.swiftHex(0x3FF0_0000_0000_0000) == "0x3FF0_0000_0000_0000")

        let deduped = MPFRGoldenCorpusEmitter.deduplicateDoubles([0.0, -0.0, 0.0, 1.0, -0.0, 1.0])
        #expect(deduped.map(\.bitPattern) == [(0.0).bitPattern, (-0.0).bitPattern, (1.0).bitPattern])
    }

    @Test("Disk round-trip emitGoldenCorpus writes all expected files and cleans stale golden slices")
    func verifyDiskEmissionRoundTrip() throws {
        let tempDir = FileManager.default.temporaryDirectory
            .appendingPathComponent("mpfr-audit-emitter-test-\(UUID().uuidString)", isDirectory: true)
        try FileManager.default.createDirectory(at: tempDir, withIntermediateDirectories: true)
        defer { try? FileManager.default.removeItem(at: tempDir) }

        let staleFile = tempDir.appendingPathComponent("SIMDMPFRGoldenVectors+StaleLegacy.swift")
        try "// stale\n".write(to: staleFile, atomically: true, encoding: .utf8)

        try MPFRGoldenCorpusEmitter.emitGoldenCorpus(to: tempDir.path, scorecardsByOperationName: [:])

        let written = try FileManager.default.contentsOfDirectory(atPath: tempDir.path).sorted()
        #expect(!written.contains("SIMDMPFRGoldenVectors+StaleLegacy.swift"))
        #expect(written.contains("SIMDMPFRGoldenVectors.swift"))
        #expect(written.contains("SIMDMPFRGoldenVectors+ExpLog.swift"))
        #expect(written.contains("SIMDMPFRGoldenVectors+Trig.swift"))
        #expect(written.contains("SIMDMPFRGoldenVectors+ShapingHyperbolic.swift"))
        #expect(written.contains("SIMDMPFRGoldenVectors+Special.swift"))
        #expect(written.contains("SIMDMPFRGoldenVectors+Binary.swift"))
        #expect(written.contains("SIMDMPFRGoldenVectors+Ternary.swift"))
        #expect(written.contains("SIMDMPFRGoldenVectors+DualUnary.swift"))
        for fileName in written {
            let content = try String(contentsOf: tempDir.appendingPathComponent(fileName), encoding: .utf8)
            #expect(!content.isEmpty, "Emitted file \(fileName) must not be empty")
        }
    }

    @Test("MPFRRegimeWorstTracker captures top-K distinct regimes, upgrades within regime, and prunes below threshold")
    func verifyRegimeWorstTrackerDistinctRegimesAndThreshold() {
        var tracker = MPFRRegimeWorstTracker(capacity: 4, arity: 1)
        let inputs: [(Double, UInt64)] = [
            (0.0625, 1),  // exp -4
            (0.078125, 2),  // same regime bucket as 0.0625 -> should upgrade to ULP 2
            (1.0, 1),  // exp 0
            (16.0, 3),  // exp 4
            (-16.0, 1),  // neg exp 4 (distinct sign!)
            (256.0, 2),  // exp 8 -> should evict one of the ULP-1 regimes
            (4096.0, 4),  // exp 12 -> should evict the remaining ULP-1 regime
            (65_536.0, 1)  // below minThreshold (now 3) -> ignored
        ]
        for (val, ulp) in inputs {
            let bits = val.bitPattern
            tracker.record(ulp: ulp, regimeKey: MPFRRegimeWorstTracker.unaryRegimeKey(bits), b0: bits)
        }
        #expect(tracker.entries.count == 4)
        #expect(tracker.minThreshold == 3)
        let top = tracker.topBitPatterns(includingPrimary: [(4096.0).bitPattern])
        #expect(top.count == 4)
        #expect(top[0] == [(4096.0).bitPattern])
        #expect(top[1] == [(16.0).bitPattern])
        #expect(top.contains([(0.078125).bitPattern]))
        #expect(top.contains([(256.0).bitPattern]))
        #expect(!top.contains([(0.0625).bitPattern]))
    }
}
