#!/usr/bin/env python3
"""Append missing tail when current file is a byte-prefix of a history snapshot."""

from __future__ import annotations

import json
import sys
from pathlib import Path
from urllib.parse import unquote, urlparse

FRONTEND = Path(__file__).resolve().parents[1]
LIB = FRONTEND / "lib"
HISTORY_ROOT = Path.home() / "AppData/Roaming/Cursor/User/History"
ERRORS = FRONTEND / "tool" / "_analyze_errors.txt"


def path_from_resource(resource: str) -> Path | None:
    parsed = urlparse(resource)
    if parsed.scheme != "file":
        return None
    raw = unquote(parsed.path)
    if raw.startswith("/") and len(raw) > 2 and raw[2] == ":":
        raw = raw[1:]
    return Path(raw)


def index_history() -> dict[Path, list[Path]]:
    index: dict[Path, list[Path]] = {}
    for entries_file in HISTORY_ROOT.glob("*/entries.json"):
        try:
            data = json.loads(entries_file.read_text(encoding="utf-8"))
        except (json.JSONDecodeError, OSError):
            continue
        file_path = path_from_resource(data.get("resource", ""))
        if file_path is None or "TraqTrace/frontend" not in str(file_path).replace("\\", "/"):
            continue
        folder = entries_file.parent
        snaps = []
        for entry in sorted(data.get("entries", []), key=lambda e: e.get("timestamp", 0), reverse=True):
            snap = folder / entry["id"]
            if snap.is_file():
                snaps.append(snap)
        if snaps:
            index[file_path.resolve()] = snaps
    return index


def load_targets() -> list[Path]:
    if ERRORS.is_file():
        paths = []
        for line in ERRORS.read_text(encoding="utf-8").splitlines():
            line = line.strip()
            if line:
                paths.append(LIB.parent / "lib" / line.replace("\\", "/"))
        return paths
    return list(LIB.rglob("*.dart"))


def main() -> None:
    index = index_history()
    fixed = 0
    for path in load_targets():
        if not path.is_file():
            continue
        current = path.read_text(encoding="utf-8")
        c = current.rstrip("\n")
        snaps = index.get(path.resolve(), [])
        for snap in snaps:
            hist = snap.read_text(encoding="utf-8")
            h = hist.rstrip("\n")
            if len(h) <= len(c):
                continue
            if h.startswith(c):
                path.write_text(h + ("\n" if current.endswith("\n") else ""), encoding="utf-8")
                print(f"PREFIX-RECOVERED {path.relative_to(FRONTEND)} from {snap.name}")
                fixed += 1
                break
    print(f"Done. {fixed} prefix recoveries.")


if __name__ == "__main__":
    main()
