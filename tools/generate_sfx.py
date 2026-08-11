#!/usr/bin/env python3
"""
Offline SFX generator for Jazireh Fandoghi.
Produces royalty-free 16-bit 44.1kHz mono WAV files under assets/audio/sfx.

All sounds are synthesized procedurally (no third-party assets).
Run:  python3 tools/generate_sfx.py
"""
import math
import os
import struct
import wave

SR = 44100  # sample rate
OUT = os.path.join(os.path.dirname(__file__), "..", "assets", "audio", "sfx")
os.makedirs(OUT, exist_ok=True)


def clamp(v):
    return max(-1.0, min(1.0, v))


def write_wav(name, samples):
    path = os.path.join(OUT, name)
    with wave.open(path, "w") as w:
        w.setnchannels(1)
        w.setsampwidth(2)
        w.setframerate(SR)
        frames = bytearray()
        for s in samples:
            frames += struct.pack("<h", int(clamp(s) * 32767))
        w.writeframes(bytes(frames))
    print("wrote", os.path.relpath(path, os.path.join(OUT, "..", "..", "..")))


def env(i, n, attack=0.01, release=0.08):
    """Simple attack/decay envelope 0..1."""
    t = i / SR
    a = min(1.0, t / max(attack, 1e-4))
    r = min(1.0, (n / SR - t) / max(release, 1e-4))
    return max(0.0, min(a, r))


def tone(freq, dur, vol=0.5, wave_type="sine", attack=0.005, release=0.06):
    n = int(SR * dur)
    out = []
    for i in range(n):
        t = i / SR
        ph = 2 * math.pi * freq * t
        if wave_type == "square":
            v = 1.0 if math.sin(ph) >= 0 else -1.0
            v *= 0.4
        elif wave_type == "triangle":
            v = 2 / math.pi * math.asin(math.sin(ph))
        elif wave_type == "saw":
            v = 2 * (freq * t - math.floor(0.5 + freq * t))
            v *= 0.5
        else:
            v = math.sin(ph)
        out.append(v * vol * env(i, n, attack, release))
    return out


def fslide(f0, f1, dur, vol=0.5, wave_type="sine", attack=0.005, release=0.05):
    n = int(SR * dur)
    out = []
    for i in range(n):
        t = i / SR
        f = f0 + (f1 - f0) * (t / dur)
        ph = 2 * math.pi * f * t
        v = math.sin(ph) if wave_type == "sine" else (1.0 if math.sin(ph) >= 0 else -1.0) * 0.4
        out.append(v * vol * env(i, n, attack, release))
    return out


def mix(*tracks):
    length = max(len(t) for t in tracks)
    out = [0.0] * length
    for tr in tracks:
        for i, s in enumerate(tr):
            out[i] += s
    # normalize to avoid clipping
    peak = max(1e-6, max(abs(s) for s in out))
    if peak > 0.9:
        out = [s / peak * 0.9 for s in out]
    return out


def seq(notes):
    out = []
    for f, d in notes:
        out.extend(tone(f, d))
    return out


# ───────────────────────────── individual SFX ─────────────────────────────

def sfx_tap():
    # soft UI tap: two quick sine blips
    a = tone(880, 0.05, 0.4)
    b = tone(1320, 0.06, 0.3)
    write_wav("tap.wav", mix(a, [0.0] * 1500 + b))


def sfx_click():
    # crisp UI click
    a = fslide(1200, 700, 0.07, 0.45, "square")
    write_wav("click.wav", a)


def sfx_correct():
    # happy ascending chime C-E-G
    write_wav("correct.wav", seq([
        (523.25, 0.10), (659.25, 0.10), (783.99, 0.18),
    ]))


def sfx_wrong():
    # gentle descending two tones (not harsh)
    a = tone(311.13, 0.13, 0.4)
    b = tone(233.08, 0.20, 0.4)
    write_wav("wrong.wav", a + [0.0] * 400 + b)


