import SwiftSIMDMathTestSupport

// MARK: - MPFR-Certified Unary Golden Vectors (Exp & Log) (Part 2)

extension SIMDUnaryOperation {
    static let log2GoldenVectors: [UnaryGoldenVector] = [
        UnaryGoldenVector(
            inputBits: 0x0000_0000_0000_0001, expectedBits: 0xC090_C800_0000_0000, maxULP: 1, label: "anchor-0"),
        UnaryGoldenVector(
            inputBits: 0x0010_0000_0000_0000, expectedBits: 0xC08F_F000_0000_0000, maxULP: 1, label: "anchor-1"),
        UnaryGoldenVector(
            inputBits: 0x3FE0_0000_0000_0000, expectedBits: 0xBFF0_0000_0000_0000, maxULP: 1, label: "anchor-2"),
        UnaryGoldenVector(
            inputBits: 0x3FEF_FFFF_FFFF_FFFF, expectedBits: 0xBCA7_1547_652B_82FE, maxULP: 1, label: "anchor-3"),
        UnaryGoldenVector(
            inputBits: 0x3FF0_0000_0000_0000, expectedBits: 0x0000_0000_0000_0000, maxULP: 1, label: "anchor-4"),
        UnaryGoldenVector(
            inputBits: 0x5F30_0000_0000_0000, expectedBits: 0x407F_4000_0000_0000, maxULP: 1, label: "anchor-5"),
        UnaryGoldenVector(
            inputBits: 0x3FEF_FFFF_FFFF_FFFE, expectedBits: 0xBCB7_1547_652B_82FF, maxULP: 1, label: "worst-0"),
        UnaryGoldenVector(
            inputBits: 0x0000_0000_0000_ED09, expectedBits: 0xC090_8871_B531_73BF, maxULP: 1, label: "worst-1"),
        UnaryGoldenVector(
            inputBits: 0x004B_A6ED_17CD_74C8, expectedBits: 0xC08F_D1AF_7BB7_C09B, maxULP: 1, label: "worst-2"),
        UnaryGoldenVector(
            inputBits: 0x0080_CBA8_881D_D6A0, expectedBits: 0xC08F_B770_A088_CA9D, maxULP: 1, label: "worst-3"),
        UnaryGoldenVector(
            inputBits: 0x0103_66AB_6C04_3E22, expectedBits: 0xC08F_75C6_86DE_F937, maxULP: 1, label: "worst-4"),
        UnaryGoldenVector(
            inputBits: 0x0168_F8D9_A36E_9812, expectedBits: 0xC08F_42DC_AF68_50E5, maxULP: 1, label: "worst-5"),
        UnaryGoldenVector(
            inputBits: 0x01D6_3289_1C99_A826, expectedBits: 0xC08F_0C38_B0C3_7F21, maxULP: 1, label: "worst-6"),
        UnaryGoldenVector(
            inputBits: 0x0224_1BCF_C8C3_F1DC, expectedBits: 0xC08E_E55C_AF69_2D9B, maxULP: 1, label: "worst-7")
    ]

