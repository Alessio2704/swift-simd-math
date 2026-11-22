import SwiftSIMDMathTestSupport

// MARK: - MPFR-Certified Unary Golden Vectors (Shaping & Hyperbolic) (Part 2)

extension SIMDUnaryOperation {
    static let tanhGoldenVectors: [UnaryGoldenVector] = [
        UnaryGoldenVector(
            inputBits: 0xC039_0000_0000_0000, expectedBits: 0xBFF0_0000_0000_0000, maxULP: 2, label: "anchor-0"),
        UnaryGoldenVector(
            inputBits: 0xBFE2_0000_0000_0000, expectedBits: 0xBFE0_5086_F2F6_D4B7, maxULP: 2, label: "anchor-1"),
        UnaryGoldenVector(
            inputBits: 0x8000_0000_0000_0000, expectedBits: 0x8000_0000_0000_0000, maxULP: 2, label: "anchor-2"),
        UnaryGoldenVector(
            inputBits: 0x0000_0000_0000_0000, expectedBits: 0x0000_0000_0000_0000, maxULP: 2, label: "anchor-3"),
        UnaryGoldenVector(
            inputBits: 0x3FE0_0000_0000_0012, expectedBits: 0x3FDD_9353_D756_8B10, maxULP: 2, label: "anchor-4"),
        UnaryGoldenVector(
            inputBits: 0x3FE2_0000_0000_0000, expectedBits: 0x3FE0_5086_F2F6_D4B7, maxULP: 2, label: "anchor-5"),
        UnaryGoldenVector(
            inputBits: 0x4034_0000_0000_0000, expectedBits: 0x3FF0_0000_0000_0000, maxULP: 2, label: "anchor-6"),
        UnaryGoldenVector(
            inputBits: 0x4076_0000_0000_0000, expectedBits: 0x3FF0_0000_0000_0000, maxULP: 2, label: "anchor-7"),
        UnaryGoldenVector(
            inputBits: 0xBFE2_1CBC_6DFE_3E00, expectedBits: 0xBFE0_65C1_816D_0E94, maxULP: 2, label: "worst-0"),
        UnaryGoldenVector(
            inputBits: 0x3FE2_16EA_3CA3_FFC0, expectedBits: 0x3FE0_6176_3378_5C9A, maxULP: 2, label: "worst-1"),
        UnaryGoldenVector(
            inputBits: 0x3FB0_99B2_9397_5B00, expectedBits: 0x3FB0_93C0_443F_3750, maxULP: 2, label: "worst-2"),
        UnaryGoldenVector(
            inputBits: 0x4010_41C3_7D64_52A4, expectedBits: 0x3FEF_FB2A_EEE4_5BF7, maxULP: 2, label: "worst-3"),
        UnaryGoldenVector(
            inputBits: 0xBFBB_ABAD_05D9_C700, expectedBits: 0xBFBB_9037_C0F3_45AC, maxULP: 2, label: "worst-4"),
        UnaryGoldenVector(
            inputBits: 0xC003_0798_2A57_7828, expectedBits: 0xBFEF_747E_FC29_87B7, maxULP: 2, label: "worst-5")
    ]

