from __future__ import annotations

import base64
from pathlib import Path

from PIL import Image, ImageDraw, ImageFont


ROOT = Path(__file__).resolve().parents[1]
FONT_PATH = ROOT / "assets/fonts/nekst/Nekst-Medium.ttf"
OUT_DIR = ROOT / "assets/images/logo/concepts"
SVG_PATH = OUT_DIR / "traq-logo-route-nekst.svg"
PNG_PATH = OUT_DIR / "traq-logo-route-nekst.png"

BURGUNDY = "#5F0F26"
RGBA = (95, 15, 38, 255)
WIDTH, HEIGHT = 2200, 620


def make_svg() -> None:
    font_data = base64.b64encode(FONT_PATH.read_bytes()).decode("ascii")
    svg = f'''<svg xmlns="http://www.w3.org/2000/svg" width="2200" height="620" viewBox="0 0 2200 620" role="img" aria-labelledby="title desc">
  <title id="title">traq logo</title>
  <desc id="desc">Traq route symbol with the word traq set in the Nekst SemiBold brand typeface.</desc>
  <defs>
    <style>
      @font-face {{
        font-family: "Nekst Embedded";
        src: url("data:font/ttf;base64,{font_data}") format("truetype");
        font-weight: 500;
      }}
      .brand {{ fill: {BURGUNDY}; }}
      .route {{ fill: none; stroke: {BURGUNDY}; stroke-width: 70; stroke-linecap: round; stroke-linejoin: round; }}
      .wordmark {{ font-family: "Nekst Embedded", "Nekst", sans-serif; font-size: 300px; font-weight: 500; letter-spacing: -8px; }}
    </style>
  </defs>
  <g aria-label="Traq route symbol">
    <path class="route" d="M110 210 H365 Q430 210 430 275 Q430 340 365 340 H205 Q145 340 145 400 Q145 455 205 455 H465"/>
    <circle class="brand" cx="110" cy="210" r="43"/>
    <circle class="brand" cx="465" cy="455" r="43"/>
    <path class="route" d="M525 390 A145 145 0 1 1 670 535"/>
    <path class="route" d="M665 530 L735 600"/>
  </g>
  <text class="brand wordmark" x="790" y="445">traq</text>
</svg>
'''
    SVG_PATH.write_text(svg, encoding="utf-8")


def make_png() -> None:
    image = Image.new("RGBA", (WIDTH, HEIGHT), (0, 0, 0, 0))
    draw = ImageDraw.Draw(image)
    stroke = 70

    draw.line([(110, 210), (365, 210)], fill=RGBA, width=stroke)
    draw.arc((300, 210, 430, 340), -90, 90, fill=RGBA, width=stroke)
    draw.line([(365, 340), (205, 340)], fill=RGBA, width=stroke)
    draw.arc((145, 340, 265, 455), 90, 270, fill=RGBA, width=stroke)
    draw.line([(205, 455), (465, 455)], fill=RGBA, width=stroke)
    draw.ellipse((67, 167, 153, 253), fill=RGBA)
    draw.ellipse((422, 412, 508, 498), fill=RGBA)

    draw.arc((380, 100, 670, 390), 150, 510, fill=RGBA, width=stroke)
    draw.line([(627, 347), (735, 455)], fill=RGBA, width=stroke)

    font = ImageFont.truetype(str(FONT_PATH), 300)
    draw.text((790, 445), "traq", font=font, fill=RGBA, anchor="ls", spacing=0)
    image.save(PNG_PATH)


if __name__ == "__main__":
    OUT_DIR.mkdir(parents=True, exist_ok=True)
    make_svg()
    make_png()
    print(SVG_PATH)
    print(PNG_PATH)
