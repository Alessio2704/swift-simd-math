import SwiftSIMDMathTestSupport

// MARK: - MPFR-Certified Dual-Unary Golden Vectors

extension SIMDDualUnaryOperation {
    static let sincosGoldenVectors: [DualUnaryGoldenVector] = [
        DualUnaryGoldenVector(
            inputBits: 0xFFEF_FFFF_FFFF_FFFF, expectedFirstBits: 0xBF74_52FC_98B3_4E97,
            expectedSecondBits: 0xBFEF_FFE6_2ECF_AB75, maxULP: 2, label: "anchor-0"),
        DualUnaryGoldenVector(
            inputBits: 0xE974_E718_D7D7_625A, expectedFirstBits: 0x3FE4_9B64_4938_C64C,
            expectedSecondBits: 0x3FE8_7B4D_F51F_679E, maxULP: 2, label: "anchor-1"),
        DualUnaryGoldenVector(
            inputBits: 0xD4B2_49AD_2594_C37D, expectedFirstBits: 0x3FD8_5C5E_5B92_9359,
            expectedSecondBits: 0x3FED_9757_4968_41F5, maxULP: 2, label: "anchor-2"),
        DualUnaryGoldenVector(
            inputBits: 0xC480_F0CF_064D_D592, expectedFirstBits: 0x3FEB_453A_B76B_F397,
            expectedSecondBits: 0x3FE0_BE2C_EF01_C8F4, maxULP: 2, label: "anchor-3"),
        DualUnaryGoldenVector(
            inputBits: 0xF506_AC5B_262C_A1FF, expectedFirstBits: 0xBFF0_0000_0000_0000,
            expectedSecondBits: 0xBC21_4AE7_2E6B_A22F, maxULP: 2, label: "anchor-4"),
        DualUnaryGoldenVector(
            inputBits: 0xC120_0000_0000_0001, expectedFirstBits: 0xBFC5_7481_ECD0_1616,
            expectedSecondBits: 0x3FEF_8C19_86C7_B96A, maxULP: 2, label: "anchor-5"),
        DualUnaryGoldenVector(
            inputBits: 0xC120_0000_0000_0000, expectedFirstBits: 0xBFC5_7481_EC90_FDE3,
            expectedSecondBits: 0x3FEF_8C19_86CA_67FA, maxULP: 2, label: "anchor-6"),
        DualUnaryGoldenVector(
            inputBits: 0xC11F_FFFF_FFFF_FFFF, expectedFirstBits: 0xBFC5_7481_EC71_71CA,
            expectedSecondBits: 0x3FEF_8C19_86CB_BF43, maxULP: 2, label: "anchor-7"),
        DualUnaryGoldenVector(
            inputBits: 0xC019_21FB_5444_2D18, expectedFirstBits: 0x3CB1_A626_3314_5C07,
            expectedSecondBits: 0x3FF0_0000_0000_0000, maxULP: 2, label: "anchor-8"),
        DualUnaryGoldenVector(
            inputBits: 0xC009_21FB_5444_2D18, expectedFirstBits: 0xBCA1_A626_3314_5C07,
            expectedSecondBits: 0xBFF0_0000_0000_0000, maxULP: 2, label: "anchor-9"),
        DualUnaryGoldenVector(
            inputBits: 0xBFF9_21FB_5444_2D18, expectedFirstBits: 0xBFF0_0000_0000_0000,
            expectedSecondBits: 0x3C91_A626_3314_5C07, maxULP: 2, label: "anchor-10"),
        DualUnaryGoldenVector(
            inputBits: 0xBFE9_21FB_5444_2D18, expectedFirstBits: 0xBFE6_A09E_667F_3BCC,
            expectedSecondBits: 0x3FE6_A09E_667F_3BCD, maxULP: 2, label: "anchor-11"),
        DualUnaryGoldenVector(
            inputBits: 0x8000_0000_0000_0001, expectedFirstBits: 0x8000_0000_0000_0001,
            expectedSecondBits: 0x3FF0_0000_0000_0000, maxULP: 2, label: "anchor-12"),
        DualUnaryGoldenVector(
            inputBits: 0x8000_0000_0000_0000, expectedFirstBits: 0x8000_0000_0000_0000,
            expectedSecondBits: 0x3FF0_0000_0000_0000, maxULP: 2, label: "anchor-13"),
        DualUnaryGoldenVector(
            inputBits: 0x0000_0000_0000_0000, expectedFirstBits: 0x0000_0000_0000_0000,
            expectedSecondBits: 0x3FF0_0000_0000_0000, maxULP: 2, label: "anchor-14"),
        DualUnaryGoldenVector(
            inputBits: 0x0000_0000_0000_0001, expectedFirstBits: 0x0000_0000_0000_0001,
            expectedSecondBits: 0x3FF0_0000_0000_0000, maxULP: 2, label: "anchor-15"),
        DualUnaryGoldenVector(
            inputBits: 0x3FE9_21FB_5444_2D18, expectedFirstBits: 0x3FE6_A09E_667F_3BCC,
            expectedSecondBits: 0x3FE6_A09E_667F_3BCD, maxULP: 2, label: "anchor-16"),
        DualUnaryGoldenVector(
            inputBits: 0x3FF9_21FB_5444_2D18, expectedFirstBits: 0x3FF0_0000_0000_0000,
            expectedSecondBits: 0x3C91_A626_3314_5C07, maxULP: 2, label: "anchor-17"),
        DualUnaryGoldenVector(
            inputBits: 0x4009_21FB_5444_2D18, expectedFirstBits: 0x3CA1_A626_3314_5C07,
            expectedSecondBits: 0xBFF0_0000_0000_0000, maxULP: 2, label: "anchor-18"),
        DualUnaryGoldenVector(
            inputBits: 0x4019_21FB_5444_2D18, expectedFirstBits: 0xBCB1_A626_3314_5C07,
            expectedSecondBits: 0x3FF0_0000_0000_0000, maxULP: 2, label: "anchor-19"),
        DualUnaryGoldenVector(
            inputBits: 0x411F_FFFF_FFFF_FFFF, expectedFirstBits: 0x3FC5_7481_EC71_71CA,
            expectedSecondBits: 0x3FEF_8C19_86CB_BF43, maxULP: 2, label: "anchor-20"),
        DualUnaryGoldenVector(
            inputBits: 0x4120_0000_0000_0000, expectedFirstBits: 0x3FC5_7481_EC90_FDE3,
            expectedSecondBits: 0x3FEF_8C19_86CA_67FA, maxULP: 2, label: "anchor-21"),
        DualUnaryGoldenVector(
            inputBits: 0x4120_0000_0000_0001, expectedFirstBits: 0x3FC5_7481_ECD0_1616,
            expectedSecondBits: 0x3FEF_8C19_86C7_B96A, maxULP: 2, label: "anchor-22"),
        DualUnaryGoldenVector(
            inputBits: 0x4164_5525_B1B6_F85C, expectedFirstBits: 0x3FEF_8459_9123_A768,
            expectedSecondBits: 0x3FC6_27D1_30AD_DB58, maxULP: 2, label: "anchor-23"),
        DualUnaryGoldenVector(
            inputBits: 0x42D0_E826_CEB0_C5C0, expectedFirstBits: 0xBFF0_0000_0000_0000,
            expectedSecondBits: 0xBD00_B905_ACAC_1B51, maxULP: 2, label: "anchor-24"),
        DualUnaryGoldenVector(
            inputBits: 0x42E8_577C_EC54_AB80, expectedFirstBits: 0x3FF0_0000_0000_0000,
            expectedSecondBits: 0x3CB2_B04A_1AF8_C362, maxULP: 2, label: "anchor-25"),
        DualUnaryGoldenVector(
            inputBits: 0x4335_08EC_B38F_52F9, expectedFirstBits: 0x3FF0_0000_0000_0000,
            expectedSecondBits: 0xBCA7_B135_449C_16BF, maxULP: 2, label: "anchor-26"),
        DualUnaryGoldenVector(
            inputBits: 0x4335_CBA8_9AF1_F855, expectedFirstBits: 0x3C9B_5EBD_E2AA_E00B,
            expectedSecondBits: 0xBFF0_0000_0000_0000, maxULP: 2, label: "anchor-27"),
        DualUnaryGoldenVector(
            inputBits: 0x43CE_3957_08F0_5C22, expectedFirstBits: 0x3F6F_4D7E_0FAC_98F4,
            expectedSecondBits: 0xBFEF_FFF0_B08C_62E2, maxULP: 2, label: "anchor-28"),
        DualUnaryGoldenVector(
            inputBits: 0x7506_AC5B_262C_A1FF, expectedFirstBits: 0x3FF0_0000_0000_0000,
            expectedSecondBits: 0xBC21_4AE7_2E6B_A22F, maxULP: 2, label: "anchor-29"),
        DualUnaryGoldenVector(
            inputBits: 0x4480_F0CF_064D_D592, expectedFirstBits: 0xBFEB_453A_B76B_F397,
            expectedSecondBits: 0x3FE0_BE2C_EF01_C8F4, maxULP: 2, label: "anchor-30"),
        DualUnaryGoldenVector(
            inputBits: 0x54B2_49AD_2594_C37D, expectedFirstBits: 0xBFD8_5C5E_5B92_9359,
            expectedSecondBits: 0x3FED_9757_4968_41F5, maxULP: 2, label: "anchor-31"),
        DualUnaryGoldenVector(
            inputBits: 0x6974_E718_D7D7_625A, expectedFirstBits: 0xBFE4_9B64_4938_C64C,
            expectedSecondBits: 0x3FE8_7B4D_F51F_679E, maxULP: 2, label: "anchor-32"),
        DualUnaryGoldenVector(
            inputBits: 0x7E37_E43C_8800_759C, expectedFirstBits: 0xBFEA_2C16_B010_E385,
            expectedSecondBits: 0xBFE2_6990_22AD_C4C1, maxULP: 2, label: "anchor-33"),
        DualUnaryGoldenVector(
            inputBits: 0x7FEF_FFFF_FFFF_FFFF, expectedFirstBits: 0x3F74_52FC_98B3_4E97,
            expectedSecondBits: 0xBFEF_FFE6_2ECF_AB75, maxULP: 2, label: "anchor-34"),
        DualUnaryGoldenVector(
            inputBits: 0x3FEE_A303_297A_9B16, expectedFirstBits: 0x3FEA_2A93_03EB_C3EB,
            expectedSecondBits: 0x3FE2_6BB7_0105_20AF, maxULP: 2, label: "worst-0"),
        DualUnaryGoldenVector(
            inputBits: 0x4002_44E0_9896_D878, expectedFirstBits: 0x3FE8_3556_0FA2_36ED,
            expectedSecondBits: 0xBFE4_ED6A_11A3_A8E2, maxULP: 2, label: "worst-1"),
        DualUnaryGoldenVector(
            inputBits: 0x4060_F776_CCF5_103A, expectedFirstBits: 0xBFE3_3B7F_8D77_28A8,
            expectedSecondBits: 0xBFE9_935E_3B69_A5B0, maxULP: 2, label: "worst-2"),
        DualUnaryGoldenVector(
            inputBits: 0x4089_401B_CC1C_3A2E, expectedFirstBits: 0xBFE2_B434_A2E1_FA79,
            expectedSecondBits: 0xBFE9_F6F3_5460_BE70, maxULP: 2, label: "worst-3"),
        DualUnaryGoldenVector(
            inputBits: 0xBFEE_A303_297A_9B16, expectedFirstBits: 0xBFEA_2A93_03EB_C3EB,
            expectedSecondBits: 0x3FE2_6BB7_0105_20AF, maxULP: 2, label: "worst-4"),
        DualUnaryGoldenVector(
            inputBits: 0xC002_44E0_9896_D878, expectedFirstBits: 0xBFE8_3556_0FA2_36ED,
            expectedSecondBits: 0xBFE4_ED6A_11A3_A8E2, maxULP: 2, label: "worst-5"),
        DualUnaryGoldenVector(
            inputBits: 0xC060_F776_CCF5_103A, expectedFirstBits: 0x3FE3_3B7F_8D77_28A8,
            expectedSecondBits: 0xBFE9_935E_3B69_A5B0, maxULP: 2, label: "worst-6"),
        DualUnaryGoldenVector(
            inputBits: 0xC089_401B_CC1C_3A2E, expectedFirstBits: 0x3FE2_B434_A2E1_FA79,
            expectedSecondBits: 0xBFE9_F6F3_5460_BE70, maxULP: 2, label: "worst-7")
    ]
}
