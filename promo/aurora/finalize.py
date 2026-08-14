#!/usr/bin/env python3
"""Rebuild clip02 (2-frame) then assemble final video from existing clips."""
import os, subprocess
import imageio_ffmpeg

FF = imageio_ffmpeg.get_ffmpeg_exe()
BASE = os.path.dirname(os.path.abspath(__file__))
W, H, FPS = 1920, 1080, 30
XF, TAIL, LEAD = 0.8, 0.9, 0.35

nars = ["nar-%02d.mp3" % (i + 1) for i in range(8)]

def run(cmd):
    subprocess.run(cmd, check=True)

def dur(path):
    out = subprocess.check_output([FF, "-i", path, "-f", "null", "-"],
                                  stderr=subprocess.STDOUT).decode("utf-8", "ignore")
    for line in out.splitlines():
        if "Duration:" in line:
            h, m, s = line.split("Duration:")[1].split(",")[0].strip().split(":")
            return int(h) * 3600 + int(m) * 60 + float(s)
    raise RuntimeError(path)

# ---- rebuild clip08 (2-frame + bubbles + dust) ----
print("rebuilding clip08...")
run([FF, "-y",
     "-framerate", "2", "-i", os.path.join(BASE, "tmp/scene08/%02d.jpg"),
     "-stream_loop", "-1", "-framerate", str(FPS),
     "-i", os.path.join(BASE, "fx/bubbles/%04d.png"),
     "-stream_loop", "-1", "-framerate", str(FPS),
     "-i", os.path.join(BASE, "fx/dust/%04d.png"),
     "-filter_complex",
     f"[0:v]scale={W}:{H}:force_original_aspect_ratio=increase,crop={W}:{H},"
     f"minterpolate=fps={FPS}:mi_mode=blend:scd=none,format=yuv420p[b0];"
     f"[1:v]format=rgba,fps={FPS}[o0];[b0][o0]overlay=eof_action=repeat[b1];"
     f"[2:v]format=rgba,fps={FPS}[o1];[b1][o1]overlay=eof_action=repeat[b2]",
     "-map", "[b2]", "-t", "2.0", "-r", str(FPS),
     "-c:v", "libx264", "-preset", "fast", "-crf", "18", "-pix_fmt", "yuv420p",
     os.path.join(BASE, "clips/clip08.mp4")])

# ---- final assembly ----
D = [dur(os.path.join(BASE, n)) + TAIL for n in nars]
offsets, start_t = [], [0.0]
acc = D[0]
offsets.append(acc - XF)
for i in range(1, 8):
    start_t.append(offsets[i - 1])
    acc = offsets[i - 1] + D[i]
    offsets.append(acc - XF)
total = start_t[-1] + D[-1]

inputs = []
for i in range(8):
    inputs += ["-stream_loop", "-1", "-i", os.path.join(BASE, f"clips/clip{i+1:02d}.mp4")]
for n in nars:
    inputs += ["-i", os.path.join(BASE, n)]

parts = []
for i in range(8):
    parts.append(f"[{i}:v]trim=duration={D[i]:.3f},setpts=PTS-STARTPTS,fps={FPS}[v{i}]")
prev = "v0"
for i in range(1, 8):
    parts.append(f"[{prev}][v{i}]xfade=transition=fade:duration={XF}:offset={offsets[i-1]:.3f}[x{i}]")
    prev = f"x{i}"
amix_in = []
for i in range(8):
    delay_ms = int(round((start_t[i] + LEAD) * 1000))
    parts.append(f"[{8+i}:a]aformat=sample_rates=44100:channel_layouts=stereo,adelay={delay_ms}:all=1[a{i}]")
    amix_in.append(f"[a{i}]")
parts.append("".join(amix_in) +
             f"amix=inputs=8:duration=longest:normalize=0,"
             f"afade=t=in:st=0:d=1.0,afade=t=out:st={total-1.5:.3f}:d=1.5[aout]")
fc = ";".join(parts)

out = os.path.join(BASE, "Jazire-Fandoqi-Aurora-Promo-v2.mp4")
print("assembling final video...")
run([FF, "-y", *inputs, "-filter_complex", fc,
     "-map", f"[{prev}]", "-map", "[aout]",
     "-c:v", "libx264", "-preset", "medium", "-crf", "19", "-pix_fmt", "yuv420p",
     "-r", str(FPS), "-c:a", "aac", "-b:a", "192k",
     "-t", f"{total:.3f}", "-movflags", "+faststart", out])
print("done ->", out, "| total", round(total, 2), "s")
