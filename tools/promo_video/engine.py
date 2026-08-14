"""
Tiny animation engine (Pillow based) used to render the Jazire Fandoqi promo video.

Everything is deterministic: the same frame index always produces the same pixels,
so renders are reproducible and can be split across worker processes.
"""

from __future__ import annotations

import math
import random
from functools import lru_cache

from PIL import Image, ImageDraw, ImageFilter


# ----------------------------------------------------------------------------- easing
def clamp(v, a=0.0, b=1.0):
    return a if v < a else (b if v > b else v)


def lerp(a, b, t):
    return a + (b - a) * t


def ease_out_cubic(t):
    t = clamp(t)
    return 1 - (1 - t) ** 3


def ease_in_out_cubic(t):
    t = clamp(t)
    return 4 * t * t * t if t < 0.5 else 1 - ((-2 * t + 2) ** 3) / 2


def ease_out_quint(t):
    t = clamp(t)
    return 1 - (1 - t) ** 5


def ease_out_back(t, s=1.70158):
    t = clamp(t)
    return 1 + (s + 1) * ((t - 1) ** 3) + s * ((t - 1) ** 2)


def ease_out_elastic(t):
    t = clamp(t)
    if t in (0.0, 1.0):
        return t
    c4 = (2 * math.pi) / 3
    return (2 ** (-9 * t)) * math.sin((t * 10 - 0.75) * c4) + 1


def ease_out_bounce(t):
    t = clamp(t)
    n1, d1 = 7.5625, 2.75
    if t < 1 / d1:
        return n1 * t * t
    if t < 2 / d1:
        t -= 1.5 / d1
        return n1 * t * t + 0.75
    if t < 2.5 / d1:
        t -= 2.25 / d1
        return n1 * t * t + 0.9375
    t -= 2.625 / d1
    return n1 * t * t + 0.984375


def seg(t, start, end):
    """Normalised 0..1 progress of `t` inside the [start, end] window."""
    if end <= start:
        return 1.0
    return clamp((t - start) / (end - start))


# ----------------------------------------------------------------------------- assets
_IMG_CACHE: dict[str, Image.Image] = {}


def load(path: str) -> Image.Image:
    im = _IMG_CACHE.get(path)
    if im is None:
        im = Image.open(path).convert("RGBA")
        _IMG_CACHE[path] = im
    return im


@lru_cache(maxsize=10)
def _scaled(path: str, w: int, h: int) -> Image.Image:
    return load(path).resize((max(1, w), max(1, h)), Image.LANCZOS)


def fit_height(path: str, h: int) -> Image.Image:
    src = load(path)
    return _scaled(path, int(round(src.width * h / src.height)), int(h))


def fit_width(path: str, w: int) -> Image.Image:
    src = load(path)
    return _scaled(path, int(w), int(round(src.height * w / src.width)))


def cover(path: str, w: int, h: int) -> Image.Image:
    """Scale + centre-crop so the image fully covers a w x h box."""
    src = load(path)
    k = max(w / src.width, h / src.height)
    nw, nh = int(math.ceil(src.width * k)), int(math.ceil(src.height * k))
    im = _scaled(path, nw, nh)
    x, y = (nw - w) // 2, (nh - h) // 2
    return im.crop((x, y, x + w, y + h))


def cover_pan(path: str, w: int, h: int, zoom=1.0, px=0.5, py=0.5) -> Image.Image:
    """Ken-Burns style cover: `zoom` >= 1, focal point at (px, py) in 0..1."""
    src = load(path)
    k = max(w / src.width, h / src.height) * zoom
    # quantise to 4 px steps: keeps the pan smooth but lets the resize cache hit
    nw = max(w, int(math.ceil(src.width * k / 4)) * 4)
    nh = max(h, int(math.ceil(src.height * k / 4)) * 4)
    im = _scaled(path, nw, nh)
    x = int(clamp(px) * (nw - w))
    y = int(clamp(py) * (nh - h))
    return im.crop((x, y, x + w, y + h))


# ----------------------------------------------------------------------------- drawing
def paste_alpha(base: Image.Image, sprite: Image.Image, xy, alpha=1.0):
    """Alpha-composite `sprite` onto `base` at top-left `xy` with global alpha."""
    if alpha <= 0.003:
        return
    if alpha < 0.997:
        a = sprite.getchannel("A").point(lambda v: int(v * alpha))
        sprite = sprite.copy()
        sprite.putalpha(a)
    base.alpha_composite(sprite, (int(xy[0]), int(xy[1])))


