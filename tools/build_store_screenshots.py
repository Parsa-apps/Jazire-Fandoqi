#!/usr/bin/env python3
"""Build Cafe Bazaar/Myket store screenshots (1080x1920) for v8.

Phone content comes from the app's own current in-app artwork (the scenes
and cards the shipped app actually renders), framed with a Persian headline
per slide. The output is palette-optimised so every file stays small enough
for the developer panels. Both stores use the same ordered image set; the
primary output lands in store/myket/upload and is mirrored to
store/bazaar/upload.

Install the small design-time dependency set in a virtual environment:
    python3 -m venv .venv
    .venv/bin/pip install -r tools/requirements-store-assets.txt

Then run from any directory:
    .venv/bin/python tools/build_store_screenshots.py
"""

from __future__ import annotations

import math
import random
from dataclasses import dataclass
from pathlib import Path

try:
    import arabic_reshaper
    from bidi.algorithm import get_display
    from PIL import Image, ImageDraw, ImageFilter, ImageFont
except ImportError as exc:  # pragma: no cover - friendly local tooling failure
    raise SystemExit(
        "Missing store-art dependencies. Install: "
        "tools/requirements-store-assets.txt in your Python environment."
    ) from exc


ROOT = Path(__file__).resolve().parents[1]
# مجموعهٔ ۸.۰ از آرت‌ورکِ واقعی و فعلیِ داخل خود اپ ساخته می‌شود (همان
# صحنه‌ها و کارت‌هایی که نسخهٔ منتشرشده رندر می‌کند)، نه از برداشت‌های
# قدیمی ۶.۲.۶ در assets/screeen که دیگر شبیه اپ نیستند.
SOURCE_DIR = ROOT / "assets"
OUTPUT_DIR = ROOT / "store" / "myket" / "upload"
MIRROR_DIR = ROOT / "store" / "bazaar" / "upload"
PREVIEW = ROOT / "store" / "myket" / "screenshots_preview.jpg"
ICON = ROOT / "assets" / "icon" / "jazireh-fandoghi-app-icon-512.png"
FONT_BOLD = ROOT / "assets" / "fonts" / "Vazirmatn-Bold.ttf"
FONT_REGULAR = ROOT / "assets" / "fonts" / "Vazirmatn-Regular.ttf"

WIDTH, HEIGHT = 1080, 1920


@dataclass(frozen=True)
class Slide:
    output: str
    capture: str  # مسیر نسبت به assets/ — آرت‌ورک واقعی داخل اپ
    title: str
    subtitle: str
    top: str
    bottom: str
    accent: str
    rotation: float


# اسلایدهای نسخهٔ ۸.۰ — هر اسلاید یک پیام، با تیترِ هماهنگ با قابلیت‌های
# فعلی اپ (کتابخانهٔ ۱۶ دسته، دانشنامهٔ حیوانات، نقشهٔ ۵۰ مرحله و…).
SLIDES = (
    Slide(
        "1_home.png",
        "theme_v2/home_scene.webp",
        "جزیره‌ای برای بازی و یادگیری",
        "ویژه کودکان ۳ تا ۸ سال؛ رایگان و بدون تبلیغ",
        "#0875D1",
        "#24C7D9",
        "#FFCD58",
        -0.5,
    ),
    Slide(
        "2_alphabet.png",
        "theme_v2/alphabet_meadow_bg.webp",
        "آموزش الفبای فارسی با فندقی",
        "حروف، صدا، نوشتن با انگشت و املا",
        "#F06A3C",
        "#FFB84E",
        "#FFF0A7",
        0.5,
    ),
    Slide(
        "3_animals.png",
        "illustrations/animals_cards.webp",
        "دانشنامه حیوانات ایران",
        "۳۰ حیوان با صدا، زیستگاه و نکته‌های جالب",
        "#1E9E62",
        "#5FC98B",
        "#FFE066",
        -0.5,
    ),
    Slide(
        "4_games.png",
        "illustrations/memory_cards.webp",
        "بازی‌های فکری، حافظه و پازل",
        "شهر بازی‌های تازه و ده‌ها بازی هدفمند",
        "#654BD8",
        "#A56AF1",
        "#66E6D4",
        0.5,
    ),
    Slide(
        "5_stories.png",
        "theme_v2/splash_scene.webp",
        "قصه، شعر و لالایی",
        "قصه‌های تعاملی، ۸ شعر و ۱۰ لالایی برای خواب",
        "#E84E82",
        "#FF8A76",
        "#FFD46C",
        -0.5,
    ),
    Slide(
        "6_stages.png",
        "theme_v2/squirrel_reward.webp",
        "نقشه ۵۰ مرحله جزیره",
        "هر مرحله یک ماجراجویی تازه و یک جایزه",
        "#EA8214",
        "#F8C437",
        "#FFF2A8",
        0.5,
    ),
    Slide(
        "7_parents.png",
        "mascot/fandoghi_welcome_hero.png",
        "رشد کودک را دنبال کنید",
        "کارنامه، گزارش هفتگی و پنل امن والدین",
        "#078B87",
        "#35C7B1",
        "#C9F76F",
        -0.5,
    ),
    Slide(
        "8_safe.png",
        "illustrations/colors_cards.webp",
        "شاد، امن و بدون تبلیغ",
        "نیمه‌اول هر بخش رایگان؛ نسخه کامل با یک خرید دائمی",
        "#15245C",
        "#246DB4",
        "#FFD15E",
        0.5,
    ),
)


