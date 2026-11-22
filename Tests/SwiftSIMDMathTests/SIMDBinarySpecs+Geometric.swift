import Foundation
import SwiftSIMDMathTestSupport

// MARK: - Geometric & Threshold Binary Grounding Specs (atan2, hypot, step)

extension SIMDBinaryOperation {
    static let atan2Spec = BinaryTestSpec(
        maxULP: 2,
        homogeneousPairs: [
            BinaryInput(a: 1.0, b: 1.0), BinaryInput(a: -1.0, b: 1.0), BinaryInput(a: 1.0, b: -1.0),
            BinaryInput(a: -1.0, b: -1.0), BinaryInput(a: 0.25, b: 3.0), BinaryInput(a: 3.0, b: -0.25)
        ],
        heterogeneousPairs: [
            [
                BinaryInput(a: 0.2, b: 1.0), BinaryInput(a: 0.8, b: 1.0),
                BinaryInput(a: 1.0, b: 0.8), BinaryInput(a: 1.0, b: 0.2),
                BinaryInput(a: -1.0, b: -0.2), BinaryInput(a: -0.8, b: -1.0),
                BinaryInput(a: 0.0, b: -0.0), BinaryInput(a: -0.0, b: -0.0)
            ],
            [
                BinaryInput(a: .infinity, b: .infinity), BinaryInput(a: -.infinity, b: -.infinity),
                BinaryInput(a: .infinity, b: -1.0), BinaryInput(a: -1.0, b: -.infinity),
                BinaryInput(a: .nan, b: 1.0), BinaryInput(a: 1.0, b: .nan),
                BinaryInput(a: Double.greatestFiniteMagnitude, b: Double.greatestFiniteMagnitude),
                BinaryInput(a: Double.leastNonzeroMagnitude, b: -Double.leastNonzeroMagnitude)
            ]
        ],
        stabilityTransitions: [
            BinaryInput(a: 0.414213562373095, b: 1.0), BinaryInput(a: 0.4142135623730951, b: 1.0),
            BinaryInput(a: 1.0, b: 0.414213562373095),
            BinaryInput(a: Double.greatestFiniteMagnitude, b: Double.greatestFiniteMagnitude),
            BinaryInput(a: Double.greatestFiniteMagnitude, b: -Double.greatestFiniteMagnitude),
            BinaryInput(a: Double.leastNonzeroMagnitude, b: Double.leastNonzeroMagnitude),
            BinaryInput(a: 1.0e-300, b: 1.0e300), BinaryInput(a: 1.0e300, b: -1.0e-300)
        ]
    ) { Foundation.atan2($0, $1) }

    static let hypotSpec = BinaryTestSpec(
        maxULP: 1,
        homogeneousPairs: [
            BinaryInput(a: 3.0, b: 4.0), BinaryInput(a: -5.0, b: 12.0), BinaryInput(a: 0.0, b: 0.0),
            BinaryInput(a: -0.0, b: -0.0), BinaryInput(a: 1.0e200, b: 1.0e200), BinaryInput(a: 1.0e-200, b: 1.0e-200)
        ],
        heterogeneousPairs: [
            [
                BinaryInput(a: 3.0, b: 4.0), BinaryInput(a: 1.0e308, b: 1.0e308),
                BinaryInput(a: Double.leastNonzeroMagnitude, b: Double.leastNonzeroMagnitude),
                BinaryInput(a: .infinity, b: .nan), BinaryInput(a: -.infinity, b: .nan),
                BinaryInput(a: .nan, b: .infinity), BinaryInput(a: .nan, b: 1.0),
                BinaryInput(a: -0.0, b: 0.0)
            ]
        ],
        stabilityTransitions: [
            BinaryInput(a: 0x1.0p500.nextDown, b: 0x1.0p500.nextDown),
            BinaryInput(a: 0x1.0p500, b: 0x1.0p500),
            BinaryInput(a: 0x1.0p-450.nextDown, b: 0x1.0p-450.nextDown),
            BinaryInput(a: 0x1.0p-450, b: 0x1.0p-450),
            BinaryInput(a: 1.0e308, b: 1.0e308),
            BinaryInput(a: Double.greatestFiniteMagnitude, b: Double.greatestFiniteMagnitude),
            BinaryInput(a: Double.leastNonzeroMagnitude, b: Double.leastNonzeroMagnitude),
            BinaryInput(a: 1.0, b: Double.leastNonzeroMagnitude)
        ]
    ) { Foundation.hypot($0, $1) }

    static let stepSpec = BinaryTestSpec(
        maxULP: 0,
        homogeneousPairs: [
            BinaryInput(a: -1.0, b: 0.0), BinaryInput(a: 0.0, b: 0.0),
            BinaryInput(a: -0.0, b: 0.0), BinaryInput(a: 1.0, b: 0.0)
        ],
        heterogeneousPairs: [
            [
                BinaryInput(a: -2.0, b: 0.0), BinaryInput(a: 0.0, b: 0.0),
                BinaryInput(a: 2.0, b: 0.0), BinaryInput(a: -0.0, b: 0.0),
                BinaryInput(a: .nan, b: 0.0), BinaryInput(a: 0.0, b: .nan),
                BinaryInput(a: -.infinity, b: -.infinity), BinaryInput(a: .infinity, b: .infinity)
            ]
        ],
        stabilityTransitions: [
            BinaryInput(a: 1.0.nextDown, b: 1.0), BinaryInput(a: 1.0, b: 1.0), BinaryInput(a: 1.0.nextUp, b: 1.0),
            BinaryInput(a: -Double.leastNonzeroMagnitude, b: 0.0), BinaryInput(a: Double.leastNonzeroMagnitude, b: 0.0)
        ]
    ) { x, edge in x < edge ? 0.0 : 1.0 }
}
