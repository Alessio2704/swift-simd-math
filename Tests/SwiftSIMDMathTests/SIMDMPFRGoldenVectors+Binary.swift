import SwiftSIMDMathTestSupport

// MARK: - MPFR-Certified Binary Golden Vectors

extension SIMDBinaryOperation {
    static let powGoldenVectors: [BinaryGoldenVector] = [
        BinaryGoldenVector(
            firstInputBits: 0x4000_0000_0000_0000, secondInputBits: 0x408F_F800_0000_0000,
            expectedBits: 0x7FE0_0000_0000_0000, maxULP: 2, label: "anchor-0"),
        BinaryGoldenVector(
            firstInputBits: 0x4000_0000_0000_0000, secondInputBits: 0xC090_C800_0000_0000,
            expectedBits: 0x0000_0000_0000_0001, maxULP: 2, label: "anchor-1"),
        BinaryGoldenVector(
            firstInputBits: 0x3FF0_0000_0000_0001, secondInputBits: 0x43AB_C16D_674E_C800,
            expectedBits: 0x53F4_4A12_826F_5073, maxULP: 2, label: "anchor-2"),
        BinaryGoldenVector(
            firstInputBits: 0xC000_0000_0000_0000, secondInputBits: 0xC008_0000_0000_0000,
            expectedBits: 0xBFC0_0000_0000_0000, maxULP: 2, label: "anchor-3"),
        BinaryGoldenVector(
            firstInputBits: 0x3FF0_0000_0000_0000, secondInputBits: 0x7FF0_0000_0000_0001,
            expectedBits: 0x7FF8_0000_0000_0000, maxULP: 2, label: "anchor-4"),
        BinaryGoldenVector(
            firstInputBits: 0x7FF0_0000_0000_0001, secondInputBits: 0x0000_0000_0000_0000,
            expectedBits: 0x7FF8_0000_0000_0000, maxULP: 2, label: "anchor-5"),
        BinaryGoldenVector(
            firstInputBits: 0x3FF0_0000_0000_0000, secondInputBits: 0x7FF8_0000_0000_0042,
            expectedBits: 0x3FF0_0000_0000_0000, maxULP: 2, label: "anchor-6"),
        BinaryGoldenVector(
            firstInputBits: 0x3FF0_06BA_F52D_A7FF, secondInputBits: 0x4118_945F_61E4_DAA1,
            expectedBits: 0x7B8D_263E_C784_17E3, maxULP: 2, label: "worst-0"),
        BinaryGoldenVector(
            firstInputBits: 0x3FF0_06C8_8DFA_BE2E, secondInputBits: 0xC119_0F5D_0AFB_3379,
            expectedBits: 0x02AC_4945_B5DF_2D38, maxULP: 2, label: "worst-1"),
        BinaryGoldenVector(
            firstInputBits: 0x3FE2_92CF_0AF0_22E6, secondInputBits: 0x3FDA_1149_C56F_16BC,
            expectedBits: 0x3FE9_A3E3_D00C_AD27, maxULP: 2, label: "worst-2"),
        BinaryGoldenVector(
            firstInputBits: 0x3FFD_6A08_DCC7_28E9, secondInputBits: 0x4090_687F_20C4_CCFF,
            expectedBits: 0x7996_30CC_D55C_E68C, maxULP: 2, label: "worst-3"),
        BinaryGoldenVector(
            firstInputBits: 0x3FFA_0CFC_F6A6_E185, secondInputBits: 0xC040_29D8_7444_9132,
            expectedBits: 0x3E83_3D66_01D0_754A, maxULP: 2, label: "worst-4"),
        BinaryGoldenVector(
            firstInputBits: 0x4049_3A87_6AE0_319A, secondInputBits: 0x3FFD_18AD_6D86_88E8,
            expectedBits: 0x4093_86D5_CC1C_1B19, maxULP: 2, label: "worst-5"),
        BinaryGoldenVector(
            firstInputBits: 0x4058_673C_1AE8_5AA7, secondInputBits: 0xBFDC_F558_D146_37C0,
            expectedBits: 0x3FC0_1B53_BCDD_E6BD, maxULP: 2, label: "worst-6"),
        BinaryGoldenVector(
            firstInputBits: 0x4030_AF50_7358_1380, secondInputBits: 0xC062_F3B7_3C6C_A9E5,
            expectedBits: 0x1974_A6BC_CC3F_419B, maxULP: 2, label: "worst-7")
    ]

