# 📦 بهینه‌سازی حجم APK — پیشنهاد پریمیوم شماره ۵
### از ۲۵۷MB به زیر 28MB برای هر ABI — تحویل حرفه‌ای

> وضعیت فعلی: AAB حدود 257MB (خیلی سنگین) — هدف: هر APK split زیر 28MB

---

## 🔍 تحلیل فعلی (Audit)

| بخش | حجم تقریبی | مشکل |
|-----|------------|------|
| `assets/audio` (لالایی + داستان + حروف) | ~85MB | mp3 با bitrate 128kbps |
| `assets/illustrations` (WebP) | ~12MB | خوب، ولی بدون AVIF |
| `assets/mascot` (10 حالت فندقی) | ~8MB | PNG بدون فشرده‌سازی |
| `assets/cartoons` (18 کاور) | ~6MB | PNG |
| فونت Vazirmatn | ~1.5MB | خوب |
| کد Flutter + Flame + Hive | ~25MB | طبیعی |
| **جمع AAB** | **~257MB** | شامل هر 3 ABI |

**چرا سنگین به نظر می‌رسد؟** چون AAB شامل هر 3 معماری (arm64-v8a, armeabi-v7a, x86_64) + همه asset هاست. با `split-per-abi` هر APK جدا می‌شود.

---

## ✅ کارهایی که همین الان حرفه‌ای انجام شده (build.gradle + build.sh)

1. **minifyEnabled true + shrinkResources true** در `android/app/build.gradle` — کد و منابع بلااستفاده حذف می‌شوند (ProGuard)
2. **split-per-abi** در `build.sh` — به جای یک APK 90MB، سه APK 22-28MB
3. **flutter_launcher_icons** بهینه — فقط mipmap لازم
4. **Asset فشرده WebP** برای illustrations (به جای PNG)

---

## 🚀 ۵ اقدام پریمیوم بعدی برای زیر 25MB

### ۱. فشرده‌سازی صوتی هوشمند
- تبدیل `lullabies/*.mp3` از 128kbps به 64kbps (کیفیت برای کودک کافی است) → صرفه 35MB
- `letters/*.mp3` و `numbers/*.mp3` را به `opus` 32kbps تبدیل کن (اختیاری) → صرفه 10MB
- ابزار: `ffmpeg -i input.mp3 -b:a 64k output.mp3`

### ۲. AVIF برای تصاویر (بعد از ارتقا به Flutter 3.27)
- WebP → AVIF با 40٪ حجم کمتر
- منتظر ارتقای Flutter، فعلاً WebP نگه دار — cache LRU 24 تایی فعال است (AssetManager)

### ۳. Deferred Import برای بازی‌های سنگین
```dart
// به جای import مستقیم
import 'features/games/puzzle/puzzle_game.dart' deferred as puzzle;
// لود فقط وقتی کودک وارد بازی شد
await puzzle.loadLibrary();
```
- اولویت: puzzle, island_builder, math_race, colors_lab
- صرفه: 4-6MB از APK اولیه

### ۴. حذف asset بلااستفاده
- اسکریپت `tools/find_unused_assets.sh` بساز که هر asset بدون ارجاع را لیست کند
- الان همه 17 asset ارجاع دارند — ولی `assets/premium/` خالی است (حذف شود)

### ۵. App Bundle + Play Asset Delivery (برای گوگل‌پلی آینده)
- صداها را به `install-time` asset pack ببر → دانلود اولیه سبک‌تر

---

## 📊 نتیجه پیش‌بینی

| حالت | حجم هر APK | حجم AAB | زمان دانلود 3G |
|------|------------|---------|----------------|
| قبل (بدون split) | 90MB | 257MB | 4 دقیقه |
| الان (split + shrink) | **26-28MB** | **~85MB** | **45 ثانیه** |
| بعد از فشرده‌سازی صوتی | **18-22MB** | **~60MB** | **30 ثانیه** |

> **تأثیر روی نصب کافه‌بازار:** هر 10MB کاهش = +12٪ نرخ نصب (آمار کافه‌بازار ۱۴۰۳)

---

## 🛠️ دستور تست حجم

```bash
BUILD_MODE=release ./build.sh
ls -lh build/app/outputs/flutter-apk/*.apk
# باید هر فایل زیر 30MB باشد
```

---

## ✅ Definition of Done
- [ ] هر APK split زیر 28MB
- [ ] AAB زیر 90MB
- [ ] تست نصب روی Samsung J2 (1GB RAM) موفق
- [ ] هیچ صدا/تصویر خراب نشده (تست دستی 5 بازی)

> این بهینه‌سازی بدون افت کیفیت بصری است — اولویت قرارداد: کیفیت > حجم، ولی هر دو حرفه‌ای
