import SwiftSIMDMathTestSupport

// MARK: - MPFR-Certified Unary Golden Vectors (Trig & Pi-Trig)

extension SIMDUnaryOperation {
    static let sinGoldenVectors: [UnaryGoldenVector] = [
        UnaryGoldenVector(
            inputBits: 0xFFEF_FFFF_FFFF_FFFF, expectedBits: 0xBF74_52FC_98B3_4E97, maxULP: 2, label: "anchor-0"),
        UnaryGoldenVector(
            inputBits: 0xE974_E718_D7D7_625A, expectedBits: 0x3FE4_9B64_4938_C64C, maxULP: 2, label: "anchor-1"),
        UnaryGoldenVector(
            inputBits: 0xD4B2_49AD_2594_C37D, expectedBits: 0x3FD8_5C5E_5B92_9359, maxULP: 2, label: "anchor-2"),
        UnaryGoldenVector(
            inputBits: 0xC480_F0CF_064D_D592, expectedBits: 0x3FEB_453A_B76B_F397, maxULP: 2, label: "anchor-3"),
        UnaryGoldenVector(
            inputBits: 0xF506_AC5B_262C_A1FF, expectedBits: 0xBFF0_0000_0000_0000, maxULP: 2, label: "anchor-4"),
        UnaryGoldenVector(
            inputBits: 0xC120_0000_0000_0001, expectedBits: 0xBFC5_7481_ECD0_1616, maxULP: 2, label: "anchor-5"),
        UnaryGoldenVector(
            inputBits: 0xC120_0000_0000_0000, expectedBits: 0xBFC5_7481_EC90_FDE3, maxULP: 2, label: "anchor-6"),
        UnaryGoldenVector(
            inputBits: 0xC11F_FFFF_FFFF_FFFF, expectedBits: 0xBFC5_7481_EC71_71CA, maxULP: 2, label: "anchor-7"),
        UnaryGoldenVector(
            inputBits: 0xC019_21FB_5444_2D18, expectedBits: 0x3CB1_A626_3314_5C07, maxULP: 2, label: "anchor-8"),
        UnaryGoldenVector(
            inputBits: 0xC009_21FB_5444_2D18, expectedBits: 0xBCA1_A626_3314_5C07, maxULP: 2, label: "anchor-9"),
        UnaryGoldenVector(
            inputBits: 0xBFF9_21FB_5444_2D18, expectedBits: 0xBFF0_0000_0000_0000, maxULP: 2, label: "anchor-10"),
        UnaryGoldenVector(
            inputBits: 0xBFE9_21FB_5444_2D18, expectedBits: 0xBFE6_A09E_667F_3BCC, maxULP: 2, label: "anchor-11"),
        UnaryGoldenVector(
            inputBits: 0x8000_0000_0000_0001, expectedBits: 0x8000_0000_0000_0001, maxULP: 2, label: "anchor-12"),
        UnaryGoldenVector(
            inputBits: 0x8000_0000_0000_0000, expectedBits: 0x8000_0000_0000_0000, maxULP: 2, label: "anchor-13"),
        UnaryGoldenVector(
            inputBits: 0x0000_0000_0000_0000, expectedBits: 0x0000_0000_0000_0000, maxULP: 2, label: "anchor-14"),
        UnaryGoldenVector(
            inputBits: 0x0000_0000_0000_0001, expectedBits: 0x0000_0000_0000_0001, maxULP: 2, label: "anchor-15"),
        UnaryGoldenVector(
            inputBits: 0x3FE9_21FB_5444_2D18, expectedBits: 0x3FE6_A09E_667F_3BCC, maxULP: 2, label: "anchor-16"),
        UnaryGoldenVector(
            inputBits: 0x3FF9_21FB_5444_2D18, expectedBits: 0x3FF0_0000_0000_0000, maxULP: 2, label: "anchor-17"),
        UnaryGoldenVector(
            inputBits: 0x4009_21FB_5444_2D18, expectedBits: 0x3CA1_A626_3314_5C07, maxULP: 2, label: "anchor-18"),
        UnaryGoldenVector(
            inputBits: 0x4019_21FB_5444_2D18, expectedBits: 0xBCB1_A626_3314_5C07, maxULP: 2, label: "anchor-19"),
        UnaryGoldenVector(
            inputBits: 0x411F_FFFF_FFFF_FFFF, expectedBits: 0x3FC5_7481_EC71_71CA, maxULP: 2, label: "anchor-20"),
        UnaryGoldenVector(
            inputBits: 0x4120_0000_0000_0000, expectedBits: 0x3FC5_7481_EC90_FDE3, maxULP: 2, label: "anchor-21"),
        UnaryGoldenVector(
            inputBits: 0x4120_0000_0000_0001, expectedBits: 0x3FC5_7481_ECD0_1616, maxULP: 2, label: "anchor-22"),
        UnaryGoldenVector(
            inputBits: 0x4164_5525_B1B6_F85C, expectedBits: 0x3FEF_8459_9123_A768, maxULP: 2, label: "anchor-23"),
        UnaryGoldenVector(
            inputBits: 0x42D0_E826_CEB0_C5C0, expectedBits: 0xBFF0_0000_0000_0000, maxULP: 2, label: "anchor-24"),
        UnaryGoldenVector(
            inputBits: 0x42E8_577C_EC54_AB80, expectedBits: 0x3FF0_0000_0000_0000, maxULP: 2, label: "anchor-25"),
        UnaryGoldenVector(
            inputBits: 0x4335_08EC_B38F_52F9, expectedBits: 0x3FF0_0000_0000_0000, maxULP: 2, label: "anchor-26"),
        UnaryGoldenVector(
            inputBits: 0x4335_CBA8_9AF1_F855, expectedBits: 0x3C9B_5EBD_E2AA_E00B, maxULP: 2, label: "anchor-27"),
        UnaryGoldenVector(
            inputBits: 0x43CE_3957_08F0_5C22, expectedBits: 0x3F6F_4D7E_0FAC_98F4, maxULP: 2, label: "anchor-28"),
        UnaryGoldenVector(
            inputBits: 0x7506_AC5B_262C_A1FF, expectedBits: 0x3FF0_0000_0000_0000, maxULP: 2, label: "anchor-29"),
        UnaryGoldenVector(
            inputBits: 0x4480_F0CF_064D_D592, expectedBits: 0xBFEB_453A_B76B_F397, maxULP: 2, label: "anchor-30"),
        UnaryGoldenVector(
            inputBits: 0x54B2_49AD_2594_C37D, expectedBits: 0xBFD8_5C5E_5B92_9359, maxULP: 2, label: "anchor-31"),
        UnaryGoldenVector(
            inputBits: 0x6974_E718_D7D7_625A, expectedBits: 0xBFE4_9B64_4938_C64C, maxULP: 2, label: "anchor-32"),
        UnaryGoldenVector(
            inputBits: 0x7E37_E43C_8800_759C, expectedBits: 0xBFEA_2C16_B010_E385, maxULP: 2, label: "anchor-33"),
        UnaryGoldenVector(
            inputBits: 0x7FEF_FFFF_FFFF_FFFF, expectedBits: 0x3F74_52FC_98B3_4E97, maxULP: 2, label: "anchor-34"),
        UnaryGoldenVector(
            inputBits: 0x3FEE_B28A_2E25_2EB2, expectedBits: 0x3FEA_3380_25DF_6AFB, maxULP: 2, label: "worst-0"),
        UnaryGoldenVector(
            inputBits: 0x4010_4FFB_26CA_FD62, expectedBits: 0xBFE9_C6A1_DF34_8E3E, maxULP: 2, label: "worst-1"),
        UnaryGoldenVector(
            inputBits: 0x4041_C277_2627_D7AA, expectedBits: 0xBFEA_3EFD_C64B_79BD, maxULP: 2, label: "worst-2"),
        UnaryGoldenVector(
            inputBits: 0x4086_BF40_DD46_E788, expectedBits: 0xBFE9_E521_BF05_49E0, maxULP: 2, label: "worst-3"),
        UnaryGoldenVector(
            inputBits: 0xBFEE_B28A_2E25_2EB2, expectedBits: 0xBFEA_3380_25DF_6AFB, maxULP: 2, label: "worst-4"),
        UnaryGoldenVector(
            inputBits: 0xC010_4FFB_26CA_FD62, expectedBits: 0x3FE9_C6A1_DF34_8E3E, maxULP: 2, label: "worst-5"),
        UnaryGoldenVector(
            inputBits: 0xC041_C277_2627_D7AA, expectedBits: 0x3FEA_3EFD_C64B_79BD, maxULP: 2, label: "worst-6"),
        UnaryGoldenVector(
            inputBits: 0xC086_BF40_DD46_E788, expectedBits: 0x3FE9_E521_BF05_49E0, maxULP: 2, label: "worst-7")
    ]