def sprite(
    base: Image.Image,
    path_or_img,
    center,
    height=None,
    width=None,
    scale=1.0,
    rot=0.0,
    alpha=1.0,
    shadow=0.0,
    shadow_offset=(0, 18),
    shadow_blur=22,
    squash=1.0,
):
    """Draw an image centred at `center` with rotation / scale / drop shadow.

    `squash` > 1 stretches horizontally and squashes vertically (cartoon bounce).
    """
    if alpha <= 0.003 or scale <= 0.001:
        return
    if isinstance(path_or_img, str):
        if height:
            im = fit_height(path_or_img, int(height))
        elif width:
            im = fit_width(path_or_img, int(width))
        else:
            im = load(path_or_img)
    else:
        im = path_or_img

    w = max(1, int(im.width * scale * squash))
    h = max(1, int(im.height * scale / squash))
    if (w, h) != im.size:
        im = im.resize((w, h), Image.LANCZOS)
    if abs(rot) > 0.01:
        im = im.rotate(rot, resample=Image.BICUBIC, expand=True)

    cx, cy = center
    x, y = int(cx - im.width / 2), int(cy - im.height / 2)

    if shadow > 0:
        sh = Image.new("RGBA", (im.width + shadow_blur * 4, im.height + shadow_blur * 4), (0, 0, 0, 0))
        mask = im.getchannel("A").point(lambda v: int(v * shadow * alpha * 0.55))
        blob = Image.new("RGBA", im.size, (25, 30, 60, 255))
        blob.putalpha(mask)
        sh.alpha_composite(blob, (shadow_blur * 2, shadow_blur * 2))
        sh = sh.filter(ImageFilter.GaussianBlur(shadow_blur))
        paste_alpha(base, sh, (x - shadow_blur * 2 + shadow_offset[0], y - shadow_blur * 2 + shadow_offset[1]), 1.0)

    paste_alpha(base, im, (x, y), alpha)


@lru_cache(maxsize=16)
def cutout(path: str, thresh: int = 234, feather: float = 1.6) -> Image.Image:
    """Knock the flat white studio background out of an RGB asset.

    A border flood fill (done on a small proxy for speed) keeps white *inside*
    the artwork — eyes, highlights, paper — while removing the backdrop.
    """
    import numpy as np

    im = load(path)
    W, H = im.size
    prox = 192
    small = im.convert("RGB").resize((prox, prox), Image.BILINEAR)
    arr = np.asarray(small).astype(np.int16)
    white = (arr.min(axis=2) >= thresh)

    # Iterative flood fill from the border, restricted to the white region.
    bg = np.zeros_like(white)
    bg[0, :] = white[0, :]
    bg[-1, :] = white[-1, :]
    bg[:, 0] = white[:, 0]
    bg[:, -1] = white[:, -1]
    for _ in range(prox * 2):
        grown = bg.copy()
        grown[1:, :] |= bg[:-1, :]
        grown[:-1, :] |= bg[1:, :]
        grown[:, 1:] |= bg[:, :-1]
        grown[:, :-1] |= bg[:, 1:]
        grown &= white
        if grown.sum() == bg.sum():
            break
        bg = grown

    mask_small = Image.fromarray(((~bg) * 255).astype("uint8"), "L")
    mask = mask_small.resize((W, H), Image.BILINEAR)
    mask = mask.filter(ImageFilter.GaussianBlur(max(1.0, feather * W / 600)))
    mask = mask.point(lambda v: 0 if v < 110 else min(255, int((v - 110) * 255 / 120)))

    out = im.copy()
    out.putalpha(mask)
    bbox = mask.getbbox()
    return out.crop(bbox) if bbox else out


@lru_cache(maxsize=24)
def _radial(size: int, color: tuple, power: float) -> Image.Image:
    """Soft radial glow sprite (cached)."""
    g = Image.new("L", (size, size), 0)
    d = ImageDraw.Draw(g)
    steps = 48
    for i in range(steps, 0, -1):
        f = i / steps
        r = f * size / 2
        v = int(255 * ((1 - f) ** power))
        d.ellipse(
            (size / 2 - r, size / 2 - r, size / 2 + r, size / 2 + r),
            fill=v,
        )
    g = g.filter(ImageFilter.GaussianBlur(size / 30))
    out = Image.new("RGBA", (size, size), color + (0,))
    out.putalpha(g)
    return out


def glow(base, center, radius, color=(255, 214, 120), alpha=0.6, power=1.8):
    size = max(8, int(radius * 2))
    # render the glow from a small cached template and upscale — cheap and
    # keeps the cache tiny (the sprite is soft, so nobody can tell).
    g = _radial(256, color, round(power, 1))
    if g.size[0] != size:
        g = g.resize((size, size), Image.BILINEAR)
    paste_alpha(base, g, (center[0] - size / 2, center[1] - size / 2), alpha)


def vignette(base: Image.Image, strength=0.35):
    w, h = base.size
    g = _radial(512, (0, 0, 0), 1.0).getchannel("A").resize((w, h), Image.BILINEAR)
    inv = g.point(lambda v: int((255 - v) * strength))
    layer = Image.new("RGBA", (w, h), (12, 18, 45, 255))
    layer.putalpha(inv)
    base.alpha_composite(layer)


