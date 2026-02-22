#!/usr/bin/env python3
"""
Build optimized UI assets for Web export without touching source art.

Source:      assets/ui/<category>/*.png
Destination: assets/web/ui/<category>/*.png
"""

from __future__ import annotations

import argparse
import subprocess
import sys
from pathlib import Path


CATEGORY_MAX_EDGE = {
    "dishes": 512,
    "ingredients": 512,
    "tools": 512,
    "techniques": 512,
    "chefs": 640,
    "judges": 640,
    "cards": 768,
    "backgrounds": 1024,
}

DEFAULT_CATEGORIES = [
    "dishes",
    "ingredients",
    "tools",
    "techniques",
    "chefs",
    "judges",
]


def run_magick(src: Path, dst: Path, max_edge: int) -> None:
    cmd = [
        "magick",
        str(src),
        "-auto-orient",
        "-resize",
        f"{max_edge}x{max_edge}>",
        "-strip",
        "-define",
        "png:compression-level=9",
        "-define",
        "png:compression-filter=5",
        "-define",
        "png:compression-strategy=1",
        str(dst),
    ]
    result = subprocess.run(cmd, stdout=subprocess.PIPE, stderr=subprocess.PIPE, text=True)
    if result.returncode != 0:
        raise RuntimeError(f"magick failed for {src}: {result.stderr.strip()}")


def main() -> int:
    parser = argparse.ArgumentParser(description="Generate optimized UI assets for Web builds.")
    parser.add_argument("--project-root", default=".", help="Project root path (default: current directory)")
    parser.add_argument(
        "--categories",
        nargs="+",
        default=DEFAULT_CATEGORIES,
        choices=sorted(CATEGORY_MAX_EDGE.keys()),
        help=f"Categories to process (default: {' '.join(DEFAULT_CATEGORIES)})",
    )
    parser.add_argument("--force", action="store_true", help="Rebuild all files even when destination is up-to-date")
    args = parser.parse_args()

    root = Path(args.project_root).resolve()
    src_root = root / "assets" / "ui"
    dst_root = root / "assets" / "web" / "ui"

    if not src_root.exists():
        print(f"[error] source root not found: {src_root}", file=sys.stderr)
        return 1

    totals_src = 0
    totals_dst = 0
    built = 0
    skipped = 0

    for category in args.categories:
        max_edge = CATEGORY_MAX_EDGE[category]
        cat_src = src_root / category
        cat_dst = dst_root / category

        if not cat_src.exists():
            print(f"[warn] skip missing category: {cat_src}")
            continue

        cat_dst.mkdir(parents=True, exist_ok=True)
        files = sorted(cat_src.glob("*.png"))
        if not files:
            print(f"[warn] no png files in {cat_src}")
            continue

        print(f"[info] {category}: {len(files)} files, max edge {max_edge}")

        for src in files:
            dst = cat_dst / src.name
            if (
                not args.force
                and dst.exists()
                and dst.stat().st_mtime_ns >= src.stat().st_mtime_ns
            ):
                skipped += 1
                totals_src += src.stat().st_size
                totals_dst += dst.stat().st_size
                continue

            run_magick(src, dst, max_edge)
            built += 1
            totals_src += src.stat().st_size
            totals_dst += dst.stat().st_size

    if totals_src == 0:
        print("[info] nothing processed")
        return 0

    saved = totals_src - totals_dst
    ratio = (totals_dst / totals_src) if totals_src else 1.0

    print("")
    print("[done] web asset build summary")
    print(f"  built:   {built}")
    print(f"  skipped: {skipped}")
    print(f"  source:  {totals_src / (1024 * 1024):.2f} MB")
    print(f"  output:  {totals_dst / (1024 * 1024):.2f} MB")
    print(f"  saved:   {saved / (1024 * 1024):.2f} MB")
    print(f"  ratio:   {ratio:.3f}")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
