public import SwiftSIMDMathTestSupport

// MARK: - Compile-Time Exhaustive Category-Level Parallel MPFR Audit Dispatch

extension MPFRAuditExecutor {
    /// Runs parallel MPFR certification across every operation in `category` (zero `default:` branches).
    public static func auditCategory(
        _ category: SIMDOperationCategory,
        samplesPerOp: Int
    ) async -> [MPFRAuditOperationScorecard] {
        switch category {
        case .unary:
            return await Self.auditParallel(SIMDUnaryOperation.allCases) { op in
                Self.auditUnary(op, samplesPerOp: samplesPerOp)
            }

        case .binary:
            return await Self.auditParallel(SIMDBinaryOperation.allCases) { op in
                Self.auditBinary(op, samplesPerOp: samplesPerOp)
            }

        case .ternary:
            return await Self.auditParallel(SIMDTernaryOperation.allCases) { op in
                Self.auditTernary(op, samplesPerOp: samplesPerOp)
            }

        case .dualUnary:
            return await Self.auditParallel(SIMDDualUnaryOperation.allCases) { op in
                Self.auditDualUnary(op, samplesPerOp: samplesPerOp)
            }
        }
    }

    private static func auditParallel<Op: Hashable & Sendable>(
        _ operations: [Op],
        worker: @escaping @Sendable (Op) -> MPFRAuditOperationScorecard
    ) async -> [MPFRAuditOperationScorecard] {
        let map = await withTaskGroup(of: (Op, MPFRAuditOperationScorecard).self) { group in
            for op in operations {
                group.addTask { (op, worker(op)) }
            }
            var collected: [Op: MPFRAuditOperationScorecard] = [:]
            for await (op, card) in group { collected[op] = card }
            return collected
        }
        return operations.compactMap { map[$0] }
    }

    static func invalidProfileScorecard(operationName: String, contractMaxULP: UInt64) -> MPFRAuditOperationScorecard {
        MPFRAuditOperationScorecard(
            operationName: operationName,
            contractMaxULP: contractMaxULP,
            totalEvaluations: 0,
            observedMaxULP: 0,
            exactZeroULPCount: 0,
            crossWidthMismatchCount: 0,
            specialValueMismatchCount: 1,
            worstInputDescription: "INVALID_PROFILE empty goldenAnchors or insufficient samples",
            worstInputBitPatterns: [],
            topWorstInputBitPatterns: []
        )
    }

    static func bitIdenticalOrBothNaN(_ lhs: Double, _ rhs: Double) -> Bool {
        if lhs.isNaN, rhs.isNaN { return true }
        return lhs.bitPattern == rhs.bitPattern
    }
}