def sfx_win():
    # triumphant fanfare: C-E-G-C arpeggio + sparkle
    arp = seq([
        (523.25, 0.10), (659.25, 0.10), (783.99, 0.10), (1046.5, 0.28),
    ])
    sparkle = []
    for i in range(6):
        f = 1568 + i * 200
        sparkle.extend([0.0] * 800)
        sparkle.extend(tone(f, 0.12, 0.18))
    write_wav("win.wav", mix(arp, sparkle))


def sfx_lose():
    # sad descending: G-Eb-C
    write_wav("lose.wav", seq([
        (392.0, 0.18), (311.13, 0.18), (261.63, 0.35),
    ]))


def sfx_coin():
    # classic coin: B5 -> E6
    a = tone(987.77, 0.06, 0.4)
    b = tone(1318.5, 0.16, 0.4)
    write_wav("coin.wav", a + b)


def sfx_star():
    # magical star ping with shimmer
    base = tone(1568, 0.35, 0.35)
    shimmer = []
    for i in range(5):
        shimmer.extend([0.0] * 1200)
        shimmer.extend(tone(2093 + i * 220, 0.10, 0.18))
    write_wav("star.wav", mix(base, shimmer))


def sfx_pop():
    # bubble pop: quick upward pitch then short noise
    return fslide(400, 1400, 0.08, 0.5, "sine", release=0.02)


def sfx_bubble():
    write_wav("bubble.wav", sfx_pop())


def sfx_swoosh():
    # whoosh: filtered noise sweep approximation via saw pitch drop
    write_wav("swoosh.wav", fslide(1200, 200, 0.22, 0.35, "saw"))


def sfx_levelup():
    # level up: C-E-G-C held major chord
    chord = mix(
        tone(523.25, 0.6, 0.3),
        tone(659.25, 0.6, 0.3),
        tone(783.99, 0.6, 0.3),
        tone(1046.5, 0.7, 0.3),
    )
    write_wav("levelup.wav", chord)


def sfx_tick():
    # short metronome tick
    write_wav("tick.wav", tone(1000, 0.03, 0.3))


def sfx_back():
    # soft back navigation
    write_wav("back.wav", fslide(700, 400, 0.08, 0.35, "sine"))


def sfx_unlock():
    # achievement unlock: rising shimmer
    arp = seq([
        (659.25, 0.08), (783.99, 0.08), (987.77, 0.08), (1318.5, 0.25),
    ])
    write_wav("unlock.wav", arp)


def sfx_error():
    # light buzzer (not scary)
    a = tone(196, 0.12, 0.35, "triangle")
    b = tone(185, 0.18, 0.35, "triangle")
    write_wav("error.wav", a + [0.0] * 300 + b)


def sfx_countdown():
    write_wav("countdown.wav", tone(880, 0.10, 0.4))


def sfx_go():
    write_wav("go.wav", seq([(659.25, 0.10), (987.77, 0.22)]))


def sfx_select():
    # gentle select (for menu/hub tiles)
    write_wav("select.wav", seq([(784, 0.07), (1046.5, 0.10)]))


def sfx_page():
    # page turn / whoosh light
    write_wav("page.wav", fslide(900, 300, 0.14, 0.25, "triangle"))


def sfx_sleep():
    # soft sleepy chime for lullabies hub
    a = tone(523.25, 0.5, 0.3)
    b = tone(392.0, 0.7, 0.3)
    write_wav("sleep.wav", a + [0.0] * 2000 + b)


def sfx_success_short():
    write_wav("success.wav", seq([(659.25, 0.08), (987.77, 0.18)]))


def main():
    sfx_tap()
    sfx_click()
    sfx_correct()
    sfx_wrong()
    sfx_win()
    sfx_lose()
    sfx_coin()
    sfx_star()
    sfx_bubble()
    sfx_swoosh()
    sfx_levelup()
    sfx_tick()
    sfx_back()
    sfx_unlock()
    sfx_error()
    sfx_countdown()
    sfx_go()
    sfx_select()
    sfx_page()
    sfx_sleep()
    sfx_success_short()
    print("All SFX generated in", os.path.abspath(OUT))


if __name__ == "__main__":
    main()
