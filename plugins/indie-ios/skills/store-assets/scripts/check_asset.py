#!/usr/bin/env python3
"""Check an App Store creative asset image before it goes up, and write crop previews.

Usage: check_asset.py IMAGE [--out DIR]

Checks the format (PNG or JPEG), the exact pixel size against the Asset Library slots, and that there is no
alpha channel. Then writes one preview per slot the image fits (the crop the store will show) and prints the
safe area, the part of the image every crop keeps, so text and the subject can be checked against it.

SLOTS mirrors `asc asset-library specs` as of 2026-10. Run that command first and update SLOTS here if Apple
changed a size; the command is the source of truth, this table is a convenience copy.
"""
import argparse
import os
import sys

from PIL import Image

UNIVERSAL = (5244, 2950)  # 16:9, the one image size both slots accept
HEADER_21X9 = (3840, 1646)
SEARCH_3X2_MIN, SEARCH_3X2_MAX = (1920, 1280), (3840, 2560)

# Slot name -> (aspect width, aspect height): what the store crops the image to.
CROPS = {"header": (21, 9), "search": (3, 2)}


def slots_for(width, height):
    if (width, height) == UNIVERSAL:
        return ["header", "search"]
    if (width, height) == HEADER_21X9:
        return ["header"]
    is_3x2 = width * 2 == height * 3
    if is_3x2 and SEARCH_3X2_MIN[0] <= width <= SEARCH_3X2_MAX[0]:
        return ["search"]
    return []


def centred_crop_box(width, height, aspect):
    aw, ah = aspect
    crop_w = min(width, round(height * aw / ah))
    crop_h = min(height, round(width * ah / aw))
    left, top = (width - crop_w) // 2, (height - crop_h) // 2
    return (left, top, left + crop_w, top + crop_h)


def main():
    parser = argparse.ArgumentParser()
    parser.add_argument("image")
    parser.add_argument("--out", default=".", help="folder for the crop previews")
    args = parser.parse_args()

    image = Image.open(args.image)
    problems = []
    if image.format not in ("PNG", "JPEG"):
        problems.append(f"format is {image.format}, App Store Connect takes PNG or JPEG")
    if image.mode in ("RGBA", "LA") or "transparency" in image.info:
        problems.append("image has an alpha channel; flatten it onto a solid background")
    slots = slots_for(*image.size)
    if not slots:
        problems.append(
            f"{image.width} x {image.height} fits no slot: use {UNIVERSAL[0]} x {UNIVERSAL[1]} (both slots), "
            f"{HEADER_21X9[0]} x {HEADER_21X9[1]} (header) or 3:2 from {SEARCH_3X2_MIN[0]} x {SEARCH_3X2_MIN[1]} "
            f"to {SEARCH_3X2_MAX[0]} x {SEARCH_3X2_MAX[1]} (search)"
        )

    if problems:
        for problem in problems:
            print("FAIL:", problem)
        sys.exit(1)

    os.makedirs(args.out, exist_ok=True)
    stem = os.path.splitext(os.path.basename(args.image))[0]
    boxes = []
    for slot in slots:
        box = centred_crop_box(image.width, image.height, CROPS[slot])
        boxes.append(box)
        path = os.path.join(args.out, f"{stem}-{slot}-preview.png")
        image.convert("RGB").crop(box).save(path)
        print(f"{slot}: crop {box[2] - box[0]} x {box[3] - box[1]} -> {path}")

    safe = (max(b[0] for b in boxes), max(b[1] for b in boxes), min(b[2] for b in boxes), min(b[3] for b in boxes))
    print(f"OK: {image.width} x {image.height} {image.format}, no alpha")
    print(f"safe area (x0, y0, x1, y1): {safe}; keep text and the subject inside it")


if __name__ == "__main__":
    main()