    static let asinhGoldenVectors: [UnaryGoldenVector] = [
        UnaryGoldenVector(
            inputBits: 0xFFEF_FFFF_FFFF_FFFF, expectedBits: 0xC086_33CE_8FB9_F87E, maxULP: 2, label: "anchor-0"),
        UnaryGoldenVector(
            inputBits: 0xBFE0_0000_0000_0000, expectedBits: 0xBFDE_CC2C_AEC5_160A, maxULP: 2, label: "anchor-1"),
        UnaryGoldenVector(
            inputBits: 0x8000_0000_0000_0000, expectedBits: 0x8000_0000_0000_0000, maxULP: 2, label: "anchor-2"),
        UnaryGoldenVector(
            inputBits: 0x0000_0000_0000_0000, expectedBits: 0x0000_0000_0000_0000, maxULP: 2, label: "anchor-3"),
        UnaryGoldenVector(
            inputBits: 0x3FE0_0000_0000_0000, expectedBits: 0x3FDE_CC2C_AEC5_160A, maxULP: 2, label: "anchor-4"),
        UnaryGoldenVector(
            inputBits: 0x7FEF_FFFF_FFFF_FFFF, expectedBits: 0x4086_33CE_8FB9_F87E, maxULP: 2, label: "anchor-5"),
        UnaryGoldenVector(
            inputBits: 0x3FCF_629B_CFC8_E336, expectedBits: 0x3FCF_1434_00C0_EB4C, maxULP: 2, label: "worst-0"),
        UnaryGoldenVector(
            inputBits: 0xBFCF_629B_CFC8_E336, expectedBits: 0xBFCF_1434_00C0_EB4C, maxULP: 2, label: "worst-1"),
        UnaryGoldenVector(
            inputBits: 0x3FAC_72E3_C873_AC70, expectedBits: 0x3FAC_6F25_C1BD_E315, maxULP: 2, label: "worst-2"),
        UnaryGoldenVector(
            inputBits: 0x4007_93A4_18A2_D754, expectedBits: 0x3FFC_D346_69D4_AB1D, maxULP: 2, label: "worst-3"),
        UnaryGoldenVector(
            inputBits: 0x404C_AF97_22F0_A8D6, expectedBits: 0x4012_F89A_468F_F287, maxULP: 2, label: "worst-4"),
        UnaryGoldenVector(
            inputBits: 0xBFAC_72E3_C873_AC70, expectedBits: 0xBFAC_6F25_C1BD_E315, maxULP: 2, label: "worst-5"),
        UnaryGoldenVector(
            inputBits: 0xC007_93A4_18A2_D754, expectedBits: 0xBFFC_D346_69D4_AB1D, maxULP: 2, label: "worst-6"),
        UnaryGoldenVector(
            inputBits: 0xC04C_AF97_22F0_A8D6, expectedBits: 0xC012_F89A_468F_F287, maxULP: 2, label: "worst-7")
    ]

    static let acoshGoldenVectors: [UnaryGoldenVector] = [
        UnaryGoldenVector(
            inputBits: 0x3FF0_0000_0000_0000, expectedBits: 0x0000_0000_0000_0000, maxULP: 2, label: "anchor-0"),
        UnaryGoldenVector(
            inputBits: 0x3FF0_0000_0000_0001, expectedBits: 0x3E56_A09E_667F_3BCC, maxULP: 2, label: "anchor-1"),
        UnaryGoldenVector(
            inputBits: 0x3FF0_0068_DB8B_AC71, expectedBits: 0x3F8C_F67D_7EC0_D4E5, maxULP: 2, label: "anchor-2"),
        UnaryGoldenVector(
            inputBits: 0x3FF8_0000_0000_0000, expectedBits: 0x3FEE_CC2C_AEC5_160A, maxULP: 2, label: "anchor-3"),
        UnaryGoldenVector(
            inputBits: 0x4000_0000_0000_0000, expectedBits: 0x3FF5_1242_7198_0435, maxULP: 2, label: "anchor-4"),
        UnaryGoldenVector(
            inputBits: 0x4190_0000_0000_0000, expectedBits: 0x4032_B708_8723_20E2, maxULP: 2, label: "anchor-5"),
        UnaryGoldenVector(
            inputBits: 0x7FEF_FFFF_FFFF_FFFF, expectedBits: 0x4086_33CE_8FB9_F87E, maxULP: 2, label: "anchor-6"),
        UnaryGoldenVector(
            inputBits: 0x3FF1_3DA4_1116_C3BD, expectedBits: 0x3FD9_0B70_DAE2_7A80, maxULP: 2, label: "worst-0"),
        UnaryGoldenVector(
            inputBits: 0x4040_4FC6_638D_B1CB, expectedBits: 0x4010_B635_2964_3309, maxULP: 2, label: "worst-1"),
        UnaryGoldenVector(
            inputBits: 0x4083_26C1_03A4_42CE, expectedBits: 0x401C_71ED_7131_C4C2, maxULP: 2, label: "worst-2"),
        UnaryGoldenVector(
            inputBits: 0x4190_0000_0000_000B, expectedBits: 0x4032_B708_8723_20E3, maxULP: 2, label: "worst-3"),
        UnaryGoldenVector(
            inputBits: 0x55B7_F3F2_2C39_3C96, expectedBits: 0x406E_49FA_D117_3575, maxULP: 2, label: "worst-4"),
        UnaryGoldenVector(
            inputBits: 0x563B_FA74_E944_6F9C, expectedBits: 0x406F_0065_767F_ED43, maxULP: 2, label: "worst-5"),
        UnaryGoldenVector(
            inputBits: 0x5FC7_999C_A731_327C, expectedBits: 0x4076_1E4C_AF7D_DBF1, maxULP: 2, label: "worst-6")
    ]

