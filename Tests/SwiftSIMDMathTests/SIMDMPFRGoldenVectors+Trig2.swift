import SwiftSIMDMathTestSupport

// MARK: - MPFR-Certified Unary Golden Vectors (Trig & Pi-Trig) (Part 2)

extension SIMDUnaryOperation {
    static let tanGoldenVectors: [UnaryGoldenVector] = [
        UnaryGoldenVector(
            inputBits: 0xFFEF_FFFF_FFFF_FFFF, expectedBits: 0x3F74_530C_FE72_9484, maxULP: 2, label: "anchor-0"),
        UnaryGoldenVector(
            inputBits: 0xE974_E718_D7D7_625A, expectedBits: 0x3FEA_EF78_45D4_1E88, maxULP: 2, label: "anchor-1"),
        UnaryGoldenVector(
            inputBits: 0xD4B2_49AD_2594_C37D, expectedBits: 0x3FDA_5807_D6F7_6F7D, maxULP: 2, label: "anchor-2"),
        UnaryGoldenVector(
            inputBits: 0xC480_F0CF_064D_D592, expectedBits: 0x3FFA_0F79_C1B6_B257, maxULP: 2, label: "anchor-3"),
        UnaryGoldenVector(
            inputBits: 0xF506_AC5B_262C_A1FF, expectedBits: 0x43BD_9BA9_A797_5636, maxULP: 2, label: "anchor-4"),
        UnaryGoldenVector(
            inputBits: 0xC120_0000_0000_0001, expectedBits: 0xBFC5_C354_A35C_5E0F, maxULP: 2, label: "anchor-5"),
        UnaryGoldenVector(
            inputBits: 0xC120_0000_0000_0000, expectedBits: 0xBFC5_C354_A31A_846E, maxULP: 2, label: "anchor-6"),
        UnaryGoldenVector(
            inputBits: 0xC11F_FFFF_FFFF_FFFF, expectedBits: 0xBFC5_C354_A2F9_979E, maxULP: 2, label: "anchor-7"),
        UnaryGoldenVector(
            inputBits: 0xC019_21FB_5444_2D18, expectedBits: 0x3CB1_A626_3314_5C07, maxULP: 2, label: "anchor-8"),
        UnaryGoldenVector(
            inputBits: 0xC009_21FB_5444_2D18, expectedBits: 0x3CA1_A626_3314_5C07, maxULP: 2, label: "anchor-9"),
        UnaryGoldenVector(
            inputBits: 0xBFF9_21FB_5444_2D18, expectedBits: 0xC34D_0296_7C31_CDB5, maxULP: 2, label: "anchor-10"),
        UnaryGoldenVector(
            inputBits: 0xBFE9_21FB_5444_2D18, expectedBits: 0xBFEF_FFFF_FFFF_FFFF, maxULP: 2, label: "anchor-11"),
        UnaryGoldenVector(
            inputBits: 0x8000_0000_0000_0001, expectedBits: 0x8000_0000_0000_0001, maxULP: 2, label: "anchor-12"),
        UnaryGoldenVector(
            inputBits: 0x8000_0000_0000_0000, expectedBits: 0x8000_0000_0000_0000, maxULP: 2, label: "anchor-13"),
        UnaryGoldenVector(
            inputBits: 0x0000_0000_0000_0000, expectedBits: 0x0000_0000_0000_0000, maxULP: 2, label: "anchor-14"),
        UnaryGoldenVector(
            inputBits: 0x0000_0000_0000_0001, expectedBits: 0x0000_0000_0000_0001, maxULP: 2, label: "anchor-15"),
        UnaryGoldenVector(
            inputBits: 0x3FE9_21FB_5444_2D18, expectedBits: 0x3FEF_FFFF_FFFF_FFFF, maxULP: 2, label: "anchor-16"),
        UnaryGoldenVector(
            inputBits: 0x3FF9_21FB_5444_2D18, expectedBits: 0x434D_0296_7C31_CDB5, maxULP: 2, label: "anchor-17"),
        UnaryGoldenVector(
            inputBits: 0x4009_21FB_5444_2D18, expectedBits: 0xBCA1_A626_3314_5C07, maxULP: 2, label: "anchor-18"),
        UnaryGoldenVector(
            inputBits: 0x4019_21FB_5444_2D18, expectedBits: 0xBCB1_A626_3314_5C07, maxULP: 2, label: "anchor-19"),
        UnaryGoldenVector(
            inputBits: 0x411F_FFFF_FFFF_FFFF, expectedBits: 0x3FC5_C354_A2F9_979E, maxULP: 2, label: "anchor-20"),
        UnaryGoldenVector(
            inputBits: 0x4120_0000_0000_0000, expectedBits: 0x3FC5_C354_A31A_846E, maxULP: 2, label: "anchor-21"),
        UnaryGoldenVector(
            inputBits: 0x4120_0000_0000_0001, expectedBits: 0x3FC5_C354_A35C_5E0F, maxULP: 2, label: "anchor-22"),
        UnaryGoldenVector(
            inputBits: 0x4164_5525_B1B6_F85C, expectedBits: 0x4016_C2B2_7B5A_4B31, maxULP: 2, label: "anchor-23"),
        UnaryGoldenVector(
            inputBits: 0x42D0_E826_CEB0_C5C0, expectedBits: 0x42DE_9DF2_DC27_4BE0, maxULP: 2, label: "anchor-24"),
        UnaryGoldenVector(
            inputBits: 0x42E8_577C_EC54_AB80, expectedBits: 0x432B_6576_3FD5_6C3A, maxULP: 2, label: "anchor-25"),
        UnaryGoldenVector(
            inputBits: 0x4335_08EC_B38F_52F9, expectedBits: 0xC335_9C47_CAC0_2BC6, maxULP: 2, label: "anchor-26"),
        UnaryGoldenVector(
            inputBits: 0x4335_CBA8_9AF1_F855, expectedBits: 0xBC9B_5EBD_E2AA_E00B, maxULP: 2, label: "anchor-27"),
        UnaryGoldenVector(
            inputBits: 0x43CE_3957_08F0_5C22, expectedBits: 0xBF6F_4D8D_09BF_421A, maxULP: 2, label: "anchor-28"),
        UnaryGoldenVector(
            inputBits: 0x7506_AC5B_262C_A1FF, expectedBits: 0xC3BD_9BA9_A797_5636, maxULP: 2, label: "anchor-29"),
        UnaryGoldenVector(
            inputBits: 0x4480_F0CF_064D_D592, expectedBits: 0xBFFA_0F79_C1B6_B257, maxULP: 2, label: "anchor-30"),
        UnaryGoldenVector(
            inputBits: 0x54B2_49AD_2594_C37D, expectedBits: 0xBFDA_5807_D6F7_6F7D, maxULP: 2, label: "anchor-31"),
        UnaryGoldenVector(
            inputBits: 0x6974_E718_D7D7_625A, expectedBits: 0xBFEA_EF78_45D4_1E88, maxULP: 2, label: "anchor-32"),
        UnaryGoldenVector(
            inputBits: 0x7E37_E43C_8800_759C, expectedBits: 0x3FF6_BE41_1F37_AC77, maxULP: 2, label: "anchor-33"),
        UnaryGoldenVector(
            inputBits: 0x7FEF_FFFF_FFFF_FFFF, expectedBits: 0xBF74_530C_FE72_9484, maxULP: 2, label: "anchor-34"),
        UnaryGoldenVector(
            inputBits: 0x3FE8_8AD1_7DAF_2CB5, expectedBits: 0x3FEE_D71E_207D_2D37, maxULP: 2, label: "worst-0"),
        UnaryGoldenVector(
            inputBits: 0x4001_1346_E514_6144, expectedBits: 0xBFF9_5106_C0E8_03F5, maxULP: 2, label: "worst-1"),
        UnaryGoldenVector(
            inputBits: 0x404D_329E_6AE6_CF3E, expectedBits: 0xC00C_3F09_3AD8_52B2, maxULP: 2, label: "worst-2"),
        UnaryGoldenVector(
            inputBits: 0x4087_FCC5_555B_1155, expectedBits: 0x3FFB_BF7C_89D6_4DE9, maxULP: 2, label: "worst-3"),
        UnaryGoldenVector(
            inputBits: 0xBFE8_8AD1_7DAF_2CB5, expectedBits: 0xBFEE_D71E_207D_2D37, maxULP: 2, label: "worst-4"),
        UnaryGoldenVector(
            inputBits: 0xC001_1346_E514_6144, expectedBits: 0x3FF9_5106_C0E8_03F5, maxULP: 2, label: "worst-5"),
        UnaryGoldenVector(
            inputBits: 0xC04D_329E_6AE6_CF3E, expectedBits: 0x400C_3F09_3AD8_52B2, maxULP: 2, label: "worst-6"),
        UnaryGoldenVector(
            inputBits: 0xC087_FCC5_555B_1155, expectedBits: 0xBFFB_BF7C_89D6_4DE9, maxULP: 2, label: "worst-7")
    ]

