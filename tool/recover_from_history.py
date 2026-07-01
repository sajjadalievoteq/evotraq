#!/usr/bin/env python3
"""
Surgical recovery of truncated Dart files from Cursor local history.

Strategy:
1. Index Cursor User/History entries for TraqTrace frontend files.
2. For each damaged file, pick the largest history snapshot that looks complete.
3. Merge: keep current content, append missing tail from history using line-anchor matching.
4. Never overwrite when merge cannot be validated.
"""

from __future__ import annotations

import json
import re
import sys
from pathlib import Path
from urllib.parse import unquote, urlparse

FRONTEND = Path(__file__).resolve().parents[1]
LIB = FRONTEND / "lib"
HISTORY_ROOT = Path.home() / "AppData/Roaming/Cursor/User/History"
DAMAGED_LIST = FRONTEND / "tool" / "_damaged_files.txt"
REPORT = FRONTEND / "tool" / "_recovery_report.txt"

COMPLETE_SUFFIX = re.compile(r"\}\s*$")


def path_from_resource(resource: str) -> Path | None:
    parsed = urlparse(resource)
    if parsed.scheme != "file":
        return None
    raw = unquote(parsed.path)
    if raw.startswith("/") and len(raw) > 2 and raw[2] == ":":
        raw = raw[1:]
    p = Path(raw)
    try:
        return p.resolve()
    except OSError:
        return p


def index_history() -> dict[Path, list[tuple[Path, int, int]]]:
    """Map absolute file path -> list of (snapshot_path, timestamp, size)."""
    index: dict[Path, list[tuple[Path, int, int]]] = {}
    if not HISTORY_ROOT.is_dir():
        return index

    for entries_file in HISTORY_ROOT.glob("*/entries.json"):
        try:
            data = json.loads(entries_file.read_text(encoding="utf-8"))
        except (json.JSONDecodeError, OSError):
            continue
        resource = data.get("resource", "")
        file_path = path_from_resource(resource)
        if file_path is None:
            continue
        if "TraqTrace" not in str(file_path) or "frontend" not in str(file_path):
            continue
        folder = entries_file.parent
        for entry in data.get("entries", []):
            snap = folder / entry["id"]
            if not snap.is_file():
                continue
            try:
                size = snap.stat().st_size
            except OSError:
                continue
            index.setdefault(file_path, []).append(
                (snap, int(entry.get("timestamp", 0)), size)
            )
    return index


def looks_complete(text: str) -> bool:
    t = text.rstrip()
    if not t:
        return False
    if not t.endswith("}"):
        return False
    # brace sanity (ignore strings — good enough for snapshot pick)
    depth = 0
    for ch in t:
        if ch == "{":
            depth += 1
        elif ch == "}":
            depth -= 1
    return depth == 0


def find_line_merge(
    current_lines: list[str], history_lines: list[str]
) -> tuple[int, int] | None:
    """Return (current_line_count, history_line_start_for_tail)."""
    max_i = min(len(current_lines), len(history_lines))
    # Exact prefix match (best case).
    for i in range(max_i, 10, -1):
        if current_lines[:i] == history_lines[:i]:
            return i, i

    # Anchor: longest suffix of current lines found in history.
    for window in range(min(40, len(current_lines)), 2, -1):
        suffix = current_lines[-window:]
        for start in range(len(history_lines) - window + 1):
            if history_lines[start : start + window] == suffix:
                return len(current_lines), start + window

    # Fuzzy: match last line if it's a truncation fragment.
    last = current_lines[-1].rstrip()
    if last and len(last) < 80:
        for i, hline in enumerate(history_lines):
            if hline.startswith(last) and len(hline) > len(last):
                # Truncated mid-line; merge before this line in history.
                return len(current_lines) - 1, i + 1

    return None