def gradient(w, h, top, bottom, vertical=True):
    small = Image.new("RGBA", (1, 256) if vertical else (256, 1))
    px = small.load()
    for i in range(256):
        t = i / 255
        c = (
            int(lerp(top[0], bottom[0], t)),
            int(lerp(top[1], bottom[1], t)),
            int(lerp(top[2], bottom[2], t)),
            255,
        )
        if vertical:
            px[0, i] = c
        else:
            px[i, 0] = c
    return small.resize((w, h), Image.BILINEAR)


def rounded_card(img: Image.Image, size, radius, border=10, border_color=(255, 255, 255, 255)):
    """Crop `img` into a rounded card with a white border."""
    w, h = int(size[0]), int(size[1])
    k = max(w / img.width, h / img.height)
    im = img.resize((int(math.ceil(img.width * k)), int(math.ceil(img.height * k))), Image.LANCZOS)
    im = im.crop(((im.width - w) // 2, (im.height - h) // 2, (im.width - w) // 2 + w, (im.height - h) // 2 + h))

    mask = Image.new("L", (w, h), 0)
    ImageDraw.Draw(mask).rounded_rectangle((0, 0, w - 1, h - 1), radius=radius, fill=255)
    card = Image.new("RGBA", (w, h), (0, 0, 0, 0))
    card.paste(im, (0, 0), mask)

    if border > 0:
        out = Image.new("RGBA", (w + border * 2, h + border * 2), (0, 0, 0, 0))
        ImageDraw.Draw(out).rounded_rectangle(
            (0, 0, out.width - 1, out.height - 1), radius=radius + border, fill=border_color
        )
        out.alpha_composite(card, (border, border))
        return out
    return card


def star_shape(size, color=(255, 214, 92, 255), points=5, inner=0.45):
    im = Image.new("RGBA", (size, size), (0, 0, 0, 0))
    d = ImageDraw.Draw(im)
    cx = cy = size / 2
    r = size / 2 - 1
    pts = []
    for i in range(points * 2):
        ang = -math.pi / 2 + i * math.pi / points
        rr = r if i % 2 == 0 else r * inner
        pts.append((cx + rr * math.cos(ang), cy + rr * math.sin(ang)))
    d.polygon(pts, fill=color)
    return im


def sparkle(size, color=(255, 255, 255, 255)):
    """Four-point 'twinkle' sparkle."""
    s = size * 4
    im = Image.new("RGBA", (s, s), (0, 0, 0, 0))
    d = ImageDraw.Draw(im)
    c = s / 2
    arm, wide = s / 2 - 1, s * 0.085
    d.polygon([(c, c - arm), (c + wide, c), (c, c + arm), (c - wide, c)], fill=color)
    d.polygon([(c - arm, c), (c, c - wide), (c + arm, c), (c, c + wide)], fill=color)
    d.ellipse((c - wide * 1.5, c - wide * 1.5, c + wide * 1.5, c + wide * 1.5), fill=color)
    return im.resize((size, size), Image.LANCZOS)


# ----------------------------------------------------------------------------- particles
class Particles:
    """Deterministic looping particle field (bubbles / stars / confetti)."""

    def __init__(self, n, w, h, seed=7, kind="bokeh"):
        rnd = random.Random(seed)
        self.kind = kind
        self.w, self.h = w, h
        self.items = []
        for _ in range(n):
            self.items.append(
                dict(
                    x=rnd.random(),
                    y=rnd.random(),
                    size=rnd.uniform(0.012, 0.05),
                    speed=rnd.uniform(0.02, 0.07),
                    phase=rnd.uniform(0, math.tau),
                    sway=rnd.uniform(0.01, 0.05),
                    spin=rnd.uniform(-90, 90),
                    hue=rnd.randrange(6),
                    alpha=rnd.uniform(0.35, 0.95),
                )
            )

    PALETTE = [
        (255, 214, 92),
        (255, 255, 255),
        (126, 220, 255),
        (255, 160, 190),
        (178, 240, 170),
        (255, 190, 120),
    ]

    def draw(self, base, t, alpha=1.0):
        w, h = self.w, self.h
        for p in self.items:
            y = (p["y"] - t * p["speed"]) % 1.0
            x = p["x"] + math.sin(t * 1.1 + p["phase"]) * p["sway"]
            px, py = x * w, y * h
            s = int(p["size"] * w)
            a = p["alpha"] * alpha * (0.4 + 0.6 * (0.5 + 0.5 * math.sin(t * 2 + p["phase"])))
            col = self.PALETTE[p["hue"]]
            if self.kind == "bokeh":
                glow(base, (px, py), s * 2.2, col, a * 0.5, 2.2)
            elif self.kind == "stars":
                sp = sparkle(max(6, s), col + (255,))
                sprite(base, sp, (px, py), rot=t * p["spin"], alpha=a)
            elif self.kind == "confetti":
                cw = max(6, s // 2)
                ch = max(8, s)
                piece = Image.new("RGBA", (cw, ch), col + (255,))
                sprite(base, piece, (px, py), rot=t * p["spin"] * 3, alpha=a)
