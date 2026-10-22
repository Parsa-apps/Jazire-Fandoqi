#!/usr/bin/env python3
"""
Gentle, extra-soft kid-safe SFX (v2) for جزیره فندقی.

Sound identity — like a wooden toy music box / marimba / glockenspiel:
- every UI sound is a rounded, plush music-box or wooden-mallet tone
- zero square-wave buzzers, zero harsh transients or dissonance
- error/wrong are warm, comforting "oopsie" phrases with a soft pad and
  an encouraging tail — never a punishment alarm
- celebrations are major-pentatonic music-box arpeggios with light sparkle
- negative cues are mastered quieter and low-passed harder than positive ones

Two section identity chimes are included:
- poem_chime: a short singable music-box intro for the poems section
- quran_chime: a slow, low, sparkle-free reverent bell for the Quran section

44.1 kHz, 16-bit, mono WAV. Fully procedural, no third-party samples.
Run:  python3 tools/generate_sfx.py
"""
from __future__ import annotations

import math
import os
import random
import struct
import wave

SR = 44100
OUT = os.path.abspath(
    os.path.join(os.path.dirname(__file__), "..", "assets", "audio", "sfx")
)
TWOPI = 2.0 * math.pi


def clamp(v: float, lo: float = -1.0, hi: float = 1.0) -> float:
    return lo if v < lo else hi if v > hi else v


def ms(n: float) -> int:
    return max(1, int(SR * n / 1000.0))


def new_buf(n: int) -> list[float]:
    return [0.0] * n


def overlay(dst: list[float], src: list[float], at: int = 0, gain: float = 1.0) -> list[float]:
    need = at + len(src)
    if len(dst) < need:
        dst = dst + [0.0] * (need - len(dst))
    for i, s in enumerate(src):
        dst[at + i] += s * gain
    return dst


def concat(*parts: list[float]) -> list[float]:
    out: list[float] = []
    for p in parts:
        out.extend(p)
    return out


