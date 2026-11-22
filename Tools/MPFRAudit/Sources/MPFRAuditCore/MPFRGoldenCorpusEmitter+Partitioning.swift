// MARK: - Scalable Bucket & Line-Budget Partitioners for Golden Corpus Emission

extension MPFRGoldenCorpusEmitter {
    static let maxFormattedLinesPerFile = 190

    static func partitionUnaryOperations<T>(
        _ all: [T],
        maxOpsPerOverflowFile: Int = maxOpsPerGeneratedFile
    ) -> [(fileName: String, title: String, operations: [T])] {
        let chunkLimit = Swift.max(1, maxOpsPerOverflowFile)
        var groups: [(fileName: String, title: String, operations: [T])] = [
            (
                "SIMDMPFRGoldenVectors+ExpLog.swift",
                "MPFR-Certified Unary Golden Vectors (Exp & Log)",
                Array(all.prefix(8))
            ),
            (
                "SIMDMPFRGoldenVectors+Trig.swift",
                "MPFR-Certified Unary Golden Vectors (Trig & Pi-Trig)",
                Array(all.dropFirst(8).prefix(9))
            ),
            (
                "SIMDMPFRGoldenVectors+ShapingHyperbolic.swift",
                "MPFR-Certified Unary Golden Vectors (Shaping & Hyperbolic)",
                Array(all.dropFirst(17).prefix(10))
            )
        ]
        let remainder = Array(all.dropFirst(27))
        if remainder.count <= chunkLimit {
            groups.append(
                (
                    "SIMDMPFRGoldenVectors+Special.swift",
                    "MPFR-Certified Unary Golden Vectors (Error, Gamma & Extended)",
                    remainder
                )
            )
            return groups
        }
        var offset = 0
        var chunkIndex = 1
        while offset < remainder.count {
            let end = Swift.min(offset + chunkLimit, remainder.count)
            let fileName =
                chunkIndex == 1
                ? "SIMDMPFRGoldenVectors+Special.swift"
                : "SIMDMPFRGoldenVectors+Special\(chunkIndex).swift"
            let title =
                chunkIndex == 1
                ? "MPFR-Certified Unary Golden Vectors (Error, Gamma & Extended)"
                : "MPFR-Certified Unary Golden Vectors (Extended Part \(chunkIndex))"
            groups.append((fileName, title, Array(remainder[offset..<end])))
            offset = end
            chunkIndex += 1
        }
        return groups
    }

    static func partitionSequential<T>(
        _ all: [T],
        baseFileStem: String,
        title: String,
        maxOpsPerFile: Int = maxOpsPerGeneratedFile
    ) -> [(fileName: String, title: String, operations: [T])] {
        let chunkLimit = Swift.max(1, maxOpsPerFile)
        guard !all.isEmpty else { return [] }
        var groups: [(fileName: String, title: String, operations: [T])] = []
        var offset = 0
        var chunkIndex = 1
        while offset < all.count {
            let end = Swift.min(offset + chunkLimit, all.count)
            let fileName = chunkIndex == 1 ? "\(baseFileStem).swift" : "\(baseFileStem)\(chunkIndex).swift"
            let chunkTitle = chunkIndex == 1 ? title : "\(title) (Part \(chunkIndex))"
            groups.append((fileName, chunkTitle, Array(all[offset..<end])))
            offset = end
            chunkIndex += 1
        }
        return groups
    }

    /// Packs pre-formatted operation blocks into files guaranteed to stay `<= maxLines` lines each.
    static func packBlocksIntoFiles(
        blocks: [[String]],
        baseFileStem: String,
        title: String,
        typeName: String,
        maxLines: Int = maxFormattedLinesPerFile
    ) -> [(fileName: String, contents: String)] {
        guard !blocks.isEmpty else { return [] }
        let wrapperLines = 6  // 5 header lines + 1 closing brace line
        var chunks: [[[String]]] = []
        var current: [[String]] = []
        var currentLines = wrapperLines

        for block in blocks {
            let separatorLines = current.isEmpty ? 0 : 1
            if !current.isEmpty, currentLines + separatorLines + block.count > maxLines {
                chunks.append(current)
                current = [block]
                currentLines = wrapperLines + block.count
            } else {
                current.append(block)
                currentLines += separatorLines + block.count
            }
        }
        if !current.isEmpty { chunks.append(current) }

        return chunks.enumerated().map { idx, chunkBlocks in
            let fileName = idx == 0 ? "\(baseFileStem).swift" : "\(baseFileStem)\(idx + 1).swift"
            let chunkTitle = idx == 0 ? title : "\(title) (Part \(idx + 1))"
            var body: [String] = []
            for (blockIdx, block) in chunkBlocks.enumerated() {
                if blockIdx > 0 { body.append("") }
                body.append(contentsOf: block)
            }
            let header = [
                "import SwiftSIMDMathTestSupport", "", "// MARK: - \(chunkTitle)", "", "extension \(typeName) {"
            ]
            let contents = (header + body + ["}"]).joined(separator: "\n") + "\n"
            return (fileName, contents)
        }
    }
}
