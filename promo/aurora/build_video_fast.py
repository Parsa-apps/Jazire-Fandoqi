#!/usr/bin/env python3
"""Fast rebuild of the Aurora promo (same look as build_video_v2.py, ~50x faster).

Why: `minterpolate=mi_mode=blend` at 1080p is unusably slow on small CPUs
(>10 min per 2 s clip). Its output for 2 keyframes is just a linear cross-blend,
so we do the blend + particle compositing directly with numpy and pipe raw
frames to x264.

Pass 1: 2 s looping motion clip per scene (ping-pong blend + particle overlays).
Pass 2: loop each clip, xfade assemble, mix Persian narration.
"""
import os
import subprocess

import numpy as np
from PIL import Image
import imageio_ffmpeg

FF = imageio_ffmpeg.get_ffmpeg_exe()
BASE = os.path.dirname(os.path.abspath(__file__))
CLIPS = os.path.join(BASE, "clips")
os.makedirs(CLIPS, exist_ok=True)

W, H = 1920, 1080
FPS = 30
LOOP_FRAMES = 60          # 2.0 s loop
XF, TAIL, LEAD = 0.8, 0.9, 0.35

# scene -> (keyframes, particle fx)
scenes = [
    ("01-hero",       ["01-hero.jpg", "frames/01-hero-f2.jpg"], ["sparkles", "dust"]),
    ("02-cartoon",    ["02-cartoon.jpg", "frames/02-cartoon-f2.jpg"], ["sparkles"]),
    ("03-story",      ["03-story.jpg", "frames/03-story-f2.jpg"], ["sparkles", "dust"]),
    ("04-game",       ["04-game.jpg"], ["confetti"]),
    ("05-lullaby",    ["05-lullaby.jpg", "frames/05-lullaby-f2.jpg"], ["stars", "sparkles"]),
    ("06-profile",    ["06-profile.jpg", "frames/06-profile-f2.jpg"], ["sparkles", "dust"]),
    ("07-about",      ["07-about.jpg", "frames/07-about-f2.jpg"], ["sparkles"]),
    ("08-underwater", ["08-underwater.jpg", "frames/08-underwater-f2.jpg"], ["bubbles", "dust"]),
]

nars = ["nar-%02d.mp3" % (i + 1) for i in range(8)]


def cover(path):
    """Load an image scaled to cover WxH then center-cropped."""
    im = Image.open(os.path.join(BASE, path)).convert("RGB")
    s = max(W / im.width, H / im.height)
    im = im.resize((max(W, int(round(im.width * s))),
                    max(H, int(round(im.height * s)))), Image.LANCZOS)
    x = (im.width - W) // 2
    y = (im.height - H) // 2
    return np.asarray(im.crop((x, y, x + W, y + H)), dtype=np.float32)


def fx_files(name):
    """Sorted frame paths of a looping RGBA particle sequence."""
    d = os.path.join(BASE, "fx", name)
    return [os.path.join(d, f) for f in sorted(os.listdir(d)) if f.endswith(".png")]


def fx_frame(path):
    """Decode one particle frame as (premultiplied rgb, alpha). Decoded lazily:
    caching every layer in RAM needs ~2 GB and gets the process OOM-killed."""
    im = Image.open(path).convert("RGBA")
    if im.size != (W, H):
        im = im.resize((W, H), Image.BILINEAR)
    a = np.asarray(im, dtype=np.float32)
    al = a[..., 3:4] / 255.0
    return a[..., :3] * al, al


def dur(path):
    out = subprocess.check_output([FF, "-i", path, "-f", "null", "-"],
                                  stderr=subprocess.STDOUT).decode("utf-8", "ignore")
    for line in out.splitlines():
        if "Duration:" in line:
            h, m, s = line.split("Duration:")[1].split(",")[0].strip().split(":")
            return int(h) * 3600 + int(m) * 60 + float(s)
    raise RuntimeError("no duration: " + path)


def zoom(base, z):
    """Center 'breathing' zoom for single-keyframe scenes."""
    if abs(z - 1.0) < 1e-4:
        return base
    cw, ch = int(W / z), int(H / z)
    x, y = (W - cw) // 2, (H - ch) // 2
    im = Image.fromarray(base.astype(np.uint8)[y:y + ch, x:x + cw])
    return np.asarray(im.resize((W, H), Image.BILINEAR), dtype=np.float32)


