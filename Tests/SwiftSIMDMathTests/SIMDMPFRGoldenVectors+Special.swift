import SwiftSIMDMathTestSupport

// MARK: - MPFR-Certified Unary Golden Vectors (Error, Gamma & Extended)

extension SIMDUnaryOperation {
    static let erfGoldenVectors: [UnaryGoldenVector] = [
        UnaryGoldenVector(
            inputBits: 0xC01A_0000_0000_0000, expectedBits: 0xBFF0_0000_0000_0000, maxULP: 2, label: "anchor-0"),
        UnaryGoldenVector(
            inputBits: 0xBFFD_70A3_D70A_3D71, expectedBits: 0xBFEF_B41B_DFB6_D30E, maxULP: 2, label: "anchor-1"),
        UnaryGoldenVector(
            inputBits: 0xBFEB_0000_0000_0000, expectedBits: 0xBFE8_8D1C_D474_A2E0, maxULP: 2, label: "anchor-2"),
        UnaryGoldenVector(
            inputBits: 0x8000_0000_0000_0000, expectedBits: 0x8000_0000_0000_0000, maxULP: 2, label: "anchor-3"),
        UnaryGoldenVector(
            inputBits: 0x0000_0000_0000_0000, expectedBits: 0x0000_0000_0000_0000, maxULP: 2, label: "anchor-4"),
        UnaryGoldenVector(
            inputBits: 0x3FEB_0000_0000_0000, expectedBits: 0x3FE8_8D1C_D474_A2E0, maxULP: 2, label: "anchor-5"),
        UnaryGoldenVector(
            inputBits: 0x3FFD_70A3_D70A_3D71, expectedBits: 0x3FEF_B41B_DFB6_D30E, maxULP: 2, label: "anchor-6"),
        UnaryGoldenVector(
            inputBits: 0x401A_0000_0000_0000, expectedBits: 0x3FF0_0000_0000_0000, maxULP: 2, label: "anchor-7"),
        UnaryGoldenVector(
            inputBits: 0xBFDC_B778_DFD7_2840, expectedBits: 0xBFDE_5AA0_6FF2_33D6, maxULP: 2, label: "worst-0"),
        UnaryGoldenVector(
            inputBits: 0x3FDD_BB81_C8E3_26E0, expectedBits: 0x3FDF_48D1_37E1_BC16, maxULP: 2, label: "worst-1"),
        UnaryGoldenVector(
            inputBits: 0x3F72_54E3_1304_B400, expectedBits: 0x3F74_AF52_117D_35F8, maxULP: 2, label: "worst-2"),
        UnaryGoldenVector(
            inputBits: 0x3FB4_213C_FCC0_F040, expectedBits: 0x3FB6_AAD8_31A6_6CA5, maxULP: 2, label: "worst-3"),
        UnaryGoldenVector(
            inputBits: 0x4003_10F7_41D7_5894, expectedBits: 0x3FEF_F9DA_4F9D_3521, maxULP: 2, label: "worst-4"),
        UnaryGoldenVector(
            inputBits: 0xBF72_F1EA_1AAB_9000, expectedBits: 0xBF75_6080_E07C_54E4, maxULP: 2, label: "worst-5"),
        UnaryGoldenVector(
            inputBits: 0xBFBC_78A1_5C6B_1C00, expectedBits: 0xBFBF_FE8E_292C_D706, maxULP: 2, label: "worst-6"),
        UnaryGoldenVector(
            inputBits: 0xC002_307A_8793_0EDA, expectedBits: 0xBFEF_F554_BA91_7D45, maxULP: 2, label: "worst-7")
    ]