    static let atanhGoldenVectors: [UnaryGoldenVector] = [
        UnaryGoldenVector(
            inputBits: 0xBFF0_0000_0000_0001, expectedBits: 0x7FF8_0000_0000_0000, maxULP: 2, label: "anchor-0"),
        UnaryGoldenVector(
            inputBits: 0xBFE0_0000_0000_0000, expectedBits: 0xBFE1_93EA_7AAD_030B, maxULP: 2, label: "anchor-1"),
        UnaryGoldenVector(
            inputBits: 0x8000_0000_0000_0001, expectedBits: 0x8000_0000_0000_0001, maxULP: 2, label: "anchor-2"),
        UnaryGoldenVector(
            inputBits: 0x8000_0000_0000_0000, expectedBits: 0x8000_0000_0000_0000, maxULP: 2, label: "anchor-3"),
        UnaryGoldenVector(
            inputBits: 0x0000_0000_0000_0000, expectedBits: 0x0000_0000_0000_0000, maxULP: 2, label: "anchor-4"),
        UnaryGoldenVector(
            inputBits: 0x3FE0_0000_0000_0000, expectedBits: 0x3FE1_93EA_7AAD_030B, maxULP: 2, label: "anchor-5"),
        UnaryGoldenVector(
            inputBits: 0x3FEF_FFFF_FFFF_FFFF, expectedBits: 0x4032_B708_8723_20E2, maxULP: 2, label: "anchor-6"),
        UnaryGoldenVector(
            inputBits: 0x3FCA_2D87_5C44_3368, expectedBits: 0x3FCA_8D61_04E9_3DC8, maxULP: 2, label: "worst-0"),
        UnaryGoldenVector(
            inputBits: 0x3E78_50DA_6E3E_DADA, expectedBits: 0x3E78_50DA_6E3E_DAED, maxULP: 2, label: "worst-1"),
        UnaryGoldenVector(
            inputBits: 0x3F7F_EB59_4B17_C800, expectedBits: 0x3F7F_EB83_A3C2_0170, maxULP: 2, label: "worst-2"),
        UnaryGoldenVector(
            inputBits: 0x3FBE_FA45_06F9_4020, expectedBits: 0x3FBF_2151_D711_4333, maxULP: 2, label: "worst-3"),
        UnaryGoldenVector(
            inputBits: 0xBEB4_5258_B65C_2125, expectedBits: 0xBEB4_5258_B65C_2C12, maxULP: 2, label: "worst-4"),
        UnaryGoldenVector(
            inputBits: 0xBF7F_D6D9_70C2_0000, expectedBits: 0xBF7F_D703_7809_9A9A, maxULP: 2, label: "worst-5"),
        UnaryGoldenVector(
            inputBits: 0xBFBF_29BB_1768_F440, expectedBits: 0xBFBF_517D_8DFC_4902, maxULP: 2, label: "worst-6"),
        UnaryGoldenVector(
            inputBits: 0xBFCB_16AF_5E17_B3B0, expectedBits: 0xBFCB_8116_6C9C_EDC3, maxULP: 2, label: "worst-7")
    ]
}
