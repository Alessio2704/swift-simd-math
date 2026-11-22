import SwiftSIMDMathTestSupport

// MARK: - MPFR Golden Corpus Emitter (Binary, Ternary & Dual-Unary Slices)

extension MPFRGoldenCorpusEmitter {
    static func renderBinaryFiles(
        scorecards: [String: MPFRAuditOperationScorecard]
    ) -> [(fileName: String, contents: String)] {
        let blocks = SIMDBinaryOperation.allCases.map { op in
            Self.renderBinaryOperationBlock(op, scorecard: scorecards[op.rawValue])
        }
        return Self.packBlocksIntoFiles(
            blocks: blocks,
            baseFileStem: "SIMDMPFRGoldenVectors+Binary",
            title: "MPFR-Certified Binary Golden Vectors",
            typeName: "SIMDBinaryOperation"
        )
    }

    static func renderTernaryFiles(
        scorecards: [String: MPFRAuditOperationScorecard]
    ) -> [(fileName: String, contents: String)] {
        let blocks = SIMDTernaryOperation.allCases.map { op in
            Self.renderTernaryOperationBlock(op, scorecard: scorecards[op.rawValue])
        }
        return Self.packBlocksIntoFiles(
            blocks: blocks,
            baseFileStem: "SIMDMPFRGoldenVectors+Ternary",
            title: "MPFR-Certified Ternary Golden Vectors",
            typeName: "SIMDTernaryOperation"
        )
    }

    static func renderDualUnaryFiles(
        scorecards: [String: MPFRAuditOperationScorecard]
    ) -> [(fileName: String, contents: String)] {
        let blocks = SIMDDualUnaryOperation.allCases.map { op in
            Self.renderDualUnaryOperationBlock(op, scorecard: scorecards[op.rawValue])
        }
        return Self.packBlocksIntoFiles(
            blocks: blocks,
            baseFileStem: "SIMDMPFRGoldenVectors+DualUnary",
            title: "MPFR-Certified Dual-Unary Golden Vectors",
            typeName: "SIMDDualUnaryOperation"
        )
    }

    private static func renderBinaryOperationBlock(
        _ op: SIMDBinaryOperation,
        scorecard: MPFRAuditOperationScorecard?
    ) -> [String] {
        let profile = op.mpfrAuditProfile
        var seen: Set<String> = []
        var entries: [(a: Double, b: Double, label: String)] = []
        for (idx, pair) in profile.goldenAnchors.enumerated() {
            let key = "\(pair.0.bitPattern):\(pair.1.bitPattern)"
            if seen.insert(key).inserted { entries.append((pair.0, pair.1, "anchor-\(idx)")) }
        }
        if let card = scorecard {
            let candidates =
                card.topWorstInputBitPatterns.isEmpty
                ? (card.worstInputBitPatterns.count == 2 ? [card.worstInputBitPatterns] : [])
                : card.topWorstInputBitPatterns
            var worstIdx = 0
            for tuple in candidates where tuple.count == 2 && worstIdx < Self.maxTopWorstPointsPerOp {
                let key = "\(tuple[0]):\(tuple[1])"
                if seen.insert(key).inserted {
                    entries.append((Double(bitPattern: tuple[0]), Double(bitPattern: tuple[1]), "worst-\(worstIdx)"))
                    worstIdx += 1
                }
            }
        }
        var lines: [String] = ["    static let \(op.rawValue)GoldenVectors: [BinaryGoldenVector] = ["]
        for (idx, item) in entries.enumerated() {
            let ref = profile.referenceEvaluator(item.a, item.b)
            let comma = idx + 1 == entries.count ? "" : ","
            lines.append("        BinaryGoldenVector(")
            lines.append(
                "            firstInputBits: \(Self.swiftHex(item.a.bitPattern)), "
                    + "secondInputBits: \(Self.swiftHex(item.b.bitPattern)),"
            )
            lines.append(
                "            expectedBits: \(Self.swiftHex(ref.bitPattern)), "
                    + "maxULP: \(profile.maxULP), label: \"\(item.label)\")\(comma)"
            )
        }
        lines.append("    ]")
        return lines
    }