    static let asinGoldenVectors: [UnaryGoldenVector] = [
        UnaryGoldenVector(
            inputBits: 0xBFF0_0000_0000_0000, expectedBits: 0xBFF9_21FB_5444_2D18, maxULP: 2, label: "anchor-0"),
        UnaryGoldenVector(
            inputBits: 0xBFF0_0000_0000_0001, expectedBits: 0x7FF8_0000_0000_0000, maxULP: 2, label: "anchor-1"),
        UnaryGoldenVector(
            inputBits: 0xBFE0_0000_0000_0000, expectedBits: 0xBFE0_C152_382D_7366, maxULP: 2, label: "anchor-2"),
        UnaryGoldenVector(
            inputBits: 0x8000_0000_0000_0000, expectedBits: 0x8000_0000_0000_0000, maxULP: 2, label: "anchor-3"),
        UnaryGoldenVector(
            inputBits: 0x0000_0000_0000_0000, expectedBits: 0x0000_0000_0000_0000, maxULP: 2, label: "anchor-4"),
        UnaryGoldenVector(
            inputBits: 0x3FE0_0000_0000_0000, expectedBits: 0x3FE0_C152_382D_7366, maxULP: 2, label: "anchor-5"),
        UnaryGoldenVector(
            inputBits: 0x3FEF_FFFF_FFFF_FFFF, expectedBits: 0x3FF9_21FB_5044_2D18, maxULP: 2, label: "anchor-6"),
        UnaryGoldenVector(
            inputBits: 0x3FF0_0000_0000_0000, expectedBits: 0x3FF9_21FB_5444_2D18, maxULP: 2, label: "anchor-7"),
        UnaryGoldenVector(
            inputBits: 0xBFEA_DA70_7AB7_5030, expectedBits: 0xBFEF_DD26_D550_5861, maxULP: 2, label: "worst-0"),
        UnaryGoldenVector(
            inputBits: 0x3FEA_E245_CE09_060A, expectedBits: 0x3FEF_EB92_F191_A86C, maxULP: 2, label: "worst-1"),
        UnaryGoldenVector(
            inputBits: 0x3FAE_4C40_5ED7_5140, expectedBits: 0x3FAE_50C9_0B09_0BF5, maxULP: 2, label: "worst-2"),
        UnaryGoldenVector(
            inputBits: 0xBFBC_F64B_450F_4E70, expectedBits: 0xBFBD_0633_AE31_4795, maxULP: 2, label: "worst-3"),
        UnaryGoldenVector(
            inputBits: 0x3F79_AA28_247E_1D00, expectedBits: 0x3F79_AA33_25FD_CA93, maxULP: 2, label: "worst-4"),
        UnaryGoldenVector(
            inputBits: 0xBF60_76B2_CAF3_1600, expectedBits: 0xBF60_76B3_84E3_5301, maxULP: 2, label: "worst-5")
    ]

