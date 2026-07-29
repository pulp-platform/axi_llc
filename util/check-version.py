#!/usr/bin/env python3
# Copyright 2026 ETH Zurich and University of Bologna.
# Solderpad Hardware License, Version 0.51, see LICENSE for details.
# SPDX-License-Identifier: SHL-0.51

"""Check that all AXI LLC version declarations agree."""

import argparse
import re
import sys
from pathlib import Path


SEMVER_PATTERN = re.compile(r"(0|[1-9]\d*)\.(0|[1-9]\d*)\.(0|[1-9]\d*)")
CHANGELOG_PATTERN = re.compile(r"^##\s+(\S+)\s+-\s+\d{4}-\d{2}-\d{2}\s*$", re.MULTILINE)
RTL_VERSION_PATTERN = re.compile(
    r"parameter\s+logic\s+\[63:0\]\s+AxiLlcVersion\s*=\s*"
    r"64'h([0-9a-fA-F_]+)\s*;"
)


def read_text(path):
    """Read a UTF-8 text file."""
    return path.read_text(encoding="utf-8")


def read_release_version(root):
    """Read and validate the canonical semantic version."""
    version = read_text(root / "VERSION").strip()
    match = SEMVER_PATTERN.fullmatch(version)
    if not match:
        raise ValueError(f"VERSION does not contain a canonical semantic version: {version!r}")
    return version, tuple(int(component) for component in match.groups())


def read_changelog_version(root):
    """Read the most recent release version from the changelog."""
    match = CHANGELOG_PATTERN.search(read_text(root / "CHANGELOG.md"))
    if not match:
        raise ValueError("CHANGELOG.md has no dated release heading")
    return match.group(1)


def read_rtl_version(root):
    """Decode the hardware-visible ASCII version from the RTL package."""
    match = RTL_VERSION_PATTERN.search(read_text(root / "src" / "axi_llc_pkg.sv"))
    if not match:
        raise ValueError("src/axi_llc_pkg.sv has no AxiLlcVersion declaration")

    encoded_hex = match.group(1).replace("_", "")
    if len(encoded_hex) != 16:
        raise ValueError("AxiLlcVersion must contain exactly 64 bits")
    try:
        return bytes.fromhex(encoded_hex).decode("ascii")
    except (ValueError, UnicodeDecodeError) as error:
        raise ValueError("AxiLlcVersion is not valid ASCII") from error


def expected_rtl_version(version_components):
    """Encode SemVer as the eight-character hardware version string."""
    major, minor, patch = version_components
    if major > 99 or minor > 99 or patch > 9:
        raise ValueError(
            "VERSION cannot be encoded as vAA.BB.C: "
            "major/minor must be <= 99 and patch must be <= 9"
        )
    return f"v{major:02d}.{minor:02d}.{patch}"


def check_versions(root):
    """Check VERSION, CHANGELOG.md, and axi_llc_pkg.sv for agreement."""
    version, components = read_release_version(root)
    changelog_version = read_changelog_version(root)
    rtl_version = read_rtl_version(root)
    expected_rtl = expected_rtl_version(components)

    errors = []
    if changelog_version != version:
        errors.append(
            f"CHANGELOG.md declares {changelog_version}, but VERSION declares {version}"
        )
    if rtl_version != expected_rtl:
        errors.append(
            f"axi_llc_pkg.sv declares {rtl_version!r}, expected {expected_rtl!r} "
            f"for VERSION {version}"
        )
    if errors:
        raise ValueError("\n".join(errors))

    print(f"Version metadata agrees: {version} ({rtl_version})")


def main():
    """Parse arguments and run the version check."""
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument(
        "--root",
        type=Path,
        default=Path(__file__).resolve().parents[1],
        help="repository root (defaults to the parent of this script)",
    )
    args = parser.parse_args()

    try:
        check_versions(args.root.resolve())
    except (OSError, ValueError) as error:
        print(f"ERROR: {error}", file=sys.stderr)
        return 1
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