    private struct TernaryGoldenItem {
        let first: Double
        let second: Double
        let third: Double
        let label: String
    }

    private static func renderTernaryOperationBlock(
        _ op: SIMDTernaryOperation,
        scorecard: MPFRAuditOperationScorecard?
    ) -> [String] {
        let profile = op.mpfrAuditProfile
        var seen: Set<String> = []
        var entries: [TernaryGoldenItem] = []
        for (idx, triplet) in profile.goldenAnchors.enumerated() {
            let key = "\(triplet.0.bitPattern):\(triplet.1.bitPattern):\(triplet.2.bitPattern)"
            if seen.insert(key).inserted {
                entries.append(
                    TernaryGoldenItem(first: triplet.0, second: triplet.1, third: triplet.2, label: "anchor-\(idx)"))
            }
        }
        if let card = scorecard {
            let candidates =
                card.topWorstInputBitPatterns.isEmpty
                ? (card.worstInputBitPatterns.count == 3 ? [card.worstInputBitPatterns] : [])
                : card.topWorstInputBitPatterns
            var worstIdx = 0
            for tuple in candidates where tuple.count == 3 && worstIdx < Self.maxTopWorstPointsPerOp {
                let key = "\(tuple[0]):\(tuple[1]):\(tuple[2])"
                if seen.insert(key).inserted {
                    entries.append(
                        TernaryGoldenItem(
                            first: Double(bitPattern: tuple[0]),
                            second: Double(bitPattern: tuple[1]),
                            third: Double(bitPattern: tuple[2]),
                            label: "worst-\(worstIdx)"
                        )
                    )
                    worstIdx += 1
                }
            }
        }
        var lines: [String] = ["    static let \(op.rawValue)GoldenVectors: [TernaryGoldenVector] = ["]
        for (idx, item) in entries.enumerated() {
            let ref = profile.referenceEvaluator(item.first, item.second, item.third)
            let comma = idx + 1 == entries.count ? "" : ","
            lines.append("        TernaryGoldenVector(")
            lines.append(
                "            firstInputBits: \(Self.swiftHex(item.first.bitPattern)), "
                    + "secondInputBits: \(Self.swiftHex(item.second.bitPattern)),"
            )
            lines.append(
                "            thirdInputBits: \(Self.swiftHex(item.third.bitPattern)), "
                    + "expectedBits: \(Self.swiftHex(ref.bitPattern)), "
                    + "maxULP: \(profile.maxULP), label: \"\(item.label)\")\(comma)"
            )
        }
        lines.append("    ]")
        return lines
    }

    private static func renderDualUnaryOperationBlock(
        _ op: SIMDDualUnaryOperation,
        scorecard: MPFRAuditOperationScorecard?
    ) -> [String] {
        let profile = op.mpfrAuditProfile
        let entries = Self.collectScalarEntries(anchors: profile.goldenAnchors, scorecard: scorecard)
        var lines: [String] = ["    static let \(op.rawValue)GoldenVectors: [DualUnaryGoldenVector] = ["]
        for (idx, item) in entries.enumerated() {
            let ref = profile.referenceEvaluator(item.value)
            let comma = idx + 1 == entries.count ? "" : ","
            lines.append("        DualUnaryGoldenVector(")
            lines.append(
                "            inputBits: \(Self.swiftHex(item.value.bitPattern)), "
                    + "expectedFirstBits: \(Self.swiftHex(ref.first.bitPattern)),"
            )
            lines.append(
                "            expectedSecondBits: \(Self.swiftHex(ref.second.bitPattern)), "
                    + "maxULP: \(profile.maxULP), label: \"\(item.label)\")\(comma)"
            )
        }
        lines.append("    ]")
        return lines
    }
}
