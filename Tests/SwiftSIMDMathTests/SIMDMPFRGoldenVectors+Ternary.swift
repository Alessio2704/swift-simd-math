import SwiftSIMDMathTestSupport

// MARK: - MPFR-Certified Ternary Golden Vectors

extension SIMDTernaryOperation {
    static let clampGoldenVectors: [TernaryGoldenVector] = [
        TernaryGoldenVector(
            firstInputBits: 0xC02E_0000_0000_0000, secondInputBits: 0xC024_0000_0000_0000,
            thirdInputBits: 0x4024_0000_0000_0000, expectedBits: 0xC024_0000_0000_0000, maxULP: 0, label: "anchor-0"),
        TernaryGoldenVector(
            firstInputBits: 0x0000_0000_0000_0000, secondInputBits: 0xC024_0000_0000_0000,
            thirdInputBits: 0x4024_0000_0000_0000, expectedBits: 0x0000_0000_0000_0000, maxULP: 0, label: "anchor-1"),
        TernaryGoldenVector(
            firstInputBits: 0x402E_0000_0000_0000, secondInputBits: 0xC024_0000_0000_0000,
            thirdInputBits: 0x4024_0000_0000_0000, expectedBits: 0x4024_0000_0000_0000, maxULP: 0, label: "anchor-2"),
        TernaryGoldenVector(
            firstInputBits: 0x7FF8_0000_0000_0000, secondInputBits: 0xBFF0_0000_0000_0000,
            thirdInputBits: 0x3FF0_0000_0000_0000, expectedBits: 0xBFF0_0000_0000_0000, maxULP: 0, label: "anchor-3"),
        TernaryGoldenVector(
            firstInputBits: 0x4041_1C16_0DA8_F5AE, secondInputBits: 0x4048_0723_2165_F1B6,
            thirdInputBits: 0x4060_20DD_DDCD_C78F, expectedBits: 0x4048_0723_2165_F1B6, maxULP: 0, label: "worst-0"),
        TernaryGoldenVector(
            firstInputBits: 0x4019_E6BD_813B_2A40, secondInputBits: 0xC043_F0FA_ADAC_523F,
            thirdInputBits: 0xC02C_CC11_2C06_E6A0, expectedBits: 0xC02C_CC11_2C06_E6A0, maxULP: 0, label: "worst-1"),
        TernaryGoldenVector(
            firstInputBits: 0xC029_6265_2F21_9C7D, secondInputBits: 0x4027_0F5B_B87B_19BD,
            thirdInputBits: 0x4046_E905_9085_D36A, expectedBits: 0x4027_0F5B_B87B_19BD, maxULP: 0, label: "worst-2"),
        TernaryGoldenVector(
            firstInputBits: 0xC02C_44CF_F02A_5077, secondInputBits: 0xC035_F4C0_B219_410A,
            thirdInputBits: 0xC019_CFFE_677E_BF10, expectedBits: 0xC02C_44CF_F02A_5077, maxULP: 0, label: "worst-3")
    ]

    static let mixGoldenVectors: [TernaryGoldenVector] = [
        TernaryGoldenVector(
            firstInputBits: 0x3FF0_0000_0000_0000, secondInputBits: 0x4014_0000_0000_0000,
            thirdInputBits: 0x0000_0000_0000_0000, expectedBits: 0x3FF0_0000_0000_0000, maxULP: 0, label: "anchor-0"),
        TernaryGoldenVector(
            firstInputBits: 0x3FF0_0000_0000_0000, secondInputBits: 0x4014_0000_0000_0000,
            thirdInputBits: 0x3FE0_0000_0000_0000, expectedBits: 0x4008_0000_0000_0000, maxULP: 0, label: "anchor-1"),
        TernaryGoldenVector(
            firstInputBits: 0x3FF0_0000_0000_0000, secondInputBits: 0x4014_0000_0000_0000,
            thirdInputBits: 0x3FF0_0000_0000_0000, expectedBits: 0x4014_0000_0000_0000, maxULP: 0, label: "anchor-2"),
        TernaryGoldenVector(
            firstInputBits: 0xC024_0000_0000_0000, secondInputBits: 0x4034_0000_0000_0000,
            thirdInputBits: 0x3FD0_0000_0000_0000, expectedBits: 0xC004_0000_0000_0000, maxULP: 0, label: "anchor-3"),
        TernaryGoldenVector(
            firstInputBits: 0x404B_8CF4_1986_4E2D, secondInputBits: 0x403B_4DBA_DE89_7F6D,
            thirdInputBits: 0x4048_C7EF_6D2E_DD7E, expectedBits: 0xC094_AA68_1446_7220, maxULP: 0, label: "worst-0"),
        TernaryGoldenVector(
            firstInputBits: 0x4044_42F4_3532_04EB, secondInputBits: 0xBFAB_82DC_D691_3D80,
            thirdInputBits: 0x4043_6DB5_AFC5_B524, expectedBits: 0xC098_00B2_93B6_F8EB, maxULP: 0, label: "worst-1"),
        TernaryGoldenVector(
            firstInputBits: 0xC03A_DB94_C6A2_7B8A, secondInputBits: 0xC050_1EBB_A6D6_5881,
            thirdInputBits: 0x4031_5068_C2DB_C2E8, expectedBits: 0xC085_320D_EAC6_6B2F, maxULP: 0, label: "worst-2"),
        TernaryGoldenVector(
            firstInputBits: 0xC025_F8B7_7A59_F74C, secondInputBits: 0xC04E_0156_AAD3_CA9D,
            thirdInputBits: 0xBFA0_96BB_BA1D_F800, expectedBits: 0xC022_CB74_B9C1_06FD, maxULP: 0, label: "worst-3"),
        TernaryGoldenVector(
            firstInputBits: 0xC05E_B943_6F50_3007, secondInputBits: 0xC058_E785_5ED6_061A,
            thirdInputBits: 0xC036_8307_CF07_F29C, expectedBits: 0xC084_3743_51A6_F611, maxULP: 0, label: "worst-4")
    ]

