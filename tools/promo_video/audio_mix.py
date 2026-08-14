"""
Audio bed for the promo video.

- a cheerful, kid-friendly music track synthesised with numpy (marimba-ish
  plucks + soft bass + light percussion), so nothing is licensed from outside;
- UI sound effects taken straight from the app (assets/audio/sfx);
- the Persian voice-over clips, ducking the music under them.
"""

from __future__ import annotations

import os
import subprocess
import wave

import numpy as np

SR = 48000


# --------------------------------------------------------------------------- utils
def sec(n):
    return int(round(n * SR))


def add(track, buf, at, gain=1.0):
    i = sec(at)
    if i < 0:
        buf = buf[-i:]
        i = 0
    n = min(len(buf), len(track) - i)
    if n > 0:
        track[i:i + n] += buf[:n] * gain


def env(n, a=0.005, d=0.12, s=0.0, r=0.2, sus=0.35):
    """Simple ADSR shaped for plucky instruments."""
    e = np.zeros(n)
    ai, di, ri = sec(a), sec(d), sec(r)
    ai = min(ai, n)
    e[:ai] = np.linspace(0, 1, ai, endpoint=False) if ai else 0
    di = min(di, n - ai)
    if di > 0:
        e[ai:ai + di] = np.linspace(1, sus, di, endpoint=False)
    rest = n - ai - di
    if rest > 0:
        ri = min(ri, rest)
        e[ai + di:n - ri] = sus
        if ri > 0:
            e[n - ri:] = np.linspace(sus, 0, ri)
    return e


def note(freq, dur, kind="marimba", gain=1.0, detune=0.0):
    n = sec(dur)
    t = np.arange(n) / SR
    f = freq * (1 + detune)
    if kind == "marimba":
        w = (np.sin(2 * np.pi * f * t)
             + 0.42 * np.sin(2 * np.pi * f * 4 * t) * np.exp(-t * 14)
             + 0.18 * np.sin(2 * np.pi * f * 9.2 * t) * np.exp(-t * 26))
        e = np.exp(-t * 5.2) * (1 - np.exp(-t * 400))
    elif kind == "bell":
        w = (np.sin(2 * np.pi * f * t)
             + 0.5 * np.sin(2 * np.pi * f * 2.76 * t) * np.exp(-t * 3.2)
             + 0.3 * np.sin(2 * np.pi * f * 5.4 * t) * np.exp(-t * 5.5))
        e = np.exp(-t * 2.1) * (1 - np.exp(-t * 300))
    elif kind == "pluck":
        w = np.sign(np.sin(2 * np.pi * f * t)) * 0.35 + np.sin(2 * np.pi * f * t)
        e = np.exp(-t * 8.0) * (1 - np.exp(-t * 500))
    elif kind == "bass":
        w = np.sin(2 * np.pi * f * t) + 0.28 * np.sin(2 * np.pi * f * 2 * t)
        e = env(n, 0.008, 0.10, r=0.18, sus=0.6)
    elif kind == "pad":
        w = (np.sin(2 * np.pi * f * t)
             + np.sin(2 * np.pi * f * 1.005 * t)
             + 0.6 * np.sin(2 * np.pi * f * 2.01 * t))
        e = env(n, 0.35, 0.4, r=0.9, sus=0.7) * 0.35
    else:
        w = np.sin(2 * np.pi * f * t)
        e = np.exp(-t * 4)
    return (w * e * gain * 0.25).astype(np.float32)


def hat(dur=0.06, gain=0.5, tone=7000):
    n = sec(dur)
    t = np.arange(n) / SR
    noise = np.random.default_rng(int(tone)).standard_normal(n)
    # crude high-pass
    noise = np.diff(np.concatenate([[0], noise]))
    return (noise * np.exp(-t * 55) * gain * 0.12).astype(np.float32)


