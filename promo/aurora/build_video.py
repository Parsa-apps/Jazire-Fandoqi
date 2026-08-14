#!/usr/bin/env python3
"""Build the Jazire Fandoqi (Aurora Soft-3D) promo video.

- 8 generated scenes with Ken Burns pan/zoom
- crossfade transitions
- Persian narration timed to each scene
"""
import subprocess, os, sys
import imageio_ffmpeg

FF = imageio_ffmpeg.get_ffmpeg_exe()
BASE = os.path.dirname(os.path.abspath(__file__))

scenes = [
    ("01-hero",       "nar-01.mp3"),
    ("02-cartoon",    "nar-02.mp3"),
    ("03-story",      "nar-03.mp3"),
    ("04-game",       "nar-04.mp3"),
    ("05-lullaby",    "nar-05.mp3"),
    ("06-profile",    "nar-06.mp3"),
    ("07-about",      "nar-07.mp3"),
    ("08-underwater", "nar-08.mp3"),
]

FPS = 30
W, H = 1920, 1080
XF = 0.8        # crossfade seconds between scenes
TAIL = 0.9      # extra tail after each narration
LEAD = 0.35     # narration lead-in after scene appears

def dur(path):
    out = subprocess.check_output(
        [FF, "-i", path, "-f", "null", "-"], stderr=subprocess.STDOUT
    ).decode("utf-8", "ignore")
    for line in out.splitlines():
        if "Duration:" in line:
            t = line.split("Duration:")[1].split(",")[0].strip()
            h, m, s = t.split(":")
            return int(h) * 3600 + int(m) * 60 + float(s)
    raise RuntimeError("no duration for " + path)

nars = [dur(os.path.join(BASE, n)) for _, n in scenes]
D = [n + TAIL for n in nars]          # scene durations
frames = [int(round(d * FPS)) for d in D]

# xfade offsets and scene start times
offsets = []
start_t = [0.0]
acc = D[0]
offsets.append(acc - XF)
for i in range(1, len(scenes)):
    start_t.append(offsets[i - 1])
    acc = offsets[i - 1] + D[i]
    offsets.append(acc - XF)

total_video = offsets[-1] + D[-1]
print("narration durations:", [round(n, 2) for n in nars])
print("scene durations     :", [round(d, 2) for d in D])
print("total video         :", round(total_video, 2), "s")

# ---- build filter graph ----
fparts = []
inputs = []
# image inputs first (single image each, no -loop; zoompan drives frames)
for i, (name, _) in enumerate(scenes):
    inputs += ["-i", os.path.join(BASE, name + ".jpg")]
# narration inputs
for _, n in scenes:
    inputs += ["-i", os.path.join(BASE, n)]

N = len(scenes)
# Ken Burns per scene: alternate zoom-in / zoom-out + gentle pan
for i in range(N):
    fr = frames[i]
    if i % 2 == 0:
        z = f"1.0+0.16*on/{fr}"
    else:
        z = f"1.16-0.16*on/{fr}"
    # slight horizontal drift for some scenes
    if i in (1, 4, 6):
        x = f"(iw-iw/zoom)/2+30*sin(2*3.14159*on/{fr})"
    else:
        x = "(iw-iw/zoom)/2"
    fparts.append(
        f"[{i}:v]scale={W}:{H}:force_original_aspect_ratio=increase,"
        f"crop={W}:{H},format=yuv420p,"
        f"zoompan=z='{z}':x='{x}':y='(ih-ih/zoom)/2':"
        f"d={fr}:s={W}x{H}:fps={FPS}[v{i}]"
    )

# crossfade chain
prev = "v0"
for i in range(1, N):
    out = f"x{i}"
    fparts.append(
        f"[{prev}][v{i}]xfade=transition=fade:duration={XF}:"
        f"offset={offsets[i-1]:.3f}[{out}]"
    )
    prev = out

# audio: delay each narration to its scene start + lead, then mix
amix_in = []
for i, n in enumerate(scenes):
    delay_ms = int(round((start_t[i] + LEAD) * 1000))
    fparts.append(
        f"[{N+i}:a]aformat=sample_rates=44100:channel_layouts=stereo,"
        f"adelay={delay_ms}:all=1[a{i}]"
    )
    amix_in.append(f"[a{i}]")
amix = "".join(amix_in)
fparts.append(
    f"{amix}amix=inputs={N}:duration=longest:normalize=0,"
    f"afade=t=in:st=0:d=1.0,"
    f"afade=t=out:st={total_video-1.5:.3f}:d=1.5[aout]"
)

filter_complex = ";".join(fparts)

out = os.path.join(BASE, "fandoghi_promo.mp4")
cmd = [
    FF, "-y",
    *inputs,
    "-filter_complex", filter_complex,
    "-map", f"[{prev}]",
    "-map", "[aout]",
    "-c:v", "libx264", "-preset", "medium", "-crf", "19",
    "-r", str(FPS),
    "-c:a", "aac", "-b:a", "192k",
    "-t", f"{total_video:.3f}",
    "-movflags", "+faststart",
    out,
]
print("running ffmpeg...")
subprocess.run(cmd, check=True)
print("done ->", out)