def hex_rgb(value: str) -> tuple[int, int, int]:
    value = value.lstrip("#")
    return tuple(int(value[i : i + 2], 16) for i in (0, 2, 4))  # type: ignore[return-value]


def mix(a: tuple[int, int, int], b: tuple[int, int, int], t: float) -> tuple[int, int, int]:
    return tuple(round(a[i] * (1 - t) + b[i] * t) for i in range(3))  # type: ignore[return-value]


def vertical_gradient(top: str, bottom: str) -> Image.Image:
    start, end = hex_rgb(top), hex_rgb(bottom)
    image = Image.new("RGB", (WIDTH, HEIGHT))
    draw = ImageDraw.Draw(image)
    for y in range(HEIGHT):
        # Slight easing keeps the header calmer and the lower canvas more vivid.
        t = (y / (HEIGHT - 1)) ** 0.82
        draw.line((0, y, WIDTH, y), fill=mix(start, end, t))
    return image.convert("RGBA")


def fa(text: str) -> str:
    """Return a visually ordered Persian string for Pillow without libraqm."""
    return get_display(arabic_reshaper.reshape(text))


def font(path: Path, size: int) -> ImageFont.FreeTypeFont:
    return ImageFont.truetype(str(path), size=size)


def fitted_font(
    draw: ImageDraw.ImageDraw,
    logical_text: str,
    path: Path,
    start_size: int,
    max_width: int,
    min_size: int,
) -> tuple[ImageFont.FreeTypeFont, str]:
    shaped = fa(logical_text)
    size = start_size
    while size > min_size:
        candidate = font(path, size)
        box = draw.textbbox((0, 0), shaped, font=candidate)
        if box[2] - box[0] <= max_width:
            return candidate, shaped
        size -= 2
    return font(path, min_size), shaped


def rounded_mask(size: tuple[int, int], radius: int) -> Image.Image:
    mask = Image.new("L", size, 0)
    ImageDraw.Draw(mask).rounded_rectangle((0, 0, size[0] - 1, size[1] - 1), radius, fill=255)
    return mask


def add_glows(canvas: Image.Image, slide: Slide) -> None:
    layer = Image.new("RGBA", canvas.size, (0, 0, 0, 0))
    draw = ImageDraw.Draw(layer)
    accent = hex_rgb(slide.accent)
    draw.ellipse((-240, 920, 430, 1590), fill=(*accent, 72))
    draw.ellipse((760, 120, 1250, 610), fill=(255, 255, 255, 46))
    draw.ellipse((640, 1390, 1260, 2010), fill=(*accent, 48))
    layer = layer.filter(ImageFilter.GaussianBlur(85))
    canvas.alpha_composite(layer)