    static let log10GoldenVectors: [UnaryGoldenVector] = [
        UnaryGoldenVector(
            inputBits: 0x0000_0000_0000_0001, expectedBits: 0xC074_34E6_420F_4374, maxULP: 1, label: "anchor-0"),
        UnaryGoldenVector(
            inputBits: 0x0010_0000_0000_0000, expectedBits: 0xC073_3A71_46F7_2A42, maxULP: 1, label: "anchor-1"),
        UnaryGoldenVector(
            inputBits: 0x3FB9_9999_9999_999A, expectedBits: 0xBFF0_0000_0000_0000, maxULP: 1, label: "anchor-2"),
        UnaryGoldenVector(
            inputBits: 0x3FEF_FFFF_FFFF_FFFF, expectedBits: 0xBC8B_CB7B_1526_E50F, maxULP: 1, label: "anchor-3"),
        UnaryGoldenVector(
            inputBits: 0x3FF0_0000_0000_0000, expectedBits: 0x0000_0000_0000_0000, maxULP: 1, label: "anchor-4"),
        UnaryGoldenVector(
            inputBits: 0x54B2_49AD_2594_C37D, expectedBits: 0x4059_0000_0000_0000, maxULP: 1, label: "anchor-5"),
        UnaryGoldenVector(
            inputBits: 0x0000_0000_0000_0915, expectedBits: 0xC073_FF09_63BD_A6D3, maxULP: 1, label: "worst-0"),
        UnaryGoldenVector(
            inputBits: 0x0047_EB9D_4863_9401, expectedBits: 0xC073_2932_DCE5_9963, maxULP: 1, label: "worst-1"),
        UnaryGoldenVector(
            inputBits: 0x0131_A80C_9B0D_A9F0, expectedBits: 0xC072_E30F_B297_B8C1, maxULP: 1, label: "worst-2"),
        UnaryGoldenVector(
            inputBits: 0x015A_02ED_B035_DEAF, expectedBits: 0xC072_D6BC_764B_D2FF, maxULP: 1, label: "worst-3"),
        UnaryGoldenVector(
            inputBits: 0x02EA_07FE_EC72_76F6, expectedBits: 0xC072_5E51_A32A_58DB, maxULP: 1, label: "worst-4"),
        UnaryGoldenVector(
            inputBits: 0x035E_C33B_0526_57D5, expectedBits: 0xC072_3B71_6DA7_94BB, maxULP: 1, label: "worst-5"),
        UnaryGoldenVector(
            inputBits: 0x4023_FFFF_FFFF_FFFB, expectedBits: 0x3FEF_FFFF_FFFF_FFFD, maxULP: 1, label: "worst-6")
    ]

    static let log1pGoldenVectors: [UnaryGoldenVector] = [
        UnaryGoldenVector(
            inputBits: 0xBFF0_0000_0000_0001, expectedBits: 0x7FF8_0000_0000_0000, maxULP: 1, label: "anchor-0"),
        UnaryGoldenVector(
            inputBits: 0xBFD2_BEC3_3301_8867, expectedBits: 0xBFD6_2E42_FEFA_39EF, maxULP: 1, label: "anchor-1"),
        UnaryGoldenVector(
            inputBits: 0x8000_0000_0000_0000, expectedBits: 0x8000_0000_0000_0000, maxULP: 1, label: "anchor-2"),
        UnaryGoldenVector(
            inputBits: 0x0000_0000_0000_0000, expectedBits: 0x0000_0000_0000_0000, maxULP: 1, label: "anchor-3"),
        UnaryGoldenVector(
            inputBits: 0x3FDA_8279_99FC_EF33, expectedBits: 0x3FD6_2E42_FEFA_39F0, maxULP: 1, label: "anchor-4"),
        UnaryGoldenVector(
            inputBits: 0x7FEF_FFFF_FFFF_FFFF, expectedBits: 0x4086_2E42_FEFA_39EF, maxULP: 1, label: "anchor-5"),
        UnaryGoldenVector(
            inputBits: 0x3CA5_EDCA_B27C_E1A5, expectedBits: 0x3CA5_EDCA_B27C_E1A5, maxULP: 1, label: "worst-0"),
        UnaryGoldenVector(
            inputBits: 0x3CCA_D927_4863_2680, expectedBits: 0x3CCA_D927_4863_267D, maxULP: 1, label: "worst-1"),
        UnaryGoldenVector(
            inputBits: 0x3D0A_E35C_820B_A14F, expectedBits: 0x3D0A_E35C_820B_A122, maxULP: 1, label: "worst-2"),
        UnaryGoldenVector(
            inputBits: 0x3D49_E548_0E9F_23F6, expectedBits: 0x3D49_E548_0E9F_2157, maxULP: 1, label: "worst-3"),
        UnaryGoldenVector(
            inputBits: 0x3D81_5B3A_7D3A_C1FC, expectedBits: 0x3D81_5B3A_7D3A_AF28, maxULP: 1, label: "worst-4"),
        UnaryGoldenVector(
            inputBits: 0x3DC0_8955_2A14_C54E, expectedBits: 0x3DC0_8955_2A13_B3DA, maxULP: 1, label: "worst-5"),
        UnaryGoldenVector(
            inputBits: 0x3E01_6516_4191_BD20, expectedBits: 0x3E01_6516_417E_D3D2, maxULP: 1, label: "worst-6")
    ]
}
