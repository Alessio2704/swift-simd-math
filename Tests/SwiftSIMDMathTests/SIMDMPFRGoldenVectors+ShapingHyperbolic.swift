import SwiftSIMDMathTestSupport

// MARK: - MPFR-Certified Unary Golden Vectors (Shaping & Hyperbolic)

extension SIMDUnaryOperation {
    static let absGoldenVectors: [UnaryGoldenVector] = [
        UnaryGoldenVector(
            inputBits: 0xFFEF_FFFF_FFFF_FFFF, expectedBits: 0x7FEF_FFFF_FFFF_FFFF, maxULP: 0, label: "anchor-0"),
        UnaryGoldenVector(
            inputBits: 0x8000_0000_0000_0001, expectedBits: 0x0000_0000_0000_0001, maxULP: 0, label: "anchor-1"),
        UnaryGoldenVector(
            inputBits: 0x8000_0000_0000_0000, expectedBits: 0x0000_0000_0000_0000, maxULP: 0, label: "anchor-2"),
        UnaryGoldenVector(
            inputBits: 0x0000_0000_0000_0000, expectedBits: 0x0000_0000_0000_0000, maxULP: 0, label: "anchor-3"),
        UnaryGoldenVector(
            inputBits: 0x3FF0_0000_0000_0000, expectedBits: 0x3FF0_0000_0000_0000, maxULP: 0, label: "anchor-4"),
        UnaryGoldenVector(
            inputBits: 0x0046_115C_1004_8DC8, expectedBits: 0x0046_115C_1004_8DC8, maxULP: 0, label: "worst-0"),
        UnaryGoldenVector(
            inputBits: 0x008B_C103_745D_8CEE, expectedBits: 0x008B_C103_745D_8CEE, maxULP: 0, label: "worst-1"),
        UnaryGoldenVector(
            inputBits: 0x8046_115C_1004_8DC8, expectedBits: 0x0046_115C_1004_8DC8, maxULP: 0, label: "worst-2"),
        UnaryGoldenVector(
            inputBits: 0x808B_C103_745D_8CEE, expectedBits: 0x008B_C103_745D_8CEE, maxULP: 0, label: "worst-3")
    ]

    static let cbrtGoldenVectors: [UnaryGoldenVector] = [
        UnaryGoldenVector(
            inputBits: 0xFFEF_FFFF_FFFF_FFFF, expectedBits: 0xD544_28A2_F98D_728B, maxULP: 1, label: "anchor-0"),
        UnaryGoldenVector(
            inputBits: 0x8010_0000_0000_0000, expectedBits: 0xAAA4_28A2_F98D_728B, maxULP: 1, label: "anchor-1"),
        UnaryGoldenVector(
            inputBits: 0x8000_0000_0000_0001, expectedBits: 0xA990_0000_0000_0000, maxULP: 1, label: "anchor-2"),
        UnaryGoldenVector(
            inputBits: 0x8000_0000_0000_0000, expectedBits: 0x8000_0000_0000_0000, maxULP: 1, label: "anchor-3"),
        UnaryGoldenVector(
            inputBits: 0x0000_0000_0000_0000, expectedBits: 0x0000_0000_0000_0000, maxULP: 1, label: "anchor-4"),
        UnaryGoldenVector(
            inputBits: 0x775A_38B3_D88A_CC71, expectedBits: 0x5267_C45F_404B_99BD, maxULP: 1, label: "anchor-5"),
        UnaryGoldenVector(
            inputBits: 0x7AF9_6FA8_2E74_568E, expectedBits: 0x539D_A485_5884_6C7B, maxULP: 1, label: "anchor-6"),
        UnaryGoldenVector(
            inputBits: 0x7DF8_D10E_9FC8_1DC2, expectedBits: 0x549D_6667_8654_5B8F, maxULP: 1, label: "anchor-7"),
        UnaryGoldenVector(
            inputBits: 0x7FEF_FFFF_FFFF_FFFF, expectedBits: 0x5544_28A2_F98D_728B, maxULP: 1, label: "anchor-8"),
        UnaryGoldenVector(
            inputBits: 0x01C0_B6A0_BB27_01AC, expectedBits: 0x2B34_7439_1790_5FE0, maxULP: 1, label: "worst-0"),
        UnaryGoldenVector(
            inputBits: 0x0223_34AC_D546_2D16, expectedBits: 0x2B55_6C8B_149E_F8ED, maxULP: 1, label: "worst-1"),
        UnaryGoldenVector(
            inputBits: 0x0275_B3C4_6F28_58C6, expectedBits: 0x2B71_B611_47E5_1B8D, maxULP: 1, label: "worst-2"),
        UnaryGoldenVector(
            inputBits: 0x0479_26C5_9E25_A9E2, expectedBits: 0x2C1D_881A_0F7C_D74D, maxULP: 1, label: "worst-3"),
        UnaryGoldenVector(
            inputBits: 0x81C0_B6A0_BB27_01AC, expectedBits: 0xAB34_7439_1790_5FE0, maxULP: 1, label: "worst-4"),
        UnaryGoldenVector(
            inputBits: 0x8223_34AC_D546_2D16, expectedBits: 0xAB55_6C8B_149E_F8ED, maxULP: 1, label: "worst-5"),
        UnaryGoldenVector(
            inputBits: 0x8275_B3C4_6F28_58C6, expectedBits: 0xAB71_B611_47E5_1B8D, maxULP: 1, label: "worst-6"),
        UnaryGoldenVector(
            inputBits: 0x8479_26C5_9E25_A9E2, expectedBits: 0xAC1D_881A_0F7C_D74D, maxULP: 1, label: "worst-7")
    ]

