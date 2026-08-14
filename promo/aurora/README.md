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

| # | Scene | Motion | Particle FX |
| --- | --- | --- | --- |
| 1 | Fandogh intro (hazelnut + leaf) | blink, leaf sway | sparkles + dust |
| 2 | Cartoon cabin + magic TV | flying bird, screen glow | sparkles |
| 3 | Story bridge + open book | page turn | sparkles + dust |
| 4 | Game: boy + minion + treasure chest | breathing zoom | confetti |
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
2. **`build_video_v2.py`** — the full two-pass pipeline: per-scene motion clips
   (`minterpolate` between AI-generated keyframes + particle overlays), then
   crossfade assembly + narration mix.
3. **`finalize.py`** — re-render a single corrupted clip and re-assemble,
   useful for incremental fixes.

Source scene images (`NN-*.jpg`) and animation keyframes (`frames/`) are the
AI-generated Soft-3D artwork; `nar-*.mp3` are the Persian voice-over clips.
