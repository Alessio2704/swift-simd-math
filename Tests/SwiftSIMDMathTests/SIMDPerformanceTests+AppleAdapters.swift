#if canImport(simd)
    import simd

    extension SIMDPerformanceTests {
        @inline(__always)
        static func appleAbs(_ v: SIMD8<Double>) -> SIMD8<Double> {
            SIMD8(lowHalf: simd.abs(v.lowHalf), highHalf: simd.abs(v.highHalf))
        }

        @inline(__always)
        static func appleSign(_ v: SIMD8<Double>) -> SIMD8<Double> {
            SIMD8(lowHalf: simd.sign(v.lowHalf), highHalf: simd.sign(v.highHalf))
        }

        @inline(__always)
        static func appleFract(_ v: SIMD8<Double>) -> SIMD8<Double> {
            SIMD8(lowHalf: simd.fract(v.lowHalf), highHalf: simd.fract(v.highHalf))
        }

        @inline(__always)
        static func appleMin(_ a: SIMD8<Double>, _ b: SIMD8<Double>) -> SIMD8<Double> {
            SIMD8(lowHalf: simd.min(a.lowHalf, b.lowHalf), highHalf: simd.min(a.highHalf, b.highHalf))
        }

        @inline(__always)
        static func appleMax(_ a: SIMD8<Double>, _ b: SIMD8<Double>) -> SIMD8<Double> {
            SIMD8(lowHalf: simd.max(a.lowHalf, b.lowHalf), highHalf: simd.max(a.highHalf, b.highHalf))
        }

        @inline(__always)
        static func appleStep(_ x: SIMD8<Double>, edge: SIMD8<Double>) -> SIMD8<Double> {
            SIMD8(
                lowHalf: simd.step(x.lowHalf, edge: edge.lowHalf),
                highHalf: simd.step(x.highHalf, edge: edge.highHalf)
            )
        }

        @inline(__always)
        static func appleClamp(_ x: SIMD8<Double>, lo: SIMD8<Double>, hi: SIMD8<Double>) -> SIMD8<Double> {
            SIMD8(
                lowHalf: simd.clamp(x.lowHalf, min: lo.lowHalf, max: hi.lowHalf),
                highHalf: simd.clamp(x.highHalf, min: lo.highHalf, max: hi.highHalf)
            )
        }

        @inline(__always)
        static func appleMix(_ a: SIMD8<Double>, _ b: SIMD8<Double>, t: SIMD8<Double>) -> SIMD8<Double> {
            SIMD8(
                lowHalf: simd.mix(a.lowHalf, b.lowHalf, t: t.lowHalf),
                highHalf: simd.mix(a.highHalf, b.highHalf, t: t.highHalf)
            )
        }

        @inline(__always)
        static func appleSmoothstep(
            _ x: SIMD8<Double>,
            edge0: SIMD8<Double>,
            edge1: SIMD8<Double>
        ) -> SIMD8<Double> {
            SIMD8(
                lowHalf: simd.smoothstep(x.lowHalf, edge0: edge0.lowHalf, edge1: edge1.lowHalf),
                highHalf: simd.smoothstep(x.highHalf, edge0: edge0.highHalf, edge1: edge1.highHalf)
            )
        }
    }
#endif
