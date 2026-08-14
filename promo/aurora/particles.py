#!/usr/bin/env python3
"""Generate looping transparent particle overlays (bubbles, stars, sparkles,
confetti, light dust) as RGBA PNG sequences for ffmpeg overlay."""
import os, math, random
import numpy as np
from PIL import Image

BASE = os.path.dirname(os.path.abspath(__file__))
FX = os.path.join(BASE, "fx")
W, H = 1920, 1080
N_FRAMES = 60
FPS = 30

def blit_glow(img, cx, cy, r, color, intensity):
    """source-over composite a soft gaussian dot onto img (float straight RGBA 0..1)."""
    Hh, Ww = img.shape[:2]
    k = r * 3.0
    x0 = max(0, int(cx - k)); x1 = min(Ww, int(cx + k + 1))
    y0 = max(0, int(cy - k)); y1 = min(Hh, int(cy + k + 1))
    if x1 <= x0 or y1 <= y0:
        return
    yy, xx = np.mgrid[y0:y1, x0:x1]
    d2 = (xx - cx) ** 2 + (yy - cy) ** 2
    a = np.exp(-d2 / (2.0 * (r * 0.55) ** 2)) * intensity
    a = np.clip(a, 0.0, 1.0)
    reg = img[y0:y1, x0:x1]
    src = np.array(color, dtype=np.float32) / 255.0
    sa = a[..., None]
    da = reg[..., 3:4]
    drgb = reg[..., :3]
    out_a = sa + da * (1.0 - sa)
    # avoid div by zero
    safe = np.where(out_a > 1e-6, out_a, 1.0)
    out_rgb = (src * sa + drgb * da * (1.0 - sa)) / safe
    reg[..., :3] = out_rgb
    reg[..., 3] = out_a[..., 0]

def save_seq(folder, frames):
    os.makedirs(folder, exist_ok=True)
    for i, arr in enumerate(frames):
        u = np.clip(arr * 255.0, 0, 255).astype(np.uint8)
        Image.fromarray(u, "RGBA").save(os.path.join(folder, f"{i:04d}.png"))

# ---------- particle definitions (sample(t) -> (x,y,r,alpha,color)) ----------
def make_sparkles(seed):
    rnd = random.Random(seed)
    ps = []
    n = 55
    for _ in range(n):
        x = rnd.uniform(0.05, 0.95) * W
        y = rnd.uniform(0.05, 0.95) * H
        r = rnd.uniform(3.0, 9.0)
        speed = rnd.uniform(0.6, 1.6)
        phase = rnd.uniform(0, 2 * math.pi)
        drift = rnd.uniform(-6, 6)
        gold = rnd.random() < 0.4
        color = (255, 224, 150) if gold else (255, 255, 255)
        ps.append((x, y, r, speed, phase, drift, color))
    def sample(t, p):
        x, y, r, speed, phase, drift, color = p
        tw = (math.sin(2 * math.pi * (t * speed) + phase) + 1) / 2
        return x + drift * math.sin(2 * math.pi * t + phase), y + 8 * math.sin(2 * math.pi * t + phase), r * (0.6 + 0.5 * tw), 0.25 + 0.75 * tw, color
    return ps, sample

def make_stars(seed):
    rnd = random.Random(seed)
    ps = []
    n = 16
    for _ in range(n):
        x = rnd.uniform(0.05, 0.95) * W
        y = rnd.uniform(0.05, 0.7) * H
        r = rnd.uniform(6.0, 16.0)
        speed = rnd.uniform(0.5, 1.2)
        phase = rnd.uniform(0, 2 * math.pi)
        color = (255, 236, 170)
        ps.append((x, y, r, speed, phase, color))
    def sample(t, p):
        x, y, r, speed, phase, color = p
        tw = (math.sin(2 * math.pi * (t * speed) + phase) + 1) / 2
        return x, y, r * (0.5 + 0.5 * tw), 0.3 + 0.7 * tw, color
    return ps, sample

def make_bubbles(seed):
    rnd = random.Random(seed)
    ps = []
    n = 28
    for _ in range(n):
        x = rnd.uniform(0.03, 0.97) * W
        y = rnd.uniform(0.0, 1.0) * H
        r = rnd.uniform(6.0, 22.0)
        speed = rnd.uniform(0.18, 0.45)
        phase = rnd.uniform(0, 2 * math.pi)
        wob = rnd.uniform(4, 16)
        ps.append((x, y, r, speed, phase, wob))
    def sample(t, p):
        x, y, r, speed, phase, wob = p
        yy = (y - (t * speed) * H) % (H + 2 * r) - r
        xx = x + wob * math.sin(2 * math.pi * t * 0.7 + phase)
        a = 0.35 + 0.3 * math.sin(2 * math.pi * t + phase)
        return xx, yy, r, a, (210, 240, 255)
    return ps, sample

def make_confetti(seed):
    rnd = random.Random(seed)
    palette = [(255, 90, 90), (255, 180, 60), (90, 210, 120), (90, 160, 255),
               (255, 120, 200), (235, 220, 100), (140, 120, 255)]
    ps = []
    n = 46
    for _ in range(n):
        x = rnd.uniform(0.0, 1.0) * W
        y = rnd.uniform(0.0, 1.0) * H
        r = rnd.uniform(3.0, 7.0)
        speed = rnd.uniform(0.25, 0.6)
        drift = rnd.uniform(8, 26)
        color = rnd.choice(palette)
        ps.append((x, y, r, speed, drift, color))
    def sample(t, p):
        x, y, r, speed, drift, color = p
        yy = (y + t * speed * H) % (H + 2 * r) - r
        xx = x + drift * math.sin(2 * math.pi * t * 0.5 + x)
        return xx, yy, r, 0.85, color
    return ps, sample

def make_dust(seed):
    rnd = random.Random(seed)
    ps = []
    n = 40
    for _ in range(n):
        x = rnd.uniform(0.0, 1.0) * W
        y = rnd.uniform(0.0, 1.0) * H
        r = rnd.uniform(2.0, 5.0)
        speed = rnd.uniform(0.05, 0.12)
        phase = rnd.uniform(0, 2 * math.pi)
        ps.append((x, y, r, speed, phase))
    def sample(t, p):
        x, y, r, speed, phase = p
        yy = (y - t * speed * H) % (H + 2 * r) - r
        xx = x + 10 * math.sin(2 * math.pi * t * 0.4 + phase)
        a = 0.12 + 0.15 * math.sin(2 * math.pi * t + phase)
        return xx, yy, r, a, (255, 250, 235)
    return ps, sample

def render(name, maker, seed):
    ps, sample = maker(seed)
    frames = []
    for f in range(N_FRAMES):
        t = f / N_FRAMES
        img = np.zeros((H, W, 4), dtype=np.float32)
        for p in ps:
            x, y, r, a, c = sample(t, p)
            blit_glow(img, x, y, r, c, a)
        frames.append(img)
    save_seq(os.path.join(FX, name), frames)
    print(f"rendered {name}: {len(frames)} frames")

if __name__ == "__main__":
    render("sparkles", make_sparkles, 1)
    render("stars", make_stars, 2)
    render("bubbles", make_bubbles, 3)
    render("confetti", make_confetti, 4)
    render("dust", make_dust, 5)
    print("done")