    static let atan2GoldenVectors: [BinaryGoldenVector] = [
        BinaryGoldenVector(
            firstInputBits: 0x3FF0_0000_0000_0000, secondInputBits: 0x3FF0_0000_0000_0000,
            expectedBits: 0x3FE9_21FB_5444_2D18, maxULP: 2, label: "anchor-0"),
        BinaryGoldenVector(
            firstInputBits: 0xBFF0_0000_0000_0000, secondInputBits: 0xBFF0_0000_0000_0000,
            expectedBits: 0xC002_D97C_7F33_21D2, maxULP: 2, label: "anchor-1"),
        BinaryGoldenVector(
            firstInputBits: 0x0000_0000_0000_0000, secondInputBits: 0x8000_0000_0000_0000,
            expectedBits: 0x4009_21FB_5444_2D18, maxULP: 2, label: "anchor-2"),
        BinaryGoldenVector(
            firstInputBits: 0x8000_0000_0000_0000, secondInputBits: 0x8000_0000_0000_0000,
            expectedBits: 0xC009_21FB_5444_2D18, maxULP: 2, label: "anchor-3"),
        BinaryGoldenVector(
            firstInputBits: 0x8000_0000_0000_0004, secondInputBits: 0x0000_0000_0000_0002,
            expectedBits: 0xBFF1_B6E1_92EB_BE44, maxULP: 2, label: "anchor-4"),
        BinaryGoldenVector(
            firstInputBits: 0x7FEF_FFFF_FFFF_FFFF, secondInputBits: 0x7FEF_FFFF_FFFF_FFFF,
            expectedBits: 0x3FE9_21FB_5444_2D18, maxULP: 2, label: "anchor-5"),
        BinaryGoldenVector(
            firstInputBits: 0x01A5_6E1F_C2F8_F359, secondInputBits: 0x7E37_E43C_8800_759C,
            expectedBits: 0x0000_0000_0000_0000, maxULP: 2, label: "anchor-6"),
        BinaryGoldenVector(
            firstInputBits: 0x33C8_F4C2_8827_06DE, secondInputBits: 0x33DD_297E_6CE0_1F10,
            expectedBits: 0x3FD9_E041_AD02_7AA4, maxULP: 2, label: "worst-0"),
        BinaryGoldenVector(
            firstInputBits: 0x3994_99ED_B45B_9192, secondInputBits: 0x39A6_CF50_92DF_4952,
            expectedBits: 0x3FDB_25A9_6CE1_6346, maxULP: 2, label: "worst-1"),
        BinaryGoldenVector(
            firstInputBits: 0x4E5B_D4E5_FD57_BB3D, secondInputBits: 0x4E6E_1D00_1F88_F441,
            expectedBits: 0x3FDB_B45C_BD0B_6D85, maxULP: 2, label: "worst-2"),
        BinaryGoldenVector(
            firstInputBits: 0x5635_BEB6_AF00_7900, secondInputBits: 0x5647_80B2_9A28_AD13,
            expectedBits: 0x3FDB_BAF9_595E_A364, maxULP: 2, label: "worst-3"),
        BinaryGoldenVector(
            firstInputBits: 0x72B1_D03D_1D31_574F, secondInputBits: 0x72C0_C9B9_6561_F464,
            expectedBits: 0x3FDF_37CD_806A_FB0C, maxULP: 2, label: "worst-4"),
        BinaryGoldenVector(
            firstInputBits: 0xC5E7_CCA3_C415_419B, secondInputBits: 0x45FC_11E9_2BEC_9A0C,
            expectedBits: 0xBFD9_A963_42CB_7806, maxULP: 2, label: "worst-5"),
        BinaryGoldenVector(
            firstInputBits: 0xE1C1_6694_0A27_400D, secondInputBits: 0x61D3_731C_D6E8_BCD5,
            expectedBits: 0xBFDA_EB93_87C2_0037, maxULP: 2, label: "worst-6"),
        BinaryGoldenVector(
            firstInputBits: 0xF75D_8F44_1BFC_0453, secondInputBits: 0x7770_5E84_EF98_DA0A,
            expectedBits: 0xBFDB_23CE_391F_077E, maxULP: 2, label: "worst-7")
    ]