def merge_current_with_history(current: str, history: str) -> str | None:
    c = current.rstrip("\n")
    h = history.rstrip("\n")

    if c == h:
        return history if current.endswith("\n") else history + "\n"

    # Exact byte prefix (truncation without prior edits).
    if h.startswith(c):
        merged = h + ("\n" if current.endswith("\n") or not h.endswith("\n") else "")
        return merged

    cl = c.splitlines()
    hl = h.splitlines()
    anchor = find_line_merge(cl, hl)
    if anchor is None:
        return None
    cur_keep, hist_tail_start = anchor
    merged_lines = cl[:cur_keep] + hl[hist_tail_start:]
    merged = "\n".join(merged_lines)
    if current.endswith("\n"):
        merged += "\n"
    return merged


def load_damaged() -> list[Path]:
    if not DAMAGED_LIST.is_file():
        return []
    paths: list[Path] = []
    for line in DAMAGED_LIST.read_text(encoding="utf-8").splitlines():
        line = line.strip()
        if not line:
            continue
        rel = line.split("\t")[0]
        if rel.startswith("lib/"):
            paths.append(FRONTEND / rel)
        else:
            paths.append(LIB.parent / rel)
    return paths


def pick_best_snapshot(
    snapshots: list[tuple[Path, int, int]], current_size: int
) -> Path | None:
    ranked = sorted(snapshots, key=lambda x: (x[2], x[1]), reverse=True)
    for snap, _ts, size in ranked:
        if size < current_size * 0.9:
            continue
        try:
            text = snap.read_text(encoding="utf-8")
        except OSError:
            continue
        if looks_complete(text):
            return snap
    # Fallback: largest snapshot.
    for snap, _ts, size in ranked:
        if size > current_size:
            try:
                text = snap.read_text(encoding="utf-8")
            except OSError:
                continue
            if looks_complete(text):
                return snap
    return None


def main() -> int:
    dry_run = "--dry-run" in sys.argv
    index = index_history()
    damaged = load_damaged()

    recovered = 0
    merged = 0
    unrecoverable: list[str] = []
    skipped_ok: list[str] = []

    lines_out: list[str] = []

    for path in damaged:
        if not path.is_file():
            unrecoverable.append(f"{path} (missing)")
            continue

        current = path.read_text(encoding="utf-8")
        if looks_complete(current):
            skipped_ok.append(str(path.relative_to(FRONTEND)))
            continue

        snaps = index.get(path.resolve(), [])
        if not snaps:
            # try case-insensitive path match
            for k, v in index.items():
                if k.name == path.name and str(k).endswith(
                    str(path.relative_to(FRONTEND)).replace("\\", "/")
                ):
                    snaps = v
                    break

        if not snaps:
            unrecoverable.append(f"{path.relative_to(FRONTEND)} (no history)")
            continue

        snap = pick_best_snapshot(snaps, len(current.encode("utf-8")))
        if snap is None:
            unrecoverable.append(f"{path.relative_to(FRONTEND)} (no complete snapshot)")
            continue

        history = snap.read_text(encoding="utf-8")
        result = merge_current_with_history(current, history)
        if result is None or not looks_complete(result):
            unrecoverable.append(
                f"{path.relative_to(FRONTEND)} (merge failed; snap={snap.name})"
            )
            continue

        if result == current:
            unrecoverable.append(f"{path.relative_to(FRONTEND)} (merge unchanged)")
            continue

        merged += 1
        if len(result) > len(current):
            recovered += 1

        rel = path.relative_to(FRONTEND)
        lines_out.append(
            f"RECOVERED {rel} (+{len(result)-len(current)} bytes) from {snap.parent.name}/{snap.name}"
        )

        if not dry_run:
            path.write_text(result, encoding="utf-8")

    report = [
        f"Recovered files: {recovered}",
        f"Merged files: {merged}",
        f"Unrecoverable: {len(unrecoverable)}",
        f"Already OK: {len(skipped_ok)}",
        "",
        "=== Recovered ===",
        *lines_out,
        "",
        "=== Unrecoverable ===",
        *unrecoverable,
    ]
    REPORT.write_text("\n".join(report), encoding="utf-8")
    print("\n".join(report[:20]))
    if len(report) > 20:
        print(f"... see {REPORT}")
    return 0


if __name__ == "__main__":
    sys.exit(main())
