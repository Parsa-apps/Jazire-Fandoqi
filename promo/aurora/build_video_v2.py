#!/usr/bin/env python3
"""Build v2 promo: real per-scene motion (interpolated keyframes) + particle overlays + narration.

Pass 1: render a 2s looping "motion clip" per scene (minterpolate + particles).
Pass 2: loop each clip, crossfade, mix narration.
"""
import os, subprocess, shutil
import imageio_ffmpeg

FF = imageio_ffmpeg.get_ffmpeg_exe()
BASE = os.path.dirname(os.path.abspath(__file__))
TMP = os.path.join(BASE, "tmp")
CLIPS = os.path.join(BASE, "clips")
os.makedirs(TMP, exist_ok=True)
os.makedirs(CLIPS, exist_ok=True)

W, H = 1920, 1080
FPS = 30
XF = 0.8
TAIL = 0.9
LEAD = 0.35

# scene -> (keyframes [distinct], particle fx list)
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

def dur(path):
    out = subprocess.check_output([FF, "-i", path, "-f", "null", "-"],
                                  stderr=subprocess.STDOUT).decode("utf-8", "ignore")
    for line in out.splitlines():
        if "Duration:" in line:
            t = line.split("Duration:")[1].split(",")[0].strip()
            h, m, s = t.split(":")
            return int(h) * 3600 + int(m) * 60 + float(s)
    raise RuntimeError("no duration: " + path)

def run(cmd):
    print(" ".join(cmd[:20]), "...")
    subprocess.run(cmd, check=True)

# ---------------- Pass 1: motion clips ----------------
for idx, (name, kfs, fxs) in enumerate(scenes):
    i = idx + 1
    scene_dir = os.path.join(TMP, f"scene{i:02d}")
    shutil.rmtree(scene_dir, ignore_errors=True)
    os.makedirs(scene_dir, exist_ok=True)
    # ping-pong keyframe order -> 4 frames = 2.0s loop @ 2fps
    if len(kfs) >= 3:
        order = [kfs[0], kfs[1], kfs[2], kfs[1]]
    elif len(kfs) == 2:
        order = [kfs[0], kfs[1], kfs[0], kfs[1]]
    else:
        order = [kfs[0]]
    for n, src in enumerate(order):
        shutil.copy(os.path.join(BASE, src), os.path.join(scene_dir, f"{n:02d}.jpg"))

    clip = os.path.join(CLIPS, f"clip{i:02d}.mp4")
    cmd = [FF, "-y"]

    if len(kfs) >= 2:
        # interpolate between keyframes for real motion
        cmd += ["-framerate", "2", "-i", os.path.join(scene_dir, "%02d.jpg")]
        vchain = ("[0:v]scale=%d:%d:force_original_aspect_ratio=increase,crop=%d:%d,"
                  "minterpolate=fps=%d:mi_mode=blend:scd=none,format=yuv420p[b0]"
                  % (W, H, W, H, FPS))
    else:
        # single image -> breathing zoom via zoompan (game scene)
        cmd += ["-i", os.path.join(scene_dir, "00.jpg")]
        vchain = ("[0:v]scale=%d:%d:force_original_aspect_ratio=increase,crop=%d:%d,"
                  "zoompan=z='1+0.04*sin(2*PI*on/60)':x='(iw-iw/zoom)/2':"
                  "y='(ih-ih/zoom)/2':d=60:s=%dx%d:fps=%d,format=yuv420p[b0]"
                  % (W, H, W, H, W, H, FPS))

    # particle inputs
    for fx in fxs:
        cmd += ["-stream_loop", "-1", "-framerate", str(FPS),
                "-i", os.path.join(BASE, "fx", fx, "%04d.png")]

    parts = [vchain]
    cur = "b0"
    for j in range(len(fxs)):
        o = f"o{j}"
        parts.append(f"[{1 + j}:v]format=rgba,fps={FPS}[{o}]")
        nxt = f"b{j + 1}"
        parts.append(f"[{cur}][{o}]overlay=eof_action=repeat[{nxt}]")
        cur = nxt

    fc = ";".join(parts)
    cmd += ["-filter_complex", fc, "-map", f"[{cur}]",
            "-t", "2.0", "-r", str(FPS),
            "-c:v", "libx264", "-preset", "fast", "-crf", "18", "-pix_fmt", "yuv420p",
            clip]
    run(cmd)

# ---------------- Pass 2: assemble ----------------
D = [dur(os.path.join(BASE, n)) + TAIL for n in nars]
offsets, start_t = [], [0.0]
acc = D[0]
offsets.append(acc - XF)
for i in range(1, len(scenes)):
    start_t.append(offsets[i - 1])
    acc = offsets[i - 1] + D[i]
    offsets.append(acc - XF)
total = start_t[-1] + D[-1]

inputs = []
for i in range(len(scenes)):
    inputs += ["-stream_loop", "-1", "-i", os.path.join(CLIPS, f"clip{i+1:02d}.mp4")]
for n in nars:
    inputs += ["-i", os.path.join(BASE, n)]

N = len(scenes)
parts = []
for i in range(N):
    parts.append(f"[{i}:v]trim=duration={D[i]:.3f},setpts=PTS-STARTPTS,fps={FPS}[v{i}]")
prev = "v0"
for i in range(1, N):
    out = f"x{i}"
    parts.append(f"[{prev}][v{i}]xfade=transition=fade:duration={XF}:offset={offsets[i-1]:.3f}[{out}]")
    prev = out
amix_in = []
for i in range(N):
    delay_ms = int(round((start_t[i] + LEAD) * 1000))
    parts.append(f"[{N+i}:a]aformat=sample_rates=44100:channel_layouts=stereo,adelay={delay_ms}:all=1[a{i}]")
    amix_in.append(f"[a{i}]")
parts.append("".join(amix_in) +
             f"amix=inputs={N}:duration=longest:normalize=0,"
             f"afade=t=in:st=0:d=1.0,afade=t=out:st={total-1.5:.3f}:d=1.5[aout]")
fc = ";".join(parts)

out = os.path.join(BASE, "Jazire-Fandoqi-Aurora-Promo-v2.mp4")
cmd = [FF, "-y", *inputs, "-filter_complex", fc,
       "-map", f"[{prev}]", "-map", "[aout]",
       "-c:v", "libx264", "-preset", "medium", "-crf", "19", "-pix_fmt", "yuv420p",
       "-r", str(FPS), "-c:a", "aac", "-b:a", "192k",
       "-t", f"{total:.3f}", "-movflags", "+faststart", out]
run(cmd)
print("done ->", out, "| total", round(total, 2), "s")
