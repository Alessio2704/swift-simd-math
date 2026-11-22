import SwiftSIMDMathTestSupport

// MARK: - MPFR-Certified Dual-Unary Golden Vectors (Part 2)

extension SIMDDualUnaryOperation {
    static let sincospiGoldenVectors: [DualUnaryGoldenVector] = [
        DualUnaryGoldenVector(
            inputBits: 0xFFEF_FFFF_FFFF_FFFF, expectedFirstBits: 0x8000_0000_0000_0000,
            expectedSecondBits: 0x3FF0_0000_0000_0000, maxULP: 2, label: "anchor-0"),
        DualUnaryGoldenVector(
            inputBits: 0xC340_0000_0000_0000, expectedFirstBits: 0x8000_0000_0000_0000,
            expectedSecondBits: 0x3FF0_0000_0000_0000, maxULP: 2, label: "anchor-1"),
        DualUnaryGoldenVector(
            inputBits: 0xC330_0000_0000_0001, expectedFirstBits: 0x8000_0000_0000_0000,
            expectedSecondBits: 0xBFF0_0000_0000_0000, maxULP: 2, label: "anchor-2"),
        DualUnaryGoldenVector(
            inputBits: 0xC330_0000_0000_0000, expectedFirstBits: 0x8000_0000_0000_0000,
            expectedSecondBits: 0x3FF0_0000_0000_0000, maxULP: 2, label: "anchor-3"),
        DualUnaryGoldenVector(
            inputBits: 0xC32F_FFFF_FFFF_FFFF, expectedFirstBits: 0x3FF0_0000_0000_0000,
            expectedSecondBits: 0x0000_0000_0000_0000, maxULP: 2, label: "anchor-4"),
        DualUnaryGoldenVector(
            inputBits: 0xC004_0000_0000_0000, expectedFirstBits: 0xBFF0_0000_0000_0000,
            expectedSecondBits: 0x0000_0000_0000_0000, maxULP: 2, label: "anchor-5"),
        DualUnaryGoldenVector(
            inputBits: 0xBFF8_0000_0000_0000, expectedFirstBits: 0x3FF0_0000_0000_0000,
            expectedSecondBits: 0x0000_0000_0000_0000, maxULP: 2, label: "anchor-6"),
        DualUnaryGoldenVector(
            inputBits: 0xBFF0_0000_0000_0000, expectedFirstBits: 0x8000_0000_0000_0000,
            expectedSecondBits: 0xBFF0_0000_0000_0000, maxULP: 2, label: "anchor-7"),
        DualUnaryGoldenVector(
            inputBits: 0xBFE0_0000_0000_0000, expectedFirstBits: 0xBFF0_0000_0000_0000,
            expectedSecondBits: 0x0000_0000_0000_0000, maxULP: 2, label: "anchor-8"),
        DualUnaryGoldenVector(
            inputBits: 0xBFD0_0000_0000_0000, expectedFirstBits: 0xBFE6_A09E_667F_3BCD,
            expectedSecondBits: 0x3FE6_A09E_667F_3BCD, maxULP: 2, label: "anchor-9"),
        DualUnaryGoldenVector(
            inputBits: 0x8000_0000_0000_0001, expectedFirstBits: 0x8000_0000_0000_0003,
            expectedSecondBits: 0x3FF0_0000_0000_0000, maxULP: 2, label: "anchor-10"),
        DualUnaryGoldenVector(
            inputBits: 0x8000_0000_0000_0000, expectedFirstBits: 0x8000_0000_0000_0000,
            expectedSecondBits: 0x3FF0_0000_0000_0000, maxULP: 2, label: "anchor-11"),
        DualUnaryGoldenVector(
            inputBits: 0x0000_0000_0000_0000, expectedFirstBits: 0x0000_0000_0000_0000,
            expectedSecondBits: 0x3FF0_0000_0000_0000, maxULP: 2, label: "anchor-12"),
        DualUnaryGoldenVector(
            inputBits: 0x0000_0000_0000_0001, expectedFirstBits: 0x0000_0000_0000_0003,
            expectedSecondBits: 0x3FF0_0000_0000_0000, maxULP: 2, label: "anchor-13"),
        DualUnaryGoldenVector(
            inputBits: 0x3FD0_0000_0000_0000, expectedFirstBits: 0x3FE6_A09E_667F_3BCD,
            expectedSecondBits: 0x3FE6_A09E_667F_3BCD, maxULP: 2, label: "anchor-14"),
        DualUnaryGoldenVector(
            inputBits: 0x3FE0_0000_0000_0000, expectedFirstBits: 0x3FF0_0000_0000_0000,
            expectedSecondBits: 0x0000_0000_0000_0000, maxULP: 2, label: "anchor-15"),
        DualUnaryGoldenVector(
            inputBits: 0x3FF0_0000_0000_0000, expectedFirstBits: 0x0000_0000_0000_0000,
            expectedSecondBits: 0xBFF0_0000_0000_0000, maxULP: 2, label: "anchor-16"),
        DualUnaryGoldenVector(
            inputBits: 0x3FF8_0000_0000_0000, expectedFirstBits: 0xBFF0_0000_0000_0000,
            expectedSecondBits: 0x0000_0000_0000_0000, maxULP: 2, label: "anchor-17"),
        DualUnaryGoldenVector(
            inputBits: 0x4004_0000_0000_0000, expectedFirstBits: 0x3FF0_0000_0000_0000,
            expectedSecondBits: 0x0000_0000_0000_0000, maxULP: 2, label: "anchor-18"),
        DualUnaryGoldenVector(
            inputBits: 0x430F_FFFF_FFFF_FFFF, expectedFirstBits: 0xBFD8_7DE2_A6AE_A963,
            expectedSecondBits: 0x3FED_906B_CF32_8D46, maxULP: 2, label: "anchor-19"),
        DualUnaryGoldenVector(
            inputBits: 0x4310_0000_0000_0000, expectedFirstBits: 0x0000_0000_0000_0000,
            expectedSecondBits: 0x3FF0_0000_0000_0000, maxULP: 2, label: "anchor-20"),
        DualUnaryGoldenVector(
            inputBits: 0x432F_FFFF_FFFF_FFFF, expectedFirstBits: 0xBFF0_0000_0000_0000,
            expectedSecondBits: 0x0000_0000_0000_0000, maxULP: 2, label: "anchor-21"),
        DualUnaryGoldenVector(
            inputBits: 0x4330_0000_0000_0000, expectedFirstBits: 0x0000_0000_0000_0000,
            expectedSecondBits: 0x3FF0_0000_0000_0000, maxULP: 2, label: "anchor-22"),
        DualUnaryGoldenVector(
            inputBits: 0x4330_0000_0000_0001, expectedFirstBits: 0x0000_0000_0000_0000,
            expectedSecondBits: 0xBFF0_0000_0000_0000, maxULP: 2, label: "anchor-23"),
        DualUnaryGoldenVector(
            inputBits: 0x4340_0000_0000_0000, expectedFirstBits: 0x0000_0000_0000_0000,
            expectedSecondBits: 0x3FF0_0000_0000_0000, maxULP: 2, label: "anchor-24"),
        DualUnaryGoldenVector(
            inputBits: 0x7FEF_FFFF_FFFF_FFFF, expectedFirstBits: 0x0000_0000_0000_0000,
            expectedSecondBits: 0x3FF0_0000_0000_0000, maxULP: 2, label: "anchor-25"),
        DualUnaryGoldenVector(
            inputBits: 0x0000_009D_ABED_16EB, expectedFirstBits: 0x0000_01EF_5703_8899,
            expectedSecondBits: 0x3FF0_0000_0000_0000, maxULP: 2, label: "worst-0"),
        DualUnaryGoldenVector(
            inputBits: 0x0049_8197_5749_464E, expectedFirstBits: 0x0064_0854_33E8_DBBD,
            expectedSecondBits: 0x3FF0_0000_0000_0000, maxULP: 2, label: "worst-1"),
        DualUnaryGoldenVector(
            inputBits: 0x008F_D854_AA7B_790C, expectedFirstBits: 0x00A9_02D3_5934_15F2,
            expectedSecondBits: 0x3FF0_0000_0000_0000, maxULP: 2, label: "worst-2"),
        DualUnaryGoldenVector(
            inputBits: 0x430F_FFFF_FFFF_FFFE, expectedFirstBits: 0xBFE6_A09E_667F_3BCD,
            expectedSecondBits: 0x3FE6_A09E_667F_3BCD, maxULP: 2, label: "worst-3"),
        DualUnaryGoldenVector(
            inputBits: 0x8000_009D_ABED_16EB, expectedFirstBits: 0x8000_01EF_5703_8899,
            expectedSecondBits: 0x3FF0_0000_0000_0000, maxULP: 2, label: "worst-4"),
        DualUnaryGoldenVector(
            inputBits: 0x8049_8197_5749_464E, expectedFirstBits: 0x8064_0854_33E8_DBBD,
            expectedSecondBits: 0x3FF0_0000_0000_0000, maxULP: 2, label: "worst-5")
    ]
}