    static let acosGoldenVectors: [UnaryGoldenVector] = [
        UnaryGoldenVector(
            inputBits: 0xBFF0_0000_0000_0000, expectedBits: 0x4009_21FB_5444_2D18, maxULP: 2, label: "anchor-0"),
        UnaryGoldenVector(
            inputBits: 0xBFF0_0000_0000_0001, expectedBits: 0x7FF8_0000_0000_0000, maxULP: 2, label: "anchor-1"),
        UnaryGoldenVector(
            inputBits: 0xBFE0_0000_0000_0000, expectedBits: 0x4000_C152_382D_7366, maxULP: 2, label: "anchor-2"),
        UnaryGoldenVector(
            inputBits: 0x8000_0000_0000_0000, expectedBits: 0x3FF9_21FB_5444_2D18, maxULP: 2, label: "anchor-3"),
        UnaryGoldenVector(
            inputBits: 0x0000_0000_0000_0000, expectedBits: 0x3FF9_21FB_5444_2D18, maxULP: 2, label: "anchor-4"),
        UnaryGoldenVector(
            inputBits: 0x3FE0_0000_0000_0000, expectedBits: 0x3FF0_C152_382D_7366, maxULP: 2, label: "anchor-5"),
        UnaryGoldenVector(
            inputBits: 0x3FEF_FFFF_FFFF_FFFF, expectedBits: 0x3E50_0000_0000_0000, maxULP: 2, label: "anchor-6"),
        UnaryGoldenVector(
            inputBits: 0x3FF0_0000_0000_0000, expectedBits: 0x0000_0000_0000_0000, maxULP: 2, label: "anchor-7"),
        UnaryGoldenVector(
            inputBits: 0xBFEF_FFFF_FFFF_FFF8, expectedBits: 0x4009_21FB_4E9C_057F, maxULP: 2, label: "worst-0"),
        UnaryGoldenVector(
            inputBits: 0x3D7E_7FA9_D0FD_681C, expectedBits: 0x3FF9_21FB_5444_0E99, maxULP: 2, label: "worst-1"),
        UnaryGoldenVector(
            inputBits: 0x3DD4_CB2A_23E2_C710, expectedBits: 0x3FF9_21FB_543E_FA4E, maxULP: 2, label: "worst-2"),
        UnaryGoldenVector(
            inputBits: 0x3FBC_C3BA_7C60_18A0, expectedBits: 0x3FF7_54C6_570A_CD35, maxULP: 2, label: "worst-3"),
        UnaryGoldenVector(
            inputBits: 0x3FDF_FFFF_FFFF_FFFD, expectedBits: 0x3FF0_C152_382D_7366, maxULP: 2, label: "worst-4"),
        UnaryGoldenVector(
            inputBits: 0xBD2E_6C9E_187E_6520, expectedBits: 0x3FF9_21FB_5444_2E0C, maxULP: 2, label: "worst-5"),
        UnaryGoldenVector(
            inputBits: 0xBD6E_C492_F88B_DA7F, expectedBits: 0x3FF9_21FB_5444_3C7B, maxULP: 2, label: "worst-6"),
        UnaryGoldenVector(
            inputBits: 0xBFBF_E566_46B9_37B0, expectedBits: 0x3FFB_21A6_1FB3_3D73, maxULP: 2, label: "worst-7")
    ]
}
