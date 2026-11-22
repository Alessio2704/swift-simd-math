import Foundation

// MARK: - Domain-Aware Stratified IEEE-754 Samplers for MPFR Audits

enum MPFRDomainSamplers: Sendable {
    /// Kahan's hardest Binary64 near-multiples of `pi/2` plus extreme magnitudes up to `greatestFiniteMagnitude`.
    static let trigCriticalAnchors: [Double] = [
        -Double.greatestFiniteMagnitude, -1.0e200, -1.0e100, -1.0e22,
        -Double(sign: .plus, exponent: 797, significand: 6_381_956_970_095_103.0),
        -524_288.0.nextUp, -524_288.0, -524_288.0.nextDown,
        -Double.pi * 2.0, -Double.pi, -Double.pi * 0.5, -Double.pi * 0.25,
        -Double.leastNonzeroMagnitude, -0.0, 0.0, Double.leastNonzeroMagnitude,
        Double.pi * 0.25, Double.pi * 0.5, Double.pi, Double.pi * 2.0,
        524_288.0.nextDown, 524_288.0, 524_288.0.nextUp,
        Double(bitPattern: 0x4164_5525_B1B6_F85C),
        7.43570781478630000e+13, 2.14112296674652000e+14,
        5.92078722874239300e+15, 6.13489952541704500e+15,
        Double(bitPattern: 0x43CE_3957_08F0_5C22),
        5.319372648326541e+255,
        Double(sign: .plus, exponent: 797, significand: 6_381_956_970_095_103.0),
        1.0e22, 1.0e100, 1.0e200, 1.0e300, Double.greatestFiniteMagnitude
    ]

    static let piTrigCriticalAnchors: [Double] = [
        -Double.greatestFiniteMagnitude, -0x1.0p53, -0x1.0p52 - 1.0, -0x1.0p52,
        -0x1.0p52 + 0.5, -2.5, -1.5, -1.0, -0.5, -0.25, -Double.leastNonzeroMagnitude,
        -0.0, 0.0, Double.leastNonzeroMagnitude, 0.25, 0.5, 1.0, 1.5, 2.5,
        0x1.0p50.nextDown, 0x1.0p50, 0x1.0p52 - 0.5, 0x1.0p52, 0x1.0p52 + 1.0,
        0x1.0p53, Double.greatestFiniteMagnitude
    ]

    static func denseULPWindow(around center: Double, radius: Int = 16) -> [Double] {
        guard center.isFinite else { return [center] }
        var values: [Double] = [center]
        values.reserveCapacity(radius * 2 + 1)
        var up = center
        var down = center
        for _ in 0..<radius {
            up = up.nextUp
            down = down.nextDown
            if up.isFinite { values.append(up) }
            if down.isFinite { values.append(down) }
        }
        return values
    }

    static func stratifiedExponents(
        seed: UInt64,
        count: Int,
        minExp: Int,
        maxExp: Int,
        signed: Bool,
        anchors: [Double]
    ) -> [Double] {
        var samples: [Double] = []
        samples.reserveCapacity(count + anchors.count * 17)
        for anchor in anchors {
            let window = Self.denseULPWindow(around: anchor, radius: 8)
            if signed {
                samples.append(contentsOf: window)
            } else {
                samples.append(contentsOf: window.filter { $0 >= 0.0 })
            }
        }
        var rng = DeterministicSplitMix64(seed: seed)
        // Stratified sweep across all exponents in [minExp, maxExp]
        let expSpan = maxExp - minExp + 1
        let perExp = Swift.max(1, count / Swift.max(1, expSpan * 2))
        for exp in minExp...maxExp {
            for _ in 0..<perExp {
                let val = Double(sign: .plus, exponent: exp, significand: 1.0 + rng.nextUnitDouble())
                samples.append(val)
                if signed { samples.append(-val) }
            }
        }
        while samples.count < count {
            samples.append(rng.nextExponentDouble(minExp: minExp, maxExp: maxExp, signed: signed))
        }
        return samples
    }

    static func uniformInterval(
        seed: UInt64,
        count: Int,
        low: Double,
        high: Double,
        anchors: [Double]
    ) -> [Double] {
        var samples: [Double] = []
        samples.reserveCapacity(count + anchors.count * 17)
        for anchor in anchors {
            samples.append(contentsOf: Self.denseULPWindow(around: anchor, radius: 8))
        }
        var rng = DeterministicSplitMix64(seed: seed)
        let span = high - low
        while samples.count < count {
            samples.append(low + rng.nextUnitDouble() * span)
        }
        return samples
    }

    static func unitIntervalAndEdges(seed: UInt64, count: Int, includeEndpoints: Bool, anchors: [Double]) -> [Double] {
        var samples: [Double] = []
        samples.reserveCapacity(count + anchors.count * 17)
        for anchor in anchors {
            for val in Self.denseULPWindow(around: anchor, radius: 12) {
                let inRange = includeEndpoints ? Swift.abs(val) <= 1.0 : Swift.abs(val) < 1.0
                if inRange { samples.append(val) }
            }
        }
        var rng = DeterministicSplitMix64(seed: seed)
        let half = count / 2
        for _ in 0..<half {
            let val = rng.nextSignedUnitDouble()
            if includeEndpoints || Swift.abs(val) < 1.0 { samples.append(val) }
        }
        while samples.count < count {
            // Focus densely near 0 and near ±1 where inverse trig/hyperbolic derivatives diverge
            let delta = rng.nextExponentDouble(minExp: -52, maxExp: -1, signed: false)
            let val = (rng.nextUInt64() & 1) == 0 ? delta : (1.0 - delta)
            let signedVal = (rng.nextUInt64() & 2) == 0 ? val : -val
            if includeEndpoints ? Swift.abs(signedVal) <= 1.0 : Swift.abs(signedVal) < 1.0 {
                samples.append(signedVal)
            }
        }
        return samples
    }

    static func acoshSamples(seed: UInt64, count: Int, anchors: [Double]) -> [Double] {
        var samples: [Double] = []
        samples.reserveCapacity(count + anchors.count * 17)
        for anchor in anchors {
            for val in Self.denseULPWindow(around: anchor, radius: 12) where val >= 1.0 {
                samples.append(val)
            }
        }
        var rng = DeterministicSplitMix64(seed: seed)
        let nearOne = count / 3
        for _ in 0..<nearOne {
            samples.append(1.0 + rng.nextExponentDouble(minExp: -52, maxExp: 4, signed: false))
        }
        while samples.count < count {
            samples.append(rng.nextExponentDouble(minExp: 0, maxExp: 1023, signed: false))
        }
        return samples
    }

    static func gammaSamples(seed: UInt64, count: Int, minX: Double, maxX: Double, anchors: [Double]) -> [Double] {
        var samples: [Double] = []
        samples.reserveCapacity(count + anchors.count * 17)
        for anchor in anchors {
            for val in Self.denseULPWindow(around: anchor, radius: 8) {
                if val > 0.0 || val != val.rounded(.down) { samples.append(val) }
            }
        }
        var rng = DeterministicSplitMix64(seed: seed)
        let negCount = count / 4
        for _ in 0..<negCount {
            let candidate = minX + rng.nextUnitDouble() * (-minX)
            if candidate != candidate.rounded(.down) { samples.append(candidate) }
        }
        while samples.count < count {
            if (rng.nextUInt64() & 3) == 0 {
                samples.append(rng.nextExponentDouble(minExp: -40, maxExp: 7, signed: false))
            } else {
                samples.append(rng.nextUnitDouble() * maxX)
            }
        }
        return samples
    }
}
