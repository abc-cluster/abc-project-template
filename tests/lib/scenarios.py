#!/usr/bin/env python3
"""Parse ctt.toml and emit scenario keys, one per line.

Used by snapshot-baselines.sh and check-baselines.sh to know which top-level
directories CTT will create. CTT writes each scenario to <base_dir>/<key>/
(the [config] output_dir setting in ctt.toml is ignored upstream).

We avoid the tomllib dependency (Python 3.11+) since macOS system Python is
3.9; we only need to extract [output."<key>"] header lines, which is a
simple regex job.

Usage:
    python3 tests/lib/scenarios.py [path/to/ctt.toml]
"""

from __future__ import annotations

import re
import sys
from pathlib import Path

HEADER_RE = re.compile(r'^\[output\."([^"]+)"\]\s*$')


def main() -> int:
    cfg_path = Path(sys.argv[1]) if len(sys.argv) > 1 else Path("ctt.toml")
    if not cfg_path.is_file():
        print(f"error: {cfg_path} not found", file=sys.stderr)
        return 1

    seen: set[str] = set()
    keys: list[str] = []
    for line in cfg_path.read_text().splitlines():
        m = HEADER_RE.match(line)
        if m:
            key = m.group(1)
            if key not in seen:
                seen.add(key)
                keys.append(key)

    if not keys:
        print(f"error: no [output.\"<key>\"] sections in {cfg_path}", file=sys.stderr)
        return 1

    for key in keys:
        print(key)
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
