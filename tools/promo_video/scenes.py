"""
Scene definitions for the Jazire Fandoqi promo video.

No on-screen Persian (or any) text is drawn — the story is told purely with
motion, the app's own artwork, the mascot and the logo.
Layout is resolution- and aspect-independent: every position is expressed in
fractions of the canvas, so the same code renders 1080x1920 and 1920x1080.
"""

from __future__ import annotations

import math
from functools import lru_cache

from PIL import Image, ImageDraw, ImageFilter

from engine import (
    Particles,
    cutout,
    clamp,
    cover_pan,
    ease_in_out_cubic,
    ease_out_back,
    ease_out_bounce,
    ease_out_cubic,
    ease_out_elastic,
    ease_out_quint,
    fit_height,
    glow,
    gradient,
    lerp,
    load,
    paste_alpha,
    rounded_card,
    seg,
    sparkle,
    sprite,
    star_shape,
    vignette,
)

A = "assets/"

MASCOT = {k: f"{A}mascot/fandoghi_baby{s}.webp" for k, s in {
    "idle": "", "cheer": "_cheer", "party": "_party", "proud": "_proud",
    "wow": "_wow", "wink": "_wink", "think": "_think", "sleep": "_sleep",
    "shy": "_shy",
}.items()}

BG_ISLAND = f"{A}gateway/island_bg.webp"
BG_CORAL = f"{A}gateway/coral_island_bg.webp"
BG_LEARN = f"{A}gateway/learn_island_bg.webp"
BG_CORAL_W = f"{A}gateway/coral_world_bg.webp"

# Cut-out props (flat white studio background removed at render time).
# Deliberately text-free so the video reads the same in every language.
GAME_TILES = [
    (f"{A}premium/numbers_premium.webp", (255, 138, 160)),
    (f"{A}premium/shapes_star.webp", (255, 196, 76)),
    (f"{A}premium/memory_game_icon.webp", (108, 196, 255)),
    (f"{A}premium/animals_premium.webp", (146, 224, 150)),
    (f"{A}premium/patterns_premium.webp", (196, 152, 255)),
    (f"{A}premium/drawing_tools_premium.webp", (255, 160, 108)),
    (f"{A}premium/shapes_heart.webp", (255, 150, 200)),
    (f"{A}premium/star_catch_icon.webp", (120, 216, 220)),
    (f"{A}premium/avatar_panda.webp", (255, 210, 120)),
]

# Story / lullaby artwork — all chosen because they carry no lettering.
CONTENT_CARDS = [
    f"{A}stories/story_2_page_1.webp",
    f"{A}lullabies/lullaby_moon_stars.webp",
    f"{A}stories/story_3_page_2.webp",
    f"{A}stories/story_5_page_2.webp",
    f"{A}lullabies/lullaby_dream_boat.webp",
    f"{A}stories/story_1_page_1.webp",
    f"{A}stories/story_7_page_1.webp",
]

# 1024x1024 master icon — crisp at 1080p/4K. Override with `--logo path.png`.
LOGO = f"{A}icons/app_icon.png"


# --------------------------------------------------------------------------- helpers
class Ctx:
    """Canvas geometry helper — everything is relative so both aspects work."""

    def __init__(self, w, h):
        self.w, self.h = w, h
        self.portrait = h >= w
        self.u = min(w, h) / 1000.0          # generic unit
        self.d = math.hypot(w, h) / 2200.0   # diagonal unit (for full-bleed art)

    def p(self, fx, fy):
        return (self.w * fx, self.h * fy)


