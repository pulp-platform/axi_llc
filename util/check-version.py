#!/usr/bin/env python3
# Copyright 2026 ETH Zurich and University of Bologna.
# Solderpad Hardware License, Version 0.51, see LICENSE for details.
# SPDX-License-Identifier: SHL-0.51

"""Check that all AXI LLC version declarations agree."""

import re
import sys
from pathlib import Path


ROOT = Path(__file__).resolve().parents[1]


def extract(path, pattern):
    """Extract the first matching version field from a file."""
    field_match = re.search(pattern, path.read_text(encoding="utf-8"), re.MULTILINE)
    if not field_match:
        sys.exit(f"ERROR: Could not find a version in {path.relative_to(ROOT)}")
    return field_match.group(1)


version = (ROOT / "VERSION").read_text(encoding="utf-8").strip()
version_match = re.fullmatch(r"(\d+)\.(\d+)\.(\d+)", version)
if not version_match:
    sys.exit(f"ERROR: Invalid semantic version in VERSION: {version!r}")

major, minor, patch = map(int, version_match.groups())
expected_rtl = f"v{major:02d}.{minor:02d}.{patch}"
if len(expected_rtl) != 8:
    sys.exit(f"ERROR: {version} cannot be encoded as vAA.BB.C")

changelog_version = extract(
    ROOT / "CHANGELOG.md", r"^##\s+(\S+)\s+-\s+\d{4}-\d{2}-\d{2}\s*$")
rtl_hex = extract(
    ROOT / "src" / "axi_llc_pkg.sv", r"AxiLlcVersion\s*=\s*64'h([0-9a-fA-F_]+)")
try:
    rtl_version = bytes.fromhex(rtl_hex.replace("_", "")).decode("ascii")
except (ValueError, UnicodeDecodeError):
    sys.exit("ERROR: AxiLlcVersion is not valid ASCII")

errors = []
if changelog_version != version:
    errors.append(f"CHANGELOG.md declares {changelog_version}, VERSION declares {version}")
if rtl_version != expected_rtl:
    errors.append(f"axi_llc_pkg.sv declares {rtl_version!r}, expected {expected_rtl!r}")
if errors:
    sys.exit("ERROR: " + "\n".join(errors))

print(f"Version metadata agrees: {version} ({rtl_version})")
