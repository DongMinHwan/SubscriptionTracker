#!/usr/bin/env python3
"""v1.1.0 기획서용 위젯 시안 이미지 생성.

실제 위젯을 만들기 전이라 배치를 합의하려고 그리는 그림이다.
색과 글자 크기는 기획서 토큰 값을 그대로 쓴다.
"""

import os

from PIL import Image, ImageDraw, ImageFont

OUT_DIR = "/Users/hwangdongmin/Projects/NewProject_1/기획서/v1.1.0/이미지"
FONT_PATH = "/System/Library/Fonts/AppleSDGothicNeo.ttc"

SCALE = 3
SURFACE = (0xFF, 0xFF, 0xFF)
BACKDROP = (0xE9, 0xE9, 0xEE)
TEXT = (0x1C, 0x1C, 0x1E)
TEXT_SECONDARY = (0x8E, 0x8E, 0x93)
ACCENT = (0x1F, 0x4E, 0x79)
SEPARATOR = (0xC6, 0xC6, 0xC8)

# 홈 화면 위젯의 실제 크기(pt)에 가깝게 잡는다.
SMALL = (158, 158)
MEDIUM = (338, 158)
CORNER = 22
PAD = 14


def font(size, weight=4):
    """AppleSDGothicNeo.ttc는 여러 굵기를 담고 있어 인덱스로 고른다."""
    return ImageFont.truetype(FONT_PATH, size * SCALE, index=weight)


def canvas(size):
    width, height = size[0] * SCALE, size[1] * SCALE
    image = Image.new("RGB", (width, height), BACKDROP)
    draw = ImageDraw.Draw(image)
    draw.rounded_rectangle(
        [(0, 0), (width - 1, height - 1)], radius=CORNER * SCALE, fill=SURFACE
    )
    return image, draw


def build_small():
    image, draw = canvas(SMALL)
    x = PAD * SCALE
    y = PAD * SCALE

    draw.text((x, y), "이번 달", font=font(12), fill=TEXT_SECONDARY)
    y += 17 * SCALE
    draw.text((x, y), "₩257,900", font=font(22, 9), fill=ACCENT)
    y += 34 * SCALE

    draw.line(
        [(x, y), ((SMALL[0] - PAD) * SCALE, y)], fill=SEPARATOR, width=max(1, SCALE // 2)
    )
    y += 12 * SCALE

    draw.text((x, y), "다음 결제", font=font(11), fill=TEXT_SECONDARY)
    y += 16 * SCALE
    draw.text((x, y), "넷플릭스", font=font(14), fill=TEXT)
    y += 19 * SCALE
    draw.text((x, y), "8월 25일", font=font(12), fill=TEXT_SECONDARY)

    return image


def build_medium():
    image, draw = canvas(MEDIUM)
    x = PAD * SCALE
    y = 30 * SCALE

    draw.text((x, y), "이번 달", font=font(12), fill=TEXT_SECONDARY)
    draw.text((x, y + 19 * SCALE), "₩257,900", font=font(26, 9), fill=ACCENT)
    draw.text((x, y + 60 * SCALE), "구독 5개", font=font(12), fill=TEXT_SECONDARY)

    divider = int(MEDIUM[0] * 0.52) * SCALE
    draw.line(
        [(divider, 22 * SCALE), (divider, (MEDIUM[1] - 22) * SCALE)],
        fill=SEPARATOR,
        width=max(1, SCALE // 2),
    )

    rx = divider + PAD * SCALE
    draw.text((rx, y), "다음 결제", font=font(12), fill=TEXT_SECONDARY)
    draw.text((rx, y + 21 * SCALE), "넷플릭스", font=font(16), fill=TEXT)
    draw.text((rx, y + 43 * SCALE), "8월 25일", font=font(12), fill=TEXT_SECONDARY)
    draw.text((rx, y + 62 * SCALE), "₩17,000", font=font(16, 9), fill=TEXT)

    return image


def build_empty():
    image, draw = canvas(SMALL)
    x = PAD * SCALE
    y = PAD * SCALE

    draw.text((x, y), "이번 달", font=font(12), fill=TEXT_SECONDARY)
    y += 17 * SCALE
    draw.text((x, y), "₩0", font=font(22, 9), fill=ACCENT)
    y += 40 * SCALE
    draw.text((x, y), "구독을 추가하면", font=font(12), fill=TEXT_SECONDARY)
    y += 17 * SCALE
    draw.text((x, y), "여기에 보입니다", font=font(12), fill=TEXT_SECONDARY)

    return image


def main():
    os.makedirs(OUT_DIR, exist_ok=True)
    for name, image in (
        ("위젯_작은것.png", build_small()),
        ("위젯_중간것.png", build_medium()),
        ("위젯_빈상태.png", build_empty()),
    ):
        image.save(os.path.join(OUT_DIR, name))
        print(name, image.size)


if __name__ == "__main__":
    main()