    static let signGoldenVectors: [UnaryGoldenVector] = [
        UnaryGoldenVector(
            inputBits: 0xFFEF_FFFF_FFFF_FFFF, expectedBits: 0xBFF0_0000_0000_0000, maxULP: 0, label: "anchor-0"),
        UnaryGoldenVector(
            inputBits: 0x8000_0000_0000_0001, expectedBits: 0xBFF0_0000_0000_0000, maxULP: 0, label: "anchor-1"),
        UnaryGoldenVector(
            inputBits: 0x8000_0000_0000_0000, expectedBits: 0x0000_0000_0000_0000, maxULP: 0, label: "anchor-2"),
        UnaryGoldenVector(
            inputBits: 0x0000_0000_0000_0000, expectedBits: 0x0000_0000_0000_0000, maxULP: 0, label: "anchor-3"),
        UnaryGoldenVector(
            inputBits: 0x3FF0_0000_0000_0000, expectedBits: 0x3FF0_0000_0000_0000, maxULP: 0, label: "anchor-4"),
        UnaryGoldenVector(
            inputBits: 0x0040_6984_2C18_F444, expectedBits: 0x3FF0_0000_0000_0000, maxULP: 0, label: "worst-0"),
        UnaryGoldenVector(
            inputBits: 0x0083_71E1_F5D1_9DFA, expectedBits: 0x3FF0_0000_0000_0000, maxULP: 0, label: "worst-1"),
        UnaryGoldenVector(
            inputBits: 0x8040_6984_2C18_F444, expectedBits: 0xBFF0_0000_0000_0000, maxULP: 0, label: "worst-2"),
        UnaryGoldenVector(
            inputBits: 0x8083_71E1_F5D1_9DFA, expectedBits: 0xBFF0_0000_0000_0000, maxULP: 0, label: "worst-3")
    ]

