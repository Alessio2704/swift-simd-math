import SwiftSIMDMathTestSupport

// MARK: - MPFR-Certified Unary Golden Vectors (Exp & Log)

extension SIMDUnaryOperation {
    static let expGoldenVectors: [UnaryGoldenVector] = [
        UnaryGoldenVector(
            inputBits: 0xC087_5000_0000_0000, expectedBits: 0x0000_0000_0000_0000, maxULP: 1, label: "anchor-0"),
        UnaryGoldenVector(
            inputBits: 0xC087_4910_D52D_3052, expectedBits: 0x0000_0000_0000_0000, maxULP: 1, label: "anchor-1"),
        UnaryGoldenVector(
            inputBits: 0xC086_232B_DD7A_BCD2, expectedBits: 0x0010_0000_0000_007C, maxULP: 1, label: "anchor-2"),
        UnaryGoldenVector(
            inputBits: 0xBFF0_0000_0000_0000, expectedBits: 0x3FD7_8B56_362C_EF38, maxULP: 1, label: "anchor-3"),
        UnaryGoldenVector(
            inputBits: 0x8000_0000_0000_0000, expectedBits: 0x3FF0_0000_0000_0000, maxULP: 1, label: "anchor-4"),
        UnaryGoldenVector(
            inputBits: 0x0000_0000_0000_0000, expectedBits: 0x3FF0_0000_0000_0000, maxULP: 1, label: "anchor-5"),
        UnaryGoldenVector(
            inputBits: 0x3FF0_0000_0000_0000, expectedBits: 0x4005_BF0A_8B14_5769, maxULP: 1, label: "anchor-6"),
        UnaryGoldenVector(
            inputBits: 0x4086_2E42_FEFA_39EF, expectedBits: 0x7FEF_FFFF_FFFF_FF2A, maxULP: 1, label: "anchor-7"),
        UnaryGoldenVector(
            inputBits: 0x3FFD_4202_4246_7A00, expectedBits: 0x4018_E6AA_ED84_215F, maxULP: 1, label: "worst-0"),
        UnaryGoldenVector(
            inputBits: 0x4036_51BC_1A15_5000, expectedBits: 0x41F2_60C5_F021_24F8, maxULP: 1, label: "worst-1"),
        UnaryGoldenVector(
            inputBits: 0x407E_C099_3B16_9F38, expectedBits: 0x6C4D_0A0A_C83A_F89E, maxULP: 1, label: "worst-2"),
        UnaryGoldenVector(
            inputBits: 0x4085_1C87_5952_F3F2, expectedBits: 0x7CD8_DC8F_C946_87B6, maxULP: 1, label: "worst-3"),
        UnaryGoldenVector(
            inputBits: 0xBFF6_5D63_33CE_3C00, expectedBits: 0x3FCF_A249_DBEC_F983, maxULP: 1, label: "worst-4"),
        UnaryGoldenVector(
            inputBits: 0xC033_7915_5E2E_B4A0, expectedBits: 0x3E2D_FD85_9B2C_D9FD, maxULP: 1, label: "worst-5"),
        UnaryGoldenVector(
            inputBits: 0xC06B_2420_D654_3C80, expectedBits: 0x2C5A_E41E_68BA_5CE7, maxULP: 1, label: "worst-6"),
        UnaryGoldenVector(
            inputBits: 0xC080_62F9_7CD9_31B8, expectedBits: 0x10A6_7E17_E849_57D4, maxULP: 1, label: "worst-7")
    ]

