#!/usr/bin/env python3
"""Scan frontend/lib for potentially truncated/corrupted Dart files."""

from __future__ import annotations

import re
import subprocess
import sys
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1] / "lib"

# Lines that strongly suggest mid-write truncation (incomplete tokens).
SUSPICIOUS_LINE_PATTERNS = [
    re.compile(r"^\s*const\s+S\s*$"),
    re.compile(r"^\s*Selectab\s*$"),
    re.compile(r"^\s*resolvedIc\s*$"),
    re.compile(r"^\s*onPresse\s*$"),
    re.compile(r"^\s*style:\s*$"),
    re.compile(r"^\s*import\s*$"),
    re.compile(r"Map<Stri\s*$"),
    re.compile(r"return\s+con\s*$"),
    re.compile(r"host\s+\?\?\s+cont\s*$"),
]

VALID_LAST_LINE = re.compile(
    r"^(\}|\);|\),|\],|''';|\"\"\";)\s*$"
)


def file_ends_abruptly(text: str) -> bool:
    lines = [ln for ln in text.splitlines() if ln.strip()]
    if not lines:
        return True
    last = lines[-1].rstrip()
    if VALID_LAST_LINE.match(last):
        return False
    # Common valid endings: closing paren/bracket with trailing comma inside block
    if last.endswith(");") or last.endswith("},") or last.endswith("],"):
        return False
    for pat in SUSPICIOUS_LINE_PATTERNS:
        if pat.search(last):
            return True
    # Mid-identifier / mid-word heuristics
    if re.search(r"[a-zA-Z_]$", last) and not last.endswith(";"):
        # Allow string continuations and comments
        if last.strip().startswith("//"):
            return False
        if last.rstrip().endswith(",") or last.rstrip().endswith("("):
            return False
        if "'''" in last or '"""' in last:
            return False
        # Likely truncated identifier
        if len(last) < 120 and not last.endswith("{") and not last.endswith("["):
            return True
    return False


def brace_balance(text: str) -> int:
    # Rough brace balance ignoring strings/comments (good enough for scan).
    depth = 0
    i = 0
    n = len(text)
    while i < n:
        c = text[i]
        if c in ("'", '"'):
            quote = c
            i += 1
            if i < n and text[i] == quote and (i + 1 >= n or text[i + 1] != quote):
                i += 1
                continue
            if i < n and text[i] == quote:
                i += 2
                while i < n:
                    if text[i] == "\\":
                        i += 2
                        continue
                    if text[i] == quote:
                        if i + 1 < n and text[i + 1] == quote:
                            i += 2
                            continue
                        i += 1
                        break
                    i += 1
                continue
            while i < n:
                if text[i] == "\\":
                    i += 2
                    continue
                if text[i] == quote:
                    i += 1
                    break
                i += 1
            continue
        if c == "{":
            depth += 1
        elif c == "}":
            depth -= 1
        i += 1
    return depth


def main() -> int:
    damaged: list[tuple[Path, list[str]]] = []

    for path in sorted(ROOT.rglob("*.dart")):
        text = path.read_text(encoding="utf-8", errors="replace")
        reasons: list[str] = []
        rel = path.relative_to(ROOT.parent)

        if file_ends_abruptly(text):
            reasons.append("abrupt_eof")
        bal = brace_balance(text)
        if bal > 0:
            reasons.append(f"unclosed_braces(+{bal})")
        elif bal < 0:
            reasons.append(f"extra_braces({bal})")

        lines = text.splitlines()
        if lines:
            last = lines[-1].strip()
            for pat in SUSPICIOUS_LINE_PATTERNS:
                if pat.search(last):
                    reasons.append(f"suspicious_last_line:{last[:40]!r}")
                    break

        if reasons:
            damaged.append((rel, reasons))

    print(f"SCAN: {len(damaged)} potentially damaged files\n")
    for rel, reasons in damaged:
        print(f"  {rel.as_posix()}  [{', '.join(reasons)}]")

    out = Path(__file__).resolve().parent / "_damaged_files.txt"
    out.write_text(
        "\n".join(f"{p.as_posix()}\t{';'.join(r)}" for p, r in damaged),
        encoding="utf-8",
    )
    print(f"\nWrote {out}")
    return 0


if __name__ == "__main__":
    sys.exit(main())