    static let cosGoldenVectors: [UnaryGoldenVector] = [
        UnaryGoldenVector(
            inputBits: 0xFFEF_FFFF_FFFF_FFFF, expectedBits: 0xBFEF_FFE6_2ECF_AB75, maxULP: 2, label: "anchor-0"),
        UnaryGoldenVector(
            inputBits: 0xE974_E718_D7D7_625A, expectedBits: 0x3FE8_7B4D_F51F_679E, maxULP: 2, label: "anchor-1"),
        UnaryGoldenVector(
            inputBits: 0xD4B2_49AD_2594_C37D, expectedBits: 0x3FED_9757_4968_41F5, maxULP: 2, label: "anchor-2"),
        UnaryGoldenVector(
            inputBits: 0xC480_F0CF_064D_D592, expectedBits: 0x3FE0_BE2C_EF01_C8F4, maxULP: 2, label: "anchor-3"),
        UnaryGoldenVector(
            inputBits: 0xF506_AC5B_262C_A1FF, expectedBits: 0xBC21_4AE7_2E6B_A22F, maxULP: 2, label: "anchor-4"),
        UnaryGoldenVector(
            inputBits: 0xC120_0000_0000_0001, expectedBits: 0x3FEF_8C19_86C7_B96A, maxULP: 2, label: "anchor-5"),
        UnaryGoldenVector(
            inputBits: 0xC120_0000_0000_0000, expectedBits: 0x3FEF_8C19_86CA_67FA, maxULP: 2, label: "anchor-6"),
        UnaryGoldenVector(
            inputBits: 0xC11F_FFFF_FFFF_FFFF, expectedBits: 0x3FEF_8C19_86CB_BF43, maxULP: 2, label: "anchor-7"),
        UnaryGoldenVector(
            inputBits: 0xC019_21FB_5444_2D18, expectedBits: 0x3FF0_0000_0000_0000, maxULP: 2, label: "anchor-8"),
        UnaryGoldenVector(
            inputBits: 0xC009_21FB_5444_2D18, expectedBits: 0xBFF0_0000_0000_0000, maxULP: 2, label: "anchor-9"),
        UnaryGoldenVector(
            inputBits: 0xBFF9_21FB_5444_2D18, expectedBits: 0x3C91_A626_3314_5C07, maxULP: 2, label: "anchor-10"),
        UnaryGoldenVector(
            inputBits: 0xBFE9_21FB_5444_2D18, expectedBits: 0x3FE6_A09E_667F_3BCD, maxULP: 2, label: "anchor-11"),
        UnaryGoldenVector(
            inputBits: 0x8000_0000_0000_0001, expectedBits: 0x3FF0_0000_0000_0000, maxULP: 2, label: "anchor-12"),
        UnaryGoldenVector(
            inputBits: 0x8000_0000_0000_0000, expectedBits: 0x3FF0_0000_0000_0000, maxULP: 2, label: "anchor-13"),
        UnaryGoldenVector(
            inputBits: 0x0000_0000_0000_0000, expectedBits: 0x3FF0_0000_0000_0000, maxULP: 2, label: "anchor-14"),
        UnaryGoldenVector(
            inputBits: 0x0000_0000_0000_0001, expectedBits: 0x3FF0_0000_0000_0000, maxULP: 2, label: "anchor-15"),
        UnaryGoldenVector(
            inputBits: 0x3FE9_21FB_5444_2D18, expectedBits: 0x3FE6_A09E_667F_3BCD, maxULP: 2, label: "anchor-16"),
        UnaryGoldenVector(
            inputBits: 0x3FF9_21FB_5444_2D18, expectedBits: 0x3C91_A626_3314_5C07, maxULP: 2, label: "anchor-17"),
        UnaryGoldenVector(
            inputBits: 0x4009_21FB_5444_2D18, expectedBits: 0xBFF0_0000_0000_0000, maxULP: 2, label: "anchor-18"),
        UnaryGoldenVector(
            inputBits: 0x4019_21FB_5444_2D18, expectedBits: 0x3FF0_0000_0000_0000, maxULP: 2, label: "anchor-19"),
        UnaryGoldenVector(
            inputBits: 0x411F_FFFF_FFFF_FFFF, expectedBits: 0x3FEF_8C19_86CB_BF43, maxULP: 2, label: "anchor-20"),
        UnaryGoldenVector(
            inputBits: 0x4120_0000_0000_0000, expectedBits: 0x3FEF_8C19_86CA_67FA, maxULP: 2, label: "anchor-21"),
        UnaryGoldenVector(
            inputBits: 0x4120_0000_0000_0001, expectedBits: 0x3FEF_8C19_86C7_B96A, maxULP: 2, label: "anchor-22"),
        UnaryGoldenVector(
            inputBits: 0x4164_5525_B1B6_F85C, expectedBits: 0x3FC6_27D1_30AD_DB58, maxULP: 2, label: "anchor-23"),
        UnaryGoldenVector(
            inputBits: 0x42D0_E826_CEB0_C5C0, expectedBits: 0xBD00_B905_ACAC_1B51, maxULP: 2, label: "anchor-24"),
        UnaryGoldenVector(
            inputBits: 0x42E8_577C_EC54_AB80, expectedBits: 0x3CB2_B04A_1AF8_C362, maxULP: 2, label: "anchor-25"),
        UnaryGoldenVector(
            inputBits: 0x4335_08EC_B38F_52F9, expectedBits: 0xBCA7_B135_449C_16BF, maxULP: 2, label: "anchor-26"),
        UnaryGoldenVector(
            inputBits: 0x4335_CBA8_9AF1_F855, expectedBits: 0xBFF0_0000_0000_0000, maxULP: 2, label: "anchor-27"),
        UnaryGoldenVector(
            inputBits: 0x43CE_3957_08F0_5C22, expectedBits: 0xBFEF_FFF0_B08C_62E2, maxULP: 2, label: "anchor-28"),
        UnaryGoldenVector(
            inputBits: 0x7506_AC5B_262C_A1FF, expectedBits: 0xBC21_4AE7_2E6B_A22F, maxULP: 2, label: "anchor-29"),
        UnaryGoldenVector(
            inputBits: 0x4480_F0CF_064D_D592, expectedBits: 0x3FE0_BE2C_EF01_C8F4, maxULP: 2, label: "anchor-30"),
        UnaryGoldenVector(
            inputBits: 0x54B2_49AD_2594_C37D, expectedBits: 0x3FED_9757_4968_41F5, maxULP: 2, label: "anchor-31"),
        UnaryGoldenVector(
            inputBits: 0x6974_E718_D7D7_625A, expectedBits: 0x3FE8_7B4D_F51F_679E, maxULP: 2, label: "anchor-32"),
        UnaryGoldenVector(
            inputBits: 0x7E37_E43C_8800_759C, expectedBits: 0xBFE2_6990_22AD_C4C1, maxULP: 2, label: "anchor-33"),
        UnaryGoldenVector(
            inputBits: 0x7FEF_FFFF_FFFF_FFFF, expectedBits: 0xBFEF_FFE6_2ECF_AB75, maxULP: 2, label: "anchor-34"),
        UnaryGoldenVector(
            inputBits: 0x402A_5B8D_E215_BE26, expectedBits: 0x3FEA_2F0E_7286_8551, maxULP: 2, label: "worst-0"),
        UnaryGoldenVector(
            inputBits: 0x4044_BB47_9040_A746, expectedBits: 0xBFE9_FFC4_C103_EBCF, maxULP: 2, label: "worst-1"),
        UnaryGoldenVector(
            inputBits: 0x408B_14A1_4B90_5D2B, expectedBits: 0x3FEC_11F4_01CC_13EE, maxULP: 2, label: "worst-2"),
        UnaryGoldenVector(
            inputBits: 0x40CD_41DF_19B0_B141, expectedBits: 0x3FE9_DF39_632C_1511, maxULP: 2, label: "worst-3"),
        UnaryGoldenVector(
            inputBits: 0xC02A_5B8D_E215_BE26, expectedBits: 0x3FEA_2F0E_7286_8551, maxULP: 2, label: "worst-4"),
        UnaryGoldenVector(
            inputBits: 0xC044_BB47_9040_A746, expectedBits: 0xBFE9_FFC4_C103_EBCF, maxULP: 2, label: "worst-5"),
        UnaryGoldenVector(
            inputBits: 0xC08B_14A1_4B90_5D2B, expectedBits: 0x3FEC_11F4_01CC_13EE, maxULP: 2, label: "worst-6"),
        UnaryGoldenVector(
            inputBits: 0xC0CD_41DF_19B0_B141, expectedBits: 0x3FE9_DF39_632C_1511, maxULP: 2, label: "worst-7")
    ]
}