    static let exp2GoldenVectors: [UnaryGoldenVector] = [
        UnaryGoldenVector(
            inputBits: 0xC090_CC00_0000_0000, expectedBits: 0x0000_0000_0000_0000, maxULP: 1, label: "anchor-0"),
        UnaryGoldenVector(
            inputBits: 0xC090_C800_0000_0000, expectedBits: 0x0000_0000_0000_0001, maxULP: 1, label: "anchor-1"),
        UnaryGoldenVector(
            inputBits: 0xC08F_F000_0000_0000, expectedBits: 0x0010_0000_0000_0000, maxULP: 1, label: "anchor-2"),
        UnaryGoldenVector(
            inputBits: 0x8000_0000_0000_0000, expectedBits: 0x3FF0_0000_0000_0000, maxULP: 1, label: "anchor-3"),
        UnaryGoldenVector(
            inputBits: 0x0000_0000_0000_0000, expectedBits: 0x3FF0_0000_0000_0000, maxULP: 1, label: "anchor-4"),
        UnaryGoldenVector(
            inputBits: 0x3FE0_0000_0000_0000, expectedBits: 0x3FF6_A09E_667F_3BCD, maxULP: 1, label: "anchor-5"),
        UnaryGoldenVector(
            inputBits: 0x408F_F800_0000_0000, expectedBits: 0x7FE0_0000_0000_0000, maxULP: 1, label: "anchor-6"),
        UnaryGoldenVector(
            inputBits: 0x4090_0000_0000_0000, expectedBits: 0x7FF0_0000_0000_0000, maxULP: 1, label: "anchor-7"),
        UnaryGoldenVector(
            inputBits: 0x400D_5E2A_2AB2_3C00, expectedBits: 0x4029_7975_4A3B_7061, maxULP: 1, label: "worst-0"),
        UnaryGoldenVector(
            inputBits: 0x407A_BE8A_3495_E100, expectedBits: 0x5AAE_09DC_134B_33EB, maxULP: 1, label: "worst-1"),
        UnaryGoldenVector(
            inputBits: 0x408A_2481_89B3_2BC0, expectedBits: 0x7437_A43A_B0CA_96C1, maxULP: 1, label: "worst-2"),
        UnaryGoldenVector(
            inputBits: 0xBFF7_EB54_0BBA_2C00, expectedBits: 0x3FD6_B4EA_F72C_3D2C, maxULP: 1, label: "worst-3"),
        UnaryGoldenVector(
            inputBits: 0xC021_1560_8D84_CB80, expectedBits: 0x3F65_FB61_57DF_869E, maxULP: 1, label: "worst-4"),
        UnaryGoldenVector(
            inputBits: 0xC07C_BA55_15B4_0F1E, expectedBits: 0x2334_73EB_8777_B585, maxULP: 1, label: "worst-5"),
        UnaryGoldenVector(
            inputBits: 0xC08F_F000_0000_0003, expectedBits: 0x000F_FFFF_FFFF_FBD7, maxULP: 1, label: "worst-6")
    ]

