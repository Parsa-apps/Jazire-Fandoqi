#!/usr/bin/env python3
"""
Render the Jazire Fandoqi app promo video.

    python3 tools/promo_video/render.py --preset portrait
    python3 tools/promo_video/render.py --preset landscape --fps 30
    python3 tools/promo_video/render.py --preset both --logo path/to/logo.png

Output: promo/jazire_fandoqi_promo_<preset>.mp4
No on-screen text is drawn anywhere (store-safe, language independent).
"""

from __future__ import annotations

import argparse
import gc
import math
import os
import subprocess
import sys
import time
from concurrent.futures import ProcessPoolExecutor

sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))

from PIL import Image, ImageFilter  # noqa: E402

import scenes as S  # noqa: E402
from engine import clamp, ease_in_out_cubic, lerp, paste_alpha  # noqa: E402

REPO = os.path.dirname(os.path.dirname(os.path.dirname(os.path.abspath(__file__))))

PRESETS = {
    "portrait": (1080, 1920),
    "landscape": (1920, 1080),
    "square": (1080, 1080),
}

XFADE = 0.55  # seconds of cross-dissolve between scenes


# --------------------------------------------------------------------------- timeline
def build_timeline():
    """Returns [(name, fn, start, dur)] with overlapping cross-fades."""
    out = []
    t = 0.0
    for name, fn, dur in S.SCENES:
        out.append((name, fn, t, dur))
        t += dur - XFADE
    total = t + XFADE
    return out, total


# --------------------------------------------------------------------------- frames
_CTX = None
_FRAMES_SINCE_GC = 0


def _init_worker(w, h, logo):
    global _CTX
    if logo:
        S.LOGO = logo
    _CTX = S.Ctx(w, h)
    S.init_particles(_CTX)


