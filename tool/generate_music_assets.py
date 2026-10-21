#!/usr/bin/env python3
"""تولید دارایی‌های صوتی «استودیوی موسیقی فندقی».

چرا این فایل در مخزن است؟
    کودک باید بتواند روی نت‌ها بزند و *همان لحظه* صدا بشنود؛ بدون اینترنت و
    بدون وابستگی به موتور TTS دستگاه. نت‌های ماریمبا و پرکاشن با همین اسکریپت
    ساخته می‌شوند تا منبعِ دارایی‌ها مشخص و بازتولیدپذیر باشد.

اجرا:
    python3 tool/generate_music_assets.py

خروجی:
    assets/audio/studio/notes/c4.wav ... c5.wav
    assets/audio/studio/perc/kick.wav, snare.wav, hat.wav, clap.wav, tom.wav
"""

from __future__ import annotations

import math
import os
import struct
import wave

import numpy as np

SAMPLE_RATE = 22050
ROOT = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
NOTES_DIR = os.path.join(ROOT, "assets", "audio", "studio", "notes")
PERC_DIR = os.path.join(ROOT, "assets", "audio", "studio", "perc")

# هفت نت گام دو ماژور + اکتاو بعد؛ نام فایل = نام نت.
NOTES = {
    "c4": 261.63,
    "d4": 293.66,
    "e4": 329.63,
    "f4": 349.23,
    "g4": 392.00,
    "a4": 440.00,
    "b4": 493.88,
    "c5": 523.25,
}


def _envelope(length: int, decay: float, attack_s: float = 0.004) -> np.ndarray:
    t = np.arange(length, dtype=np.float64) / SAMPLE_RATE
    attack = np.clip(t / max(attack_s, 1e-4), 0.0, 1.0)
    return attack * np.exp(-decay * t)


def marimba(freq: float, duration: float = 1.05) -> np.ndarray:
    """تنِ گرم و چوبی شبیه ماریمبا/زیلوفون با هارمونیک‌های ۴ و ۱۰."""
    length = int(SAMPLE_RATE * duration)
    t = np.arange(length, dtype=np.float64) / SAMPLE_RATE
    body = np.sin(2 * math.pi * freq * t)
    fourth = 0.30 * np.sin(2 * math.pi * freq * 4 * t) * np.exp(-4.5 * t)
    tenth = 0.12 * np.sin(2 * math.pi * freq * 10 * t) * np.exp(-7.0 * t)
    tone = (body + fourth + tenth) * _envelope(length, 3.4)
    return _normalize(_fade_out(tone, 0.04), peak=0.72)


def kick(duration: float = 0.38) -> np.ndarray:
    length = int(SAMPLE_RATE * duration)
    t = np.arange(length, dtype=np.float64) / SAMPLE_RATE
    sweep = 118 * np.exp(-14 * t) + 42
    phase = 2 * math.pi * np.cumsum(sweep) / SAMPLE_RATE
    tone = np.sin(phase) * np.exp(-9.5 * t)
    click = np.sin(2 * math.pi * 1450 * t) * np.exp(-90 * t) * 0.25
    return _normalize(_fade_out(tone + click, 0.03), peak=0.85)


def tom(duration: float = 0.34) -> np.ndarray:
    length = int(SAMPLE_RATE * duration)
    t = np.arange(length, dtype=np.float64) / SAMPLE_RATE
    sweep = 185 * np.exp(-10 * t) + 88
    phase = 2 * math.pi * np.cumsum(sweep) / SAMPLE_RATE
    return _normalize(_fade_out(np.sin(phase) * np.exp(-8 * t), 0.02), peak=0.75)


def snare(duration: float = 0.30) -> np.ndarray:
    rng = np.random.default_rng(7)
    length = int(SAMPLE_RATE * duration)
    t = np.arange(length, dtype=np.float64) / SAMPLE_RATE
    noise = rng.uniform(-1.0, 1.0, length) * np.exp(-17 * t)
    body = 0.55 * np.sin(2 * math.pi * 185 * t) * np.exp(-20 * t)
    return _normalize(_fade_out(noise + body, 0.02), peak=0.62)


def hat(duration: float = 0.10, rng_seed: int = 11) -> np.ndarray:
    rng = np.random.default_rng(rng_seed)
    length = int(SAMPLE_RATE * duration)
    t = np.arange(length, dtype=np.float64) / SAMPLE_RATE
    noise = rng.uniform(-1.0, 1.0, length)
    # فیلتر سادهٔ بالاگذر: تفاضلِ نویز، انرژیِ فرکانس‌های بالا را نگه می‌دارد.
    high = np.diff(noise, prepend=noise[0])
    return _normalize(_fade_out(high * np.exp(-55 * t), 0.01), peak=0.45)


def clap(duration: float = 0.32) -> np.ndarray:
    rng = np.random.default_rng(3)
    length = int(SAMPLE_RATE * duration)
    t = np.arange(length, dtype=np.float64) / SAMPLE_RATE
    noise = rng.uniform(-1.0, 1.0, length)
    high = np.diff(noise, prepend=noise[0])
    shape = np.zeros(length, dtype=np.float64)
    for offset, gain in ((0.00, 1.0), (0.014, 0.72), (0.028, 0.52)):
        start = int(offset * SAMPLE_RATE)
        shape[start:] += gain * np.exp(-70 * (t[: length - start]))
    return _normalize(_fade_out(high * shape, 0.03), peak=0.55)


def _normalize(samples: np.ndarray, peak: float) -> np.ndarray:
    biggest = float(np.max(np.abs(samples))) if samples.size else 0.0
    if biggest > 0:
        samples = samples / biggest * peak
    return samples


def _fade_out(samples: np.ndarray, seconds: float) -> np.ndarray:
    count = min(len(samples), max(1, int(seconds * SAMPLE_RATE)))
    if count <= 1:
        return samples
    samples = samples.copy()
    samples[-count:] *= np.linspace(1.0, 0.0, count)
    return samples


def write_wav(path: str, samples: np.ndarray) -> None:
    os.makedirs(os.path.dirname(path), exist_ok=True)
    pcm = np.clip(samples, -1.0, 1.0)
    pcm = (pcm * 32767.0).astype(np.int16)
    with wave.open(path, "wb") as handle:
        handle.setnchannels(1)
        handle.setsampwidth(2)
        handle.setframerate(SAMPLE_RATE)
        handle.writeframes(pcm.tobytes())
    print(f"{path}  {os.path.getsize(path):,} bytes")


def main() -> None:
    for name, freq in NOTES.items():
        write_wav(os.path.join(NOTES_DIR, f"{name}.wav"), marimba(freq))
    write_wav(os.path.join(PERC_DIR, "kick.wav"), kick())
    write_wav(os.path.join(PERC_DIR, "snare.wav"), snare())
    write_wav(os.path.join(PERC_DIR, "hat.wav"), hat())
    write_wav(os.path.join(PERC_DIR, "clap.wav"), clap())
    write_wav(os.path.join(PERC_DIR, "tom.wav"), tom())
    print("done")


if __name__ == "__main__":
    main()
