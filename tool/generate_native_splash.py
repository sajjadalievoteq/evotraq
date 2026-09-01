#!/usr/bin/env python3
"""Extract embedded raster from logo.svg for flutter_native_splash (OS requires PNG)."""

from __future__ import annotations

import base64
import re
import shutil
import subprocess
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
SVG = ROOT / "assets" / "images" / "logo" / "logo.svg"
RASTER = ROOT / "tool" / ".native_splash_logo.png"
YAML = ROOT / "flutter_native_splash.yaml"
WEB_INDEX = ROOT / "web" / "index.html"

# Responsive source-image box. The raster contains transparent safe-area
# padding, so the visible mark occupies roughly 20% of the shorter viewport.
WEB_SPLASH_LOGO_VMIN = 40
WEB_SPLASH_LOGO_MIN_PX = 140
WEB_SPLASH_LOGO_MAX_PX = 300


def extract_embedded_png() -> None:
    text = SVG.read_text(encoding="utf-8")
    match = re.search(r'xlink:href="data:image/png;base64,([^"]+)"', text)
    if not match:
        raise SystemExit(f"No embedded PNG found in {SVG}")
    RASTER.write_bytes(base64.b64decode(match.group(1)))


def upscale_raster_for_large_screens() -> None:
    try:
        from PIL import Image
    except ImportError:
        return

    with Image.open(RASTER) as logo:
        logo = logo.convert("RGBA")
        side = max(logo.size) * 2
        side = max(side, 512)
        canvas = Image.new("RGBA", (side, side), (0, 0, 0, 0))
        # Retain generous transparent padding so large/high-density platform
        # assets do not turn into an oversized visual mark. Android 12 also
        # applies its own icon mask and safe-area constraints.
        scale = min(side * 0.65 / logo.width, side * 0.65 / logo.height)
        scaled = logo.resize(
            (max(1, int(logo.width * scale)), max(1, int(logo.height * scale))),
            Image.Resampling.LANCZOS,
        )
        offset = ((side - scaled.width) // 2, (side - scaled.height) // 2)
        canvas.paste(scaled, offset, scaled)
        canvas.save(RASTER, format="PNG", optimize=True)


def patch_yaml_for_raster() -> str:
    original = YAML.read_text(encoding="utf-8")
    patched = original.replace("assets/images/logo/logo.svg", "tool/.native_splash_logo.png")
    YAML.write_text(patched, encoding="utf-8")
    return original


def restore_yaml(original: str) -> None:
    YAML.write_text(original, encoding="utf-8")


def patch_web_responsive_splash() -> None:
    if not WEB_INDEX.is_file():
        return

    text = WEB_INDEX.read_text(encoding="utf-8")
    marker = "/* traq-native-splash-responsive */"
    if marker not in text:
        responsive_rule = f"""
    {marker}
    #splash img.center {{
      width: clamp({WEB_SPLASH_LOGO_MIN_PX}px, {WEB_SPLASH_LOGO_VMIN}vmin, {WEB_SPLASH_LOGO_MAX_PX}px);
      height: auto;
      max-width: 50vw;
      max-height: 50vh;
      object-fit: contain;
}}
"""
        anchor = "  </style>\n  <script id=\"splash-screen-script\">"
        if anchor not in text:
            raise SystemExit("Could not patch web/index.html for responsive splash logo.")
        text = text.replace(anchor, f"{responsive_rule}\n{anchor}", 1)

    # flutter_native_splash emits whitespace-only lines; normalize them so
    # generated output remains diff-clean across platforms.
    text = "\n".join(line.rstrip() for line in text.splitlines()) + "\n"
    WEB_INDEX.write_text(text, encoding="utf-8")


def main() -> int:
    extract_embedded_png()
    upscale_raster_for_large_screens()
    original_yaml = patch_yaml_for_raster()
    dart = shutil.which("dart") or shutil.which("dart.bat")
    if dart is None:
        raise SystemExit("dart executable not found on PATH")
    try:
        subprocess.run(
            [dart, "run", "flutter_native_splash:create", f"--path={YAML.name}"],
            cwd=ROOT,
            check=True,
        )
        patch_web_responsive_splash()
    finally:
        restore_yaml(original_yaml)
    print("Native splash regenerated from SVG source.")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
