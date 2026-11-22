import SwiftSIMDMathTestSupport

// MARK: - MPFR-Certified Unary Golden Vectors (Trig & Pi-Trig) (Part 3)

extension SIMDUnaryOperation {
    static let atanGoldenVectors: [UnaryGoldenVector] = [
        UnaryGoldenVector(
            inputBits: 0xFFEF_FFFF_FFFF_FFFF, expectedBits: 0xBFF9_21FB_5444_2D18, maxULP: 2, label: "anchor-0"),
        UnaryGoldenVector(
            inputBits: 0xC003_504F_333F_9DE6, expectedBits: 0xBFF2_D97C_7F33_21D2, maxULP: 2, label: "anchor-1"),
        UnaryGoldenVector(
            inputBits: 0xBFDA_8279_99FC_EF31, expectedBits: 0xBFD9_21FB_5444_2D17, maxULP: 2, label: "anchor-2"),
        UnaryGoldenVector(
            inputBits: 0x8000_0000_0000_0000, expectedBits: 0x8000_0000_0000_0000, maxULP: 2, label: "anchor-3"),
        UnaryGoldenVector(
            inputBits: 0x0000_0000_0000_0000, expectedBits: 0x0000_0000_0000_0000, maxULP: 2, label: "anchor-4"),
        UnaryGoldenVector(
            inputBits: 0x3FDA_8279_99FC_EF31, expectedBits: 0x3FD9_21FB_5444_2D17, maxULP: 2, label: "anchor-5"),
        UnaryGoldenVector(
            inputBits: 0x4003_504F_333F_9DE6, expectedBits: 0x3FF2_D97C_7F33_21D2, maxULP: 2, label: "anchor-6"),
        UnaryGoldenVector(
            inputBits: 0x7FEF_FFFF_FFFF_FFFF, expectedBits: 0x3FF9_21FB_5444_2D18, maxULP: 2, label: "anchor-7"),
        UnaryGoldenVector(
            inputBits: 0x3FDB_D21E_1BB5_CBD6, expectedBits: 0x3FDA_3E61_C98E_CBB5, maxULP: 2, label: "worst-0"),
        UnaryGoldenVector(
            inputBits: 0xBFDB_D21E_1BB5_CBD6, expectedBits: 0xBFDA_3E61_C98E_CBB5, maxULP: 2, label: "worst-1"),
        UnaryGoldenVector(
            inputBits: 0x3FAE_65C3_7311_11B0, expectedBits: 0x3FAE_5CA3_C19D_5850, maxULP: 2, label: "worst-2"),
        UnaryGoldenVector(
            inputBits: 0x4003_504F_333F_9DE3, expectedBits: 0x3FF2_D97C_7F33_21D1, maxULP: 2, label: "worst-3"),
        UnaryGoldenVector(
            inputBits: 0x4044_48CC_36B5_0EF6, expectedBits: 0x3FF8_BD09_A942_72A5, maxULP: 2, label: "worst-4"),
        UnaryGoldenVector(
            inputBits: 0xBFAE_65C3_7311_11B0, expectedBits: 0xBFAE_5CA3_C19D_5850, maxULP: 2, label: "worst-5"),
        UnaryGoldenVector(
            inputBits: 0xC003_504F_333F_9DE3, expectedBits: 0xBFF2_D97C_7F33_21D1, maxULP: 2, label: "worst-6"),
        UnaryGoldenVector(
            inputBits: 0xC044_48CC_36B5_0EF6, expectedBits: 0xBFF8_BD09_A942_72A5, maxULP: 2, label: "worst-7")
    ]

