"""
Compiles the Crimson Veil Illustrated Novella (`crimson_veil_novella.typ`) using the Python
`typst` package (offline, using Windows system fonts) into:
  - Crimson_Veil_Illustrated_Novella_EN.pdf
  - preview/page_*.png (for visual QA)
"""

from __future__ import annotations

import shutil
from pathlib import Path
import typst

ROOT = Path(__file__).resolve().parent
ENTRY_TYP = ROOT / "crimson_veil_novella.typ"
OUT_PDF = ROOT / "Crimson_Veil_Illustrated_Novella_EN.pdf"
PREVIEW_DIR = ROOT / "preview"

FONT_PATHS = [
    r"C:\Windows\Fonts",
    str(Path.home() / "AppData" / "Local" / "Microsoft" / "Windows" / "Fonts"),
]


def main() -> None:
    if not ENTRY_TYP.is_file():
        raise FileNotFoundError(f"Missing entry Typst file: {ENTRY_TYP}")

    pdf_bytes, warnings = typst.compile_with_warnings(
        str(ENTRY_TYP),
        font_paths=FONT_PATHS,
    )
    if warnings:
        print(f"[WARN] {len(warnings)} Typst warnings:")
        for w in warnings:
            print(" ", w)
    OUT_PDF.write_bytes(pdf_bytes)
    print(f"[PDF OK] {OUT_PDF} ({OUT_PDF.stat().st_size / (1024 * 1024):.2f} MB)")

    if PREVIEW_DIR.exists():
        shutil.rmtree(PREVIEW_DIR)
    PREVIEW_DIR.mkdir(parents=True, exist_ok=True)
    rendered = typst.compile(
        str(ENTRY_TYP),
        format="png",
        ppi=120.0,
        font_paths=FONT_PATHS,
    )
    if isinstance(rendered, list):
        for idx, page_bytes in enumerate(rendered, start=1):
            (PREVIEW_DIR / f"page_{idx:02d}.png").write_bytes(page_bytes)
    else:
        (PREVIEW_DIR / "page_01.png").write_bytes(rendered)
    pages = sorted(PREVIEW_DIR.glob("page_*.png"))
    print(f"[PREVIEW OK] {len(pages)} pages rendered into {PREVIEW_DIR}")


if __name__ == "__main__":
    main()
