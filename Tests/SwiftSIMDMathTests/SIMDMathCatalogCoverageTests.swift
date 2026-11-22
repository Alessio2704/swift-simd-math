import Foundation
import SwiftSIMDMathTestSupport
import Testing

@Suite("SIMDMath Public API to Operation Catalog Coverage Guard")
struct SIMDMathCatalogCoverageTests {
    struct DiscoveredOperation {
        var categories: Set<SIMDOperationCategory> = []
        var hasUnsupportedSignature = false
        var widths: Set<String> = []
        var unknownWidths: Set<String> = []
    }

    static let requiredSIMDWidths = Set(SIMDVectorWidth.allCases.map(\.swiftTypeName))

    @Test("Every public SIMDMath operation matches its catalog enum, category, and exact SIMDVectorWidth set")
    func verifyEveryPublicOperationIsCataloged() throws {
        let sourcesDir = Self.swiftSIMDMathSourcesDirectory()
        let swiftFiles = Self.collectSwiftSourceFiles(in: sourcesDir)
        #expect(!swiftFiles.isEmpty, "Expected Swift source files in \(sourcesDir.path)")

        let discovered = try Self.discoverPublicOperations(in: swiftFiles)
        #expect(!discovered.isEmpty, "Expected public SIMDMath operations in \(sourcesDir.path)")

        var catalogByCategory: [SIMDOperationCategory: Set<String>] = [:]
        var allCatalogNames: Set<String> = []
        var totalCatalogCases = 0
        for category in SIMDOperationCategory.allCases {
            let names = Self.catalogNames(for: category)
            #expect(!names.isEmpty, "Category '\(category.rawValue)' must declare at least one operation")
            catalogByCategory[category] = names
            allCatalogNames.formUnion(names)
            totalCatalogCases += names.count
        }
        #expect(allCatalogNames.count == totalCatalogCases, "Duplicate operation rawValue detected across catalogs")
        #expect(totalCatalogCases == SIMDOperationCategory.totalOperationCount)

        for (name, info) in discovered.sorted(by: { $0.key < $1.key }) {
            #expect(
                info.unknownWidths.isEmpty,
                "Public operation '\(name)' declares uncataloged lane width(s) \(info.unknownWidths.sorted()) — add to `SIMDVectorWidth` and implement across all operations"
            )
            #expect(
                info.widths == Self.requiredSIMDWidths,
                "Public operation '\(name)' must expose \(Self.requiredSIMDWidths.sorted()) overloads (found: \(info.widths.sorted()))"
            )
            if info.hasUnsupportedSignature {
                Issue.record(
                    "Public func '\(name)' uses an unsupported signature — add a new case to `SIMDOperationCategory` and its catalog enum"
                )
                continue
            }
            #expect(
                info.categories.count == 1,
                "Public operation '\(name)' has ambiguous/mixed categories: \(info.categories.map(\.rawValue).sorted())"
            )
            guard let category = info.categories.first, let names = catalogByCategory[category] else { continue }
            #expect(
                names.contains(name),
                "Uncataloged \(category.rawValue) public func '\(name)' — add `case \(name)` to its catalog enum"
            )
        }

        let missingFromSources = allCatalogNames.subtracting(discovered.keys).sorted()
        #expect(
            missingFromSources.isEmpty,
            "Catalog enum cases missing public static func definitions in Sources/SwiftSIMDMath: \(missingFromSources)"
        )
    }

    private static func catalogNames(for category: SIMDOperationCategory) -> Set<String> {
        switch category {
        case .unary: Set(SIMDUnaryOperation.allCases.map(\.rawValue))
        case .binary: Set(SIMDBinaryOperation.allCases.map(\.rawValue))
        case .ternary: Set(SIMDTernaryOperation.allCases.map(\.rawValue))
        case .dualUnary: Set(SIMDDualUnaryOperation.allCases.map(\.rawValue))
        }
    }

    private static func swiftSIMDMathSourcesDirectory(testFilePath: StaticString = #filePath) -> URL {
        URL(fileURLWithPath: "\(testFilePath)")
            .deletingLastPathComponent()
            .deletingLastPathComponent()
            .deletingLastPathComponent()
            .appendingPathComponent("Sources", isDirectory: true)
            .appendingPathComponent("SwiftSIMDMath", isDirectory: true)
    }

    private static func collectSwiftSourceFiles(in directory: URL) -> [URL] {
        guard
            let enumerator = FileManager.default.enumerator(
                at: directory,
                includingPropertiesForKeys: nil,
                options: [.skipsHiddenFiles]
            )
        else {
            return []
        }
        var files: [URL] = []
        for case let fileURL as URL in enumerator where fileURL.pathExtension == "swift" {
            files.append(fileURL)
        }
        return files.sorted { $0.path < $1.path }
    }

    private static func discoverPublicOperations(in files: [URL]) throws -> [String: DiscoveredOperation] {
        let sources = try files.map { file in
            (fileName: file.lastPathComponent, source: try String(contentsOf: file, encoding: .utf8))
        }
        return try Self.discoverPublicOperations(inSources: sources)
    }

    static func discoverPublicOperations(
        inSources sources: [(fileName: String, source: String)]
    ) throws -> [String: DiscoveredOperation] {
        let signatureRegex = try NSRegularExpression(
            pattern:
                #"(?:public\s+static|static\s+public|public)\s+func\s+([A-Za-z_][A-Za-z0-9_]*)\s*\(([^)]*)\)\s*->\s*([^{]+)"#,
            options: [.dotMatchesLineSeparators]
        )
        let anyPublicFuncRegex = try NSRegularExpression(
            pattern: #"(?:public\s+static|static\s+public|public)\s+func\s+([A-Za-z_][A-Za-z0-9_]*)"#
        )
        let widthRegex = try NSRegularExpression(pattern: #"SIMD\d+<\s*[A-Za-z0-9_]+\s*>"#)
        var ops: [String: DiscoveredOperation] = [:]

        for entryFile in sources {
            let stripped = try Self.stripComments(from: entryFile.source)
            let nsText = stripped as NSString
            let fullRange = NSRange(location: 0, length: nsText.length)

            let allMatches = anyPublicFuncRegex.matches(in: stripped, range: fullRange)
            let sigMatches = signatureRegex.matches(in: stripped, range: fullRange)
            #expect(
                allMatches.count == sigMatches.count,
                "Found public func in \(entryFile.fileName) without an explicit `-> ReturnType` SIMD signature"
            )

            for match in sigMatches {
                let name = nsText.substring(with: match.range(at: 1))
                let params = nsText.substring(with: match.range(at: 2))
                let ret = nsText.substring(with: match.range(at: 3)).trimmingCharacters(in: .whitespacesAndNewlines)

                var entry = ops[name] ?? DiscoveredOperation()
                if let category = Self.classifyCategory(params: params, returnType: ret) {
                    entry.categories.insert(category)
                } else {
                    entry.hasUnsupportedSignature = true
                }
                let foundWidths = Self.extractSIMDWidths(in: ret, regex: widthRegex)
                if foundWidths.isEmpty {
                    entry.unknownWidths.insert(ret)
                } else {
                    for width in foundWidths {
                        if Self.requiredSIMDWidths.contains(width) {
                            entry.widths.insert(width)
                        } else {
                            entry.unknownWidths.insert(width)
                        }
                    }
                }
                ops[name] = entry
            }
        }
        return ops
    }

    static func classifyCategory(params: String, returnType: String) -> SIMDOperationCategory? {
        let paramCount = params.split(separator: ",").filter { param in
            !param.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
        }.count
        let isTupleReturn = returnType.hasPrefix("(")
        switch (paramCount, isTupleReturn) {
        case (1, false): return .unary
        case (2, false): return .binary
        case (3, false): return .ternary
        case (1, true): return .dualUnary
        default: return nil
        }
    }

    private static func extractSIMDWidths(in returnType: String, regex: NSRegularExpression) -> [String] {
        let nsRet = returnType as NSString
        return regex.matches(in: returnType, range: NSRange(location: 0, length: nsRet.length)).map { match in
            nsRet.substring(with: match.range).replacingOccurrences(of: " ", with: "")
        }
    }

    private static func stripComments(from source: String) throws -> String {
        let blockRegex = try NSRegularExpression(pattern: #"/\*.*?\*/"#, options: [.dotMatchesLineSeparators])
        let lineRegex = try NSRegularExpression(pattern: #"//[^\n]*"#)
        let withoutBlocks = blockRegex.stringByReplacingMatches(
            in: source,
            range: NSRange(location: 0, length: (source as NSString).length),
            withTemplate: ""
        )
        return lineRegex.stringByReplacingMatches(
            in: withoutBlocks,
            range: NSRange(location: 0, length: (withoutBlocks as NSString).length),
            withTemplate: ""
        )
    }
}