    static let fractGoldenVectors: [UnaryGoldenVector] = [
        UnaryGoldenVector(
            inputBits: 0xC330_0000_0000_0000, expectedBits: 0x0000_0000_0000_0000, maxULP: 0, label: "anchor-0"),
        UnaryGoldenVector(
            inputBits: 0xBFF0_0000_0000_0001, expectedBits: 0x3FEF_FFFF_FFFF_FFFE, maxULP: 0, label: "anchor-1"),
        UnaryGoldenVector(
            inputBits: 0x8000_0000_0000_0001, expectedBits: 0x3FEF_FFFF_FFFF_FFFF, maxULP: 0, label: "anchor-2"),
        UnaryGoldenVector(
            inputBits: 0x8000_0000_0000_0000, expectedBits: 0x0000_0000_0000_0000, maxULP: 0, label: "anchor-3"),
        UnaryGoldenVector(
            inputBits: 0x0000_0000_0000_0000, expectedBits: 0x0000_0000_0000_0000, maxULP: 0, label: "anchor-4"),
        UnaryGoldenVector(
            inputBits: 0x3FEF_FFFF_FFFF_FFFF, expectedBits: 0x3FEF_FFFF_FFFF_FFFF, maxULP: 0, label: "anchor-5"),
        UnaryGoldenVector(
            inputBits: 0x4330_0000_0000_0000, expectedBits: 0x0000_0000_0000_0000, maxULP: 0, label: "anchor-6"),
        UnaryGoldenVector(
            inputBits: 0x0043_1D3B_652F_BA9E, expectedBits: 0x0043_1D3B_652F_BA9E, maxULP: 0, label: "worst-0"),
        UnaryGoldenVector(
            inputBits: 0x8043_1D3B_652F_BA9E, expectedBits: 0x3FEF_FFFF_FFFF_FFFF, maxULP: 0, label: "worst-1")
    ]

    static let sinhGoldenVectors: [UnaryGoldenVector] = [
        UnaryGoldenVector(
            inputBits: 0xC086_3800_0000_0000, expectedBits: 0xFFF0_0000_0000_0000, maxULP: 2, label: "anchor-0"),
        UnaryGoldenVector(
            inputBits: 0xC086_33CE_8FB9_F87D, expectedBits: 0xFFEF_FFFF_FFFF_FD3B, maxULP: 2, label: "anchor-1"),
        UnaryGoldenVector(
            inputBits: 0xBFF0_0000_0000_0000, expectedBits: 0xBFF2_CD9F_C44E_B982, maxULP: 2, label: "anchor-2"),
        UnaryGoldenVector(
            inputBits: 0xBFE9_8B1E_7F81_D840, expectedBits: 0xBFEC_5802_22EA_0D7B, maxULP: 2, label: "anchor-3"),
        UnaryGoldenVector(
            inputBits: 0x8000_0000_0000_0000, expectedBits: 0x8000_0000_0000_0000, maxULP: 2, label: "anchor-4"),
        UnaryGoldenVector(
            inputBits: 0x0000_0000_0000_0000, expectedBits: 0x0000_0000_0000_0000, maxULP: 2, label: "anchor-5"),
        UnaryGoldenVector(
            inputBits: 0x3FF0_0000_0000_0000, expectedBits: 0x3FF2_CD9F_C44E_B982, maxULP: 2, label: "anchor-6"),
        UnaryGoldenVector(
            inputBits: 0x4086_33CE_8FB9_F87D, expectedBits: 0x7FEF_FFFF_FFFF_FD3B, maxULP: 2, label: "anchor-7"),
        UnaryGoldenVector(
            inputBits: 0x4027_59CC_ECC8_1E40, expectedBits: 0x40EC_B88D_8651_1FB0, maxULP: 2, label: "worst-0"),
        UnaryGoldenVector(
            inputBits: 0x3FF6_88BA_042E_6800, expectedBits: 0x3FFE_C220_76DD_2213, maxULP: 2, label: "worst-1"),
        UnaryGoldenVector(
            inputBits: 0xBFF7_0B43_6F8C_E600, expectedBits: 0xBFFF_E109_CACB_1D4E, maxULP: 2, label: "worst-2"),
        UnaryGoldenVector(
            inputBits: 0xC031_C6FF_D0EB_AE60, expectedBits: 0xC179_0F36_B835_49EC, maxULP: 2, label: "worst-3"),
        UnaryGoldenVector(
            inputBits: 0x4065_A7F7_E950_E278, expectedBits: 0x4F7E_D042_805D_F2DB, maxULP: 2, label: "worst-4"),
        UnaryGoldenVector(
            inputBits: 0x4080_E766_8B5E_4E6C, expectedBits: 0x70A4_F70F_C22B_24E8, maxULP: 2, label: "worst-5"),
        UnaryGoldenVector(
            inputBits: 0xC061_BB5B_A508_00C8, expectedBits: 0xCCA9_2A8A_B093_0062, maxULP: 2, label: "worst-6"),
        UnaryGoldenVector(
            inputBits: 0xC082_4C4B_AD73_16D0, expectedBits: 0xF4AA_EEA0_855D_C0E7, maxULP: 2, label: "worst-7")
    ]

