#!/usr/bin/env python3
"""구독 아이콘 시안 이미지 생성.

브랜드 로고 대신 무엇을 쓸지 정하려고 그리는 그림이다.
목록 행의 크기와 색은 DesignTokens 값을 그대로 쓴다.
"""

import os

from PIL import Image, ImageDraw, ImageFont

OUT_DIR = "/Users/hwangdongmin/Projects/NewProject_1/기획서/v1.1.0/이미지"
FONT_PATH = "/System/Library/Fonts/AppleSDGothicNeo.ttc"

SCALE = 3

BACKGROUND = (0xF2, 0xF2, 0xF7)
SURFACE = (0xFF, 0xFF, 0xFF)
TEXT = (0x1C, 0x1C, 0x1E)
TEXT_SECONDARY = (0x8E, 0x8E, 0x93)
SEPARATOR = (0xC6, 0xC6, 0xC8)
ACCENT = (0x1F, 0x4E, 0x79)

ROW_HEIGHT = 60
PAD_H = 16
ICON = 36
ICON_GAP = 12

PANEL_W = 360
TITLE_H = 30
GAP = 18

# 흰 글자가 얹혔을 때 읽히는 선에서 서로 구분되는 여덟 가지.
PALETTE = [
    (0xE5, 0x39, 0x35),
    (0xF9, 0xA8, 0x25),
    (0x43, 0xA0, 0x47),
    (0x00, 0x89, 0x7B),
    (0x1E, 0x88, 0xE5),
    (0x5E, 0x35, 0xB1),
    (0xD8, 0x1B, 0x60),
    (0x6D, 0x4C, 0x41),
]

ROWS = [
    ("넷플릭스", "D-6", "₩17,000", 0),
    ("네이버멤버십", "D-DAY", "₩4,900", 2),
    ("유튜브 프리미엄", "D-12", "₩14,900", 4),
    ("밀리의서재", "D-23", "₩9,900", 5),
]


def font(size, weight=4):
    return ImageFont.truetype(FONT_PATH, size * SCALE, index=weight)


def initial(name):
    """이름에서 머리글자 한 자를 뽑는다. 한글이면 첫 음절, 영문이면 첫 글자."""
    for ch in name:
        if not ch.isspace():
            return ch.upper()
    return "?"


def tint(color, ratio=0.16):
    """흰 바탕에 색을 옅게 깐다."""
    return tuple(round(c * ratio + 0xFF * (1 - ratio)) for c in color)


def darken(color, ratio=0.72):
    return tuple(round(c * ratio) for c in color)


def centered(draw, box, text, fnt, fill):
    left, top, right, bottom = box
    l, t, r, b = draw.textbbox((0, 0), text, font=fnt)
    x = left + (right - left - (r - l)) / 2 - l
    y = top + (bottom - top - (b - t)) / 2 - t
    draw.text((x, y), text, font=fnt, fill=fill)


def draw_icon(draw, x, y, name, color_index, style):
    """style: none | solid | tinted | rounded"""
    if style == "none":
        return

    color = PALETTE[color_index % len(PALETTE)]
    box = (x, y, x + ICON * SCALE, y + ICON * SCALE)

    if style == "solid":
        draw.ellipse(box, fill=color)
        letter_fill = SURFACE
    elif style == "tinted":
        draw.ellipse(box, fill=tint(color))
        letter_fill = darken(color)
    else:
        draw.rounded_rectangle(box, radius=int(ICON * 0.28) * SCALE, fill=color)
        letter_fill = SURFACE

    centered(draw, box, initial(name), font(16, 9), letter_fill)