    static let erfcGoldenVectors: [UnaryGoldenVector] = [
        UnaryGoldenVector(
            inputBits: 0xC018_0000_0000_0000, expectedBits: 0x4000_0000_0000_0000, maxULP: 6, label: "anchor-0"),
        UnaryGoldenVector(
            inputBits: 0x0000_0000_0000_0000, expectedBits: 0x3FF0_0000_0000_0000, maxULP: 6, label: "anchor-1"),
        UnaryGoldenVector(
            inputBits: 0x3FEB_0000_0000_0000, expectedBits: 0x3FCD_CB8C_AE2D_747F, maxULP: 6, label: "anchor-2"),
        UnaryGoldenVector(
            inputBits: 0x3FFD_70A3_D70A_3D71, expectedBits: 0x3F82_F908_124B_3C6A, maxULP: 6, label: "anchor-3"),
        UnaryGoldenVector(
            inputBits: 0x4012_0000_0000_0000, expectedBits: 0x3DEB_05CF_E2E9_9435, maxULP: 6, label: "anchor-4"),
        UnaryGoldenVector(
            inputBits: 0x403A_8A3D_70A3_D70A, expectedBits: 0x0013_060B_1CF4_4591, maxULP: 6, label: "anchor-5"),
        UnaryGoldenVector(
            inputBits: 0x403B_3333_3333_3333, expectedBits: 0x0000_0000_0000_0002, maxULP: 6, label: "anchor-6"),
        UnaryGoldenVector(
            inputBits: 0x403B_5999_9999_999A, expectedBits: 0x0000_0000_0000_0000, maxULP: 6, label: "anchor-7"),
        UnaryGoldenVector(
            inputBits: 0x4003_BAF1_3282_3904, expectedBits: 0x3F3F_E944_E6CC_B94C, maxULP: 6, label: "worst-0"),
        UnaryGoldenVector(
            inputBits: 0x3FFE_1A04_0E97_4CD0, expectedBits: 0x3F7F_F242_4164_F6EB, maxULP: 6, label: "worst-1"),
        UnaryGoldenVector(
            inputBits: 0x3F37_D5F5_32F0_4000, expectedBits: 0x3FEF_FCA3_55B4_17C0, maxULP: 6, label: "worst-2"),
        UnaryGoldenVector(
            inputBits: 0x3F62_1A98_3BBA_1000, expectedBits: 0x3FEF_EB92_6DAE_E12A, maxULP: 6, label: "worst-3"),
        UnaryGoldenVector(
            inputBits: 0x3FAC_80F6_A8AA_0680, expectedBits: 0x3FED_FDEC_1BC8_F6F1, maxULP: 6, label: "worst-4"),
        UnaryGoldenVector(
            inputBits: 0xBFBE_A91D_EFEB_0BC0, expectedBits: 0x3FF2_26E9_D028_7BE3, maxULP: 6, label: "worst-5"),
        UnaryGoldenVector(
            inputBits: 0xBFE6_08C0_CA85_5CB8, expectedBits: 0x3FFA_B7A5_977D_6B1D, maxULP: 6, label: "worst-6"),
        UnaryGoldenVector(
            inputBits: 0xC002_CAF4_247A_54DE, expectedBits: 0x3FFF_FC57_43BE_98C3, maxULP: 6, label: "worst-7")
    ]

    static let tgammaGoldenVectors: [UnaryGoldenVector] = [
        UnaryGoldenVector(
            inputBits: 0xC065_7000_0000_0000, expectedBits: 0x0000_238E_E05C_879E, maxULP: 4, label: "anchor-0"),
        UnaryGoldenVector(
            inputBits: 0xC065_5000_0000_0000, expectedBits: 0x8017_D237_4DFC_DA7A, maxULP: 4, label: "anchor-1"),
        UnaryGoldenVector(
            inputBits: 0xC038_D265_6BB4_B2E8, expectedBits: 0xBAEA_4368_48CC_9743, maxULP: 4, label: "anchor-2"),
        UnaryGoldenVector(
            inputBits: 0xC025_0000_0000_0000, expectedBits: 0xBE91_B7B1_DB2E_47F1, maxULP: 4, label: "anchor-3"),
        UnaryGoldenVector(
            inputBits: 0xBFE0_0000_0000_0000, expectedBits: 0xC00C_5BF8_91B4_EF6B, maxULP: 4, label: "anchor-4"),
        UnaryGoldenVector(
            inputBits: 0x3FE0_0000_0000_0000, expectedBits: 0x3FFC_5BF8_91B4_EF6B, maxULP: 4, label: "anchor-5"),
        UnaryGoldenVector(
            inputBits: 0x3FF0_0000_0000_0000, expectedBits: 0x3FF0_0000_0000_0000, maxULP: 4, label: "anchor-6"),
        UnaryGoldenVector(
            inputBits: 0x4020_0000_0000_0000, expectedBits: 0x40B3_B000_0000_0000, maxULP: 4, label: "anchor-7"),
        UnaryGoldenVector(
            inputBits: 0x4065_73F7_CED9_1687, expectedBits: 0x7FEF_F022_B304_6114, maxULP: 4, label: "anchor-8"),
        UnaryGoldenVector(
            inputBits: 0xC065_1AA6_832A_C78A, expectedBits: 0x80EE_628F_489E_10AA, maxULP: 4, label: "worst-0"),
        UnaryGoldenVector(
            inputBits: 0x3E50_A1B1_CD75_5FFD, expectedBits: 0x418E_C8E4_6736_275C, maxULP: 4, label: "worst-1"),
        UnaryGoldenVector(
            inputBits: 0x3E91_0644_8958_0852, expectedBits: 0x414E_1307_472D_D60C, maxULP: 4, label: "worst-2"),
        UnaryGoldenVector(
            inputBits: 0x3F10_FA5D_28F5_164E, expectedBits: 0x40CE_27D3_BAF0_8219, maxULP: 4, label: "worst-3"),
        UnaryGoldenVector(
            inputBits: 0x3F70_73EF_82F5_126A, expectedBits: 0x406F_0C2A_BD13_7119, maxULP: 4, label: "worst-4"),
        UnaryGoldenVector(
            inputBits: 0x3FA0_15FF_527C_BBEA, expectedBits: 0x403F_4834_CEB2_B2A1, maxULP: 4, label: "worst-5"),
        UnaryGoldenVector(
            inputBits: 0x3FF0_2BCF_9719_67CA, expectedBits: 0x3FEF_CE57_5E24_3AEE, maxULP: 4, label: "worst-6"),
        UnaryGoldenVector(
            inputBits: 0xBFF1_03F5_7AB5_2180, expectedBits: 0x402E_D7CE_A9F9_1CD7, maxULP: 4, label: "worst-7")
    ]

