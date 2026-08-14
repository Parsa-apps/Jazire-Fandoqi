#!/usr/bin/env python3
"""حذف پس‌زمینهٔ سفید از عناصر نقشهٔ جزیره و برش به کوچک‌ترین کادر ممکن.

هر عنصر روی پس‌زمینهٔ سفیدِ تخت تولید شده است. مولد تصویر خروجی شفاف
نمی‌دهد، پس اینجا سفید را به آلفا تبدیل می‌کنیم.

روش سه‌مرحله‌ای:
  ۱. flood fill از چهار ضلع روی پیکسل‌های سفید ← فقط سفیدِ *متصل به لبه*
     حذف می‌شود، پس سفیدهای درونی (چشم‌ها، صفحهٔ کتاب، ابرها) می‌مانند.
  ۲. رشد ماسک داخل سایه‌های خاکستریِ روشنِ چسبیده به عنصر، تا هالهٔ محوِ
     زیر شیء هم پاک شود.
  ۳. لکه‌های خیلی کوچکِ حذف‌شده (براقیِ نقطه‌ایِ روی طناب و لبه‌ها) دوباره
     مات می‌شوند تا داخل جسم سوراخ نیفتد.

خروجی در parts_cutout/ ذخیره می‌شود.
"""
import os
from collections import deque

import numpy as np
from PIL import Image, ImageFilter

HERE = os.path.dirname(os.path.abspath(__file__))
SRC = os.path.join(HERE, "parts")
DST = os.path.join(HERE, "parts_cutout")

# مرحلهٔ ۱ — سفیدِ پس‌زمینه: هر سه کانال بالای این آستانه
WHITE_MIN = 232
# اختلاف کانال‌ها کم باشد تا فقط خاکستریِ بی‌رنگ حذف شود، نه رنگ روشن
CHANNEL_SPREAD_MAX = 14

# مرحلهٔ ۲ — سایهٔ محوِ چسبیده به پس‌زمینه
SHADOW_MIN = 214
SHADOW_SPREAD_MAX = 26

# مرحلهٔ ۳ — لکه‌های کوچک‌تر از این تعداد پیکسل دوباره مات می‌شوند
SPECK_MAX_PIXELS = 220

# استثناها: عناصری که هیچ سفید/کِرِمِ عمدی ندارند و سایه‌شان پررنگ است.
# برای این‌ها ماسک به‌جای flood از لبه، سراسری گرفته می‌شود و بعد
# لکه‌های کوچک (براقیِ روی طناب) با despeckle برمی‌گردند.
AGGRESSIVE = {
    "bridge.png": {"min": 132, "spread": 80},
}


def _flood(mask_seed: np.ndarray, allowed: np.ndarray) -> np.ndarray:
    """گسترش mask_seed داخل پیکسل‌های allowed با پویش چهارهمسایه."""
    h, w = allowed.shape
    seen = mask_seed.copy()
    q = deque(zip(*np.nonzero(mask_seed)))
    while q:
        y, x = q.popleft()
        for dy, dx in ((1, 0), (-1, 0), (0, 1), (0, -1)):
            ny, nx = y + dy, x + dx
            if 0 <= ny < h and 0 <= nx < w and allowed[ny, nx] and not seen[ny, nx]:
                seen[ny, nx] = True
                q.append((ny, nx))
    return seen


def background_mask(rgb: np.ndarray) -> np.ndarray:
    h, w, _ = rgb.shape
    mn = rgb.min(axis=2).astype(int)
    spread = rgb.max(axis=2).astype(int) - mn

    is_white = (mn >= WHITE_MIN) & (spread <= CHANNEL_SPREAD_MAX)

    # بذر: پیکسل‌های سفیدِ روی چهار ضلع
    seed = np.zeros((h, w), dtype=bool)
    seed[0, :] |= is_white[0, :]
    seed[h - 1, :] |= is_white[h - 1, :]
    seed[:, 0] |= is_white[:, 0]
    seed[:, w - 1] |= is_white[:, w - 1]

    bg = _flood(seed, is_white)

    is_shadow = (mn >= SHADOW_MIN) & (spread <= SHADOW_SPREAD_MAX)
    return _flood(bg, is_shadow | is_white)


def despeckle(mask: np.ndarray) -> np.ndarray:
    """لکه‌های حذف‌شدهٔ خیلی کوچک را دوباره مات می‌کند."""
    h, w = mask.shape
    seen = np.zeros((h, w), dtype=bool)
    out = mask.copy()
    for sy in range(h):
        for sx in range(w):
            if mask[sy, sx] and not seen[sy, sx]:
                seen[sy, sx] = True
                q = deque([(sy, sx)])
                px = []
                touches_edge = False
                while q:
                    y, x = q.popleft()
                    px.append((y, x))
                    if y in (0, h - 1) or x in (0, w - 1):
                        touches_edge = True
                    for dy, dx in ((1, 0), (-1, 0), (0, 1), (0, -1)):
                        ny, nx = y + dy, x + dx
                        if 0 <= ny < h and 0 <= nx < w and mask[ny, nx] and not seen[ny, nx]:
                            seen[ny, nx] = True
                            q.append((ny, nx))
                if not touches_edge and len(px) < SPECK_MAX_PIXELS:
                    for y, x in px:
                        out[y, x] = False
    return out


def process(path_in: str, path_out: str) -> str:
    img = Image.open(path_in).convert("RGB")
    rgb = np.asarray(img)

    rule = AGGRESSIVE.get(os.path.basename(path_in))
    if rule:
        mn = rgb.min(axis=2).astype(int)
        spread = rgb.max(axis=2).astype(int) - mn
        bg = (mn >= rule["min"]) & (spread <= rule["spread"])
    else:
        bg = background_mask(rgb)
    bg = despeckle(bg)

    a = Image.fromarray(np.where(bg, 0, 255).astype(np.uint8), mode="L")
    # نرم کردن لبه، سپس سفت کردن، تا هالهٔ سفید نماند و لبه دندانه‌دار نشود
    a = a.filter(ImageFilter.GaussianBlur(0.7))
    a = a.point(lambda v: 0 if v < 105 else (255 if v > 195 else v))

    out = img.convert("RGBA")
    out.putalpha(a)
    box = out.getbbox()
    if box:
        out = out.crop(box)
    out.save(path_out)
    return f"{os.path.basename(path_out):22s} {out.width:4d}x{out.height:<4d}"


def main() -> None:
    os.makedirs(DST, exist_ok=True)
    for name in sorted(os.listdir(SRC)):
        if name.lower().endswith(".png"):
            print(process(os.path.join(SRC, name), os.path.join(DST, name)))


if __name__ == "__main__":
    main()