def kick(dur=0.22, gain=1.0):
    n = sec(dur)
    t = np.arange(n) / SR
    f = 120 * np.exp(-t * 26) + 46
    w = np.sin(2 * np.pi * np.cumsum(f) / SR)
    return (w * np.exp(-t * 9) * gain * 0.34).astype(np.float32)


def clap(dur=0.25, gain=0.6, seed=3):
    n = sec(dur)
    t = np.arange(n) / SR
    rng = np.random.default_rng(seed)
    w = rng.standard_normal(n) * np.exp(-t * 16)
    return (w * gain * 0.10).astype(np.float32)


def shaker(dur=0.09, gain=0.4, seed=5):
    n = sec(dur)
    t = np.arange(n) / SR
    rng = np.random.default_rng(seed)
    w = np.diff(np.concatenate([[0], rng.standard_normal(n)]))
    return (w * np.exp(-t * 40) * gain * 0.09).astype(np.float32)


# --------------------------------------------------------------------------- music
NOTE = {"C": 0, "C#": 1, "D": 2, "D#": 3, "E": 4, "F": 5, "F#": 6,
        "G": 7, "G#": 8, "A": 9, "A#": 10, "B": 11}


def hz(name, octave):
    return 440.0 * (2 ** ((NOTE[name] + (octave - 4) * 12 - 9) / 12))


def make_music(total):
    """Bright, bouncy C-major kids theme with a build and a big finish."""
    n = sec(total + 1.0)
    tr = np.zeros(n, dtype=np.float32)

    bpm = 116.0
    beat = 60.0 / bpm
    bar = beat * 4
    nbars = int(total / bar) + 2

    # I - V - vi - IV, the friendliest progression there is
    prog = [
        [("C", 3), ("E", 4), ("G", 4), ("C", 5)],
        [("G", 2), ("D", 4), ("G", 4), ("B", 4)],
        [("A", 2), ("E", 4), ("A", 4), ("C", 5)],
        [("F", 2), ("C", 4), ("F", 4), ("A", 4)],
    ]
    melody = [
        [("G", 5, 0.0, 0.5), ("E", 5, 0.5, 0.5), ("C", 5, 1.0, 0.5), ("E", 5, 1.5, 0.5),
         ("G", 5, 2.0, 1.0), ("A", 5, 3.0, 0.5), ("G", 5, 3.5, 0.5)],
        [("B", 4, 0.0, 0.5), ("D", 5, 0.5, 0.5), ("G", 5, 1.0, 1.0),
         ("F#", 5, 2.0, 0.5), ("D", 5, 2.5, 0.5), ("B", 4, 3.0, 1.0)],
        [("A", 4, 0.0, 0.5), ("C", 5, 0.5, 0.5), ("E", 5, 1.0, 0.5), ("A", 5, 1.5, 0.5),
         ("G", 5, 2.0, 1.0), ("E", 5, 3.0, 1.0)],
        [("F", 5, 0.0, 0.5), ("E", 5, 0.5, 0.5), ("D", 5, 1.0, 0.5), ("C", 5, 1.5, 0.5),
         ("D", 5, 2.0, 1.0), ("G", 4, 3.0, 1.0)],
    ]

    for b in range(nbars):
        t0 = b * bar
        if t0 > total + 0.5:
            break
        ch = prog[b % 4]
        mel = melody[b % 4]
        section = t0 / max(total, 1e-6)          # 0..1 through the piece
        energy = 0.55 + 0.45 * min(1.0, section * 1.5)

        # bass on 1 and 3 (+ pickup on the "and" of 4 later in the piece)
        root = ch[0]
        add(tr, note(hz(*root), beat * 0.9, "bass", 0.95), t0, energy)
        add(tr, note(hz(*root), beat * 0.9, "bass", 0.75), t0 + beat * 2, energy)
        if section > 0.3:
            add(tr, note(hz(root[0], root[1]) * 1.5, beat * 0.4, "bass", 0.5),
                t0 + beat * 3.5, energy)

        # warm pad
        for nm, oc in ch[1:]:
            add(tr, note(hz(nm, oc), bar * 0.95, "pad", 0.5), t0, 0.5 + 0.3 * section)

        # marimba arpeggio, eighths
        arp = ch[1:] + ch[1:][::-1]
        for i in range(8):
            nm, oc = arp[i % len(arp)]
            add(tr, note(hz(nm, oc), beat * 0.7, "marimba", 0.62),
                t0 + i * beat * 0.5, energy * (0.85 if i % 2 else 1.0))

        # lead melody (bells double it in the last third for lift)
        for nm, oc, off, ln in mel:
            add(tr, note(hz(nm, oc), beat * ln * 0.95, "pluck", 0.55), t0 + off * beat, energy)
            if section > 0.55:
                add(tr, note(hz(nm, oc + 1), beat * ln, "bell", 0.30), t0 + off * beat, energy * 0.8)

        # light percussion
        if section > 0.12:
            add(tr, kick(gain=0.9), t0, energy)
            add(tr, kick(gain=0.7), t0 + beat * 2, energy)
        if section > 0.3:
            add(tr, clap(gain=0.55, seed=b), t0 + beat, energy)
            add(tr, clap(gain=0.55, seed=b + 40), t0 + beat * 3, energy)
        for i in range(8):
            add(tr, shaker(gain=0.45 if i % 2 else 0.7, seed=b * 8 + i),
                t0 + i * beat * 0.5, energy * 0.9)
        if section > 0.45:
            for i in range(4):
                add(tr, hat(gain=0.5, tone=6000 + i * 400), t0 + beat * (i + 0.5), energy)

    # final accent
    for nm, oc in (("C", 5), ("E", 5), ("G", 5), ("C", 6)):
        add(tr, note(hz(nm, oc), 2.0, "bell", 0.7), total - 2.0, 1.0)

    # simple stereo-ready mono track, softly filtered
    k = np.ones(24) / 24
    tr = np.convolve(tr, k, mode="same").astype(np.float32)
    return tr[:sec(total)]