    static let sinpiGoldenVectors: [UnaryGoldenVector] = [
        UnaryGoldenVector(
            inputBits: 0xFFEF_FFFF_FFFF_FFFF, expectedBits: 0x8000_0000_0000_0000, maxULP: 2, label: "anchor-0"),
        UnaryGoldenVector(
            inputBits: 0xC340_0000_0000_0000, expectedBits: 0x8000_0000_0000_0000, maxULP: 2, label: "anchor-1"),
        UnaryGoldenVector(
            inputBits: 0xC330_0000_0000_0001, expectedBits: 0x8000_0000_0000_0000, maxULP: 2, label: "anchor-2"),
        UnaryGoldenVector(
            inputBits: 0xC330_0000_0000_0000, expectedBits: 0x8000_0000_0000_0000, maxULP: 2, label: "anchor-3"),
        UnaryGoldenVector(
            inputBits: 0xC32F_FFFF_FFFF_FFFF, expectedBits: 0x3FF0_0000_0000_0000, maxULP: 2, label: "anchor-4"),
        UnaryGoldenVector(
            inputBits: 0xC004_0000_0000_0000, expectedBits: 0xBFF0_0000_0000_0000, maxULP: 2, label: "anchor-5"),
        UnaryGoldenVector(
            inputBits: 0xBFF8_0000_0000_0000, expectedBits: 0x3FF0_0000_0000_0000, maxULP: 2, label: "anchor-6"),
        UnaryGoldenVector(
            inputBits: 0xBFF0_0000_0000_0000, expectedBits: 0x8000_0000_0000_0000, maxULP: 2, label: "anchor-7"),
        UnaryGoldenVector(
            inputBits: 0xBFE0_0000_0000_0000, expectedBits: 0xBFF0_0000_0000_0000, maxULP: 2, label: "anchor-8"),
        UnaryGoldenVector(
            inputBits: 0xBFD0_0000_0000_0000, expectedBits: 0xBFE6_A09E_667F_3BCD, maxULP: 2, label: "anchor-9"),
        UnaryGoldenVector(
            inputBits: 0x8000_0000_0000_0001, expectedBits: 0x8000_0000_0000_0003, maxULP: 2, label: "anchor-10"),
        UnaryGoldenVector(
            inputBits: 0x8000_0000_0000_0000, expectedBits: 0x8000_0000_0000_0000, maxULP: 2, label: "anchor-11"),
        UnaryGoldenVector(
            inputBits: 0x0000_0000_0000_0000, expectedBits: 0x0000_0000_0000_0000, maxULP: 2, label: "anchor-12"),
        UnaryGoldenVector(
            inputBits: 0x0000_0000_0000_0001, expectedBits: 0x0000_0000_0000_0003, maxULP: 2, label: "anchor-13"),
        UnaryGoldenVector(
            inputBits: 0x3FD0_0000_0000_0000, expectedBits: 0x3FE6_A09E_667F_3BCD, maxULP: 2, label: "anchor-14"),
        UnaryGoldenVector(
            inputBits: 0x3FE0_0000_0000_0000, expectedBits: 0x3FF0_0000_0000_0000, maxULP: 2, label: "anchor-15"),
        UnaryGoldenVector(
            inputBits: 0x3FF0_0000_0000_0000, expectedBits: 0x0000_0000_0000_0000, maxULP: 2, label: "anchor-16"),
        UnaryGoldenVector(
            inputBits: 0x3FF8_0000_0000_0000, expectedBits: 0xBFF0_0000_0000_0000, maxULP: 2, label: "anchor-17"),
        UnaryGoldenVector(
            inputBits: 0x4004_0000_0000_0000, expectedBits: 0x3FF0_0000_0000_0000, maxULP: 2, label: "anchor-18"),
        UnaryGoldenVector(
            inputBits: 0x430F_FFFF_FFFF_FFFF, expectedBits: 0xBFD8_7DE2_A6AE_A963, maxULP: 2, label: "anchor-19"),
        UnaryGoldenVector(
            inputBits: 0x4310_0000_0000_0000, expectedBits: 0x0000_0000_0000_0000, maxULP: 2, label: "anchor-20"),
        UnaryGoldenVector(
            inputBits: 0x432F_FFFF_FFFF_FFFF, expectedBits: 0xBFF0_0000_0000_0000, maxULP: 2, label: "anchor-21"),
        UnaryGoldenVector(
            inputBits: 0x4330_0000_0000_0000, expectedBits: 0x0000_0000_0000_0000, maxULP: 2, label: "anchor-22"),
        UnaryGoldenVector(
            inputBits: 0x4330_0000_0000_0001, expectedBits: 0x0000_0000_0000_0000, maxULP: 2, label: "anchor-23"),
        UnaryGoldenVector(
            inputBits: 0x4340_0000_0000_0000, expectedBits: 0x0000_0000_0000_0000, maxULP: 2, label: "anchor-24"),
        UnaryGoldenVector(
            inputBits: 0x7FEF_FFFF_FFFF_FFFF, expectedBits: 0x0000_0000_0000_0000, maxULP: 2, label: "anchor-25"),
        UnaryGoldenVector(
            inputBits: 0x3FDF_A0CB_4ADF_E940, expectedBits: 0x3FEF_FEA2_8ECC_73E6, maxULP: 2, label: "worst-0"),
        UnaryGoldenVector(
            inputBits: 0x400C_520C_2188_B355, expectedBits: 0xBFEF_BF33_EDB7_8128, maxULP: 2, label: "worst-1"),
        UnaryGoldenVector(
            inputBits: 0x4041_C32B_B855_B4B8, expectedBits: 0xBFEF_E734_A3C8_CC8A, maxULP: 2, label: "worst-2"),
        UnaryGoldenVector(
            inputBits: 0x4086_B360_675E_CAB4, expectedBits: 0x3FEF_0BBA_3898_8A84, maxULP: 2, label: "worst-3"),
        UnaryGoldenVector(
            inputBits: 0xBFDF_A0CB_4ADF_E940, expectedBits: 0xBFEF_FEA2_8ECC_73E6, maxULP: 2, label: "worst-4"),
        UnaryGoldenVector(
            inputBits: 0xC00C_520C_2188_B355, expectedBits: 0x3FEF_BF33_EDB7_8128, maxULP: 2, label: "worst-5"),
        UnaryGoldenVector(
            inputBits: 0xC041_C32B_B855_B4B8, expectedBits: 0x3FEF_E734_A3C8_CC8A, maxULP: 2, label: "worst-6"),
        UnaryGoldenVector(
            inputBits: 0xC086_B360_675E_CAB4, expectedBits: 0xBFEF_0BBA_3898_8A84, maxULP: 2, label: "worst-7")
    ]