def build_clip(idx, name, kfs, fxs):
    out = os.path.join(CLIPS, "clip%02d.mp4" % idx)
    imgs = [cover(k) for k in kfs]
    layers = [fx_files(f) for f in fxs]

    proc = subprocess.Popen(
        [FF, "-y", "-f", "rawvideo", "-pix_fmt", "rgb24", "-s", "%dx%d" % (W, H),
         "-framerate", str(FPS), "-i", "pipe:0",
         "-c:v", "libx264", "-preset", "veryfast", "-crf", "17",
         "-pix_fmt", "yuv420p", "-r", str(FPS), out],
        stdin=subprocess.PIPE, stdout=subprocess.DEVNULL, stderr=subprocess.DEVNULL)

    for i in range(LOOP_FRAMES):
        p = i / LOOP_FRAMES
        if len(imgs) >= 2:
            # smooth ping-pong blend between the two keyframes
            t = 0.5 - 0.5 * np.cos(2.0 * np.pi * p)
            frame = imgs[0] * (1.0 - t) + imgs[1] * t
        else:
            frame = zoom(imgs[0], 1.0 + 0.04 * (0.5 - 0.5 * np.cos(2.0 * np.pi * p)))
        for files in layers:
            rgb, alpha = fx_frame(files[i % len(files)])
            frame = frame * (1.0 - alpha) + rgb
        proc.stdin.write(np.clip(frame, 0, 255).astype(np.uint8).tobytes())
    proc.stdin.close()
    if proc.wait() != 0:
        raise RuntimeError("encode failed: " + out)
    print("clip%02d (%s) ok" % (idx, name), flush=True)


def main():
    for i, (name, kfs, fxs) in enumerate(scenes, start=1):
        build_clip(i, name, kfs, fxs)

    # ---------------- Pass 2: assemble ----------------
    N = len(scenes)
    D = [dur(os.path.join(BASE, n)) + TAIL for n in nars]
    offsets, start_t = [], [0.0]
    offsets.append(D[0] - XF)
    for i in range(1, N):
        start_t.append(offsets[i - 1])
        offsets.append(offsets[i - 1] + D[i] - XF)
    total = start_t[-1] + D[-1]

    inputs = []
    for i in range(N):
        inputs += ["-stream_loop", "-1", "-i", os.path.join(CLIPS, "clip%02d.mp4" % (i + 1))]
    for n in nars:
        inputs += ["-i", os.path.join(BASE, n)]

    parts = []
    for i in range(N):
        parts.append(f"[{i}:v]trim=duration={D[i]:.3f},setpts=PTS-STARTPTS,fps={FPS}[v{i}]")
    prev = "v0"
    for i in range(1, N):
        parts.append(f"[{prev}][v{i}]xfade=transition=fade:duration={XF}:"
                     f"offset={offsets[i-1]:.3f}[x{i}]")
        prev = f"x{i}"
    amix = []
    for i in range(N):
        delay = int(round((start_t[i] + LEAD) * 1000))
        parts.append(f"[{N+i}:a]aformat=sample_rates=44100:channel_layouts=stereo,"
                     f"adelay={delay}:all=1[a{i}]")
        amix.append(f"[a{i}]")
    parts.append("".join(amix) + f"amix=inputs={N}:duration=longest:normalize=0,"
                 f"afade=t=in:st=0:d=1.0,afade=t=out:st={total-1.5:.3f}:d=1.5[aout]")

    out = os.path.join(BASE, "Jazire-Fandoqi-Aurora-Promo.mp4")
    print("assembling final video...", flush=True)
    subprocess.run([FF, "-y", *inputs, "-filter_complex", ";".join(parts),
                    "-map", f"[{prev}]", "-map", "[aout]",
                    "-c:v", "libx264", "-preset", "veryfast", "-crf", "20",
                    "-pix_fmt", "yuv420p", "-r", str(FPS),
                    "-c:a", "aac", "-b:a", "192k",
                    "-t", f"{total:.3f}", "-movflags", "+faststart", out], check=True)
    print("done ->", out, "| total", round(total, 2), "s")


if __name__ == "__main__":
    main()