# --------------------------------------------------------------------------- io
def read_audio(path, ffmpeg):
    """Decode any file to mono float32 @ SR via ffmpeg."""
    out = subprocess.run(
        [ffmpeg, "-v", "error", "-i", path, "-f", "f32le", "-ac", "1", "-ar", str(SR), "-"],
        capture_output=True, check=True).stdout
    return np.frombuffer(out, dtype=np.float32).copy()


def fade(buf, fin=0.01, fout=0.05):
    n = len(buf)
    a, b = sec(fin), sec(fout)
    if a and a < n:
        buf[:a] *= np.linspace(0, 1, a)
    if b and b < n:
        buf[-b:] *= np.linspace(1, 0, b)
    return buf


def write_wav(path, mono):
    peak = float(np.max(np.abs(mono))) or 1.0
    if peak > 0.98:
        mono = mono * (0.98 / peak)
    # soft limiter for a punchy, consistent store-video loudness
    mono = np.tanh(mono * 1.25) * 0.92
    st = np.stack([mono, mono], axis=1)
    data = (np.clip(st, -1, 1) * 32767).astype("<i2").tobytes()
    with wave.open(path, "wb") as w:
        w.setnchannels(2)
        w.setsampwidth(2)
        w.setframerate(SR)
        w.writeframes(data)