def fade(samples: list[float], fade_ms: float = 4.0) -> list[float]:
    n = len(samples)
    f = min(ms(fade_ms), n // 3)
    if f <= 0:
        return samples
    for i in range(f):
        g = i / f
        samples[i] *= g
        samples[n - 1 - i] *= g
    return samples


def one_pole(samples: list[float], cutoff_hz: float) -> list[float]:
    if cutoff_hz <= 0:
        return samples
    x = math.exp(-TWOPI * cutoff_hz / SR)
    a = 1.0 - x
    y = 0.0
    out = new_buf(len(samples))
    for i, s in enumerate(samples):
        y = a * s + x * y
        out[i] = y
    return out


def highpass(samples: list[float], cutoff_hz: float) -> list[float]:
    lp = one_pole(samples, cutoff_hz)
    return [s - l for s, l in zip(samples, lp)]


def tanh_sat(samples: list[float], drive: float = 1.1) -> list[float]:
    return [math.tanh(s * drive) for s in samples]


def normalize(samples: list[float], peak: float = 0.70) -> list[float]:
    p = max((abs(s) for s in samples), default=0.0)
    if p < 1e-8:
        return samples
    g = peak / p
    return [s * g for s in samples]


def finalize(samples: list[float], peak: float = 0.68, cut: float = 6000.0) -> list[float]:
    samples = fade(samples, 3.5)
    samples = one_pole(samples, cut)
    samples = tanh_sat(samples, 1.06)
    samples = normalize(samples, peak)
    samples = fade(samples, 2.5)
    return samples


def write_wav(name: str, samples: list[float], peak: float = 0.68, cut: float = 6000.0) -> None:
    os.makedirs(OUT, exist_ok=True)
    samples = finalize(samples, peak=peak, cut=cut)
    path = os.path.join(OUT, name)
    with wave.open(path, "w") as w:
        w.setnchannels(1)
        w.setsampwidth(2)
        w.setframerate(SR)
        frames = bytearray()
        for s in samples:
            frames += struct.pack("<h", int(clamp(s) * 32767))
        w.writeframes(bytes(frames))
    dur = len(samples) / SR
    print(f"  {name:16} {dur:5.3f}s  {os.path.getsize(path):6d} B")


def env_exp(n: int, attack_ms: float, decay_ms: float, sustain: float = 0.0) -> list[float]:
    """Attack + exponential decay. Natural mallet / bell shape."""
    a = max(1, ms(attack_ms))
    out = new_buf(n)
    decay = max(decay_ms / 1000.0, 0.008)
    for i in range(n):
        if i < a:
            att = i / a
        else:
            att = 1.0
        t = i / SR
        out[i] = att * ((1.0 - sustain) * math.exp(-t / decay) + sustain)
    return out


def env_adsr(n: int, a_ms: float, d_ms: float, s: float, r_ms: float) -> list[float]:
    a = max(1, ms(a_ms))
    d = max(1, ms(d_ms))
    r = max(1, ms(r_ms))
    out = new_buf(n)
    for i in range(n):
        if i < a:
            out[i] = i / a
        elif i < a + d:
            out[i] = 1.0 - (1.0 - s) * ((i - a) / d)
        elif i < n - r:
            out[i] = s
        else:
            remain = n - 1 - i
            out[i] = s * (remain / r)
    return out


def osc(n: int, freq, harmonics: tuple[float, ...] = (1.0, 0.32, 0.12, 0.04)) -> list[float]:
    """Phase-accumulating additive sine. `freq` is Hz or a callable(i)->Hz."""
    out = new_buf(n)
    phases = [0.0] * len(harmonics)
    for i in range(n):
        f = float(freq(i) if callable(freq) else freq)
        s = 0.0
        for k, amp in enumerate(harmonics, start=1):
            phases[k - 1] += TWOPI * f * k / SR
            if phases[k - 1] > TWOPI * 32:
                phases[k - 1] -= TWOPI * 32
            s += amp * math.sin(phases[k - 1])
        out[i] = s
    return out


def tone(
    freq,
    dur: float,
    vol: float = 0.4,
    attack_ms: float = 6.0,
    decay_ms: float = 80.0,
    harmonics: tuple[float, ...] = (1.0, 0.28, 0.10, 0.03),
    sustain: float = 0.0,
) -> list[float]:
    n = max(1, int(SR * dur))
    wave = osc(n, freq, harmonics)
    e = env_exp(n, attack_ms, decay_ms, sustain)
    return [wave[i] * e[i] * vol for i in range(n)]


def triangle_tone(freq: float, dur: float, vol: float = 0.3, attack_ms: float = 8.0, decay_ms: float = 90.0) -> list[float]:
    n = max(1, int(SR * dur))
    out = new_buf(n)
    ph = 0.0
    e = env_exp(n, attack_ms, decay_ms)
    for i in range(n):
        ph += TWOPI * freq / SR
        if ph > TWOPI * 8:
            ph -= TWOPI * 8
        # band-limited-ish triangle via two harmonics
        v = (8 / (math.pi ** 2)) * (math.sin(ph) - (1 / 9) * math.sin(3 * ph))
        out[i] = v * e[i] * vol
    return out


def fm_bell(freq: float, dur: float, vol: float = 0.38, decay_ms: float = 220.0, index: float = 1.6, ratio: float = 2.01) -> list[float]:
    """Soft FM bell."""
    n = max(1, int(SR * dur))
    out = new_buf(n)
    ph_c = 0.0
    ph_m = 0.0
    e = env_exp(n, 3.0, decay_ms)
    for i in range(n):
        e_i = e[i]
        ph_m += TWOPI * freq * ratio / SR
        mod = math.sin(ph_m) * freq * index * e_i
        ph_c += TWOPI * (freq + mod) / SR
        if ph_c > TWOPI * 64:
            ph_c -= TWOPI * 64
        v = math.sin(ph_c) + 0.18 * math.sin(2 * ph_c)
        out[i] = v * e_i * vol
    return out


def music_box(freq: float, dur: float, vol: float = 0.3, decay_ms: float = 260.0) -> list[float]:
    """Round, gentle music-box note: low-modulation FM bell + soft sine body."""
    bell = fm_bell(freq, dur, vol, decay_ms=decay_ms, index=0.85, ratio=2.0)
    body = tone(freq, dur, vol * 0.35, attack_ms=4.0, decay_ms=decay_ms * 0.8,
                harmonics=(1.0, 0.18, 0.06))
    return overlay(bell, body)


def marimba(freq: float, dur: float, vol: float = 0.3, decay_ms: float = 150.0) -> list[float]:
    """Warm wooden marimba hit: soft triangle + rounded sine, plush attack."""
    n = max(1, int(SR * dur))
    a = triangle_tone(freq, dur, vol * 0.7, attack_ms=5.0, decay_ms=decay_ms)
    b = tone(freq, dur, vol * 0.45, attack_ms=3.0, decay_ms=decay_ms * 0.7,
             harmonics=(1.0, 0.22, 0.07))
    # faint octave-up "stick" contact, very short
    tick = tone(freq * 2.0, min(dur, 0.05), vol * 0.10, attack_ms=1.5,
                decay_ms=28.0, harmonics=(1.0,))
    return overlay(overlay(a, b), tick)


def pad(freq: float, dur: float, vol: float = 0.08) -> list[float]:
    """Soft sustained warm pad under comforting cues (error/wrong/lose)."""
    n = max(1, int(SR * dur))
    e = env_adsr(n, 40, 120, 0.8, 220)
    out = new_buf(n)
    ph1 = ph2 = ph3 = 0.0
    for i in range(n):
        ph1 += TWOPI * freq / SR
        ph2 += TWOPI * freq * 1.5 / SR
        ph3 += TWOPI * freq * 2.0 / SR
        v = math.sin(ph1) + 0.28 * math.sin(ph2 + 0.4) + 0.12 * math.sin(ph3)
        out[i] = v * e[i] * vol
    return out


def noise(n: int, amp: float = 1.0, seed: int = 1) -> list[float]:
    rng = random.Random(seed)
    return [amp * (rng.random() * 2.0 - 1.0) for _ in range(n)]


def pinkish(n: int, amp: float = 1.0, seed: int = 2) -> list[float]:
    white = noise(n, 1.0, seed)
    return [s * amp for s in one_pole(white, 900.0)]


def pluck(freq: float, dur: float, vol: float = 0.32, seed: int = 7) -> list[float]:
    """Karplus–Strong wooden tap — warm UI hit."""
    delay = max(2, int(SR / max(freq, 80.0)))
    rng = random.Random(seed)
    buf = [rng.random() * 2.0 - 1.0 for _ in range(delay)]
    n = max(1, int(SR * dur))
    out = new_buf(n)
    idx = 0
    for i in range(n):
        v = buf[idx]
        nxt = buf[(idx + 1) % delay]
        buf[idx] = 0.498 * (v + nxt)
        out[i] = v * vol
        idx = (idx + 1) % delay
    return one_pole(out, 4200.0)


def sweep(f0: float, f1: float, dur: float, vol: float = 0.35, decay_ms: float = 70.0) -> list[float]:
    n = max(1, int(SR * dur))

    def f(i: int) -> float:
        t = i / max(n - 1, 1)
        # ease-out so the drop feels physical
        t = 1.0 - (1.0 - t) * (1.0 - t)
        return f0 + (f1 - f0) * t

    wave = osc(n, f, (1.0, 0.22, 0.06))
    e = env_exp(n, 4.0, decay_ms)
    return [wave[i] * e[i] * vol for i in range(n)]


def whoosh(dur: float, vol: float = 0.28, f0: float = 2400.0, f1: float = 280.0, seed: int = 11) -> list[float]:
    n = max(1, int(SR * dur))
    raw = pinkish(n, 1.0, seed)
    out = new_buf(n)
    y = 0.0
    e = env_adsr(n, 12, 40, 0.55, 70)
    for i, s in enumerate(raw):
        t = i / max(n - 1, 1)
        cut = f0 + (f1 - f0) * (t * t)
        x = math.exp(-TWOPI * cut / SR)
        a = 1.0 - x
        y = a * s + x * y
        out[i] = y * e[i] * vol
    return out


def paper(dur: float = 0.16, vol: float = 0.22, seed: int = 19) -> list[float]:
    n = max(1, int(SR * dur))
    raw = highpass(pinkish(n, 1.0, seed), 700.0)
    raw = one_pole(raw, 3800.0)
    e = env_adsr(n, 8, 35, 0.35, 55)
    # two overlapping rustles
    a = [raw[i] * e[i] * vol for i in range(n)]
    b = pinkish(n, 0.55, seed + 3)
    b = one_pole(highpass(b, 1200.0), 5000.0)
    e2 = env_adsr(n, 18, 50, 0.2, 40)
    for i in range(n):
        a[i] += b[i] * e2[i] * vol * 0.7
    return a


# ── individual SFX (v2 — softer, warmer, music-box identity) ──────────────


def sfx_tap() -> None:
    # plush marimba tap on C5, with a warm low wooden body
    body = pluck(196.0, 0.14, 0.22, seed=3)
    hit = marimba(523.25, 0.14, 0.30, decay_ms=120)
    air = one_pole(noise(ms(16), 0.06, seed=5), 2400.0)
    write_wav("tap.wav", overlay(overlay(hit, body, 0, 0.9), air, 0, 1.0),
              peak=0.46, cut=4800)


def sfx_click() -> None:
    # tiny glockenspiel blip — short, light, never snappy
    blip = music_box(1567.98, 0.09, 0.16, decay_ms=70)
    body = tone(783.99, 0.08, 0.08, attack_ms=2, decay_ms=55,
                harmonics=(1.0, 0.12))
    write_wav("click.wav", overlay(blip, body), peak=0.40, cut=5400)


def sfx_select() -> None:
    # sweet two-note music-box answer: G5 → C6, with a whisper-soft E6 tail
    a = music_box(783.99, 0.20, 0.26, decay_ms=180)
    b = music_box(1046.50, 0.26, 0.28, decay_ms=230)
    tail = music_box(1318.51, 0.20, 0.10, decay_ms=200)
    buf = overlay(a, b, ms(65))
    buf = overlay(buf, tail, ms(140))
    write_wav("select.wav", buf, peak=0.55, cut=6800)


def sfx_back() -> None:
    # rounded, airy little descent ending on a warm marimba G4
    drop = sweep(620.0, 350.0, 0.12, vol=0.22, decay_ms=80)
    end = marimba(392.00, 0.14, 0.20, decay_ms=130)
    write_wav("back.wav", overlay(drop, end, ms(70)), peak=0.46, cut=4600)


def sfx_page() -> None:
    rustle = paper(0.18, 0.16, 21)
    air = whoosh(0.15, 0.08, 1600, 380, 22)
    write_wav("page.wav", overlay(rustle, air, 0), peak=0.40, cut=4400)


def sfx_swoosh() -> None:
    write_wav("swoosh.wav", whoosh(0.28, 0.24, 2400, 220, 13),
              peak=0.46, cut=4200)


def sfx_bubble() -> None:
    # round water bubble: soft rising chirp, gentle pop, wet body
    chirp = sweep(480.0, 920.0, 0.09, vol=0.26, decay_ms=60)
    pop = sweep(920.0, 300.0, 0.10, vol=0.22, decay_ms=55)
    wet = tone(420.0, 0.10, 0.08, decay_ms=70, harmonics=(1.0, 0.4, 0.1))
    write_wav("bubble.wav", overlay(overlay(chirp, pop, ms(55)), wet, ms(60)),
              peak=0.52, cut=5200)


def sfx_coin() -> None:
    # gentle music-box C6 → E6
    a = music_box(1046.50, 0.14, 0.26, decay_ms=110)
    b = music_box(1318.51, 0.30, 0.30, decay_ms=220)
    write_wav("coin.wav", overlay(a, b, ms(50)), peak=0.60, cut=7400)


def sfx_star() -> None:
    # pentatonic twinkle C6 E6 G6 C7 with a soft high sparkle
    notes = [(1046.50, 0), (1318.51, 70), (1567.98, 140), (2093.00, 210)]
    buf: list[float] = []
    for i, (f, start) in enumerate(notes):
        buf = overlay(buf, music_box(f, 0.34, 0.24 - i * 0.03,
                                     decay_ms=240 - i * 20), ms(start))
    sparkle = fm_bell(2637.02, 0.22, 0.08, decay_ms=150, index=1.0)
    buf = overlay(buf, sparkle, ms(280))
    write_wav("star.wav", buf, peak=0.60, cut=8000)


def sfx_correct() -> None:
    # warm C-major music-box arpeggio C5 E5 G5 C6, overlapping like a lullaby
    e5 = music_box(523.25, 0.30, 0.26, decay_ms=210)
    g5 = music_box(659.25, 0.32, 0.28, decay_ms=230)
    c6a = music_box(783.99, 0.36, 0.30, decay_ms=260)
    c6 = music_box(1046.50, 0.46, 0.32, decay_ms=320)
    buf = overlay(e5, g5, ms(95))
    buf = overlay(buf, c6a, ms(190))
    buf = overlay(buf, c6, ms(285))
    write_wav("correct.wav", buf, peak=0.64, cut=7200)


def sfx_success() -> None:
    # uplifting G5 → C6 over a soft E5 warmth
    bed = tone(659.25, 0.40, 0.07, attack_ms=20, decay_ms=340,
               harmonics=(1.0, 0.2))
    a = music_box(783.99, 0.24, 0.26, decay_ms=180)
    b = music_box(1046.50, 0.38, 0.32, decay_ms=280)
    buf = overlay(overlay(a, b, ms(85)), bed, 0)
    write_wav("success.wav", buf, peak=0.62, cut=7000)


def sfx_wrong() -> None:
    # plush "aww": G4 → E4 wooden marimba over a warm C4 pad.
    # Gentle and comforting — a soft invitation to try again, not a buzzer.
    bed = pad(261.63, 0.55, vol=0.10)
    a = marimba(392.00, 0.22, 0.20, decay_ms=160)
    b = marimba(329.63, 0.34, 0.20, decay_ms=240)
    buf = overlay(overlay(a, b, ms(130)), bed, 0, 0.9)
    write_wav("wrong.wav", buf, peak=0.44, cut=3200)


def sfx_error() -> None:
    # kindest possible "oopsie": E4 → C4 marimba, warm G3 pad, then a
    # whisper-quiet encouraging E5 bell ("دوباره تلاش کن"). No alarm color.
    bed = pad(196.00, 0.62, vol=0.09)
    a = marimba(329.63, 0.20, 0.18, decay_ms=150)
    b = marimba(261.63, 0.30, 0.18, decay_ms=230)
    cheer = music_box(659.25, 0.30, 0.08, decay_ms=260)
    buf = overlay(overlay(a, b, ms(120)), bed, 0, 0.9)
    buf = overlay(buf, cheer, ms(330))
    write_wav("error.wav", buf, peak=0.40, cut=3000)


def sfx_win() -> None:
    # celebratory C-major ascent C5 E5 G5 C6 E6 G6 + C7 sparkle, music box
    notes = [
        (523.25, 0), (659.25, 100), (783.99, 200), (1046.50, 300),
        (1318.51, 400), (1567.98, 500),
    ]
    buf: list[float] = []
    for i, (f, start) in enumerate(notes):
        buf = overlay(buf, music_box(f, 0.40 + i * 0.03, 0.24,
                                     decay_ms=220 + i * 12), ms(start))
    sparkle = fm_bell(2093.00, 0.42, 0.12, decay_ms=260, index=1.1)
    buf = overlay(buf, sparkle, ms(600))
    warmth = pad(523.25, 0.95, vol=0.05)
    buf = overlay(buf, warmth, 0, 0.8)
    write_wav("win.wav", buf, peak=0.68, cut=7800)


def sfx_lose() -> None:
    # comforting lullaby descent E5 → D5 → C5 with a soft G4 pad
    bed = pad(392.00, 0.85, vol=0.08)
    e5 = triangle_tone(659.25, 0.26, 0.16, attack_ms=16, decay_ms=220)
    d5 = triangle_tone(587.33, 0.28, 0.15, attack_ms=18, decay_ms=240)
    c5 = triangle_tone(523.25, 0.46, 0.16, attack_ms=20, decay_ms=380)
    buf = overlay(e5, d5, ms(180))
    buf = overlay(buf, c5, ms(360))
    buf = overlay(buf, bed, 0, 0.9)
    write_wav("lose.wav", buf, peak=0.44, cut=3400)


def sfx_levelup() -> None:
    # rising C-major music-box scale, finished with a bright E6 sparkle
    scale = [523.25, 587.33, 659.25, 698.46, 783.99, 880.00, 987.77, 1046.50]
    buf: list[float] = []
    for i, f in enumerate(scale):
        buf = overlay(buf, music_box(f, 0.26, 0.22, decay_ms=170), ms(75 * i))
    buf = overlay(buf, fm_bell(1318.51, 0.42, 0.14, decay_ms=260, index=1.1),
                  ms(600))
    write_wav("levelup.wav", buf, peak=0.68, cut=8000)


def sfx_unlock() -> None:
    # soft ascending G5 C6 E6 + gentle high sparkle
    a = music_box(783.99, 0.22, 0.22, decay_ms=160)
    b = music_box(1046.50, 0.26, 0.26, decay_ms=200)
    c = music_box(1318.51, 0.38, 0.28, decay_ms=260)
    sh = fm_bell(2093.00, 0.26, 0.10, decay_ms=170, index=1.0)
    buf = overlay(a, b, ms(75))
    buf = overlay(buf, c, ms(160))
    buf = overlay(buf, sh, ms(230))
    write_wav("unlock.wav", buf, peak=0.64, cut=7800)


def sfx_tick() -> None:
    # tiny soft woodblock — quiet and rounded
    write_wav(
        "tick.wav",
        overlay(
            tone(880.00, 0.045, 0.10, attack_ms=1.2, decay_ms=26,
                 harmonics=(1.0,)),
            tone(440.00, 0.07, 0.08, attack_ms=1.8, decay_ms=42,
                 harmonics=(1.0, 0.1)),
        ),
        peak=0.32,
        cut=4400,
    )


def sfx_countdown() -> None:
    # single warm music-box bell, calm rather than urgent
    bell = music_box(659.25, 0.18, 0.22, decay_ms=140)
    body = tone(329.63, 0.14, 0.07, decay_ms=100)
    write_wav("countdown.wav", overlay(bell, body), peak=0.48, cut=5400)


def sfx_go() -> None:
    # bright but gentle C5 E5 G5 triple chime
    a = music_box(523.25, 0.18, 0.24, decay_ms=130)
    b = music_box(659.25, 0.22, 0.26, decay_ms=170)
    c = music_box(783.99, 0.32, 0.28, decay_ms=230)
    buf = overlay(a, b, ms(75))
    buf = overlay(buf, c, ms(160))
    write_wav("go.wav", buf, peak=0.60, cut=7400)


def sfx_sleep() -> None:
    # slow music-box lullaby: C5 E5 G5 C6 with long decays over a soft C4 bed
    bed = pad(261.63, 1.9, vol=0.06)
    c5 = music_box(523.25, 0.85, 0.18, decay_ms=620)
    e5 = music_box(659.25, 0.80, 0.15, decay_ms=580)
    g5 = music_box(783.99, 0.85, 0.16, decay_ms=640)
    c6 = music_box(1046.50, 1.00, 0.14, decay_ms=760)
    buf = overlay(c5, e5, ms(300))
    buf = overlay(buf, g5, ms(600))
    buf = overlay(buf, c6, ms(900))
    buf = overlay(buf, bed, 0, 0.9)
    write_wav("sleep.wav", buf, peak=0.46, cut=4000)


def sfx_poem_chime() -> None:
    # little music-box song intro: C5 E5 G5 C6, slow and singable
    notes = [(523.25, 0), (659.25, 170), (783.99, 340), (1046.50, 510)]
    buf: list[float] = []
    for f, start in notes:
        buf = overlay(buf, music_box(f, 0.55, 0.22, decay_ms=380), ms(start))
    warmth = pad(523.25, 1.25, vol=0.045)
    buf = overlay(buf, warmth, 0, 0.8)
    write_wav("poem_chime.wav", buf, peak=0.52, cut=6800)


def sfx_quran_chime() -> None:
    # calm two-note reverent bell (G4 -> C5) with a long soft pad;
    # deliberately slow, low and sparkle-free
    bed = pad(196.00, 2.0, vol=0.07)
    g4 = fm_bell(392.00, 1.1, 0.20, decay_ms=820, index=0.7, ratio=2.0)
    c5 = fm_bell(523.25, 1.2, 0.18, decay_ms=900, index=0.7, ratio=2.0)
    body = tone(261.63, 1.4, 0.06, attack_ms=30, decay_ms=900,
                harmonics=(1.0, 0.15))
    buf = overlay(overlay(g4, c5, ms(420)), body, 0)
    buf = overlay(buf, bed, 0, 0.9)
    write_wav("quran_chime.wav", buf, peak=0.44, cut=3600)


def main() -> None:
    print("Generating gentle kid-safe SFX v2 →", OUT)
    sfx_tap()
    sfx_click()
    sfx_select()
    sfx_back()
    sfx_page()
    sfx_swoosh()
    sfx_bubble()
    sfx_coin()
    sfx_star()
    sfx_correct()
    sfx_success()
    sfx_wrong()
    sfx_error()
    sfx_win()
    sfx_lose()
    sfx_levelup()
    sfx_unlock()
    sfx_tick()
    sfx_countdown()
    sfx_go()
    sfx_sleep()
    sfx_poem_chime()
    sfx_quran_chime()
    print("done.")


if __name__ == "__main__":
    main()