    static let hypotGoldenVectors: [BinaryGoldenVector] = [
        BinaryGoldenVector(
            firstInputBits: 0x4008_0000_0000_0000, secondInputBits: 0x4010_0000_0000_0000,
            expectedBits: 0x4014_0000_0000_0000, maxULP: 1, label: "anchor-0"),
        BinaryGoldenVector(
            firstInputBits: 0x5F30_0000_0000_0000, secondInputBits: 0x5F30_0000_0000_0000,
            expectedBits: 0x5F36_A09E_667F_3BCD, maxULP: 1, label: "anchor-1"),
        BinaryGoldenVector(
            firstInputBits: 0x23D0_0000_0000_0000, secondInputBits: 0x23D0_0000_0000_0000,
            expectedBits: 0x23D6_A09E_667F_3BCD, maxULP: 1, label: "anchor-2"),
        BinaryGoldenVector(
            firstInputBits: 0x7FE1_CCF3_85EB_C8A0, secondInputBits: 0x7FE1_CCF3_85EB_C8A0,
            expectedBits: 0x7FE9_2C80_954C_51F5, maxULP: 1, label: "anchor-3"),
        BinaryGoldenVector(
            firstInputBits: 0x0000_0000_0000_0001, secondInputBits: 0x0000_0000_0000_0001,
            expectedBits: 0x0000_0000_0000_0001, maxULP: 1, label: "anchor-4"),
        BinaryGoldenVector(
            firstInputBits: 0x7FF0_0000_0000_0000, secondInputBits: 0x7FF8_0000_0000_0000,
            expectedBits: 0x7FF0_0000_0000_0000, maxULP: 1, label: "anchor-5"),
        BinaryGoldenVector(
            firstInputBits: 0xACA3_36CA_A2BB_533C, secondInputBits: 0xACAA_6002_5344_37AE,
            expectedBits: 0x2CB0_50D8_5287_5D2B, maxULP: 1, label: "worst-0"),
        BinaryGoldenVector(
            firstInputBits: 0x0007_5428_33DA_E861, secondInputBits: 0x8004_56A1_FB0C_AF1A,
            expectedBits: 0x0008_843E_D747_202B, maxULP: 1, label: "worst-1"),
        BinaryGoldenVector(
            firstInputBits: 0x309D_4D9D_7B3B_24CE, secondInputBits: 0x309B_29BA_5239_15B1,
            expectedBits: 0x30A3_FA67_B89B_0F43, maxULP: 1, label: "worst-2"),
        BinaryGoldenVector(
            firstInputBits: 0x7CF2_6E24_83B3_DFC4, secondInputBits: 0x7CF6_3121_23CF_A5D2,
            expectedBits: 0x7CFC_D8DB_32F5_7312, maxULP: 1, label: "worst-3"),
        BinaryGoldenVector(
            firstInputBits: 0x8954_84B8_1CDF_4D04, secondInputBits: 0x0957_783F_5A68_0922,
            expectedBits: 0x095F_2C9B_8747_150E, maxULP: 1, label: "worst-4"),
        BinaryGoldenVector(
            firstInputBits: 0x947A_4709_FBF3_8982, secondInputBits: 0x1475_FCE3_B945_73D4,
            expectedBits: 0x1481_21B3_26A3_C2AD, maxULP: 1, label: "worst-5"),
        BinaryGoldenVector(
            firstInputBits: 0xA019_3C9F_6022_FCC9, secondInputBits: 0x2012_DE07_263C_E7E0,
            expectedBits: 0x201F_8286_35F3_CC9B, maxULP: 1, label: "worst-6"),
        BinaryGoldenVector(
            firstInputBits: 0xB5D3_0AAA_E9B6_3586, secondInputBits: 0xB5D0_9547_9989_2A9E,
            expectedBits: 0x35D9_401D_779A_30C1, maxULP: 1, label: "worst-7")
    ]

    static let minGoldenVectors: [BinaryGoldenVector] = [
        BinaryGoldenVector(
            firstInputBits: 0xC014_0000_0000_0000, secondInputBits: 0x0000_0000_0000_0000,
            expectedBits: 0xC014_0000_0000_0000, maxULP: 0, label: "anchor-0"),
        BinaryGoldenVector(
            firstInputBits: 0x8000_0000_0000_0000, secondInputBits: 0x0000_0000_0000_0000,
            expectedBits: 0x8000_0000_0000_0000, maxULP: 0, label: "anchor-1"),
        BinaryGoldenVector(
            firstInputBits: 0x0000_0000_0000_0000, secondInputBits: 0x8000_0000_0000_0000,
            expectedBits: 0x8000_0000_0000_0000, maxULP: 0, label: "anchor-2"),
        BinaryGoldenVector(
            firstInputBits: 0x7FF8_0000_0000_0000, secondInputBits: 0x4008_0000_0000_0000,
            expectedBits: 0x4008_0000_0000_0000, maxULP: 0, label: "anchor-3"),
        BinaryGoldenVector(
            firstInputBits: 0x7FF0_0000_0000_0001, secondInputBits: 0x4008_0000_0000_0000,
            expectedBits: 0x7FF8_0000_0000_0000, maxULP: 0, label: "anchor-4"),
        BinaryGoldenVector(
            firstInputBits: 0x0D78_7BDA_9F35_8ECB, secondInputBits: 0x56A0_59C3_F581_A00F,
            expectedBits: 0x0D78_7BDA_9F35_8ECB, maxULP: 0, label: "worst-0"),
        BinaryGoldenVector(
            firstInputBits: 0x3ABA_9ED2_B67C_7A89, secondInputBits: 0x1AF9_101E_52EE_0790,
            expectedBits: 0x1AF9_101E_52EE_0790, maxULP: 0, label: "worst-1"),
        BinaryGoldenVector(
            firstInputBits: 0x7F40_0F76_1114_6250, secondInputBits: 0xC3CF_159C_5360_9800,
            expectedBits: 0xC3CF_159C_5360_9800, maxULP: 0, label: "worst-2"),
        BinaryGoldenVector(
            firstInputBits: 0x8B77_F29F_71A8_644C, secondInputBits: 0x20FF_8BBA_D92A_1A72,
            expectedBits: 0x8B77_F29F_71A8_644C, maxULP: 0, label: "worst-3")
    ]
}