def draw_panel(title, style):
    height = TITLE_H + ROW_HEIGHT * len(ROWS)
    image = Image.new("RGB", (PANEL_W * SCALE, height * SCALE), BACKGROUND)
    draw = ImageDraw.Draw(image)

    draw.text((PAD_H * SCALE, 6 * SCALE), title, font=font(13, 9), fill=TEXT_SECONDARY)

    top = TITLE_H * SCALE
    draw.rectangle(
        [(0, top), (PANEL_W * SCALE, height * SCALE)], fill=SURFACE
    )

    for index, (name, dday, amount, color_index) in enumerate(ROWS):
        y = top + index * ROW_HEIGHT * SCALE
        text_x = PAD_H * SCALE

        if style != "none":
            icon_y = y + (ROW_HEIGHT - ICON) / 2 * SCALE
            draw_icon(draw, text_x, icon_y, name, color_index, style)
            text_x += (ICON + ICON_GAP) * SCALE

        draw.text((text_x, y + 13 * SCALE), name, font=font(17), fill=TEXT)
        draw.text(
            (text_x, y + 35 * SCALE), dday, font=font(13), fill=TEXT_SECONDARY
        )

        l, _, r, _ = draw.textbbox((0, 0), amount, font=font(17))
        draw.text(
            ((PANEL_W - PAD_H) * SCALE - (r - l), y + 20 * SCALE),
            amount,
            font=font(17),
            fill=TEXT,
        )

        if index < len(ROWS) - 1:
            line_y = y + ROW_HEIGHT * SCALE
            draw.line(
                [(text_x, line_y), ((PANEL_W - PAD_H) * SCALE, line_y)],
                fill=SEPARATOR,
                width=max(1, SCALE // 2),
            )

    return image


SCREEN_W = 375
SCREEN_H = 600
NAV_H = 52
TABBAR_H = 56


def draw_list_glyph(draw, cx, cy, color):
    size = 20 * SCALE
    left, top = cx - size / 2, cy - size / 2
    step = size / 3
    for i in range(3):
        y = top + step * i + step / 2
        draw.ellipse(
            [(left, y - 2 * SCALE), (left + 4 * SCALE, y + 2 * SCALE)], fill=color
        )
        draw.line(
            [(left + 7 * SCALE, y), (left + size, y)],
            fill=color,
            width=max(1, int(1.8 * SCALE)),
        )


def draw_gear_glyph(draw, cx, cy, color):
    outer = 10 * SCALE
    draw.ellipse(
        [(cx - outer, cy - outer), (cx + outer, cy + outer)],
        outline=color,
        width=max(1, int(2.2 * SCALE)),
    )
    inner = 3.4 * SCALE
    draw.ellipse(
        [(cx - inner, cy - inner), (cx + inner, cy + inner)],
        outline=color,
        width=max(1, int(2 * SCALE)),
    )


def draw_screen():
    image = Image.new("RGB", (SCREEN_W * SCALE, SCREEN_H * SCALE), BACKGROUND)
    draw = ImageDraw.Draw(image)

    draw.rectangle([(0, 0), (SCREEN_W * SCALE, NAV_H * SCALE)], fill=BACKGROUND)
    centered(draw, (0, 0, SCREEN_W * SCALE, NAV_H * SCALE), "구독", font(17, 9), TEXT)
    plus = (SCREEN_W - PAD_H - 9) * SCALE, NAV_H / 2 * SCALE
    draw.line(
        [(plus[0] - 8 * SCALE, plus[1]), (plus[0] + 8 * SCALE, plus[1])],
        fill=ACCENT,
        width=max(1, int(2 * SCALE)),
    )
    draw.line(
        [(plus[0], plus[1] - 8 * SCALE), (plus[0], plus[1] + 8 * SCALE)],
        fill=ACCENT,
        width=max(1, int(2 * SCALE)),
    )

    y = (NAV_H + 24) * SCALE
    draw.text((PAD_H * SCALE, y), "이번 달", font=font(13), fill=TEXT_SECONDARY)
    draw.text((PAD_H * SCALE, y + 18 * SCALE), "₩46,700", font=font(34, 9), fill=ACCENT)

    top = int(y + 84 * SCALE)
    draw.rectangle(
        [(0, top), (SCREEN_W * SCALE, top + ROW_HEIGHT * SCALE * len(ROWS))],
        fill=SURFACE,
    )

    for index, (name, dday, amount, color_index) in enumerate(ROWS):
        ry = top + index * ROW_HEIGHT * SCALE
        text_x = PAD_H * SCALE
        draw_icon(
            draw,
            text_x,
            ry + (ROW_HEIGHT - ICON) / 2 * SCALE,
            name,
            color_index,
            "rounded",
        )
        text_x += (ICON + ICON_GAP) * SCALE

        draw.text((text_x, ry + 13 * SCALE), name, font=font(17), fill=TEXT)
        draw.text((text_x, ry + 35 * SCALE), dday, font=font(13), fill=TEXT_SECONDARY)

        l, _, r, _ = draw.textbbox((0, 0), amount, font=font(17))
        draw.text(
            ((SCREEN_W - PAD_H) * SCALE - (r - l), ry + 20 * SCALE),
            amount,
            font=font(17),
            fill=TEXT,
        )
        if index < len(ROWS) - 1:
            line_y = ry + ROW_HEIGHT * SCALE
            draw.line(
                [(text_x, line_y), ((SCREEN_W - PAD_H) * SCALE, line_y)],
                fill=SEPARATOR,
                width=max(1, SCALE // 2),
            )

    bar_top = (SCREEN_H - TABBAR_H) * SCALE
    draw.rectangle([(0, bar_top), (SCREEN_W * SCALE, SCREEN_H * SCALE)], fill=SURFACE)
    draw.line(
        [(0, bar_top), (SCREEN_W * SCALE, bar_top)],
        fill=SEPARATOR,
        width=max(1, SCALE // 2),
    )

    for index, (label, glyph, color) in enumerate(
        (("구독", draw_list_glyph, ACCENT), ("설정", draw_gear_glyph, TEXT_SECONDARY))
    ):
        cx = SCREEN_W * SCALE * (0.25 + 0.5 * index)
        glyph(draw, cx, bar_top + 20 * SCALE, color)
        centered(
            draw,
            (cx - 40 * SCALE, bar_top + 32 * SCALE, cx + 40 * SCALE, bar_top + 48 * SCALE),
            label,
            font(10),
            color,
        )

    return image


def main():
    os.makedirs(OUT_DIR, exist_ok=True)

    panels = [
        draw_panel("A. 지금 (아이콘 없음)", "none"),
        draw_panel("B. 채운 원 + 흰 글자", "solid"),
        draw_panel("C. 옅은 원 + 진한 글자", "tinted"),
        draw_panel("D. 라운드 사각 + 흰 글자", "rounded"),
    ]

    pw, ph = panels[0].size
    sheet = Image.new(
        "RGB",
        (pw * 2 + GAP * SCALE * 3, ph * 2 + GAP * SCALE * 3),
        (0xE5, 0xE5, 0xEA),
    )
    for index, panel in enumerate(panels):
        col, row = index % 2, index // 2
        x = GAP * SCALE + col * (pw + GAP * SCALE)
        y = GAP * SCALE + row * (ph + GAP * SCALE)
        sheet.paste(panel, (x, y))

    for name, image in (
        ("아이콘_시안비교.png", sheet),
        ("화면_구독탭.png", draw_screen()),
    ):
        path = os.path.join(OUT_DIR, name)
        image.save(path)
        print(path, image.size)


if __name__ == "__main__":
    main()
