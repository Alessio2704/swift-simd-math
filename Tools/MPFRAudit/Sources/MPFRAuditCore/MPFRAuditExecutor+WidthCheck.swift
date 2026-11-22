import SwiftSIMDMathTestSupport

// MARK: - Compile-Time Exhaustive SIMDVectorWidth Cross-Width Verification Helpers

extension MPFRAuditExecutor {
    static func countUnaryCrossWidthErrors(
        v8: SIMD8<Double>,
        out8: SIMD8<Double>,
        lanes: Int,
        eval2: (SIMD2<Double>) -> SIMD2<Double>,
        eval4: (SIMD4<Double>) -> SIMD4<Double>
    ) -> Int {
        var errors = 0
        for width in SIMDVectorWidth.allCases {
            let candidate: SIMD8<Double> =
                switch width {
                case .lanes2:
                    SIMD8<Double>(
                        lowHalf: SIMD4(lowHalf: eval2(v8.lowHalf.lowHalf), highHalf: eval2(v8.lowHalf.highHalf)),
                        highHalf: SIMD4(lowHalf: eval2(v8.highHalf.lowHalf), highHalf: eval2(v8.highHalf.highHalf))
                    )

                case .lanes4:
                    SIMD8<Double>(lowHalf: eval4(v8.lowHalf), highHalf: eval4(v8.highHalf))

                case .lanes8:
                    out8
                }
            for lane in 0..<lanes where !Self.bitIdenticalOrBothNaN(out8[lane], candidate[lane]) {
                errors += 1
            }
        }
        return errors
    }

    static func countBinaryCrossWidthErrors(
        va8: SIMD8<Double>,
        vb8: SIMD8<Double>,
        out8: SIMD8<Double>,
        lanes: Int,
        eval2: (SIMD2<Double>, SIMD2<Double>) -> SIMD2<Double>,
        eval4: (SIMD4<Double>, SIMD4<Double>) -> SIMD4<Double>
    ) -> Int {
        var errors = 0
        for width in SIMDVectorWidth.allCases {
            let candidate: SIMD8<Double> =
                switch width {
                case .lanes2:
                    SIMD8<Double>(
                        lowHalf: SIMD4(
                            lowHalf: eval2(va8.lowHalf.lowHalf, vb8.lowHalf.lowHalf),
                            highHalf: eval2(va8.lowHalf.highHalf, vb8.lowHalf.highHalf)),
                        highHalf: SIMD4(
                            lowHalf: eval2(va8.highHalf.lowHalf, vb8.highHalf.lowHalf),
                            highHalf: eval2(va8.highHalf.highHalf, vb8.highHalf.highHalf))
                    )

                case .lanes4:
                    SIMD8<Double>(
                        lowHalf: eval4(va8.lowHalf, vb8.lowHalf),
                        highHalf: eval4(va8.highHalf, vb8.highHalf)
                    )

                case .lanes8:
                    out8
                }
            for lane in 0..<lanes where !Self.bitIdenticalOrBothNaN(out8[lane], candidate[lane]) {
                errors += 1
            }
        }
        return errors
    }

    static func countTernaryCrossWidthErrors(
        vx8: SIMD8<Double>,
        vl8: SIMD8<Double>,
        vu8: SIMD8<Double>,
        out8: SIMD8<Double>,
        lanes: Int,
        eval2: (SIMD2<Double>, SIMD2<Double>, SIMD2<Double>) -> SIMD2<Double>,
        eval4: (SIMD4<Double>, SIMD4<Double>, SIMD4<Double>) -> SIMD4<Double>
    ) -> Int {
        var errors = 0
        for width in SIMDVectorWidth.allCases {
            let candidate: SIMD8<Double> =
                switch width {
                case .lanes2:
                    SIMD8<Double>(
                        lowHalf: SIMD4(
                            lowHalf: eval2(vx8.lowHalf.lowHalf, vl8.lowHalf.lowHalf, vu8.lowHalf.lowHalf),
                            highHalf: eval2(vx8.lowHalf.highHalf, vl8.lowHalf.highHalf, vu8.lowHalf.highHalf)),
                        highHalf: SIMD4(
                            lowHalf: eval2(vx8.highHalf.lowHalf, vl8.highHalf.lowHalf, vu8.highHalf.lowHalf),
                            highHalf: eval2(vx8.highHalf.highHalf, vl8.highHalf.highHalf, vu8.highHalf.highHalf))
                    )

                case .lanes4:
                    SIMD8<Double>(
                        lowHalf: eval4(vx8.lowHalf, vl8.lowHalf, vu8.lowHalf),
                        highHalf: eval4(vx8.highHalf, vl8.highHalf, vu8.highHalf)
                    )

                case .lanes8:
                    out8
                }
            for lane in 0..<lanes where !Self.bitIdenticalOrBothNaN(out8[lane], candidate[lane]) {
                errors += 1
            }
        }
        return errors
    }

    static func countDualCrossWidthErrors(
        v8: SIMD8<Double>,
        f8: SIMD8<Double>,
        s8: SIMD8<Double>,
        lanes: Int,
        eval2: (SIMD2<Double>) -> (first: SIMD2<Double>, second: SIMD2<Double>),
        eval4: (SIMD4<Double>) -> (first: SIMD4<Double>, second: SIMD4<Double>)
    ) -> Int {
        var errors = 0
        for width in SIMDVectorWidth.allCases {
            let candidate: (first: SIMD8<Double>, second: SIMD8<Double>) =
                switch width {
                case .lanes2:
                    Self.assembleDualFromLanes2(v8, eval2: eval2)

                case .lanes4:
                    Self.assembleDualFromLanes4(v8, eval4: eval4)

                case .lanes8:
                    (f8, s8)
                }
            for lane in 0..<lanes {
                let ok =
                    Self.bitIdenticalOrBothNaN(f8[lane], candidate.first[lane])
                    && Self.bitIdenticalOrBothNaN(s8[lane], candidate.second[lane])
                if !ok { errors += 1 }
            }
        }
        return errors
    }

    private static func assembleDualFromLanes2(
        _ v8: SIMD8<Double>,
        eval2: (SIMD2<Double>) -> (first: SIMD2<Double>, second: SIMD2<Double>)
    ) -> (first: SIMD8<Double>, second: SIMD8<Double>) {
        let ll = eval2(v8.lowHalf.lowHalf)
        let lh = eval2(v8.lowHalf.highHalf)
        let hl = eval2(v8.highHalf.lowHalf)
        let hh = eval2(v8.highHalf.highHalf)
        return (
            SIMD8(
                lowHalf: SIMD4(lowHalf: ll.first, highHalf: lh.first),
                highHalf: SIMD4(lowHalf: hl.first, highHalf: hh.first)),
            SIMD8(
                lowHalf: SIMD4(lowHalf: ll.second, highHalf: lh.second),
                highHalf: SIMD4(lowHalf: hl.second, highHalf: hh.second))
        )
    }

    private static func assembleDualFromLanes4(
        _ v8: SIMD8<Double>,
        eval4: (SIMD4<Double>) -> (first: SIMD4<Double>, second: SIMD4<Double>)
    ) -> (first: SIMD8<Double>, second: SIMD8<Double>) {
        let lo = eval4(v8.lowHalf)
        let hi = eval4(v8.highHalf)
        return (SIMD8(lowHalf: lo.first, highHalf: hi.first), SIMD8(lowHalf: lo.second, highHalf: hi.second))
    }
}
