import SwiftSIMDMathTestSupport

// MARK: - MPFR-Certified Unary Golden Vectors (Trig & Pi-Trig) (Part 4)

extension SIMDUnaryOperation {
    static let tanpiGoldenVectors: [UnaryGoldenVector] = [
        UnaryGoldenVector(
            inputBits: 0xFFEF_FFFF_FFFF_FFFF, expectedBits: 0x8000_0000_0000_0000, maxULP: 2, label: "anchor-0"),
        UnaryGoldenVector(
            inputBits: 0xC340_0000_0000_0000, expectedBits: 0x8000_0000_0000_0000, maxULP: 2, label: "anchor-1"),
        UnaryGoldenVector(
            inputBits: 0xC330_0000_0000_0001, expectedBits: 0x0000_0000_0000_0000, maxULP: 2, label: "anchor-2"),
        UnaryGoldenVector(
            inputBits: 0xC330_0000_0000_0000, expectedBits: 0x8000_0000_0000_0000, maxULP: 2, label: "anchor-3"),
        UnaryGoldenVector(
            inputBits: 0xC32F_FFFF_FFFF_FFFF, expectedBits: 0x7FF0_0000_0000_0000, maxULP: 2, label: "anchor-4"),
        UnaryGoldenVector(
            inputBits: 0xC004_0000_0000_0000, expectedBits: 0xFFF0_0000_0000_0000, maxULP: 2, label: "anchor-5"),
        UnaryGoldenVector(
            inputBits: 0xBFF8_0000_0000_0000, expectedBits: 0x7FF0_0000_0000_0000, maxULP: 2, label: "anchor-6"),
        UnaryGoldenVector(
            inputBits: 0xBFF0_0000_0000_0000, expectedBits: 0x0000_0000_0000_0000, maxULP: 2, label: "anchor-7"),
        UnaryGoldenVector(
            inputBits: 0xBFE0_0000_0000_0000, expectedBits: 0xFFF0_0000_0000_0000, maxULP: 2, label: "anchor-8"),
        UnaryGoldenVector(
            inputBits: 0xBFD0_0000_0000_0000, expectedBits: 0xBFF0_0000_0000_0000, maxULP: 2, label: "anchor-9"),
        UnaryGoldenVector(
            inputBits: 0x8000_0000_0000_0001, expectedBits: 0x8000_0000_0000_0003, maxULP: 2, label: "anchor-10"),
        UnaryGoldenVector(
            inputBits: 0x8000_0000_0000_0000, expectedBits: 0x8000_0000_0000_0000, maxULP: 2, label: "anchor-11"),
        UnaryGoldenVector(
            inputBits: 0x0000_0000_0000_0000, expectedBits: 0x0000_0000_0000_0000, maxULP: 2, label: "anchor-12"),
        UnaryGoldenVector(
            inputBits: 0x0000_0000_0000_0001, expectedBits: 0x0000_0000_0000_0003, maxULP: 2, label: "anchor-13"),
        UnaryGoldenVector(
            inputBits: 0x3FD0_0000_0000_0000, expectedBits: 0x3FF0_0000_0000_0000, maxULP: 2, label: "anchor-14"),
        UnaryGoldenVector(
            inputBits: 0x3FE0_0000_0000_0000, expectedBits: 0x7FF0_0000_0000_0000, maxULP: 2, label: "anchor-15"),
        UnaryGoldenVector(
            inputBits: 0x3FF0_0000_0000_0000, expectedBits: 0x8000_0000_0000_0000, maxULP: 2, label: "anchor-16"),
        UnaryGoldenVector(
            inputBits: 0x3FF8_0000_0000_0000, expectedBits: 0xFFF0_0000_0000_0000, maxULP: 2, label: "anchor-17"),
        UnaryGoldenVector(
            inputBits: 0x4004_0000_0000_0000, expectedBits: 0x7FF0_0000_0000_0000, maxULP: 2, label: "anchor-18"),
        UnaryGoldenVector(
            inputBits: 0x430F_FFFF_FFFF_FFFF, expectedBits: 0xBFDA_8279_99FC_EF32, maxULP: 2, label: "anchor-19"),
        UnaryGoldenVector(
            inputBits: 0x4310_0000_0000_0000, expectedBits: 0x0000_0000_0000_0000, maxULP: 2, label: "anchor-20"),
        UnaryGoldenVector(
            inputBits: 0x432F_FFFF_FFFF_FFFF, expectedBits: 0xFFF0_0000_0000_0000, maxULP: 2, label: "anchor-21"),
        UnaryGoldenVector(
            inputBits: 0x4330_0000_0000_0000, expectedBits: 0x0000_0000_0000_0000, maxULP: 2, label: "anchor-22"),
        UnaryGoldenVector(
            inputBits: 0x4330_0000_0000_0001, expectedBits: 0x8000_0000_0000_0000, maxULP: 2, label: "anchor-23"),
        UnaryGoldenVector(
            inputBits: 0x4340_0000_0000_0000, expectedBits: 0x0000_0000_0000_0000, maxULP: 2, label: "anchor-24"),
        UnaryGoldenVector(
            inputBits: 0x7FEF_FFFF_FFFF_FFFF, expectedBits: 0x0000_0000_0000_0000, maxULP: 2, label: "anchor-25"),
        UnaryGoldenVector(
            inputBits: 0x3FCF_A2CC_ADF6_BE6A, expectedBits: 0x3FEF_6EE4_CE79_9D67, maxULP: 2, label: "worst-0"),
        UnaryGoldenVector(
            inputBits: 0x400E_35EA_76D9_EF02, expectedBits: 0xBFEB_19D0_5B31_515B, maxULP: 2, label: "worst-1"),
        UnaryGoldenVector(
            inputBits: 0x4046_5579_D914_CEEE, expectedBits: 0xBFFB_7D77_EFF2_634B, maxULP: 2, label: "worst-2"),
        UnaryGoldenVector(
            inputBits: 0x408E_2618_DD1A_6EFA, expectedBits: 0xBFED_A5C8_BF54_F5D9, maxULP: 2, label: "worst-3"),
        UnaryGoldenVector(
            inputBits: 0xBFCF_A2CC_ADF6_BE6A, expectedBits: 0xBFEF_6EE4_CE79_9D67, maxULP: 2, label: "worst-4"),
        UnaryGoldenVector(
            inputBits: 0xC00E_35EA_76D9_EF02, expectedBits: 0x3FEB_19D0_5B31_515B, maxULP: 2, label: "worst-5"),
        UnaryGoldenVector(
            inputBits: 0xC046_5579_D914_CEEE, expectedBits: 0x3FFB_7D77_EFF2_634B, maxULP: 2, label: "worst-6"),
        UnaryGoldenVector(
            inputBits: 0xC08E_2618_DD1A_6EFA, expectedBits: 0x3FED_A5C8_BF54_F5D9, maxULP: 2, label: "worst-7")
    ]
}