    static let cospiGoldenVectors: [UnaryGoldenVector] = [
        UnaryGoldenVector(
            inputBits: 0xFFEF_FFFF_FFFF_FFFF, expectedBits: 0x3FF0_0000_0000_0000, maxULP: 2, label: "anchor-0"),
        UnaryGoldenVector(
            inputBits: 0xC340_0000_0000_0000, expectedBits: 0x3FF0_0000_0000_0000, maxULP: 2, label: "anchor-1"),
        UnaryGoldenVector(
            inputBits: 0xC330_0000_0000_0001, expectedBits: 0xBFF0_0000_0000_0000, maxULP: 2, label: "anchor-2"),
        UnaryGoldenVector(
            inputBits: 0xC330_0000_0000_0000, expectedBits: 0x3FF0_0000_0000_0000, maxULP: 2, label: "anchor-3"),
        UnaryGoldenVector(
            inputBits: 0xC32F_FFFF_FFFF_FFFF, expectedBits: 0x0000_0000_0000_0000, maxULP: 2, label: "anchor-4"),
        UnaryGoldenVector(
            inputBits: 0xC004_0000_0000_0000, expectedBits: 0x0000_0000_0000_0000, maxULP: 2, label: "anchor-5"),
        UnaryGoldenVector(
            inputBits: 0xBFF8_0000_0000_0000, expectedBits: 0x0000_0000_0000_0000, maxULP: 2, label: "anchor-6"),
        UnaryGoldenVector(
            inputBits: 0xBFF0_0000_0000_0000, expectedBits: 0xBFF0_0000_0000_0000, maxULP: 2, label: "anchor-7"),
        UnaryGoldenVector(
            inputBits: 0xBFE0_0000_0000_0000, expectedBits: 0x0000_0000_0000_0000, maxULP: 2, label: "anchor-8"),
        UnaryGoldenVector(
            inputBits: 0xBFD0_0000_0000_0000, expectedBits: 0x3FE6_A09E_667F_3BCD, maxULP: 2, label: "anchor-9"),
        UnaryGoldenVector(
            inputBits: 0x8000_0000_0000_0001, expectedBits: 0x3FF0_0000_0000_0000, maxULP: 2, label: "anchor-10"),
        UnaryGoldenVector(
            inputBits: 0x8000_0000_0000_0000, expectedBits: 0x3FF0_0000_0000_0000, maxULP: 2, label: "anchor-11"),
        UnaryGoldenVector(
            inputBits: 0x0000_0000_0000_0000, expectedBits: 0x3FF0_0000_0000_0000, maxULP: 2, label: "anchor-12"),
        UnaryGoldenVector(
            inputBits: 0x0000_0000_0000_0001, expectedBits: 0x3FF0_0000_0000_0000, maxULP: 2, label: "anchor-13"),
        UnaryGoldenVector(
            inputBits: 0x3FD0_0000_0000_0000, expectedBits: 0x3FE6_A09E_667F_3BCD, maxULP: 2, label: "anchor-14"),
        UnaryGoldenVector(
            inputBits: 0x3FE0_0000_0000_0000, expectedBits: 0x0000_0000_0000_0000, maxULP: 2, label: "anchor-15"),
        UnaryGoldenVector(
            inputBits: 0x3FF0_0000_0000_0000, expectedBits: 0xBFF0_0000_0000_0000, maxULP: 2, label: "anchor-16"),
        UnaryGoldenVector(
            inputBits: 0x3FF8_0000_0000_0000, expectedBits: 0x0000_0000_0000_0000, maxULP: 2, label: "anchor-17"),
        UnaryGoldenVector(
            inputBits: 0x4004_0000_0000_0000, expectedBits: 0x0000_0000_0000_0000, maxULP: 2, label: "anchor-18"),
        UnaryGoldenVector(
            inputBits: 0x430F_FFFF_FFFF_FFFF, expectedBits: 0x3FED_906B_CF32_8D46, maxULP: 2, label: "anchor-19"),
        UnaryGoldenVector(
            inputBits: 0x4310_0000_0000_0000, expectedBits: 0x3FF0_0000_0000_0000, maxULP: 2, label: "anchor-20"),
        UnaryGoldenVector(
            inputBits: 0x432F_FFFF_FFFF_FFFF, expectedBits: 0x0000_0000_0000_0000, maxULP: 2, label: "anchor-21"),
        UnaryGoldenVector(
            inputBits: 0x4330_0000_0000_0000, expectedBits: 0x3FF0_0000_0000_0000, maxULP: 2, label: "anchor-22"),
        UnaryGoldenVector(
            inputBits: 0x4330_0000_0000_0001, expectedBits: 0xBFF0_0000_0000_0000, maxULP: 2, label: "anchor-23"),
        UnaryGoldenVector(
            inputBits: 0x4340_0000_0000_0000, expectedBits: 0x3FF0_0000_0000_0000, maxULP: 2, label: "anchor-24"),
        UnaryGoldenVector(
            inputBits: 0x7FEF_FFFF_FFFF_FFFF, expectedBits: 0x3FF0_0000_0000_0000, maxULP: 2, label: "anchor-25"),
        UnaryGoldenVector(
            inputBits: 0x3E3E_9306_9B97_6DCE, expectedBits: 0x3FEF_FFFF_FFFF_FFFE, maxULP: 2, label: "worst-0"),
        UnaryGoldenVector(
            inputBits: 0x3E4D_A8EE_2C20_225B, expectedBits: 0x3FEF_FFFF_FFFF_FFF8, maxULP: 2, label: "worst-1"),
        UnaryGoldenVector(
            inputBits: 0x3E83_DF7E_C4CD_A23C, expectedBits: 0x3FEF_FFFF_FFFF_FC32, maxULP: 2, label: "worst-2"),
        UnaryGoldenVector(
            inputBits: 0x3EC3_95E5_9FE2_27A4, expectedBits: 0x3FEF_FFFF_FFFC_4D86, maxULP: 2, label: "worst-3"),
        UnaryGoldenVector(
            inputBits: 0xBE3E_9306_9B97_6DCE, expectedBits: 0x3FEF_FFFF_FFFF_FFFE, maxULP: 2, label: "worst-4"),
        UnaryGoldenVector(
            inputBits: 0xBE4D_A8EE_2C20_225B, expectedBits: 0x3FEF_FFFF_FFFF_FFF8, maxULP: 2, label: "worst-5"),
        UnaryGoldenVector(
            inputBits: 0xBE83_DF7E_C4CD_A23C, expectedBits: 0x3FEF_FFFF_FFFF_FC32, maxULP: 2, label: "worst-6"),
        UnaryGoldenVector(
            inputBits: 0xBEC3_95E5_9FE2_27A4, expectedBits: 0x3FEF_FFFF_FFFC_4D86, maxULP: 2, label: "worst-7")
    ]
}
