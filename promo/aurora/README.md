# Aurora Soft-3D Promo — جزیره فندقی

A cinematic promo video for the **Jazire Fandoqi** kids app, generated from the
"Aurora" design brief (soft-3D toon style, vertical island map, the Fandogh
hazelnut mascot).

## Output

| File | Size | Use |
| --- | --- | --- |
| `Jazire-Fandoqi-Aurora-Promo.mp4` | 1920×1080, 30 fps | YouTube / website / press kit / social |

Duration ≈ 77 s, H.264 High profile + AAC 192 kbps, `+faststart`, yuv420p.

## Storyboard

**Mascot:** Fandoghi is the **hazelnut/nut character** — brown textured shell, a
small stem with a single green leaf on top, big glossy eyes, thick eyebrows and
rosy cheeks (see `assets/mascot/Screenshot_20260811_063705.jpg`). He is *not* a
bunny; scenes 1 and 4 were re-rendered to correct an earlier mix-up.

| # | Scene | Motion | Particle FX |
| --- | --- | --- | --- |
| 1 | Fandoghi intro (hazelnut + leaf) | blink, leaf sway | sparkles + dust |
| 2 | Cartoon cabin + magic TV | flying bird, screen glow | sparkles |
| 3 | Story bridge + open book | page turn | sparkles + dust |
| 4 | Game: boy + Fandoghi + treasure chest | breathing zoom | confetti |
| 5 | Lullaby: moon + stars | shooting star, twinkle | stars + sparkles |
| 6 | Profile: wooden home + name board | door opening | sparkles + dust |
| 7 | About: seaside boulder + info icon | icon spin, waves | sparkles |
| 8 | Underwater world | fish + turtle swim | bubbles + dust |

Persian narration (child-friendly female voice) is timed to each scene.

## How it's built

The video is assembled with ffmpeg (no editor):

1. **`particles.py`** — renders looping transparent particle overlays
   (bubbles, stars, sparkles, confetti, dust) as RGBA PNG sequences with
   numpy/PIL.
2. **`build_video_fast.py`** — ⭐ the pipeline actually used now. Same two passes
   and the same output look, but the per-scene keyframe blend and particle
   compositing are done in numpy and piped raw to x264. Full 77 s rebuild takes
   ~2 minutes instead of hours.
3. **`build_video_v2.py`** — the original pipeline, kept for reference. It uses
   ffmpeg `minterpolate=mi_mode=blend`, which is unusably slow at 1080p on small
   CPUs (>10 min for a single 2 s clip). Prefer `build_video_fast.py`.
4. **`finalize.py`** — re-render a single corrupted clip and re-assemble,
   useful for incremental fixes.

Rebuild from scratch:

```bash
cd promo/aurora
python3 particles.py          # renders fx/ overlays (gitignored)
python3 build_video_fast.py   # -> Jazire-Fandoqi-Aurora-Promo.mp4
```

Source scene images (`NN-*.jpg`) and animation keyframes (`frames/`) are the
AI-generated Soft-3D artwork; `nar-*.mp3` are the Persian voice-over clips.
