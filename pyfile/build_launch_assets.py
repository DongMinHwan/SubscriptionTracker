#!/usr/bin/env python3
"""v1.0.1 에셋 생성: 앱 아이콘 + 런치 로고 + 런치 배경색.

생성한 로고 그림 한 장에서 마크 모양만 뽑아, 기획서의 색 토큰으로 다시 칠한다.
그래야 앱 아이콘과 런치스크린의 마크가 완전히 같고, 색이 정확히 일치한다.
"""

import json
import os

from PIL import Image

SOURCE = "/Users/hwangdongmin/.cursor/projects/Users-hwangdongmin-Projects-NewProject-1/assets/app-icon.png"
ASSETS = "/Users/hwangdongmin/Projects/NewProject_1/SubscriptionTracker/SubscriptionTracker/Assets.xcassets"

ICON_BACKGROUND = (0x1F, 0x4E, 0x79)
ICON_MARK = (0xFF, 0xFF, 0xFF)
LAUNCH_MARK = (0x1F, 0x4E, 0x79)
LAUNCH_BACKGROUND = "F2F2F7"

ICON_SIZE = 1024
LOGO_POINT_SIZE = 120
LOGO_MARK_RATIO = 0.78

# 원본은 배경 58~63, 마크 248~255로 갈린다. 그 사이 값만 가장자리로 본다.
BACKGROUND_LEVEL = 70
MARK_LEVEL = 240


def mark_coverage(image):
    """원본에서 '마크 부분'의 비율(0~1)을 픽셀별로 뽑는다.

    어두운 배경 위의 밝은 마크라서 밝기를 그대로 커버리지로 쓸 수 있다.
    배경의 미세한 그라데이션은 0으로 눌러 평평하게 만들고,
    두 레벨 사이의 값만 남겨 마크 가장자리의 안티에일리어싱을 보존한다.
    """
    span = MARK_LEVEL - BACKGROUND_LEVEL
    return image.convert("L").point(
        lambda v: min(255, max(0, round((v - BACKGROUND_LEVEL) * 255 / span)))
    )


def write_json(path, payload):
    with open(path, "w", encoding="utf-8") as file:
        json.dump(payload, file, indent=2, ensure_ascii=False)
        file.write("\n")


def build_app_icon(coverage):
    """배경 #1F4E79, 마크 #FFFFFF, 알파 없음, 1024x1024."""
    directory = os.path.join(ASSETS, "AppIcon.appiconset")
    os.makedirs(directory, exist_ok=True)

    background = Image.new("RGB", coverage.size, ICON_BACKGROUND)
    mark = Image.new("RGB", coverage.size, ICON_MARK)
    icon = Image.composite(mark, background, coverage)
    icon = icon.resize((ICON_SIZE, ICON_SIZE), Image.LANCZOS).convert("RGB")
    icon.save(os.path.join(directory, "AppIcon-1024.png"), format="PNG")

    write_json(
        os.path.join(directory, "Contents.json"),
        {
            "images": [
                {
                    "filename": "AppIcon-1024.png",
                    "idiom": "universal",
                    "platform": "ios",
                    "size": "1024x1024",
                }
            ],
            "info": {"author": "xcode", "version": 1},
        },
    )


def build_launch_logo(coverage):
    """마크만 #1F4E79로, 배경은 투명. 120pt 기준 @1x/@2x/@3x."""
    directory = os.path.join(ASSETS, "LaunchLogo.imageset")
    os.makedirs(directory, exist_ok=True)

    box = coverage.getbbox()
    trimmed = coverage.crop(box)

    side = max(trimmed.size)
    canvas_side = int(round(side / LOGO_MARK_RATIO))
    canvas = Image.new("L", (canvas_side, canvas_side), 0)
    canvas.paste(
        trimmed,
        ((canvas_side - trimmed.width) // 2, (canvas_side - trimmed.height) // 2),
    )

    images = []
    for scale in (1, 2, 3):
        pixels = LOGO_POINT_SIZE * scale
        alpha = canvas.resize((pixels, pixels), Image.LANCZOS)
        logo = Image.new("RGBA", (pixels, pixels), LAUNCH_MARK + (0,))
        logo.putalpha(alpha)

        filename = "LaunchLogo.png" if scale == 1 else f"LaunchLogo@{scale}x.png"
        logo.save(os.path.join(directory, filename), format="PNG")
        images.append({"filename": filename, "idiom": "universal", "scale": f"{scale}x"})

    write_json(
        os.path.join(directory, "Contents.json"),
        {"images": images, "info": {"author": "xcode", "version": 1}},
    )


def build_launch_background():
    """런치스크린 배경색 #F2F2F7. Info.plist가 이름으로 참조한다."""
    directory = os.path.join(ASSETS, "LaunchBackground.colorset")
    os.makedirs(directory, exist_ok=True)

    write_json(
        os.path.join(directory, "Contents.json"),
        {
            "colors": [
                {
                    "color": {
                        "color-space": "srgb",
                        "components": {
                            "alpha": "1.000",
                            "blue": f"0x{LAUNCH_BACKGROUND[4:6]}",
                            "green": f"0x{LAUNCH_BACKGROUND[2:4]}",
                            "red": f"0x{LAUNCH_BACKGROUND[0:2]}",
                        },
                    },
                    "idiom": "universal",
                }
            ],
            "info": {"author": "xcode", "version": 1},
        },
    )


def main():
    source = Image.open(SOURCE).convert("RGB")
    coverage = mark_coverage(source)

    build_app_icon(coverage)
    build_launch_logo(coverage)
    build_launch_background()
    print("assets written")


if __name__ == "__main__":
    main()