def add_edge_decor(canvas: Image.Image, index: int, accent: str) -> None:
    """Add quiet, deterministic confetti around—not over—the main message."""
    rng = random.Random(8200 + index)
    layer = Image.new("RGBA", canvas.size, (0, 0, 0, 0))
    draw = ImageDraw.Draw(layer)
    accent_rgb = hex_rgb(accent)

    for _ in range(28):
        side = rng.choice(("left", "right"))
        x = rng.randint(18, 150) if side == "left" else rng.randint(930, 1062)
        y = rng.randint(170, 1740)
        radius = rng.randint(3, 9)
        color = rng.choice(
            (
                (255, 255, 255, rng.randint(80, 165)),
                (*accent_rgb, rng.randint(105, 190)),
            )
        )
        if rng.random() < 0.55:
            draw.ellipse((x - radius, y - radius, x + radius, y + radius), fill=color)
        else:
            draw.rounded_rectangle(
                (x - radius, y - radius // 2, x + radius, y + radius // 2),
                radius=radius // 2,
                fill=color,
            )

    # Three hand-drawn sparkle marks make the set feel playful but still clean.
    for x, y, scale in ((92, 390, 18), (984, 300, 14), (948, 760, 11)):
        points = (
            (x, y - scale),
            (x + scale // 4, y - scale // 4),
            (x + scale, y),
            (x + scale // 4, y + scale // 4),
            (x, y + scale),
            (x - scale // 4, y + scale // 4),
            (x - scale, y),
            (x - scale // 4, y - scale // 4),
        )
        draw.polygon(points, fill=(255, 255, 255, 205))

    canvas.alpha_composite(layer)


def add_brand_badge(canvas: Image.Image) -> None:
    """Add a compact brand mark that stays legible at store-thumbnail size."""
    layer = Image.new("RGBA", canvas.size, (0, 0, 0, 0))
    draw = ImageDraw.Draw(layer)

    badge_w, badge_h = 330, 92
    x, y = (WIDTH - badge_w) // 2, 52
    shadow = Image.new("RGBA", canvas.size, (0, 0, 0, 0))
    shadow_draw = ImageDraw.Draw(shadow)
    shadow_draw.rounded_rectangle((x, y + 8, x + badge_w, y + badge_h + 8), 46, fill=(8, 22, 54, 55))
    shadow = shadow.filter(ImageFilter.GaussianBlur(10))
    canvas.alpha_composite(shadow)

    draw.rounded_rectangle((x, y, x + badge_w, y + badge_h), 46, fill=(255, 255, 255, 238))

    icon = Image.open(ICON).convert("RGB").resize((70, 70), Image.Resampling.LANCZOS)
    icon_mask = rounded_mask(icon.size, 19)
    layer.paste(icon, (x + badge_w - 80, y + 11), icon_mask)

    badge_font = font(FONT_BOLD, 34)
    badge_text = fa("جزیره فندقی")
    box = draw.textbbox((0, 0), badge_text, font=badge_font)
    text_y = y + (badge_h - (box[3] - box[1])) // 2 - box[1]
    draw.text((x + badge_w - 98, text_y), badge_text, font=badge_font, fill="#17304F", anchor="ra")

    canvas.alpha_composite(layer)


def add_headline(canvas: Image.Image, slide: Slide) -> None:
    layer = Image.new("RGBA", canvas.size, (0, 0, 0, 0))
    draw = ImageDraw.Draw(layer)

    title_font, title = fitted_font(draw, slide.title, FONT_BOLD, 82, 940, 58)
    title_box = draw.textbbox((0, 0), title, font=title_font)
    title_h = title_box[3] - title_box[1]
    title_y = 223 - title_box[1]

    # Small text shadow preserves contrast on every colourway.
    draw.text((WIDTH / 2 + 2, title_y + 5), title, font=title_font, fill=(8, 25, 57, 78), anchor="ma")
    draw.text((WIDTH / 2, title_y), title, font=title_font, fill=(255, 255, 255, 255), anchor="ma")

    subtitle_font, subtitle = fitted_font(draw, slide.subtitle, FONT_REGULAR, 40, 880, 32)
    subtitle_box = draw.textbbox((0, 0), subtitle, font=subtitle_font)
    subtitle_y = 338 - subtitle_box[1]
    draw.text((WIDTH / 2, subtitle_y), subtitle, font=subtitle_font, fill=(255, 255, 255, 225), anchor="ma")

    # Accent underline: deliberately short so it stays a motif, not a divider.
    underline_y = max(405, 223 + title_h + 24)
    draw.rounded_rectangle((470, underline_y, 610, underline_y + 8), radius=4, fill=hex_rgb(slide.accent) + (235,))

    canvas.alpha_composite(layer)


def build_phone(capture_path: Path, rotation: float) -> Image.Image:
    screen_w = 754
    frame = 18
    screenshot = Image.open(capture_path).convert("RGB")

    # محتوای قاب از آرت‌ورکِ داخل اپ پر می‌شود (cover-fill با برش مرکزی)
    # تا با هر نسبتی — صحنهٔ عمودی خانه، کارت افقی حیوانات و… — قاب همیشه
    # کامل و بدون نوار خالی دیده شود. برش نوار وضعیت لازم نیست چون این‌ها
    # برداشت دستگاهی نیستند.
    screen_h = 1280
    scale = max(screen_w / screenshot.width, screen_h / screenshot.height)
    resized = screenshot.resize(
        (round(screenshot.width * scale), round(screenshot.height * scale)),
        Image.Resampling.LANCZOS,
    )
    left = (resized.width - screen_w) // 2
    top = (resized.height - screen_h) // 2
    screenshot = resized.crop((left, top, left + screen_w, top + screen_h)).convert("RGBA")

    phone_w, phone_h = screen_w + frame * 2, screen_h + frame * 2
    phone = Image.new("RGBA", (phone_w + 70, phone_h + 70), (0, 0, 0, 0))
    px, py = 35, 30
    phone_draw = ImageDraw.Draw(phone)

    shadow = Image.new("RGBA", phone.size, (0, 0, 0, 0))
    ImageDraw.Draw(shadow).rounded_rectangle(
        (px - 2, py + 15, px + phone_w + 2, py + phone_h + 19),
        radius=67,
        fill=(4, 14, 38, 135),
    )
    shadow = shadow.filter(ImageFilter.GaussianBlur(22))
    phone.alpha_composite(shadow)

    phone_draw.rounded_rectangle(
        (px, py, px + phone_w, py + phone_h),
        radius=63,
        fill="#10192D",
        outline=(255, 255, 255, 120),
        width=3,
    )

    screen_mask = rounded_mask(screenshot.size, 48)
    phone.paste(screenshot, (px + frame, py + frame), screen_mask)

    # Very light edge highlight adds depth without hiding authentic UI pixels.
    phone_draw.rounded_rectangle(
        (px + 4, py + 4, px + phone_w - 4, py + phone_h - 4),
        radius=59,
        outline=(255, 255, 255, 85),
        width=3,
    )

    return phone.rotate(rotation, resample=Image.Resampling.BICUBIC, expand=True)


def add_phone(canvas: Image.Image, slide: Slide) -> None:
    capture_path = SOURCE_DIR / slide.capture
    if not capture_path.exists():
        raise FileNotFoundError(f"Missing source capture: {capture_path}")

    phone = build_phone(capture_path, slide.rotation)
    # Keep the handset centred; the intentional bottom crop is a standard store
    # composition and lets the actual app UI remain large and readable.
    x = (WIDTH - phone.width) // 2
    y = 444
    canvas.alpha_composite(phone, (x, y))


def save_upload_png(canvas: Image.Image, output: Path) -> None:
    """Save a high-quality indexed PNG, typically comfortably below 1 MB."""
    output.parent.mkdir(parents=True, exist_ok=True)
    rgb = canvas.convert("RGB")
    quantized = rgb.quantize(
        colors=256,
        method=Image.Quantize.MEDIANCUT,
        dither=Image.Dither.FLOYDSTEINBERG,
    )
    quantized.save(output, format="PNG", optimize=True, compress_level=9)


def build_slide(slide: Slide, index: int) -> Path:
    canvas = vertical_gradient(slide.top, slide.bottom)
    add_glows(canvas, slide)
    add_edge_decor(canvas, index, slide.accent)
    add_brand_badge(canvas)
    add_headline(canvas, slide)
    add_phone(canvas, slide)

    output = OUTPUT_DIR / slide.output
    save_upload_png(canvas, output)
    return output


def build_preview(outputs: list[Path]) -> None:
    """Create a review-only contact sheet outside the upload directory."""
    thumb_w, thumb_h, gap = 252, 448, 12
    preview = Image.new("RGB", (1104, 944), "#13203A")
    for index, output in enumerate(outputs):
        thumb = Image.open(output).convert("RGB").resize((thumb_w, thumb_h), Image.Resampling.LANCZOS)
        column, row = index % 4, index // 4
        x = gap + column * (thumb_w + gap * 2)
        y = gap + row * (thumb_h + gap * 2)
        preview.paste(thumb, (x, y))
    preview.save(PREVIEW, format="JPEG", quality=92, optimize=True, progressive=True)


def main() -> None:
    missing = [path for path in (ICON, FONT_BOLD, FONT_REGULAR) if not path.exists()]
    if missing:
        raise SystemExit("Missing required design asset(s): " + ", ".join(map(str, missing)))

    OUTPUT_DIR.mkdir(parents=True, exist_ok=True)
    expected = {slide.output for slide in SLIDES}
    # Prevent raw captures or stale exports from accidentally being uploaded
    # with the final set. Source captures belong in assets/screeen, never here.
    for old in OUTPUT_DIR.iterdir():
        if (
            old.is_file()
            and old.suffix.lower() in {".png", ".jpg", ".jpeg"}
            and old.name not in expected
        ):
            old.unlink()

    print(f"Building {len(SLIDES)} store screenshots...")
    outputs: list[Path] = []
    for index, slide in enumerate(SLIDES, start=1):
        output = build_slide(slide, index)
        outputs.append(output)
        size_kib = output.stat().st_size / 1024
        print(f"  {index}. {output.relative_to(ROOT)} ({size_kib:.0f} KiB)")
    build_preview(outputs)

    # همان مجموعه برای کافه‌بازار هم استفاده می‌شود (مایکت سرصفحهٔ ۵×۲
    # ندارد و همین تصاویر عمودی کافی است).
    import shutil

    MIRROR_DIR.mkdir(parents=True, exist_ok=True)
    for output in outputs:
        shutil.copyfile(output, MIRROR_DIR / output.name)
    shutil.copyfile(PREVIEW, ROOT / "store" / "bazaar" / "screenshots_preview.jpg")

    print(f"  Preview: {PREVIEW.relative_to(ROOT)}")
    print("Done. Same ordered set mirrored to store/bazaar/upload.")


if __name__ == "__main__":
    main()
