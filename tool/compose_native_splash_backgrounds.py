#!/usr/bin/env python3
"""Compose patterned splash backgrounds with the centered traq lockup.

Expects pattern-only sources named *_pattern.png next to each output.
If those are missing, this script is a no-op for that file (avoids double-baking).
"""

from __future__ import annotations

from pathlib import Path

from PIL import Image

ROOT = Path(__file__).resolve().parents[1]

PAIRS = (
    (
        "assets/images/native_splash_mobile_tablet_pattern.png",
        "assets/images/native_splash_mobile_tablet.png",
        "assets/branding/splash-lockup-light.png",
        0.52,
    ),
    (
        "assets/images/native_splash_mobile_tablet_dark_pattern.png",
        "assets/images/native_splash_mobile_tablet_dark.png",
        "assets/branding/splash-lockup-dark.png",
        0.52,
    ),
    (
        "assets/images/native_splash_desktop_pattern.png",
        "assets/images/native_splash_desktop.png",
        "assets/branding/splash-lockup-light.png",
        0.28,
    ),
    (
        "assets/images/native_splash_desktop_dark_pattern.png",
        "assets/images/native_splash_desktop_dark.png",
        "assets/branding/splash-lockup-dark.png",
        0.28,
    ),
)


def compose(pattern_path: Path, out_path: Path, lock_path: Path, frac: float) -> None:
    if not pattern_path.is_file():
        print(f"skip (missing pattern): {pattern_path.relative_to(ROOT)}")
        return
    source_mode = Image.open(pattern_path).mode
    bg = Image.open(pattern_path).convert("RGBA")
    lock = Image.open(lock_path).convert("RGBA")
    target_w = int(bg.width * frac)
    scale = target_w / lock.width
    size = (max(1, int(lock.width * scale)), max(1, int(lock.height * scale)))
    lock2 = lock.resize(size, Image.Resampling.LANCZOS)
    x = (bg.width - lock2.width) // 2
    y = (bg.height - lock2.height) // 2
    out = bg.copy()
    out.paste(lock2, (x, y), lock2)
    if source_mode == "RGB":
        out = out.convert("RGB")
    out.save(out_path, optimize=True)
    print(f"composed {out_path.relative_to(ROOT)}")


def main() -> int:
    for pattern_rel, out_rel, lock_rel, frac in PAIRS:
        compose(ROOT / pattern_rel, ROOT / out_rel, ROOT / lock_rel, frac)
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
