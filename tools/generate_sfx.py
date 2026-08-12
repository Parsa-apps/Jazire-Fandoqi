#!/usr/bin/env python3
"""
Premium kid-safe SFX for جزیره فندقی.

Designed like Duolingo / Khan Academy Kids / Toca Boca:
- no square-wave buzzers
- no harsh dissonance
- UI taps are soft wooden toys, not phone clicks
- wrong/lose are gentle "oops", never a punishment alarm
- celebrations are major pentatonic bells with a short sparkle

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


def finalize(samples: list[float], peak: float = 0.68, cut: float = 6500.0) -> list[float]:
    samples = fade(samples, 3.5)
    samples = one_pole(samples, cut)
    samples = tanh_sat(samples, 1.08)
    samples = normalize(samples, peak)
    samples = fade(samples, 2.5)
    return samples


def write_wav(name: str, samples: list[float], peak: float = 0.68, cut: float = 6500.0) -> None:
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
    """Soft FM bell — coin, star, unlock sparkle."""
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


# ── individual SFX ────────────────────────────────────────────────────────


def sfx_tap() -> None:
    body = pluck(210, 0.13, 0.38, seed=3)
    mallet = tone(540, 0.09, 0.16, attack_ms=2, decay_ms=55, harmonics=(1.0, 0.18))
    air = one_pole(noise(ms(18), 0.10, seed=5), 2800.0)
    write_wav("tap.wav", overlay(overlay(body, mallet, 0, 1.0), air, 0, 1.0), peak=0.52, cut=5200)


def sfx_click() -> None:
    tick = tone(1760, 0.032, 0.16, attack_ms=1.2, decay_ms=22, harmonics=(1.0, 0.08))
    body = tone(580, 0.09, 0.24, attack_ms=2, decay_ms=62, harmonics=(1.0, 0.16))
    wood = pluck(240, 0.08, 0.12, seed=4)
    write_wav("click.wav", overlay(overlay(body, tick, 0), wood, 0), peak=0.48, cut=5600)


def sfx_select() -> None:
    a = fm_bell(659.25, 0.16, 0.28, decay_ms=140, index=1.1)
    b = fm_bell(880.00, 0.22, 0.30, decay_ms=180, index=1.2)
    write_wav("select.wav", overlay(a, b, ms(55)), peak=0.60, cut=7000)


def sfx_back() -> None:
    drop = sweep(720, 340, 0.11, vol=0.30, decay_ms=70)
    soft = tone(420, 0.10, 0.14, decay_ms=80)
    write_wav("back.wav", overlay(drop, soft, ms(10)), peak=0.50, cut=5000)


def sfx_page() -> None:
    write_wav("page.wav", overlay(paper(0.17, 0.24, 21), whoosh(0.14, 0.10, 1800, 400, 22), 0), peak=0.42, cut=4800)


def sfx_swoosh() -> None:
    write_wav("swoosh.wav", whoosh(0.26, 0.32, 2800, 220, 13), peak=0.50, cut=4500)


def sfx_bubble() -> None:
    pop = sweep(980, 260, 0.13, vol=0.42, decay_ms=55)
    wet = tone(420, 0.10, 0.12, decay_ms=70, harmonics=(1.0, 0.4, 0.1))
    drip = one_pole(noise(ms(22), 0.14, seed=9), 2200.0)
    write_wav("bubble.wav", overlay(overlay(pop, wet, ms(8)), drip, 0), peak=0.58, cut=5600)


def sfx_coin() -> None:
    a = fm_bell(987.77, 0.12, 0.34, decay_ms=90, index=1.8)
    b = fm_bell(1318.5, 0.28, 0.40, decay_ms=200, index=2.0)
    write_wav("coin.wav", overlay(a, b, ms(45)), peak=0.64, cut=7800)


def sfx_star() -> None:
    base = fm_bell(1318.5, 0.42, 0.28, decay_ms=280, index=1.5)
    buf = overlay(base, fm_bell(1760.0, 0.36, 0.22, decay_ms=240, index=1.7), ms(70))
    buf = overlay(buf, fm_bell(2093.0, 0.30, 0.16, decay_ms=200, index=1.4), ms(140))
    buf = overlay(buf, fm_bell(2637.0, 0.22, 0.10, decay_ms=160, index=1.2), ms(210))
    write_wav("star.wav", buf, peak=0.62, cut=8200)


def sfx_correct() -> None:
    # Duolingo-like major arpeggio, overlapping bells (E5 G5 C6)
    e5 = fm_bell(659.25, 0.28, 0.32, decay_ms=180, index=1.15)
    g5 = fm_bell(783.99, 0.32, 0.34, decay_ms=200, index=1.15)
    c6 = fm_bell(1046.5, 0.42, 0.38, decay_ms=260, index=1.25)
    buf = overlay(e5, g5, ms(85))
    buf = overlay(buf, c6, ms(170))
    write_wav("correct.wav", buf, peak=0.66, cut=7600)


def sfx_success() -> None:
    a = fm_bell(783.99, 0.22, 0.30, decay_ms=160, index=1.1)
    b = fm_bell(1174.7, 0.34, 0.36, decay_ms=230, index=1.2)
    write_wav("success.wav", overlay(a, b, ms(70)), peak=0.64, cut=7400)


def sfx_wrong() -> None:
    # soft "hmm" — major third down, never a buzzer
    a = triangle_tone(392.00, 0.16, 0.28, attack_ms=10, decay_ms=130)
    b = triangle_tone(329.63, 0.24, 0.26, attack_ms=12, decay_ms=180)
    body = tone(196.0, 0.28, 0.10, decay_ms=200, harmonics=(1.0, 0.2))
    write_wav("wrong.wav", overlay(overlay(a, b, ms(110)), body, 0), peak=0.50, cut=3800)


def sfx_error() -> None:
    a = triangle_tone(349.23, 0.14, 0.22, attack_ms=12, decay_ms=110)
    b = triangle_tone(293.66, 0.20, 0.20, attack_ms=14, decay_ms=150)
    write_wav("error.wav", overlay(a, b, ms(90)), peak=0.44, cut=3400)


def sfx_win() -> None:
    notes = [523.25, 659.25, 783.99, 1046.5, 1318.5]
    buf: list[float] = []
    for i, f in enumerate(notes):
        buf = overlay(buf, fm_bell(f, 0.36 + i * 0.04, 0.30, decay_ms=200 + i * 20, index=1.2), ms(90 * i))
    # held major sparkle on the last chord
    buf = overlay(buf, tone(1046.5, 0.55, 0.10, decay_ms=400, harmonics=(1.0, 0.2)), ms(280))
    buf = overlay(buf, fm_bell(1568.0, 0.30, 0.12, decay_ms=180, index=1.4), ms(360))
    buf = overlay(buf, fm_bell(2093.0, 0.24, 0.08, decay_ms=150, index=1.3), ms(430))
    write_wav("win.wav", buf, peak=0.70, cut=8000)


def sfx_lose() -> None:
    # comforting descent, quieter than win
    g = triangle_tone(392.00, 0.22, 0.24, attack_ms=14, decay_ms=180)
    e = triangle_tone(329.63, 0.24, 0.22, attack_ms=16, decay_ms=200)
    c = triangle_tone(261.63, 0.40, 0.22, attack_ms=18, decay_ms=320)
    pad = tone(196.00, 0.55, 0.08, decay_ms=380, harmonics=(1.0, 0.15))
    buf = overlay(g, e, ms(160))
    buf = overlay(buf, c, ms(320))
    buf = overlay(buf, pad, 0)
    write_wav("lose.wav", buf, peak=0.46, cut=3600)


def sfx_levelup() -> None:
    notes = [523.25, 587.33, 659.25, 783.99, 1046.5, 1318.5]
    buf: list[float] = []
    for i, f in enumerate(notes):
        buf = overlay(buf, fm_bell(f, 0.30, 0.26, decay_ms=180, index=1.25), ms(70 * i))
    buf = overlay(buf, fm_bell(1568.0, 0.40, 0.16, decay_ms=260, index=1.4), ms(420))
    buf = overlay(buf, tone(783.99, 0.55, 0.10, decay_ms=420, harmonics=(1.0, 0.25, 0.08)), ms(200))
    write_wav("levelup.wav", buf, peak=0.70, cut=8200)


def sfx_unlock() -> None:
    a = fm_bell(783.99, 0.22, 0.26, decay_ms=150, index=1.3)
    b = fm_bell(1046.5, 0.26, 0.30, decay_ms=180, index=1.4)
    c = fm_bell(1568.0, 0.40, 0.34, decay_ms=260, index=1.6)
    sh = fm_bell(2093.0, 0.28, 0.12, decay_ms=180, index=1.2)
    buf = overlay(a, b, ms(70))
    buf = overlay(buf, c, ms(150))
    buf = overlay(buf, sh, ms(210))
    write_wav("unlock.wav", buf, peak=0.66, cut=8000)


def sfx_tick() -> None:
    write_wav(
        "tick.wav",
        overlay(
            tone(1320, 0.036, 0.15, attack_ms=1.0, decay_ms=22, harmonics=(1.0,)),
            tone(660, 0.055, 0.12, attack_ms=1.5, decay_ms=38, harmonics=(1.0, 0.1)),
        ),
        peak=0.36,
        cut=4800,
    )


def sfx_countdown() -> None:
    write_wav(
        "countdown.wav",
        overlay(
            fm_bell(659.25, 0.14, 0.28, decay_ms=90, index=1.0),
            tone(329.63, 0.12, 0.10, decay_ms=80),
        ),
        peak=0.52,
        cut=5600,
    )


def sfx_go() -> None:
    a = fm_bell(659.25, 0.18, 0.28, decay_ms=120, index=1.1)
    b = fm_bell(987.77, 0.22, 0.32, decay_ms=160, index=1.2)
    c = fm_bell(1318.5, 0.30, 0.34, decay_ms=210, index=1.3)
    buf = overlay(a, b, ms(70))
    buf = overlay(buf, c, ms(150))
    write_wav("go.wav", buf, peak=0.64, cut=7600)


def sfx_sleep() -> None:
    # music-box chime for the lullaby hub — not a song, just a soft cue
    c5 = fm_bell(523.25, 0.70, 0.22, decay_ms=520, index=0.7, ratio=1.99)
    e5 = fm_bell(659.25, 0.65, 0.16, decay_ms=480, index=0.6, ratio=2.00)
    g5 = fm_bell(783.99, 0.80, 0.18, decay_ms=560, index=0.6, ratio=2.01)
    c4 = tone(261.63, 0.90, 0.08, decay_ms=700, harmonics=(1.0, 0.12))
    buf = overlay(c5, e5, ms(280))
    buf = overlay(buf, g5, ms(560))
    buf = overlay(buf, c4, 0)
    write_wav("sleep.wav", buf, peak=0.48, cut=4200)


def main() -> None:
    print("Generating premium kid-safe SFX →", OUT)
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
    print("done.")


if __name__ == "__main__":
    main()
