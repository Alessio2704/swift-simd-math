import SwiftSIMDMathTestSupport
import Testing

@testable import MPFRAuditCore

@Suite("MPFRDomainSamplers & DeterministicSplitMix64: Reproducibility & Domain Invariants")
struct MPFRDomainSamplersTests {
    @Test("DeterministicSplitMix64 is reproducible and stays within declared numeric bounds")
    func verifySplitMix64ReproducibilityAndBounds() {
        var rngA = DeterministicSplitMix64(seed: 0xDEAD_BEEF_1234_5678)
        var rngB = DeterministicSplitMix64(seed: 0xDEAD_BEEF_1234_5678)

        for _ in 0..<256 {
            #expect(rngA.nextUInt64() == rngB.nextUInt64())
            let unit = rngA.nextUnitDouble()
            #expect(unit >= 0.0 && unit < 1.0)
            let signedUnit = rngA.nextSignedUnitDouble()
            #expect(signedUnit >= -1.0 && signedUnit < 1.0)
            _ = rngB.nextUnitDouble()
            _ = rngB.nextSignedUnitDouble()
        }
    }

    @Test("denseULPWindow preserves center, produces symmetric finite neighbors, and handles non-finite inputs")
    func verifyDenseULPWindow() {
        let window = MPFRDomainSamplers.denseULPWindow(around: 1.0, radius: 4)
        #expect(window.count == 9)
        #expect(window.first == 1.0)
        #expect(window.contains((1.0).nextUp))
        #expect(window.contains((1.0).nextDown))

        #expect(MPFRDomainSamplers.denseULPWindow(around: .infinity, radius: 4) == [.infinity])
        #expect(MPFRDomainSamplers.denseULPWindow(around: .nan, radius: 4).first?.isNaN == true)
    }

    @Test("stratifiedExponents covers full subnormal-to-max exponent range and respects signed flag")
    func verifyStratifiedExponentsCoverage() {
        let positiveOnly = MPFRDomainSamplers.stratifiedExponents(
            seed: 0x1111, count: 400, minExp: -1074, maxExp: 1023, signed: false,
            anchors: [Double.leastNonzeroMagnitude, Double.leastNormalMagnitude, 1.0]
        )
        let positiveRepeat = MPFRDomainSamplers.stratifiedExponents(
            seed: 0x1111, count: 400, minExp: -1074, maxExp: 1023, signed: false,
            anchors: [Double.leastNonzeroMagnitude, Double.leastNormalMagnitude, 1.0]
        )
        #expect(positiveOnly.map(\.bitPattern) == positiveRepeat.map(\.bitPattern))
        #expect(positiveOnly.allSatisfy { $0.isFinite && $0 >= 0.0 })
        #expect(positiveOnly.contains { $0.isSubnormal })
        #expect(positiveOnly.contains { $0 >= Double(sign: .plus, exponent: 1023, significand: 1.0) })

        let signedSamples = MPFRDomainSamplers.stratifiedExponents(
            seed: 0x2222, count: 400, minExp: -20, maxExp: 20, signed: true, anchors: [0.0]
        )
        #expect(signedSamples.contains { $0 < 0.0 })
        #expect(signedSamples.contains { $0 > 0.0 })
    }

    @Test("Interval, acosh, and gamma samplers strictly respect domain bounds and exclude negative integer poles")
    func verifyDomainSpecializedSamplers() {
        let openUnit = MPFRDomainSamplers.unitIntervalAndEdges(
            seed: 0x3333, count: 500, includeEndpoints: false, anchors: [-1.0, 0.0, 1.0]
        )
        #expect(openUnit.allSatisfy { $0 > -1.0 && $0 < 1.0 })

        let closedUnit = MPFRDomainSamplers.unitIntervalAndEdges(
            seed: 0x4444, count: 500, includeEndpoints: true, anchors: [-1.0, 0.0, 1.0]
        )
        #expect(closedUnit.allSatisfy { $0 >= -1.0 && $0 <= 1.0 })
        #expect(closedUnit.contains(1.0) && closedUnit.contains(-1.0))

        let acosh = MPFRDomainSamplers.acoshSamples(seed: 0x5555, count: 400, anchors: [1.0, 2.0])
        #expect(acosh.allSatisfy { $0 >= 1.0 && $0.isFinite })

        let gamma = MPFRDomainSamplers.gammaSamples(
            seed: 0x6666, count: 400, minX: -170.0, maxX: 170.0, anchors: [-5.5, -0.5, 0.5, 1.0]
        )
        #expect(gamma.allSatisfy { $0 > 0.0 || $0 != $0.rounded(.down) })
        #expect(gamma.contains { $0 < 0.0 })
        #expect(gamma.contains { $0 > 0.0 })
    }

    @Test("Every catalog operation sampleGenerator satisfies requested count even for odd/non-divisible budgets")
    func verifyAllOperationSampleGeneratorsMeetRequestedBudget() {
        for requested in [65, 100, 1001, 10_001] {
            for op in SIMDUnaryOperation.allCases {
                let count = op.mpfrAuditProfile.sampleGenerator(requested).count
                #expect(count >= requested, "\(op.rawValue) generated \(count) < \(requested)")
            }
            for op in SIMDBinaryOperation.allCases {
                let count = op.mpfrAuditProfile.sampleGenerator(requested).count
                #expect(count >= requested, "\(op.rawValue) generated \(count) < \(requested)")
            }
            for op in SIMDTernaryOperation.allCases {
                let count = op.mpfrAuditProfile.sampleGenerator(requested).count
                #expect(count >= requested, "\(op.rawValue) generated \(count) < \(requested)")
            }
            for op in SIMDDualUnaryOperation.allCases {
                let count = op.mpfrAuditProfile.sampleGenerator(requested).count
                #expect(count >= requested, "\(op.rawValue) generated \(count) < \(requested)")
            }
        }
    }
}