def render_frame(args):
    idx, tsec = args
    ctx = _CTX
    timeline, total = build_timeline()

    frame = None
    for name, fn, start, dur in timeline:
        if tsec < start - 1e-6 or tsec > start + dur + 1e-6:
            continue
        local = tsec - start
        layer = Image.new("RGBA", (ctx.w, ctx.h), (0, 0, 0, 255))
        fn(layer, ctx, local, dur)

        if frame is None:
            frame = layer
        else:
            # cross-dissolve with a subtle scale/blur so cuts feel filmic
            k = ease_in_out_cubic(clamp(local / XFADE))
            zoom = lerp(1.06, 1.0, k)
            if zoom > 1.001:
                nw, nh = int(ctx.w * zoom), int(ctx.h * zoom)
                lz = layer.resize((nw, nh), Image.BILINEAR)
                layer = lz.crop(((nw - ctx.w) // 2, (nh - ctx.h) // 2,
                                 (nw - ctx.w) // 2 + ctx.w, (nh - ctx.h) // 2 + ctx.h))
            frame = Image.blend(frame, layer, k)

    if frame is None:
        frame = Image.new("RGBA", (ctx.w, ctx.h), (0, 0, 0, 255))

    # global fade in / out
    fin = clamp(tsec / 0.5)
    fout = clamp((total - tsec) / 0.7)
    f = min(fin, fout)
    if f < 0.999:
        frame = Image.blend(Image.new("RGBA", frame.size, (0, 0, 0, 255)), frame, f)

    # keep worker memory flat on small machines
    global _FRAMES_SINCE_GC
    _FRAMES_SINCE_GC += 1
    if _FRAMES_SINCE_GC >= 10:
        _FRAMES_SINCE_GC = 0
        from engine import _scaled, cutout
        _scaled.cache_clear()
        gc.collect()

    return idx, frame.convert("RGB").tobytes()


# --------------------------------------------------------------------------- audio
def ffmpeg_exe():
    import imageio_ffmpeg
    return imageio_ffmpeg.get_ffmpeg_exe()


def build_audio(total, out_path, vo_dir, sfx_dir, fps):
    """Music bed (synthesised) + SFX from the app + Persian voice-over."""
    import audio_mix
    audio_mix.build(total, out_path, vo_dir, sfx_dir)


# --------------------------------------------------------------------------- main
def main():
    ap = argparse.ArgumentParser()
    ap.add_argument("--preset", default="portrait",
                    choices=list(PRESETS) + ["both", "all"])
    ap.add_argument("--fps", type=int, default=30)
    ap.add_argument("--scale", type=float, default=1.0,
                    help="render at a fraction of the preset size (fast previews)")
    ap.add_argument("--logo", default=None, help="path to the logo image to use")
    ap.add_argument("--vo-dir", default=os.path.join(os.path.dirname(os.path.abspath(__file__)), "vo"),
                    help="directory holding the Persian voice-over clips (s1..s6.mp3)")
    ap.add_argument("--workers", type=int, default=max(1, (os.cpu_count() or 2)))
    ap.add_argument("--outdir", default=os.path.join(REPO, "promo"))
    ap.add_argument("--audio", default=None, help="pre-built audio track to mux")
    ap.add_argument("--crf", type=int, default=19)
    args = ap.parse_args()

    presets = (["portrait", "landscape"] if args.preset == "both"
               else list(PRESETS) if args.preset == "all" else [args.preset])

    os.makedirs(args.outdir, exist_ok=True)
    _, total = build_timeline()
    nframes = int(round(total * args.fps))
    print(f"duration {total:.2f}s  frames {nframes}  fps {args.fps}")

    audio = args.audio
    if audio is None:
        audio = os.path.join(REPO, ".tmp_build", "mix.m4a")
        os.makedirs(os.path.dirname(audio), exist_ok=True)
        build_audio(total, audio, args.vo_dir,
                    os.path.join(REPO, "assets", "audio", "sfx"), args.fps)

    for preset in presets:
        w, h = PRESETS[preset]
        w, h = int(w * args.scale) // 2 * 2, int(h * args.scale) // 2 * 2
        out = os.path.join(args.outdir, f"jazire_fandoqi_promo_{preset}.mp4")
        print(f"\n=== {preset} {w}x{h} -> {out}")

        cmd = [
            ffmpeg_exe(), "-y",
            "-f", "rawvideo", "-pix_fmt", "rgb24", "-s", f"{w}x{h}", "-r", str(args.fps), "-i", "-",
            "-i", audio,
            "-map", "0:v", "-map", "1:a",
            "-c:v", "libx264", "-preset", "slow", "-crf", str(args.crf),
            "-pix_fmt", "yuv420p", "-profile:v", "high", "-level", "4.1",
            "-movflags", "+faststart", "-g", str(args.fps * 2),
            "-c:a", "aac", "-b:a", "192k", "-ar", "48000",
            "-shortest", out,
        ]
        proc = subprocess.Popen(cmd, stdin=subprocess.PIPE,
                                stdout=subprocess.DEVNULL, stderr=subprocess.PIPE)

        t0 = time.time()
        jobs = [(i, i / args.fps) for i in range(nframes)]
        with ProcessPoolExecutor(max_workers=args.workers,
                                 initializer=_init_worker,
                                 initargs=(w, h, args.logo)) as ex:
            for i, (idx, buf) in enumerate(ex.map(render_frame, jobs, chunksize=2)):
                proc.stdin.write(buf)
                if i % 30 == 0 or i == nframes - 1:
                    el = time.time() - t0
                    print(f"  {i + 1}/{nframes}  {el:.0f}s", flush=True)
        proc.stdin.close()
        err = proc.stderr.read().decode()[-1500:]
        rc = proc.wait()
        if rc != 0:
            print(err)
            sys.exit(rc)
        print(f"  done in {time.time() - t0:.0f}s -> {out} "
              f"({os.path.getsize(out) / 1e6:.1f} MB)")


if __name__ == "__main__":
    main()
