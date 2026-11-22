// MARK: - Lock-Free Top-K Distinct-Regime Worst-ULP Tracker for Multi-Million MPFR Sweeps

/// Tracks up to `capacity` distinct IEEE-754 exponent/sign regimes with the highest observed ULP error.
/// Uses a fast `minThreshold` guard so >99% of low-ULP samples exit in a single branch with zero allocations.
struct MPFRRegimeWorstTracker: Sendable {
    struct Entry: Sendable {
        let regimeKey: Int
        let ulp: UInt64
        let b0: UInt64
        let b1: UInt64
        let b2: UInt64
    }

    static let defaultCapacity = 8

    let capacity: Int
    let arity: Int
    private(set) var entries: [Entry] = []
    private(set) var minThreshold: UInt64 = 0

    init(capacity: Int = Self.defaultCapacity, arity: Int) {
        self.capacity = Swift.max(1, capacity)
        self.arity = arity
        entries.reserveCapacity(self.capacity)
    }

    @inline(__always)
    static func unaryRegimeKey(_ bits: UInt64) -> Int {
        let sign = Int(bits >> 63)
        let exp = Int((bits >> 52) & 0x7FF)
        return (sign << 9) | (exp >> 2)
    }

    @inline(__always)
    static func binaryRegimeKey(_ aBits: UInt64, _ bBits: UInt64) -> Int {
        let ka = (Int(aBits >> 63) << 7) | Int(((aBits >> 52) & 0x7FF) >> 4)
        let kb = (Int(bBits >> 63) << 7) | Int(((bBits >> 52) & 0x7FF) >> 4)
        return (ka << 8) | kb
    }

    @inline(__always)
    static func ternaryRegimeKey(_ aBits: UInt64, _ bBits: UInt64, _ cBits: UInt64) -> Int {
        let ka = (Int(aBits >> 63) << 6) | Int(((aBits >> 52) & 0x7FF) >> 5)
        let kb = (Int(bBits >> 63) << 6) | Int(((bBits >> 52) & 0x7FF) >> 5)
        let kc = (Int(cBits >> 63) << 6) | Int(((cBits >> 52) & 0x7FF) >> 5)
        return (ka << 14) | (kb << 7) | kc
    }

    @inline(__always)
    mutating func record(ulp: UInt64, regimeKey: Int, b0: UInt64, b1: UInt64 = 0, b2: UInt64 = 0) {
        if ulp < minThreshold { return }
        for idx in entries.indices where entries[idx].regimeKey == regimeKey {
            if ulp > entries[idx].ulp {
                entries[idx] = Entry(regimeKey: regimeKey, ulp: ulp, b0: b0, b1: b1, b2: b2)
                recomputeMinThreshold()
            }
            return
        }
        if entries.count < capacity {
            entries.append(Entry(regimeKey: regimeKey, ulp: ulp, b0: b0, b1: b1, b2: b2))
            recomputeMinThreshold()
            return
        }
        var minIdx = 0
        for idx in 1..<entries.count where entries[idx].ulp < entries[minIdx].ulp {
            minIdx = idx
        }
        if ulp > entries[minIdx].ulp {
            entries[minIdx] = Entry(regimeKey: regimeKey, ulp: ulp, b0: b0, b1: b1, b2: b2)
            recomputeMinThreshold()
        }
    }

    func topBitPatterns(includingPrimary primary: [UInt64]) -> [[UInt64]] {
        let sorted = entries.sorted { lhs, rhs in
            if lhs.ulp != rhs.ulp { return lhs.ulp > rhs.ulp }
            return lhs.regimeKey < rhs.regimeKey
        }
        var out: [[UInt64]] = []
        out.reserveCapacity(capacity)
        if primary.count == arity {
            out.append(primary)
        }
        for entry in sorted {
            let bits = bitTuple(for: entry)
            if !out.contains(bits) {
                out.append(bits)
                if out.count >= capacity { break }
            }
        }
        return out
    }

    private func bitTuple(for entry: Entry) -> [UInt64] {
        switch arity {
        case 1: [entry.b0]
        case 2: [entry.b0, entry.b1]
        case 3: [entry.b0, entry.b1, entry.b2]
        default: [entry.b0]
        }
    }

    private mutating func recomputeMinThreshold() {
        guard entries.count >= capacity else {
            minThreshold = 0
            return
        }
        var smallest = entries[0].ulp
        for idx in 1..<entries.count where entries[idx].ulp < smallest {
            smallest = entries[idx].ulp
        }
        minThreshold = smallest == UInt64.max ? UInt64.max : smallest &+ 1
    }
}
