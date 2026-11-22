# swift-simd-math

Zero-dependency, pure-Swift vectorized double-precision (`SIMD2<Double>`, `SIMD4<Double>`, `SIMD8<Double>`) math library (`SwiftSIMDMath`) verified against GNU MPFR.

## Features

- **Zero external dependencies & cross-platform** — pure Swift Standard Library (`Swift 6.0+`) in `SwiftSIMDMath` and `SwiftSIMDMathTests`, supporting macOS, iOS, tvOS, watchOS, visionOS, Linux, and Windows.
- **42 operations across 4 categories** (126 public vector entrypoints across `SIMD2<Double>`, `SIMD4<Double>`, and `SIMD8<Double>`):
  - **Unary (31):** `exp`, `exp2`, `exp10`, `expm1`, `log`, `log2`, `log10`, `log1p`, `sin`, `cos`, `tan`, `asin`, `acos`, `atan`, `sinpi`, `cospi`, `tanpi`, `abs`, `cbrt`, `sign`, `fract`, `sinh`, `cosh`, `tanh`, `asinh`, `acosh`, `atanh`, `erf`, `erfc`, `tgamma`, `lgamma`
  - **Binary (6):** `pow`, `atan2`, `hypot`, `min`, `max`, `step`
  - **Ternary (3):** `clamp`, `mix`, `smoothstep`
  - **Dual-Unary (2):** `sincos`, `sincospi`
- **Strict IEEE-754 semantics** across signed zeros, subnormals, infinities, quiet/signaling NaNs, and bit-identical lane behavior across `SIMD2`, `SIMD4`, and `SIMD8`.
- **Standalone GNU MPFR certification tool** (`Tools/MPFRAudit`) kept in an isolated Swift package so consumers never need `mpfr`/`gmp` installed.

## Usage

Add `swift-simd-math` to your `Package.swift`:

```swift
dependencies: [
    .package(url: "https://github.com/Alessio2704/swift-simd-math.git", from: "1.0.0")
]
```

And depend on the `SwiftSIMDMath` product:

```swift
import SwiftSIMDMath

let x = SIMD8<Double>(0.1, 0.2, 0.3, 0.4, 0.5, 0.6, 0.7, 0.8)
let y = SIMDMath.exp(x)
let (s, c) = SIMDMath.sincos(x)
```

## Verification & Testing

### Zero-Dependency Test Suite

```bash
swift test -c release
```

Includes:
- **Catalog Coverage Guard:** Verifies every `public` operation in `Sources/SwiftSIMDMath` is registered across all exhaustive enums and exposes every `SIMDVectorWidth` (`SIMD2`, `SIMD4`, `SIMD8`).
- **Grounding & Identities:** Dense domain sweeps, subnormals, large-range Payne–Hanek reduction, and mathematical identities across all widths.
- **Adversarial IEEE-754 Matrix:** All 10 IEEE-754 classes, cross-lane poison isolation, singularities, and bit-exact cross-width parity.
- **MPFR Golden Corpus Regression:** Replays GNU MPFR-certified exact 64-bit reference vectors (every op's curated domain anchors plus up to 8 distinct-regime worst-ULP inputs discovered during exhaustive certification) without requiring MPFR at test time.
- **Throughput Benchmarks:** `SIMD8<Double>` performance parity checks against Apple `simd` / `libm`.
- **Test-Harness Self-Tests:** Unit tests for the IEEE-754 matchers, source catalog parser, and metadata catalogs.

### Developer Setup (`setup.sh`)

Consuming `SwiftSIMDMath` via SwiftPM requires **zero** setup or system libraries. For contributors developing or running the full MPFR audit and lint hooks locally, run:

```bash
./setup.sh
```

This configures `git config core.hooksPath .githooks` and installs any missing developer tools (`pkg-config`, `gmp`, `mpfr`, plus `swiftlint` and `periphery` on macOS).

### Optional GNU MPFR Certification Tool (`Tools/MPFRAudit`)

After running `./setup.sh` (or installing `gmp`, `mpfr`, and `pkg-config` manually):

```bash
# Run MPFR tool unit tests
swift test -c release --package-path Tools/MPFRAudit

# Quick certification (10,000 samples/op, ~0.5 s — also run by pre-push hook)
swift run -c release --package-path Tools/MPFRAudit MPFRAudit --quick

# Full certification (100,000 samples/op, ~4.7 s)
swift run -c release --package-path Tools/MPFRAudit MPFRAudit

# Deep certification (1,000,000 samples/op = 42M+ evals, ~48 s)
swift run -c release --package-path Tools/MPFRAudit MPFRAudit --deep

# Exhaustive certification (10,000,000 samples/op = 422M+ evals, ~8 min) + regenerate golden corpus
swift run -c release --package-path Tools/MPFRAudit MPFRAudit \
  --exhaustive --emit-golden Tests/SwiftSIMDMathTests

# Custom sample budget
swift run -c release --package-path Tools/MPFRAudit MPFRAudit --samples 500000
```

Passing `--emit-golden Tests/SwiftSIMDMathTests` writes every operation's curated `goldenAnchors` plus up to 8 distinct-regime worst-ULP inputs discovered during the sweep as exact 64-bit IEEE-754 hex bit patterns, automatically partitioning generated files to stay within strict lint limits and cleaning stale slices.

## License

Released under the [MIT License](LICENSE).