# --------------------------------------------------------------------------- cues
# (file, time, gain) — SFX taken from the app itself
def sfx_cues():
    return [
        ("swoosh.wav", 0.35, 0.55),
        ("unlock.wav", 1.25, 0.60),
        ("star.wav", 1.45, 0.50),
        ("bubble.wav", 2.05, 0.45),

        ("go.wav", 4.15, 0.45),
        ("bubble.wav", 4.45, 0.50),
        ("bubble.wav", 4.85, 0.50),
        ("bubble.wav", 5.30, 0.50),
        ("tap.wav", 5.85, 0.45),
        ("tap.wav", 6.75, 0.45),
        ("tap.wav", 7.65, 0.45),

        ("page.wav", 8.45, 0.40),
        ("select.wav", 8.75, 0.40),
        ("select.wav", 9.05, 0.40),
        ("select.wav", 9.40, 0.40),
        ("select.wav", 9.75, 0.40),
        ("select.wav", 10.10, 0.40),
        ("correct.wav", 10.55, 0.45),
        ("correct.wav", 11.20, 0.40),
        ("levelup.wav", 12.10, 0.45),

        ("page.wav", 14.80, 0.45),
        ("page.wav", 16.20, 0.35),
        ("page.wav", 17.60, 0.35),
        ("sleep.wav", 18.60, 0.35),

        ("win.wav", 20.35, 0.50),
        ("coin.wav", 20.95, 0.45),
        ("coin.wav", 21.25, 0.45),
        ("coin.wav", 21.60, 0.45),
        ("star.wav", 22.00, 0.45),
        ("star.wav", 22.40, 0.45),
        ("success.wav", 23.10, 0.50),
        ("levelup.wav", 24.10, 0.45),

        ("swoosh.wav", 26.20, 0.50),
        ("unlock.wav", 26.70, 0.55),
        ("success.wav", 27.60, 0.50),
        ("star.wav", 28.40, 0.45),
    ]


# (file, time, gain)
def vo_cues():
    return [
        ("1.mp3", 0.85, 1.0),
        ("s2.mp3", 4.55, 1.0),
        ("s3.mp3", 8.75, 1.0),
        ("s4.mp3", 15.05, 1.0),
        ("5.mp3", 20.35, 1.0),
        ("s6.mp3", 26.45, 1.0),
    ]


def build(total, out_path, vo_dir, sfx_dir):
    import imageio_ffmpeg
    ffmpeg = imageio_ffmpeg.get_ffmpeg_exe()

    n = sec(total)
    music = make_music(total)
    if len(music) < n:
        music = np.pad(music, (0, n - len(music)))
    music = music[:n] * 0.55

    sfx = np.zeros(n, dtype=np.float32)
    for name, at, g in sfx_cues():
        p = os.path.join(sfx_dir, name)
        if not os.path.exists(p) or at > total:
            continue
        add(sfx, fade(read_audio(p, ffmpeg)), at, g * 0.5)

    vo = np.zeros(n, dtype=np.float32)
    duck = np.ones(n, dtype=np.float32)
    for name, at, g in vo_cues():
        p = os.path.join(vo_dir, name)
        if not os.path.exists(p):
            print(f"  ! missing voice-over {p}")
            continue
        buf = fade(read_audio(p, ffmpeg), 0.02, 0.08)
        peak = float(np.max(np.abs(buf))) or 1.0
        buf = buf * (0.92 / peak)
        add(vo, buf, at, g)
        # duck music/sfx while the narrator speaks (with smooth ramps)
        i0, i1 = sec(max(0, at - 0.25)), min(n, sec(at + len(buf) / SR + 0.35))
        if i1 > i0:
            ramp = sec(0.22)
            seg_len = i1 - i0
            d = np.full(seg_len, 0.34, dtype=np.float32)
            r = min(ramp, seg_len // 2)
            if r > 0:
                d[:r] = np.linspace(1.0, 0.34, r)
                d[-r:] = np.linspace(0.34, 1.0, r)
            duck[i0:i1] = np.minimum(duck[i0:i1], d)

    mix = music * duck + sfx * (0.45 + 0.55 * duck) + vo * 1.0

    tmp_wav = out_path + ".wav"
    write_wav(tmp_wav, mix)
    subprocess.run([ffmpeg, "-y", "-v", "error", "-i", tmp_wav,
                    "-c:a", "aac", "-b:a", "192k", out_path], check=True)
    os.remove(tmp_wav)
    print(f"  audio -> {out_path}")