    static let lgammaGoldenVectors: [UnaryGoldenVector] = [
        UnaryGoldenVector(
            inputBits: 0xC059_2000_0000_0000, expectedBits: 0xC076_CE6A_5DBE_FB91, maxULP: 4, label: "anchor-0"),
        UnaryGoldenVector(
            inputBits: 0xC025_0000_0000_0000, expectedBits: 0xC02E_4B67_0D05_976A, maxULP: 4, label: "anchor-1"),
        UnaryGoldenVector(
            inputBits: 0xBFF8_0000_0000_0000, expectedBits: 0x3FEB_8581_5182_0F86, maxULP: 4, label: "anchor-2"),
        UnaryGoldenVector(
            inputBits: 0xBFE0_0000_0000_0000, expectedBits: 0x3FF4_3F89_A3F0_EDD6, maxULP: 4, label: "anchor-3"),
        UnaryGoldenVector(
            inputBits: 0x3FE0_0000_0000_0000, expectedBits: 0x3FE2_50D0_48E7_A1BD, maxULP: 4, label: "anchor-4"),
        UnaryGoldenVector(
            inputBits: 0x3FF0_0000_0000_0000, expectedBits: 0x0000_0000_0000_0000, maxULP: 4, label: "anchor-5"),
        UnaryGoldenVector(
            inputBits: 0x3FF8_0000_0000_0000, expectedBits: 0xBFBE_EB95_B094_C191, maxULP: 4, label: "anchor-6"),
        UnaryGoldenVector(
            inputBits: 0x4020_0000_0000_0000, expectedBits: 0x4021_0CE1_F32D_CC30, maxULP: 4, label: "anchor-7"),
        UnaryGoldenVector(
            inputBits: 0x54B2_49AD_2594_C37D, expectedBits: 0x5530_60A2_2460_99AE, maxULP: 4, label: "anchor-8"),
        UnaryGoldenVector(
            inputBits: 0xBFFA_FF00_2C34_6B80, expectedBits: 0x3FEC_EE30_ACD0_6081, maxULP: 4, label: "worst-0"),
        UnaryGoldenVector(
            inputBits: 0x4004_DECF_3A14_3188, expectedBits: 0x3FD7_4C56_F759_FC99, maxULP: 4, label: "worst-1"),
        UnaryGoldenVector(
            inputBits: 0xC001_B901_257C_A540, expectedBits: 0x3FE6_CAEE_838B_98E2, maxULP: 4, label: "worst-2"),
        UnaryGoldenVector(
            inputBits: 0xC068_AF15_F428_29EA, expectedBits: 0xC08A_8590_E6B5_99C1, maxULP: 4, label: "worst-3"),
        UnaryGoldenVector(
            inputBits: 0x4051_90DB_C4D4_4F3C, expectedBits: 0x406C_69DD_5E17_D828, maxULP: 4, label: "worst-4"),
        UnaryGoldenVector(
            inputBits: 0x40AF_A273_96F1_D3DE, expectedBits: 0x40DC_E363_012A_F131, maxULP: 4, label: "worst-5"),
        UnaryGoldenVector(
            inputBits: 0x40CC_B6AC_D765_4A9C, expectedBits: 0x40FE_D9C7_067E_18E3, maxULP: 4, label: "worst-6"),
        UnaryGoldenVector(
            inputBits: 0x4115_4C16_D65A_1F04, expectedBits: 0x414F_505B_9722_7CFC, maxULP: 4, label: "worst-7")
    ]
}
