#!/usr/bin/env python3
"""Apply known surgical tail repairs for common truncation patterns."""

from __future__ import annotations

from pathlib import Path

FRONTEND = Path(__file__).resolve().parents[1]
LIB = FRONTEND / "lib"

SCANNING_TAIL = """      ],
      selected: {selectedMode},
      onSelectionChanged: (modes) {
        if (modes.isEmpty) return;
        onModeChanged(modes.first);
      },
    );
  }
}
"""

SCANNING_FILES = {
    "decommissioning_scanning_mode_selector.dart": "DecommissioningScanningMode",
    "packing_scanning_mode_selector.dart": "PackingScanningMode",
    "receiving_scanning_mode_selector.dart": "ReceivingScanningMode",
    "return_receiving_scanning_mode_selector.dart": "ReturnReceivingScanningMode",
    "return_shipping_scanning_mode_selector.dart": "ReturnShippingScanningMode",
    "shipping_scanning_mode_selector.dart": "ShippingScanningMode",
    "unpacking_scanning_mode_selector.dart": "UnpackingScanningMode",
}

TRUNCATED_SCANNING_SUFFIX = """        ),
     """


def fix_scanning_selectors() -> list[str]:
    fixed = []
    for name in SCANNING_FILES:
        for path in LIB.rglob(name):
            text = path.read_text(encoding="utf-8")
            if text.rstrip().endswith("),") and "selected:" not in text:
                # normalize ending
                base = text.rstrip()
                if base.endswith("),"):
                    base = base[: base.rfind("        ),")]
                new_text = base + "\n" + SCANNING_TAIL
                path.write_text(new_text, encoding="utf-8")
                fixed.append(str(path.relative_to(FRONTEND)))
    return fixed


def main() -> None:
    fixed = fix_scanning_selectors()
    print(f"Fixed {len(fixed)} scanning mode selectors:")
    for f in fixed:
        print(f"  {f}")


if __name__ == "__main__":
    main()
