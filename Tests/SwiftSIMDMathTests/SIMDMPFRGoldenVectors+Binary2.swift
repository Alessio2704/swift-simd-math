import SwiftSIMDMathTestSupport

// MARK: - MPFR-Certified Binary Golden Vectors (Part 2)

extension SIMDBinaryOperation {
    static let maxGoldenVectors: [BinaryGoldenVector] = [
        BinaryGoldenVector(
            firstInputBits: 0xC014_0000_0000_0000, secondInputBits: 0x0000_0000_0000_0000,
            expectedBits: 0x0000_0000_0000_0000, maxULP: 0, label: "anchor-0"),
        BinaryGoldenVector(
            firstInputBits: 0x8000_0000_0000_0000, secondInputBits: 0x0000_0000_0000_0000,
            expectedBits: 0x0000_0000_0000_0000, maxULP: 0, label: "anchor-1"),
        BinaryGoldenVector(
            firstInputBits: 0x0000_0000_0000_0000, secondInputBits: 0x8000_0000_0000_0000,
            expectedBits: 0x0000_0000_0000_0000, maxULP: 0, label: "anchor-2"),
        BinaryGoldenVector(
            firstInputBits: 0x7FF8_0000_0000_0000, secondInputBits: 0x4008_0000_0000_0000,
            expectedBits: 0x4008_0000_0000_0000, maxULP: 0, label: "anchor-3"),
        BinaryGoldenVector(
            firstInputBits: 0x7FF0_0000_0000_0001, secondInputBits: 0x4008_0000_0000_0000,
            expectedBits: 0x7FF8_0000_0000_0000, maxULP: 0, label: "anchor-4"),
        BinaryGoldenVector(
            firstInputBits: 0x0209_3857_4CD1_08B0, secondInputBits: 0xCCD8_0598_6D93_D209,
            expectedBits: 0x0209_3857_4CD1_08B0, maxULP: 0, label: "worst-0"),
        BinaryGoldenVector(
            firstInputBits: 0x3AE0_7DBF_9780_8160, secondInputBits: 0x8017_27A9_4343_B604,
            expectedBits: 0x3AE0_7DBF_9780_8160, maxULP: 0, label: "worst-1"),
        BinaryGoldenVector(
            firstInputBits: 0x3DEE_DFDE_783A_ADCF, secondInputBits: 0x489F_8309_955A_747C,
            expectedBits: 0x489F_8309_955A_747C, maxULP: 0, label: "worst-2"),
        BinaryGoldenVector(
            firstInputBits: 0xC575_B56C_5F95_8F8A, secondInputBits: 0xC894_C74B_7C97_7EF4,
            expectedBits: 0xC575_B56C_5F95_8F8A, maxULP: 0, label: "worst-3")
    ]

    static let stepGoldenVectors: [BinaryGoldenVector] = [
        BinaryGoldenVector(
            firstInputBits: 0x3FEF_FFFF_FFFF_FFFF, secondInputBits: 0x3FF0_0000_0000_0000,
            expectedBits: 0x0000_0000_0000_0000, maxULP: 0, label: "anchor-0"),
        BinaryGoldenVector(
            firstInputBits: 0x3FF0_0000_0000_0000, secondInputBits: 0x3FF0_0000_0000_0000,
            expectedBits: 0x3FF0_0000_0000_0000, maxULP: 0, label: "anchor-1"),
        BinaryGoldenVector(
            firstInputBits: 0x3FF0_0000_0000_0001, secondInputBits: 0x3FF0_0000_0000_0000,
            expectedBits: 0x3FF0_0000_0000_0000, maxULP: 0, label: "anchor-2"),
        BinaryGoldenVector(
            firstInputBits: 0x8000_0000_0000_0000, secondInputBits: 0x0000_0000_0000_0000,
            expectedBits: 0x3FF0_0000_0000_0000, maxULP: 0, label: "anchor-3"),
        BinaryGoldenVector(
            firstInputBits: 0x7FF8_0000_0000_0000, secondInputBits: 0x0000_0000_0000_0000,
            expectedBits: 0x3FF0_0000_0000_0000, maxULP: 0, label: "anchor-4"),
        BinaryGoldenVector(
            firstInputBits: 0x25C5_4529_E1D9_CDEC, secondInputBits: 0x1F1A_47DC_BEC0_15CB,
            expectedBits: 0x3FF0_0000_0000_0000, maxULP: 0, label: "worst-0"),
        BinaryGoldenVector(
            firstInputBits: 0x38AF_50B5_F3E2_5038, secondInputBits: 0x07AA_C2C7_7EC6_70EC,
            expectedBits: 0x3FF0_0000_0000_0000, maxULP: 0, label: "worst-1"),
        BinaryGoldenVector(
            firstInputBits: 0x3CFF_1F32_B259_98D2, secondInputBits: 0xD414_2F0D_5BAF_6B59,
            expectedBits: 0x3FF0_0000_0000_0000, maxULP: 0, label: "worst-2"),
        BinaryGoldenVector(
            firstInputBits: 0x53DA_AFC0_F4D0_F618, secondInputBits: 0x1BDA_C007_9F5B_CD3A,
            expectedBits: 0x3FF0_0000_0000_0000, maxULP: 0, label: "worst-3"),
        BinaryGoldenVector(
            firstInputBits: 0x7E0A_5A03_26F7_8542, secondInputBits: 0x14C0_DEBA_321F_DE83,
            expectedBits: 0x3FF0_0000_0000_0000, maxULP: 0, label: "worst-4")
    ]
}