    static let exp10GoldenVectors: [UnaryGoldenVector] = [
        UnaryGoldenVector(
            inputBits: 0xC074_4000_0000_0000, expectedBits: 0x0000_0000_0000_0000, maxULP: 1, label: "anchor-0"),
        UnaryGoldenVector(
            inputBits: 0xC074_34CC_CCCC_CCCD, expectedBits: 0x0000_0000_0000_0001, maxULP: 1, label: "anchor-1"),
        UnaryGoldenVector(
            inputBits: 0xC073_3A66_6666_6666, expectedBits: 0x0010_191F_577A_FF64, maxULP: 1, label: "anchor-2"),
        UnaryGoldenVector(
            inputBits: 0x8000_0000_0000_0000, expectedBits: 0x3FF0_0000_0000_0000, maxULP: 1, label: "anchor-3"),
        UnaryGoldenVector(
            inputBits: 0x0000_0000_0000_0000, expectedBits: 0x3FF0_0000_0000_0000, maxULP: 1, label: "anchor-4"),
        UnaryGoldenVector(
            inputBits: 0x3FF0_0000_0000_0000, expectedBits: 0x4024_0000_0000_0000, maxULP: 1, label: "anchor-5"),
        UnaryGoldenVector(
            inputBits: 0x4073_4413_509F_79FE, expectedBits: 0x7FEF_FFFF_FFFF_FBA1, maxULP: 1, label: "anchor-6"),
        UnaryGoldenVector(
            inputBits: 0x4073_5000_0000_0000, expectedBits: 0x7FF0_0000_0000_0000, maxULP: 1, label: "anchor-7"),
        UnaryGoldenVector(
            inputBits: 0xC073_3A71_46F7_2A42, expectedBits: 0x000F_FFFF_FFFF_FFE3, maxULP: 1, label: "worst-0"),
        UnaryGoldenVector(
            inputBits: 0x3FBF_3CE5_372E_A000, expectedBits: 0x3FF5_30CA_1A19_2D77, maxULP: 1, label: "worst-1"),
        UnaryGoldenVector(
            inputBits: 0x3FF1_F586_36EA_6000, expectedBits: 0x402A_838A_46BA_598B, maxULP: 1, label: "worst-2"),
        UnaryGoldenVector(
            inputBits: 0x403B_5173_E6E7_5E20, expectedBits: 0x459A_E3E8_AB1E_BE37, maxULP: 1, label: "worst-3"),
        UnaryGoldenVector(
            inputBits: 0x4062_0D66_A987_CBAA, expectedBits: 0x5DEA_E2F0_D94E_D9C5, maxULP: 1, label: "worst-4"),
        UnaryGoldenVector(
            inputBits: 0xBFB5_9C3A_7BDD_5000, expectedBits: 0x3FEA_58E3_B3BD_2AA9, maxULP: 1, label: "worst-5"),
        UnaryGoldenVector(
            inputBits: 0xBFDE_2657_3FB9_2800, expectedBits: 0x3FD5_A1B4_6E4C_0FF1, maxULP: 1, label: "worst-6"),
        UnaryGoldenVector(
            inputBits: 0xC014_D71B_6DAB_2FC0, expectedBits: 0x3ED9_DBA3_90F1_7C0B, maxULP: 1, label: "worst-7")
    ]

    static let expm1GoldenVectors: [UnaryGoldenVector] = [
        UnaryGoldenVector(
            inputBits: 0xC044_0000_0000_0000, expectedBits: 0xBFF0_0000_0000_0000, maxULP: 2, label: "anchor-0"),
        UnaryGoldenVector(
            inputBits: 0xBFD6_6666_6666_6666, expectedBits: 0xBFD2_E663_ED31_C11E, maxULP: 2, label: "anchor-1"),
        UnaryGoldenVector(
            inputBits: 0xBD71_9799_812D_EA11, expectedBits: 0xBD71_9799_812D_E065, maxULP: 2, label: "anchor-2"),
        UnaryGoldenVector(
            inputBits: 0x8000_0000_0000_0000, expectedBits: 0x8000_0000_0000_0000, maxULP: 2, label: "anchor-3"),
        UnaryGoldenVector(
            inputBits: 0x0000_0000_0000_0000, expectedBits: 0x0000_0000_0000_0000, maxULP: 2, label: "anchor-4"),
        UnaryGoldenVector(
            inputBits: 0x3D71_9799_812D_EA11, expectedBits: 0x3D71_9799_812D_F3BD, maxULP: 2, label: "anchor-5"),
        UnaryGoldenVector(
            inputBits: 0x3FD8_1158_34E5_1400, expectedBits: 0x3FDD_37D4_3191_BED4, maxULP: 2, label: "anchor-6"),
        UnaryGoldenVector(
            inputBits: 0x4086_2E42_FEFA_39EF, expectedBits: 0x7FEF_FFFF_FFFF_FF2A, maxULP: 2, label: "anchor-7"),
        UnaryGoldenVector(
            inputBits: 0x3FB8_A977_9C82_5400, expectedBits: 0x3FB9_E394_4330_59AA, maxULP: 2, label: "worst-0"),
        UnaryGoldenVector(
            inputBits: 0x4016_D29F_5810_1270, expectedBits: 0x4072_B925_3F68_F1AF, maxULP: 2, label: "worst-1"),
        UnaryGoldenVector(
            inputBits: 0x4066_0E82_341A_115C, expectedBits: 0x4FD7_BA05_AA65_06CD, maxULP: 2, label: "worst-2"),
        UnaryGoldenVector(
            inputBits: 0x4080_FECC_3493_DAAB, expectedBits: 0x70F8_686F_49C3_74AF, maxULP: 2, label: "worst-3"),
        UnaryGoldenVector(
            inputBits: 0xBFD6_2E42_FEFA_39EF, expectedBits: 0xBFD2_BEC3_3301_8867, maxULP: 2, label: "worst-4"),
        UnaryGoldenVector(
            inputBits: 0xC010_12AD_F5B9_39E0, expectedBits: 0xBFEF_6CAB_A578_C20B, maxULP: 2, label: "worst-5"),
        UnaryGoldenVector(
            inputBits: 0xC042_A49B_CA25_2715, expectedBits: 0xBFEF_FFFF_FFFF_FFFF, maxULP: 2, label: "worst-6")
    ]

