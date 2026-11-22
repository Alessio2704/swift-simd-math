#!/usr/bin/env bash
set -euo pipefail

REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
OS="$(uname -s)"

echo "=== swift-simd-math Developer Environment Setup ==="

# 1. Configure repository git hooks
if git -C "$REPO_ROOT" rev-parse --is-inside-work-tree >/dev/null 2>&1; then
    git -C "$REPO_ROOT" config core.hooksPath .githooks
    chmod +x "$REPO_ROOT/.githooks/pre-commit" "$REPO_ROOT/.githooks/pre-push"
    echo "✓ Configured git core.hooksPath = .githooks"
fi

# 2. Install missing optional audit & verification dependencies (GMP, MPFR, SwiftLint, Periphery)
install_macos() {
    if ! command -v brew >/dev/null 2>&1; then
        echo "error: Homebrew is required on macOS to install missing packages." >&2
        echo "Install Homebrew from https://brew.sh and re-run ./setup.sh" >&2
        exit 1
    fi

    local missing=()
    command -v pkg-config >/dev/null 2>&1 || missing+=("pkg-config")
    if ! (command -v pkg-config >/dev/null 2>&1 && pkg-config --exists gmp); then
        brew list --formula gmp >/dev/null 2>&1 || missing+=("gmp")
    fi
    if ! (command -v pkg-config >/dev/null 2>&1 && pkg-config --exists mpfr); then
        brew list --formula mpfr >/dev/null 2>&1 || missing+=("mpfr")
    fi
    command -v swiftlint >/dev/null 2>&1 || missing+=("swiftlint")
    command -v periphery >/dev/null 2>&1 || missing+=("periphery")

    if [ "${#missing[@]}" -eq 0 ]; then
        echo "✓ All macOS dependencies already installed (pkg-config, gmp, mpfr, swiftlint, periphery)"
    else
        echo "Installing missing Homebrew packages: ${missing[*]}"
        brew install "${missing[@]}"
    fi
}

install_linux() {
    if command -v pkg-config >/dev/null 2>&1 && pkg-config --exists mpfr gmp; then
        echo "✓ System GMP and MPFR development libraries already installed"
    else
        local sudo_cmd=""
        if [ "${EUID:-$(id -u)}" -ne 0 ] && command -v sudo >/dev/null 2>&1; then
            sudo_cmd="sudo"
        fi

        if command -v apt-get >/dev/null 2>&1; then
            echo "Installing pkg-config, libgmp-dev, and libmpfr-dev via apt-get..."
            $sudo_cmd apt-get update -y
            $sudo_cmd apt-get install -y pkg-config libgmp-dev libmpfr-dev
        elif command -v dnf >/dev/null 2>&1; then
            echo "Installing pkgconf-pkg-config, gmp-devel, and mpfr-devel via dnf..."
            $sudo_cmd dnf install -y pkgconf-pkg-config gmp-devel mpfr-devel
        elif command -v yum >/dev/null 2>&1; then
            echo "Installing pkgconfig, gmp-devel, and mpfr-devel via yum..."
            $sudo_cmd yum install -y pkgconfig gmp-devel mpfr-devel
        else
            echo "error: Unsupported Linux package manager. Please install pkg-config, GMP, and MPFR dev packages manually." >&2
            exit 1
        fi
    fi

    if ! command -v swiftlint >/dev/null 2>&1; then
        echo "note: swiftlint not found (optional on Linux; pre-commit skips it when absent)"
    fi
    if ! command -v periphery >/dev/null 2>&1; then
        echo "note: periphery not found (optional on Linux; pre-commit skips it when absent)"
    fi
}

case "$OS" in
    Darwin) install_macos ;;
    Linux) install_linux ;;
    *)
        echo "error: Unsupported OS '$OS'. Install pkg-config, GMP, and MPFR manually." >&2
        exit 1
        ;;
esac

# 3. Verify toolchain & native library visibility
echo ""
echo "--- Verification Summary ---"
if command -v swift >/dev/null 2>&1; then
    echo "✓ Swift:      $(swift --version 2>&1 | head -n 1)"
else
    echo "✗ Swift:      not found on PATH" >&2
    exit 1
fi

if command -v pkg-config >/dev/null 2>&1 && pkg-config --exists mpfr gmp; then
    echo "✓ GMP:        $(pkg-config --modversion gmp)"
    echo "✓ MPFR:       $(pkg-config --modversion mpfr)"
else
    echo "✗ GMP/MPFR:   pkg-config could not locate mpfr/gmp" >&2
    exit 1
fi

if command -v swiftlint >/dev/null 2>&1; then
    echo "✓ SwiftLint:  $(swiftlint version)"
fi
if command -v periphery >/dev/null 2>&1; then
    echo "✓ Periphery:  $(periphery version)"
fi

echo ""
echo "Setup complete. Run 'swift test -c release' or 'swift run -c release --package-path Tools/MPFRAudit MPFRAudit --quick'."