    static let smoothstepGoldenVectors: [TernaryGoldenVector] = [
        TernaryGoldenVector(
            firstInputBits: 0xBFF0_0000_0000_0000, secondInputBits: 0x0000_0000_0000_0000,
            thirdInputBits: 0x3FF0_0000_0000_0000, expectedBits: 0x0000_0000_0000_0000, maxULP: 0, label: "anchor-0"),
        TernaryGoldenVector(
            firstInputBits: 0x3FD0_0000_0000_0000, secondInputBits: 0x0000_0000_0000_0000,
            thirdInputBits: 0x3FF0_0000_0000_0000, expectedBits: 0x3FC4_0000_0000_0000, maxULP: 0, label: "anchor-1"),
        TernaryGoldenVector(
            firstInputBits: 0x3FE0_0000_0000_0000, secondInputBits: 0x0000_0000_0000_0000,
            thirdInputBits: 0x3FF0_0000_0000_0000, expectedBits: 0x3FE0_0000_0000_0000, maxULP: 0, label: "anchor-2"),
        TernaryGoldenVector(
            firstInputBits: 0x4000_0000_0000_0000, secondInputBits: 0x0000_0000_0000_0000,
            thirdInputBits: 0x3FF0_0000_0000_0000, expectedBits: 0x3FF0_0000_0000_0000, maxULP: 0, label: "anchor-3"),
        TernaryGoldenVector(
            firstInputBits: 0x4046_BCC4_1C4B_4805, secondInputBits: 0x3FF7_0134_92B2_5BCC,
            thirdInputBits: 0x403C_DEBE_5CB9_385D, expectedBits: 0x3FF0_0000_0000_0000, maxULP: 0, label: "worst-0"),
        TernaryGoldenVector(
            firstInputBits: 0x405F_4B85_D377_BBE0, secondInputBits: 0x4057_9B4B_C601_605E,
            thirdInputBits: 0x405D_8305_62A2_8474, expectedBits: 0x3FF0_0000_0000_0000, maxULP: 0, label: "worst-1"),
        TernaryGoldenVector(
            firstInputBits: 0x4029_1A74_9F41_D418, secondInputBits: 0xC057_05A8_DB12_9A14,
            thirdInputBits: 0xC013_FE94_F486_8CA0, expectedBits: 0x3FF0_0000_0000_0000, maxULP: 0, label: "worst-2"),
        TernaryGoldenVector(
            firstInputBits: 0xC04D_1A12_471E_0E35, secondInputBits: 0xC056_81A3_D705_9B3D,
            thirdInputBits: 0x4022_F2AA_B574_91E0, expectedBits: 0x3FCE_E723_DB2F_1FDB, maxULP: 0, label: "worst-3"),
        TernaryGoldenVector(
            firstInputBits: 0xC051_E342_24FD_315E, secondInputBits: 0xC051_87E8_A36D_F2C4,
            thirdInputBits: 0xC051_138C_BCBC_B654, expectedBits: 0x0000_0000_0000_0000, maxULP: 0, label: "worst-4")
    ]
}