    static let coshGoldenVectors: [UnaryGoldenVector] = [
        UnaryGoldenVector(
            inputBits: 0xC086_3800_0000_0000, expectedBits: 0x7FF0_0000_0000_0000, maxULP: 2, label: "anchor-0"),
        UnaryGoldenVector(
            inputBits: 0xC086_33CE_8FB9_F87D, expectedBits: 0x7FEF_FFFF_FFFF_FD3B, maxULP: 2, label: "anchor-1"),
        UnaryGoldenVector(
            inputBits: 0xBFF0_0000_0000_0000, expectedBits: 0x3FF8_B075_51D9_F550, maxULP: 2, label: "anchor-2"),
        UnaryGoldenVector(
            inputBits: 0x8000_0000_0000_0000, expectedBits: 0x3FF0_0000_0000_0000, maxULP: 2, label: "anchor-3"),
        UnaryGoldenVector(
            inputBits: 0x0000_0000_0000_0000, expectedBits: 0x3FF0_0000_0000_0000, maxULP: 2, label: "anchor-4"),
        UnaryGoldenVector(
            inputBits: 0x3FF0_0000_0000_0000, expectedBits: 0x3FF8_B075_51D9_F550, maxULP: 2, label: "anchor-5"),
        UnaryGoldenVector(
            inputBits: 0x4086_2000_0000_0000, expectedBits: 0x7FB5_86F6_BF26_0CF1, maxULP: 2, label: "anchor-6"),
        UnaryGoldenVector(
            inputBits: 0x4086_33CE_8FB9_F87D, expectedBits: 0x7FEF_FFFF_FFFF_FD3B, maxULP: 2, label: "anchor-7"),
        UnaryGoldenVector(
            inputBits: 0xC031_CD1E_4503_A700, expectedBits: 0x4179_AA66_0AEA_042A, maxULP: 2, label: "worst-0"),
        UnaryGoldenVector(
            inputBits: 0x3FF1_7CA9_16E9_D140, expectedBits: 0x3FFA_8BC4_F048_E0CC, maxULP: 2, label: "worst-1"),
        UnaryGoldenVector(
            inputBits: 0x401D_7A79_FE58_FF00, expectedBits: 0x4088_CC09_36D6_F438, maxULP: 2, label: "worst-2"),
        UnaryGoldenVector(
            inputBits: 0xBFF4_4187_9D26_5820, expectedBits: 0x3FFE_A0F3_B1D7_E256, maxULP: 2, label: "worst-3"),
        UnaryGoldenVector(
            inputBits: 0x3F87_B09B_8C59_0000, expectedBits: 0x3FF0_0046_26EC_7231, maxULP: 2, label: "worst-4"),
        UnaryGoldenVector(
            inputBits: 0x406B_1956_7D86_F53C, expectedBits: 0x536B_2E0B_5CEC_3002, maxULP: 2, label: "worst-5"),
        UnaryGoldenVector(
            inputBits: 0x4081_FB71_AB18_2CBA, expectedBits: 0x73C2_0293_DD47_BA2E, maxULP: 2, label: "worst-6"),
        UnaryGoldenVector(
            inputBits: 0xC079_0B6A_224D_D8A8, expectedBits: 0x6401_3C1B_283E_E087, maxULP: 2, label: "worst-7")
    ]
}