    static let logGoldenVectors: [UnaryGoldenVector] = [
        UnaryGoldenVector(
            inputBits: 0x0000_0000_0000_0001, expectedBits: 0xC087_4385_446D_71C3, maxULP: 1, label: "anchor-0"),
        UnaryGoldenVector(
            inputBits: 0x0010_0000_0000_0000, expectedBits: 0xC086_232B_DD7A_BCD2, maxULP: 1, label: "anchor-1"),
        UnaryGoldenVector(
            inputBits: 0x3FE0_0000_0000_0000, expectedBits: 0xBFE6_2E42_FEFA_39EF, maxULP: 1, label: "anchor-2"),
        UnaryGoldenVector(
            inputBits: 0x3FEF_FFFF_FFFF_FFFF, expectedBits: 0xBCA0_0000_0000_0000, maxULP: 1, label: "anchor-3"),
        UnaryGoldenVector(
            inputBits: 0x3FF0_0000_0000_0000, expectedBits: 0x0000_0000_0000_0000, maxULP: 1, label: "anchor-4"),
        UnaryGoldenVector(
            inputBits: 0x4000_0000_0000_0000, expectedBits: 0x3FE6_2E42_FEFA_39EF, maxULP: 1, label: "anchor-5"),
        UnaryGoldenVector(
            inputBits: 0x3FE6_A09E_667F_3BCC, expectedBits: 0xBFD6_2E42_FEFA_39F1, maxULP: 1, label: "worst-0"),
        UnaryGoldenVector(
            inputBits: 0x0000_0000_0000_C330, expectedBits: 0xC086_ECF7_AC29_7E17, maxULP: 1, label: "worst-1"),
        UnaryGoldenVector(
            inputBits: 0x006A_B745_0ECB_C266, expectedBits: 0xC086_0358_16F6_FF13, maxULP: 1, label: "worst-2"),
        UnaryGoldenVector(
            inputBits: 0x00A7_5FFA_BC4B_79E2, expectedBits: 0xC085_EE3B_6E4F_0559, maxULP: 1, label: "worst-3"),
        UnaryGoldenVector(
            inputBits: 0x00C6_F447_2164_71AF, expectedBits: 0xC085_E349_7F10_E92F, maxULP: 1, label: "worst-4"),
        UnaryGoldenVector(
            inputBits: 0x0113_9D8F_A945_2383, expectedBits: 0xC085_C8D1_944E_9509, maxULP: 1, label: "worst-5"),
        UnaryGoldenVector(
            inputBits: 0x0166_6C2F_BA51_7196, expectedBits: 0xC085_AC05_D49D_92AF, maxULP: 1, label: "worst-6"),
        UnaryGoldenVector(
            inputBits: 0x01A8_D3CC_5006_EE00, expectedBits: 0xC085_9506_ED5D_398D, maxULP: 1, label: "worst-7")
    ]
}
