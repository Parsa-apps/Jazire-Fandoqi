#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""✂️ برش خودکار بَچ‌های صوتیِ «کلمه‌های کارگاه واژه‌سازی».

هر بَچ یک فایل WAV است که چند کلمه پشت سر هم در آن خوانده شده و بین
کلمه‌ها سکوت کوتاهی هست. این ابزار روی سکوت می‌بُرد، هر کلمه را جدا
می‌کند، نویز/سکوت لبه‌ها را می‌تراشد، fade کوتاه می‌گذارد و نرمالایز
می‌کند تا بلندیِ همهٔ کلمه‌ها یکسان باشد.

فقط از کتابخانهٔ استاندارد پایتون استفاده می‌کند (بدون numpy/ffmpeg) تا
روی هر ماشینی بدون نصب چیزی اجرا شود.

نحوهٔ اجرا:
    python3 tools/split_word_batches.py \
        --batch .audio_work/batch01.wav آب بابا باد داد آباد

خروجی: assets/audio/words/w01.wav ... (نام فایل از نگاشت
`WORD_KEYS` داخل همین فایل خوانده می‌شود.)
"""

from __future__ import annotations

import argparse
import array
import os
import sys
import wave

# ── تنظیمات برش ────────────────────────────────────────────────────
SILENCE_RATIO = 0.06     # آستانهٔ سکوت نسبت به بلندترین نمونهٔ فایل
MIN_SILENCE_MS = 140     # سکوت کوتاه‌تر از این «مرز کلمه» نیست
MIN_WORD_MS = 180        # قطعهٔ کوتاه‌تر از این احتمالاً نویز است
PAD_MS = 60              # کمی هوا قبل/بعد هر کلمه
FADE_MS = 18             # fade in/out تا صدا «کلیک» ندهد
TARGET_PEAK = 0.89       # اوج نهایی بعد از نرمالایز
TARGET_RATE = 22050      # نرخ نهایی؛ برای گفتار کاملاً کافی و نصف حجم


def downsample_half(samples: array.array) -> array.array:
    """نصف‌کردن نرخ نمونه‌برداری با میانگین هر دو نمونه.

    میانگین‌گیری نقش یک فیلتر پایین‌گذر سادهٔ ضدِ aliasing را بازی می‌کند؛
    برای گفتار (که انرژی‌اش زیر ۸ کیلوهرتز است) کیفیت شنیداری تفاوتی
    نمی‌کند ولی حجم فایل نصف می‌شود.
    """
    out = array.array("h", [0] * (len(samples) // 2))
    for i in range(len(out)):
        out[i] = int((samples[2 * i] + samples[2 * i + 1]) / 2)
    return out


def read_wav(path: str):
    with wave.open(path, "rb") as w:
        if w.getsampwidth() != 2:
            raise SystemExit(f"{path}: فقط WAV شانزده‌بیتی پشتیبانی می‌شود")
        channels = w.getnchannels()
        rate = w.getframerate()
        raw = w.readframes(w.getnframes())
    samples = array.array("h")
    samples.frombytes(raw)
    if channels > 1:  # به مونو تبدیل کن (میانگین کانال‌ها)
        mono = array.array("h", [0] * (len(samples) // channels))
        for i in range(len(mono)):
            total = sum(samples[i * channels + c] for c in range(channels))
            mono[i] = int(total / channels)
        samples = mono
    return samples, rate


def write_wav(path: str, samples: array.array, rate: int) -> None:
    os.makedirs(os.path.dirname(path), exist_ok=True)
    with wave.open(path, "wb") as w:
        w.setnchannels(1)
        w.setsampwidth(2)
        w.setframerate(rate)
        w.writeframes(samples.tobytes())


def envelope(samples: array.array, rate: int, window_ms: int = 12):
    """بلندی میانگین در پنجره‌های کوچک — مبنای تشخیص سکوت."""
    win = max(1, int(rate * window_ms / 1000))
    out = []
    for start in range(0, len(samples), win):
        chunk = samples[start:start + win]
        if not chunk:
            break
        out.append(sum(abs(s) for s in chunk) / len(chunk))
    return out, win


def find_segments(samples: array.array, rate: int):
    env, win = envelope(samples, rate)
    if not env:
        return []
    peak = max(env) or 1
    threshold = peak * SILENCE_RATIO
    loud = [value > threshold for value in env]

    min_gap = max(1, int(MIN_SILENCE_MS / 12))
    segments = []
    start = None
    silence = 0
    for index, is_loud in enumerate(loud):
        if is_loud:
            if start is None:
                start = index
            silence = 0
        elif start is not None:
            silence += 1
            if silence >= min_gap:
                segments.append((start, index - silence + 1))
                start = None
                silence = 0
    if start is not None:
        segments.append((start, len(loud)))

    min_len = max(1, int(MIN_WORD_MS / 12))
    pad = int(rate * PAD_MS / 1000)
    result = []
    for a, b in segments:
        if b - a < min_len:
            continue
        lo = max(0, a * win - pad)
        hi = min(len(samples), b * win + pad)
        result.append((lo, hi))
    return result


def polish(chunk: array.array, rate: int) -> array.array:
    """نرمالایز + fade نرم در دو سر قطعه."""
    peak = max((abs(s) for s in chunk), default=0)
    if peak == 0:
        return chunk
    gain = (TARGET_PEAK * 32767) / peak
    gain = min(gain, 8.0)  # جلوی تقویت بیش‌ازحدِ نویز را می‌گیرد
    out = array.array("h", [0] * len(chunk))
    fade = max(1, int(rate * FADE_MS / 1000))
    for i, sample in enumerate(chunk):
        value = sample * gain
        if i < fade:
            value *= i / fade
        elif i >= len(chunk) - fade:
            value *= (len(chunk) - i) / fade
        out[i] = max(-32768, min(32767, int(value)))
    return out


def main() -> int:
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--batch", required=True, help="فایل WAV بَچ")
    parser.add_argument("--out-dir", default="assets/audio/words")
    parser.add_argument("--dry-run", action="store_true")
    parser.add_argument("keys", nargs="+",
                        help="کلید فایل هر کلمه به ترتیب خوانده‌شدن، مثل w01 w02")
    args = parser.parse_args()

    samples, rate = read_wav(args.batch)
    segments = find_segments(samples, rate)

    print(f"🎧 {args.batch}: {len(segments)} قطعه پیدا شد "
          f"(انتظار: {len(args.keys)})")
    for (lo, hi) in segments:
        print(f"   • {lo / rate:6.2f}s → {hi / rate:6.2f}s "
              f"({(hi - lo) / rate:.2f}s)")

    if len(segments) != len(args.keys):
        print("❌ تعداد قطعه‌ها با تعداد کلمه‌ها یکی نیست؛ بَچ را دوباره "
              "با مکث بیشتر بین کلمه‌ها بساز یا آستانه را تنظیم کن.")
        return 1

    if args.dry_run:
        return 0

    for key, (lo, hi) in zip(args.keys, segments):
        chunk = polish(samples[lo:hi], rate)
        out_rate = rate
        while out_rate >= TARGET_RATE * 2:
            chunk = downsample_half(chunk)
            out_rate //= 2
        path = os.path.join(args.out_dir, f"{key}.wav")
        write_wav(path, chunk, out_rate)
        size = os.path.getsize(path) / 1024
        print(f"   ✅ {path}  ({(hi - lo) / rate:.2f}s, {size:.0f} KB)")
    return 0


if __name__ == "__main__":
    sys.exit(main())
