// MARK: - MPFR-Certified Exact Bit-Pattern Golden Vector Types & IEEE-754 ULP Comparison

/// A single unary mathematical test vector certified against GNU MPFR (exact IEEE-754 Binary64 bit patterns).
public struct UnaryGoldenVector: Sendable {
    public let inputBits: UInt64
    public let expectedBits: UInt64
    public let maxULP: UInt64
    public let label: String

    public init(inputBits: UInt64, expectedBits: UInt64, maxULP: UInt64, label: String) {
        self.inputBits = inputBits
        self.expectedBits = expectedBits
        self.maxULP = maxULP
        self.label = label
    }

    public var input: Double { Double(bitPattern: inputBits) }
    public var expected: Double { Double(bitPattern: expectedBits) }
}

/// A single binary mathematical test vector certified against GNU MPFR (exact IEEE-754 Binary64 bit patterns).
public struct BinaryGoldenVector: Sendable {
    public let firstInputBits: UInt64
    public let secondInputBits: UInt64
    public let expectedBits: UInt64
    public let maxULP: UInt64
    public let label: String

    public init(
        firstInputBits: UInt64,
        secondInputBits: UInt64,
        expectedBits: UInt64,
        maxULP: UInt64,
        label: String
    ) {
        self.firstInputBits = firstInputBits
        self.secondInputBits = secondInputBits
        self.expectedBits = expectedBits
        self.maxULP = maxULP
        self.label = label
    }

    public var firstInput: Double { Double(bitPattern: firstInputBits) }
    public var secondInput: Double { Double(bitPattern: secondInputBits) }
    public var expected: Double { Double(bitPattern: expectedBits) }
}

/// A single ternary mathematical test vector certified against exact IEEE-754 Binary64 bit patterns.
public struct TernaryGoldenVector: Sendable {
    public let firstInputBits: UInt64
    public let secondInputBits: UInt64
    public let thirdInputBits: UInt64
    public let expectedBits: UInt64
    public let maxULP: UInt64
    public let label: String

    public init(
        firstInputBits: UInt64,
        secondInputBits: UInt64,
        thirdInputBits: UInt64,
        expectedBits: UInt64,
        maxULP: UInt64,
        label: String
    ) {
        self.firstInputBits = firstInputBits
        self.secondInputBits = secondInputBits
        self.thirdInputBits = thirdInputBits
        self.expectedBits = expectedBits
        self.maxULP = maxULP
        self.label = label
    }

    public var firstInput: Double { Double(bitPattern: firstInputBits) }
    public var secondInput: Double { Double(bitPattern: secondInputBits) }
    public var thirdInput: Double { Double(bitPattern: thirdInputBits) }
    public var expected: Double { Double(bitPattern: expectedBits) }
}

/// A single dual-output unary test vector certified against GNU MPFR.
public struct DualUnaryGoldenVector: Sendable {
    public let inputBits: UInt64
    public let expectedFirstBits: UInt64
    public let expectedSecondBits: UInt64
    public let maxULP: UInt64
    public let label: String

    public init(
        inputBits: UInt64,
        expectedFirstBits: UInt64,
        expectedSecondBits: UInt64,
        maxULP: UInt64,
        label: String
    ) {
        self.inputBits = inputBits
        self.expectedFirstBits = expectedFirstBits
        self.expectedSecondBits = expectedSecondBits
        self.maxULP = maxULP
        self.label = label
    }

    public var input: Double { Double(bitPattern: inputBits) }
    public var expectedFirst: Double { Double(bitPattern: expectedFirstBits) }
    public var expectedSecond: Double { Double(bitPattern: expectedSecondBits) }
}

/// Exact IEEE-754 Binary64 ULP distance between two finite `Double` values.
public func ieee754ULPDistance(_ lhs: Double, _ rhs: Double) -> UInt64 {
    if lhs == rhs {
        return 0
    }
    let lhsBits = lhs.bitPattern
    let rhsBits = rhs.bitPattern
    if (lhsBits >> 63) != (rhsBits >> 63) {
        return (lhsBits & 0x7FFF_FFFF_FFFF_FFFF) &+ (rhsBits & 0x7FFF_FFFF_FFFF_FFFF)
    }
    return lhsBits > rhsBits ? lhsBits - rhsBits : rhsBits - lhsBits
}

/// Verifies an actual `Double` against an exact MPFR-certified IEEE-754 Binary64 reference bit pattern.
public func ieee754MatchesReference(_ actual: Double, expectedBits: UInt64, maxULP: UInt64) -> Bool {
    let expected = Double(bitPattern: expectedBits)
    if expected.isNaN {
        return actual.isNaN
    }
    if expected.isInfinite {
        return actual.isInfinite && actual.sign == expected.sign
    }
    if !actual.isFinite {
        return false
    }
    if expected == 0.0, actual == 0.0 {
        return actual.sign == expected.sign
    }
    return ieee754ULPDistance(actual, expected) <= maxULP
}