@lru_cache(maxsize=64)
def game_tile(cell: int, art_path: str, tint: tuple) -> Image.Image:
    """A candy-coloured rounded tile with the cut-out artwork floating on it."""
    cell = int(cell)
    radius = int(cell * 0.26)
    top = tuple(min(255, int(c * 1.12 + 26)) for c in tint)
    bottom = tuple(int(c * 0.86) for c in tint)
    face = gradient(cell, cell, top, bottom).convert("RGBA")

    mask = Image.new("L", (cell, cell), 0)
    ImageDraw.Draw(mask).rounded_rectangle((0, 0, cell - 1, cell - 1), radius=radius, fill=255)
    tile = Image.new("RGBA", (cell, cell), (0, 0, 0, 0))
    tile.paste(face, (0, 0), mask)

    # glossy top highlight
    gloss = Image.new("RGBA", (cell, cell), (0, 0, 0, 0))
    ImageDraw.Draw(gloss).ellipse((-cell * 0.25, -cell * 0.85, cell * 1.25, cell * 0.42),
                                 fill=(255, 255, 255, 58))
    tile.alpha_composite(Image.composite(gloss, Image.new("RGBA", (cell, cell), (0, 0, 0, 0)), mask))

    art = cutout(art_path)
    box = int(cell * 0.70)
    k = min(box / art.width, box / art.height)
    art = art.resize((max(1, int(art.width * k)), max(1, int(art.height * k))), Image.LANCZOS)
    tile.alpha_composite(art, ((cell - art.width) // 2, (cell - art.height) // 2))

    # white border
    b = max(3, int(cell * 0.042))
    out = Image.new("RGBA", (cell + b * 2, cell + b * 2), (0, 0, 0, 0))
    ImageDraw.Draw(out).rounded_rectangle((0, 0, out.width - 1, out.height - 1),
                                          radius=radius + b, fill=(255, 255, 255, 255))
    out.alpha_composite(tile, (b, b))
    return out


def round_icon(img: Image.Image, size: int) -> Image.Image:
    """Circular crop with a soft white rim — used for the world bubbles."""
    size = int(size)
    k = max(size / img.width, size / img.height)
    im = img.resize((int(img.width * k), int(img.height * k)), Image.LANCZOS)
    im = im.crop(((im.width - size) // 2, (im.height - size) // 2,
                  (im.width - size) // 2 + size, (im.height - size) // 2 + size))
    mask = Image.new("L", (size, size), 0)
    ImageDraw.Draw(mask).ellipse((0, 0, size - 1, size - 1), fill=255)
    disc = Image.new("RGBA", (size, size), (0, 0, 0, 0))
    disc.paste(im, (0, 0), mask)
    b = max(3, int(size * 0.045))
    out = Image.new("RGBA", (size + b * 2, size + b * 2), (0, 0, 0, 0))
    ImageDraw.Draw(out).ellipse((0, 0, out.width - 1, out.height - 1), fill=(255, 255, 255, 240))
    out.alpha_composite(disc, (b, b))
    # gentle glass highlight
    hl = Image.new("RGBA", out.size, (0, 0, 0, 0))
    ImageDraw.Draw(hl).ellipse((out.width * 0.14, out.height * 0.07,
                                out.width * 0.72, out.height * 0.42),
                               fill=(255, 255, 255, 60))
    m2 = Image.new("L", out.size, 0)
    ImageDraw.Draw(m2).ellipse((0, 0, out.width - 1, out.height - 1), fill=255)
    out.alpha_composite(Image.composite(hl, Image.new("RGBA", out.size, (0, 0, 0, 0)), m2))
    return out


@lru_cache(maxsize=1)
def trophy_clean() -> Image.Image:
    """The trophy prop with its small engraved plaque smoothed away, so the
    video stays completely text-free in every language."""
    im = cutout(f"{A}premium/trophy.webp").copy()
    w, h = im.size
    box = (int(w * 0.20), int(h * 0.845), int(w * 0.80), int(h * 0.935))
    patch = im.crop(box).filter(ImageFilter.GaussianBlur(max(3, w * 0.02)))
    im.paste(patch, box)
    return im


def fit_h(img: Image.Image, h: int) -> Image.Image:
    return img.resize((max(1, int(img.width * h / img.height)), int(h)), Image.LANCZOS)


def new_frame(ctx: Ctx, top=(120, 205, 255), bottom=(190, 240, 255)):
    return gradient(ctx.w, ctx.h, top, bottom).convert("RGBA")


def bg_pan(frame, ctx, path, t, dur, zoom_from=1.14, zoom_to=1.0, px=0.5, py=0.5, alpha=1.0):
    k = ease_in_out_cubic(t / dur)
    img = cover_pan(path, ctx.w, ctx.h, lerp(zoom_from, zoom_to, k), px, py)
    paste_alpha(frame, img, (0, 0), alpha)


def breathe(t, speed=2.0, amount=0.03):
    return 1 + math.sin(t * speed) * amount


def hop(t, speed=2.4, height=1.0):
    """0..1 vertical hop factor with squash timing."""
    ph = (t * speed) % 1.0
    return math.sin(ph * math.pi) ** 0.7 * height


def mascot_bob(frame, ctx, key, center, height, t, rot_amp=3.0, hop_px=0.0, shadow=0.9, alpha=1.0, scale=1.0):
    """Mascot with a lively idle: bob, tilt, squash and a ground shadow."""
    hf = hop(t, 1.6)
    y = center[1] - hop_px * hf
    squash = 1 + 0.045 * math.sin(t * 3.2)
    rot = math.sin(t * 1.7) * rot_amp
    # ground shadow ellipse
    gh = height * 0.10
    gw = height * 0.42 * (1 - 0.18 * hf)
    sh = Image.new("RGBA", (int(gw), int(max(4, gh))), (0, 0, 0, 0))
    ImageDraw.Draw(sh).ellipse((0, 0, sh.width - 1, sh.height - 1), fill=(40, 60, 110, 90))
    sh = sh.filter(ImageFilter.GaussianBlur(gh / 3))
    paste_alpha(frame, sh, (center[0] - gw / 2, center[1] + height * 0.47), alpha * 0.75 * (1 - 0.3 * hf))
    sprite(frame, MASCOT[key], (center[0], y), height=int(height * scale),
           rot=rot, alpha=alpha, squash=squash, shadow=shadow * 0.5, shadow_blur=int(20 * ctx.u))


def logo_sprite(ctx, size, ring=True):
    """The logo rendered as a soft rounded badge with a white ring."""
    size = int(size)
    src = load(LOGO)
    k = max(size / src.width, size / src.height)
    im = src.resize((int(src.width * k), int(src.height * k)), Image.LANCZOS)
    im = im.crop(((im.width - size) // 2, (im.height - size) // 2,
                  (im.width - size) // 2 + size, (im.height - size) // 2 + size))
    radius = int(size * 0.235)
    mask = Image.new("L", (size, size), 0)
    ImageDraw.Draw(mask).rounded_rectangle((0, 0, size - 1, size - 1), radius=radius, fill=255)
    badge = Image.new("RGBA", (size, size), (0, 0, 0, 0))
    badge.paste(im, (0, 0), mask)
    if not ring:
        return badge
    b = max(4, int(size * 0.035))
    out = Image.new("RGBA", (size + b * 2, size + b * 2), (0, 0, 0, 0))
    ImageDraw.Draw(out).rounded_rectangle((0, 0, out.width - 1, out.height - 1),
                                          radius=radius + b, fill=(255, 255, 255, 255))
    out.alpha_composite(badge, (b, b))
    return out


def burst(frame, ctx, center, t, dur, n=14, radius=1.0, color=(255, 220, 120), size=1.0):
    """Radial sparkle burst, t in 0..dur."""
    if t < 0 or t > dur:
        return
    k = t / dur
    e = ease_out_quint(k)
    fade = 1 - k ** 1.6
    for i in range(n):
        ang = i * math.tau / n + k * 0.6
        r = e * radius * ctx.d * 420
        x = center[0] + math.cos(ang) * r
        y = center[1] + math.sin(ang) * r * 0.95
        s = int((26 + 16 * math.sin(i * 2.3)) * ctx.u * size * (1 - 0.45 * k))
        if s > 2:
            sprite(frame, sparkle(s, color + (255,)), (x, y), rot=k * 180 + i * 30, alpha=fade)


def confetti_burst(frame, ctx, center, t, dur, n=48, spread=1.0):
    if t < 0 or t > dur:
        return
    k = t / dur
    cols = [(255, 92, 120), (255, 200, 60), (90, 210, 255), (130, 235, 150), (200, 140, 255), (255, 255, 255)]
    for i in range(n):
        ang = (i * 137.5) % 360 * math.pi / 180
        sp = 0.55 + ((i * 37) % 100) / 100 * 0.75
        r = ease_out_cubic(k) * spread * ctx.d * 900 * sp
        x = center[0] + math.cos(ang) * r
        y = center[1] + math.sin(ang) * r * 0.8 + (k ** 2) * ctx.h * 0.45
        w = int(10 * ctx.u)
        h = int(18 * ctx.u)
        piece = Image.new("RGBA", (w, h), cols[i % len(cols)] + (255,))
        sprite(frame, piece, (x, y), rot=(i * 47 + k * 720) % 360, alpha=clamp(1.35 - k * 1.35))


# --------------------------------------------------------------------------- scenes
def scene_logo(frame, ctx: Ctx, t, dur):
    """S1 — the island wakes up and the logo lands with a happy bounce."""
    bg_pan(frame, ctx, BG_ISLAND, t, dur, 1.22, 1.05, 0.5, 0.42)

    # warm sun glow, breathing
    glow(frame, ctx.p(0.5, 0.26), ctx.d * 1500, (255, 236, 180), 0.30 + 0.06 * math.sin(t * 1.6), 2.1)
    Ctx_particles_bokeh.draw(frame, t, alpha=0.75)

    # logo: drops from above, elastic settle, then gentle float
    app = seg(t, 0.35, 1.55)
    if app > 0:
        e = ease_out_elastic(app)
        size = ctx.d * (640 if ctx.portrait else 600)
        # Landscape has half the vertical room, so logo and mascot sit
        # side by side instead of stacked (otherwise the mascot covers
        # the lettering baked into the logo).
        cx, cy = ctx.p(0.5, 0.40) if ctx.portrait else ctx.p(0.37, 0.44)
        y = lerp(-ctx.h * 0.35, cy, ease_out_cubic(seg(t, 0.35, 1.15)))
        float_y = math.sin((t - 1.5) * 1.7) * ctx.u * 12 if t > 1.5 else 0
        sc = lerp(0.55, 1.0, e)
        rot = (1 - ease_out_cubic(app)) * -16 + math.sin(t * 1.4) * 1.2
        glow(frame, (cx, y + float_y), size * 1.5, (255, 240, 190), 0.45 * clamp(app * 2), 2.0)
        sprite(frame, logo_sprite(ctx, size), (cx, y + float_y), scale=sc, rot=rot,
               shadow=1.0, shadow_offset=(0, int(26 * ctx.u)), shadow_blur=int(30 * ctx.u))
        burst(frame, ctx, (cx, cy), t - 1.05, 0.85, n=16, radius=1.15, size=1.15)

    # mascot peeks in from the bottom, waving
    mp = seg(t, 1.25, 2.25)
    if mp > 0:
        h = ctx.d * (700 if ctx.portrait else 620)
        base_y = ctx.h * (0.82 if ctx.portrait else 0.72)
        mx = ctx.w * (0.5 if ctx.portrait else 0.71)
        y = lerp(ctx.h + h * 0.6, base_y, ease_out_back(mp, 1.2))
        mascot_bob(frame, ctx, "wow" if t < 2.6 else "cheer",
                   (mx, y), h, t, rot_amp=4.0, hop_px=ctx.u * 14)

    vignette(frame, 0.30)


def scene_play(frame, ctx: Ctx, t, dur):
    """S2 — Fandoqi bounces between three glowing world bubbles."""
    plate = cover_pan(BG_LEARN, ctx.w, ctx.h,
                      lerp(1.0, 1.16, ease_in_out_cubic(t / dur)), 0.5, 0.55)
    paste_alpha(frame, plate.filter(ImageFilter.GaussianBlur(ctx.u * 4)), (0, 0))
    glow(frame, ctx.p(0.5, 0.5), ctx.d * 1700, (255, 255, 255), 0.16, 2.4)

    bubbles = [
        (f"{A}gateway/bubble_learn.webp", 0.20, 0.30),
        (f"{A}gateway/bubble_story.webp", 0.80, 0.36),
        (f"{A}gateway/bubble_cartoon.webp", 0.50, 0.17),
    ] if ctx.portrait else [
        (f"{A}gateway/bubble_learn.webp", 0.17, 0.34),
        (f"{A}gateway/bubble_story.webp", 0.83, 0.36),
        (f"{A}gateway/bubble_cartoon.webp", 0.50, 0.16),
    ]
    for i, (path, fx, fy) in enumerate(bubbles):
        p = seg(t, 0.25 + i * 0.22, 1.15 + i * 0.22)
        if p <= 0:
            continue
        sc = ease_out_back(p, 2.0)
        cx, cy = ctx.p(fx, fy)
        cy += math.sin(t * 1.5 + i * 2.1) * ctx.u * 18
        cx += math.cos(t * 1.1 + i * 1.4) * ctx.u * 10
        size = ctx.d * (350 if ctx.portrait else 320)
        glow(frame, (cx, cy), size * 1.4, (255, 255, 255), 0.34 * p, 2.0)
        bubble = round_icon(load(path), int(size))
        sprite(frame, bubble, (cx, cy), scale=sc,
               rot=math.sin(t * 1.3 + i) * 4, alpha=clamp(p * 1.4),
               shadow=0.85, shadow_blur=int(24 * ctx.u))

    # mascot: energetic jumping in the lower third
    h = ctx.d * (860 if ctx.portrait else 740)
    cy = ctx.h * (0.72 if ctx.portrait else 0.70)
    jump = hop(t * 1.0 + 0.2, 1.15) * ctx.u * 90
    key = "cheer" if int(t * 1.15) % 2 == 0 else "party"
    mascot_bob(frame, ctx, key, (ctx.w * 0.5, cy - jump), h, t, rot_amp=5.0, hop_px=0)

    # touch ripples where he lands
    land = (t * 1.15) % 1.0
    if land < 0.28:
        k = land / 0.28
        r = ctx.d * 90 + k * ctx.d * 380
        ring = Image.new("RGBA", (int(r * 2), int(r * 0.7)), (0, 0, 0, 0))
        ImageDraw.Draw(ring).ellipse((0, 0, ring.width - 1, ring.height - 1),
                                     outline=(255, 255, 255, int(190 * (1 - k))),
                                     width=max(2, int(7 * ctx.u)))
        paste_alpha(frame, ring, (ctx.w * 0.5 - r, cy + h * 0.45 - r * 0.35))

    Ctx_particles_stars.draw(frame, t, alpha=0.55)
    vignette(frame, 0.26)


def scene_games(frame, ctx: Ctx, t, dur):
    """S3 — a grid of colourful game tiles pops in one by one, then breathes."""
    paste_alpha(frame, gradient(ctx.w, ctx.h, (120, 214, 255), (166, 146, 255)).convert("RGBA"), (0, 0))
    plate = cover_pan(BG_CORAL_W, ctx.w, ctx.h,
                      lerp(1.18, 1.02, ease_in_out_cubic(t / dur)), 0.5, 0.5)
    paste_alpha(frame, plate.filter(ImageFilter.GaussianBlur(ctx.u * 9)), (0, 0), 0.40)
    glow(frame, ctx.p(0.5, 0.44), ctx.d * 1700, (255, 252, 230), 0.30, 2.0)

    cols, rows = (3, 3) if ctx.portrait else (3, 2)
    tiles = GAME_TILES[: cols * rows]
    cell = ctx.d * (330 if ctx.portrait else 320)
    gap = cell * 0.17
    gw = cols * cell + (cols - 1) * gap
    gh = rows * cell + (rows - 1) * gap
    ox = ctx.w / 2 - gw / 2 + cell / 2
    oy = ctx.h * (0.45 if ctx.portrait else 0.44) - gh / 2 + cell / 2

    for i, (path, tint) in enumerate(tiles):
        r, c = divmod(i, cols)
        delay = 0.20 + (r + c) * 0.12 + (i % 2) * 0.03
        p = seg(t, delay, delay + 0.75)
        if p <= 0:
            continue
        e = ease_out_back(p, 2.1)
        cx = ox + c * (cell + gap)
        cy = oy + r * (cell + gap)
        wob = math.sin((t - delay) * 5.0) * (1 - clamp((t - delay - 0.7) / 0.6)) * 5
        bob = math.sin(t * 2.0 + i * 0.8) * ctx.u * 7

        card = game_tile(cell, path, tint)
        glow(frame, (cx, cy + bob), cell * 1.3, (255, 255, 255), 0.24 * p, 2.2)
        sprite(frame, card, (cx, cy + bob), scale=e, rot=wob, alpha=clamp(p * 1.6),
               shadow=0.9, shadow_offset=(0, int(15 * ctx.u)), shadow_blur=int(22 * ctx.u))
        burst(frame, ctx, (cx, cy), t - delay - 0.28, 0.45, n=7, radius=0.42, size=0.55)

    # little mascot cheering from the bottom corner
    mp = seg(t, 1.5, 2.3)
    if mp > 0:
        h = ctx.d * (520 if ctx.portrait else 470)
        cx = ctx.w * (0.79 if ctx.portrait else 0.89)
        cy = ctx.h * (0.86 if ctx.portrait else 0.80)
        y = lerp(ctx.h + h, cy, ease_out_back(mp, 1.4))
        mascot_bob(frame, ctx, "wow", (cx, y), h, t + 1.0, rot_amp=6.0, hop_px=ctx.u * 12)

    Ctx_particles_stars.draw(frame, t, alpha=0.5)
    vignette(frame, 0.24)


def scene_content(frame, ctx: Ctx, t, dur):
    """S4 — stories, lullabies and animals glide past in a 3D-ish carousel."""
    paste_alpha(frame, gradient(ctx.w, ctx.h, (108, 92, 200), (46, 40, 110)).convert("RGBA"), (0, 0))
    plate = cover_pan(BG_CORAL, ctx.w, ctx.h,
                      lerp(1.02, 1.16, ease_in_out_cubic(t / dur)), 0.5, 0.4)
    paste_alpha(frame, plate.filter(ImageFilter.GaussianBlur(ctx.u * 11)), (0, 0), 0.40)
    glow(frame, ctx.p(0.5, 0.44), ctx.d * 1500, (170, 200, 255), 0.30, 2.0)

    cw = ctx.d * (760 if ctx.portrait else 660)
    ch = cw * 1.12
    spacing = cw * 0.86
    speed = 0.62
    intro = ease_out_cubic(seg(t, 0.0, 0.9))
    scroll = (t * speed) * spacing
    cyc = len(CONTENT_CARDS) * spacing
    center_y = ctx.h * (0.45 if ctx.portrait else 0.46)

    drawn = []
    for i, path in enumerate(CONTENT_CARDS):
        x = ctx.w / 2 + ((i * spacing - scroll) % cyc)
        if x > ctx.w / 2 + cyc / 2:
            x -= cyc
        drawn.append((abs(x - ctx.w / 2), i, path, x))
    drawn.sort(reverse=True)

    for dist, i, path, x in drawn:
        f = clamp(dist / (spacing * 1.9))
        sc = lerp(1.0, 0.66, f) * lerp(0.75, 1.0, intro)
        a = clamp((1 - f) * 1.5) * intro
        if a <= 0.02:
            continue
        y = center_y + math.sin(t * 1.4 + i * 1.3) * ctx.u * 16 + f * ctx.u * 40
        rot = (x - ctx.w / 2) / ctx.w * -9
        card = rounded_card(load(path), (cw, ch), int(cw * 0.11), border=int(cw * 0.028))
        if f < 0.35:
            glow(frame, (x, y), cw * 1.15, (255, 240, 200), 0.30 * (1 - f / 0.35), 2.2)
        sprite(frame, card, (x, y), scale=sc, rot=rot, alpha=a,
               shadow=0.95, shadow_offset=(0, int(20 * ctx.u)), shadow_blur=int(26 * ctx.u))

    # dreamy mascot reading along at the bottom
    mp = seg(t, 0.6, 1.5)
    if mp > 0:
        h = ctx.d * (540 if ctx.portrait else 480)
        cx = ctx.w * (0.24 if ctx.portrait else 0.13)
        cy = ctx.h * (0.855 if ctx.portrait else 0.82)
        y = lerp(ctx.h + h, cy, ease_out_back(mp, 1.3))
        mascot_bob(frame, ctx, "think" if t < dur * 0.55 else "wink",
                   (cx, y), h, t + 2.0, rot_amp=3.5, hop_px=ctx.u * 8)

    Ctx_particles_bokeh.draw(frame, t + 3, alpha=0.8)
    vignette(frame, 0.38)


def scene_rewards(frame, ctx: Ctx, t, dur):
    """S5 — stars fly into the trophy, confetti explodes, mascot celebrates."""
    paste_alpha(frame, gradient(ctx.w, ctx.h, (255, 196, 92), (255, 122, 140)).convert("RGBA"), (0, 0))
    paste_alpha(frame, cover_pan(BG_ISLAND, ctx.w, ctx.h,
                                 lerp(1.16, 1.0, ease_in_out_cubic(t / dur)), 0.5, 0.62), (0, 0), 0.38)

    tro_c = ctx.p(0.5, 0.36 if ctx.portrait else 0.36)
    # rotating rays behind the trophy
    rays = Image.new("RGBA", (int(ctx.d * 1800),) * 2, (0, 0, 0, 0))
    rd = ImageDraw.Draw(rays)
    R = rays.width / 2
    for i in range(16):
        a0 = i * 22.5 + t * 10
        rd.pieslice((0, 0, rays.width - 1, rays.height - 1), a0, a0 + 11,
                    fill=(255, 255, 255, 42))
    paste_alpha(frame, rays, (tro_c[0] - R, tro_c[1] - R), 0.55)
    glow(frame, tro_c, ctx.d * 1100, (255, 236, 160), 0.5, 1.9)

    # trophy bounces up
    tp = seg(t, 0.15, 1.15)
    if tp > 0:
        e = ease_out_bounce(tp)
        h = ctx.d * (700 if ctx.portrait else 620)
        y = lerp(tro_c[1] + ctx.h * 0.35, tro_c[1], e)
        sc = lerp(0.6, 1.0, ease_out_back(tp, 1.6)) * breathe(t * 2.2, 3.0, 0.025)
        sprite(frame, fit_h(trophy_clean(), int(h)), (tro_c[0], y), scale=sc,
               rot=math.sin(t * 2.0) * 2.5, shadow=1.0,
               shadow_offset=(0, int(24 * ctx.u)), shadow_blur=int(28 * ctx.u))

    # stars streak in from the edges and land on the trophy
    for i in range(9):
        d0 = 0.55 + i * 0.115
        p = seg(t, d0, d0 + 0.62)
        if p <= 0 or p >= 1:
            if p >= 1:
                # tiny pop where it arrived
                burst(frame, ctx, tro_c, t - (d0 + 0.62), 0.35, n=6, radius=0.3, size=0.5)
            continue
        e = ease_out_cubic(p)
        ang = math.pi * (0.15 + (i % 5) * 0.19) + (math.pi if i % 2 else 0)
        r0 = ctx.d * 1500
        sx = tro_c[0] + math.cos(ang) * r0
        sy = tro_c[1] + math.sin(ang) * r0 * 0.8
        x = lerp(sx, tro_c[0], e)
        y = lerp(sy, tro_c[1], e) - math.sin(p * math.pi) * ctx.u * 120
        s = int(ctx.d * 190 * lerp(1.0, 0.45, e))
        glow(frame, (x, y), s * 1.8, (255, 226, 130), 0.55 * (1 - p * 0.6), 2.0)
        sprite(frame, star_shape(max(8, s)), (x, y), rot=p * 400 + i * 40, alpha=clamp(1.3 - p * 0.5))

    # medal + star badge slide in as side rewards
    for j, (path, fx) in enumerate(((f"{A}premium/medal_gold.webp", 0.18),
                                    (f"{A}premium/star_badge.webp", 0.82))):
        p = seg(t, 1.5 + j * 0.18, 2.25 + j * 0.18)
        if p <= 0:
            continue
        cx = lerp(ctx.w * (fx - 0.45 if fx < 0.5 else fx + 0.45), ctx.w * fx, ease_out_back(p, 1.5))
        cy = ctx.h * (0.60 if ctx.portrait else 0.62) + math.sin(t * 1.8 + j * 2) * ctx.u * 14
        sprite(frame, fit_h(cutout(path), int(ctx.d * 330)), (cx, cy), scale=ease_out_back(p, 1.4),
               rot=math.sin(t * 1.6 + j) * 6, alpha=clamp(p * 1.5),
               shadow=0.9, shadow_blur=int(20 * ctx.u))

    # celebrating mascot
    mp = seg(t, 1.05, 1.9)
    if mp > 0:
        h = ctx.d * (760 if ctx.portrait else 660)
        cy = ctx.h * (0.83 if ctx.portrait else 0.80)
        y = lerp(ctx.h + h, cy, ease_out_back(mp, 1.5))
        mascot_bob(frame, ctx, "party", (ctx.w * 0.5, y - hop(t, 1.9) * ctx.u * 60), h, t,
                   rot_amp=6.0, hop_px=0)

    confetti_burst(frame, ctx, ctx.p(0.5, 0.30), t - 1.25, 2.6, n=54, spread=1.15)
    confetti_burst(frame, ctx, ctx.p(0.5, 0.22), t - 2.4, 2.6, n=40, spread=1.0)
    Ctx_particles_stars.draw(frame, t + 6, alpha=0.6)
    vignette(frame, 0.28)


def scene_final(frame, ctx: Ctx, t, dur):
    """S6 — clean end card: logo, mascot, sparkles, gentle safe-and-offline mood."""
    paste_alpha(frame, gradient(ctx.w, ctx.h, (86, 196, 255), (28, 96, 190)).convert("RGBA"), (0, 0))
    paste_alpha(frame, cover_pan(BG_ISLAND, ctx.w, ctx.h,
                                 lerp(1.05, 1.14, ease_in_out_cubic(t / dur)), 0.5, 0.45), (0, 0), 0.45)
    glow(frame, ctx.p(0.5, 0.40), ctx.d * 1700, (255, 250, 220), 0.34, 2.0)

    lp = seg(t, 0.1, 1.0)
    size = ctx.d * (760 if ctx.portrait else 640)
    # side-by-side end card in landscape — see scene_logo for the reasoning
    cx, cy = ctx.p(0.5, 0.36) if ctx.portrait else ctx.p(0.36, 0.44)
    if lp > 0:
        sc = ease_out_elastic(lp)
        pulse = breathe(t, 1.9, 0.028)
        fy = math.sin(t * 1.5) * ctx.u * 10
        glow(frame, (cx, cy + fy), size * 1.6, (255, 245, 205), 0.5, 1.9)
        # halo ring
        rr = size * (0.72 + 0.05 * math.sin(t * 1.6))
        ring = Image.new("RGBA", (int(rr * 2.4),) * 2, (0, 0, 0, 0))
        ImageDraw.Draw(ring).ellipse((int(rr * 0.2), int(rr * 0.2), int(rr * 2.2), int(rr * 2.2)),
                                     outline=(255, 255, 255, 90), width=max(2, int(5 * ctx.u)))
        paste_alpha(frame, ring, (cx - rr * 1.2, cy + fy - rr * 1.2), 0.8 * lp)
        sprite(frame, logo_sprite(ctx, size), (cx, cy + fy), scale=sc * pulse,
               rot=math.sin(t * 1.2) * 1.5, shadow=1.0,
               shadow_offset=(0, int(26 * ctx.u)), shadow_blur=int(32 * ctx.u))
        burst(frame, ctx, (cx, cy), t - 0.55, 1.0, n=18, radius=1.25, size=1.2)

    mp = seg(t, 0.75, 1.7)
    if mp > 0:
        h = ctx.d * (840 if ctx.portrait else 680)
        mx = ctx.w * (0.5 if ctx.portrait else 0.72)
        y = lerp(ctx.h + h, ctx.h * (0.79 if ctx.portrait else 0.71), ease_out_back(mp, 1.4))
        mascot_bob(frame, ctx, "proud" if t < dur * 0.5 else "cheer",
                   (mx, y), h, t, rot_amp=4.0, hop_px=ctx.u * 16)

    # a soft light sweep across the logo near the end
    sw = seg(t, dur * 0.55, dur * 0.55 + 0.9)
    if 0 < sw < 1:
        band = Image.new("RGBA", (int(ctx.w * 0.22), ctx.h), (255, 255, 255, 0))
        bd = ImageDraw.Draw(band)
        for i in range(band.width):
            a = int(120 * math.sin(math.pi * i / band.width) ** 2)
            bd.line((i, 0, i, ctx.h), fill=(255, 255, 255, a))
        band = band.rotate(14, expand=True, resample=Image.BICUBIC)
        x = lerp(-band.width, ctx.w, ease_in_out_cubic(sw))
        paste_alpha(frame, band, (x, -ctx.h * 0.1), 0.55)

    Ctx_particles_stars.draw(frame, t + 12, alpha=0.7)
    Ctx_particles_bokeh.draw(frame, t + 9, alpha=0.5)
    vignette(frame, 0.30)


# --------------------------------------------------------------------------- registry
Ctx_particles_bokeh: Particles
Ctx_particles_stars: Particles


def init_particles(ctx: Ctx):
    global Ctx_particles_bokeh, Ctx_particles_stars
    Ctx_particles_bokeh = Particles(26, ctx.w, ctx.h, seed=11, kind="bokeh")
    Ctx_particles_stars = Particles(22, ctx.w, ctx.h, seed=29, kind="stars")


SCENES = [
    ("logo", scene_logo, 4.6),
    ("play", scene_play, 4.8),
    ("games", scene_games, 6.9),
    ("content", scene_content, 6.0),
    ("rewards", scene_rewards, 6.6),
    ("final", scene_final, 6.1),
]
