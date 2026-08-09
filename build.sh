#!/usr/bin/env bash
# 🚀 KUDAKE IRAN — Professional Multi-Stage Build Script (فاز ۹)
# چک ۷ مرحله‌ای با توقف شفاف: analyze → test → coverage → build → size → icon
set -Eeuo pipefail

BUILD_MODE="${BUILD_MODE:-debug}"
PROJECT_NAME="amoozesh_fandoghi"
FAILED=0

log()  { printf '▶ %s\n' "$1"; }
ok()   { printf '✅ %s\n' "$1"; }
fail() { printf '❌ %s\n' "$1"; FAILED=1; }

printf '===========================================================\n'
printf '🐰 کودک ایران — سیستم بیلد حرفه‌ای (حالت: %s)\n' "$BUILD_MODE"
printf '===========================================================\n'

# ── ۱. محیط Flutter ─────────────────────────────────────────────
log 'مرحله ۱/۷: بررسی محیط Flutter'
if ! command -v flutter >/dev/null 2>&1; then
  fail 'خطا: فلاتر نصب نیست. (flutter doctor)'
  exit 1
fi
ok "Flutter: $(flutter --version | head -1)"

# ── ۲. پروژه اندروید ────────────────────────────────────────────
log 'مرحله ۲/۷: بررسی پروژه اندروید'
if [[ ! -d android ]]; then
  log 'ساختار اندروید ساخته می‌شود...'
  flutter create . --platforms android --project-name "$PROJECT_NAME" --org com.parsaapps
fi
ok 'پروژه اندروید موجود است'

# ── ۳. وابستگی‌ها ────────────────────────────────────────────────
log 'مرحله ۳/۷: دریافت کتابخانه‌ها'
if ! flutter pub get; then
  fail 'pub get شکست خورد'
fi
ok 'وابستگی‌ها نصب شد'

# ── ۴. آیکون‌ها ──────────────────────────────────────────────────
log 'مرحله ۴/۷: تولید آیکون‌های اپلیکیشن'
if ! flutter pub run flutter_launcher_icons; then
  fail 'تولید آیکون شکست خورد'
fi
if [[ ! -f android/app/src/main/res/mipmap-xxxhdpi/ic_launcher.png ]]; then
  fail 'آیکون لانچر ساخته نشد (mipmap missing)'
fi
ok 'آیکون‌ها تولید شد'

# ── ۵. تحلیل استاتیک (نمایش کامل خروجی) ─────────────────────────
log 'مرحله ۵/۷: تحلیل استاتیک کد'
if ! flutter analyze; then
  fail 'تحلیل استاتیک خطا دارد — لطفاً قبل از بیلد رفع کنید'
  exit 1
fi
ok 'تحلیل استاتیک بدون خطا'

# ── ۶. تست‌ها + پوشش ─────────────────────────────────────────────
log 'مرحله ۶/۷: اجرای تست‌های خودکار'
if ! flutter test --coverage; then
  fail 'تست‌ها شکست خوردند'
  exit 1
fi
if [[ -f coverage/lcov.info ]]; then
  LINE_COV=$(awk -F: '/^LF:/{lf+=$2}/^LH:/{lh+=$2}END{printf "%.1f", 100*lh/lf}' coverage/lcov.info 2>/dev/null || echo "?")
  ok "پوشش خطوط کد: ${LINE_COV}%"
fi

# ── ۷. بیلد + حجم + آیکون نهایی ──────────────────────────────────
log 'مرحله ۷/۷: ساخت خروجی'
if [[ "$BUILD_MODE" == "release" ]]; then
  log 'ساخت APK (split per ABI)...'
  if ! flutter build apk --release --split-per-abi; then
    fail 'ساخت APK شکست خورد'
    exit 1
  fi
  log 'ساخت AAB...'
  if ! flutter build appbundle --release; then
    fail 'ساخت AAB شکست خورد'
    exit 1
  fi

  TOTAL=0
  for apk in build/app/outputs/flutter-apk/*.apk; do
    SIZE=$(du -m "$apk" | cut -f1)
    TOTAL=$((TOTAL + SIZE))
    ok "APK: $(basename "$apk") → ${SIZE}MB"
  done
  ok "حجم کل APKها: ${TOTAL}MB (هدف < ۳۵MB برای هر ABI)"
else
  log 'ساخت نسخه آزمایشی (Debug)...'
  if ! flutter build apk --debug; then
    fail 'ساخت Debug شکست خورد'
    exit 1
  fi
fi

if [[ $FAILED -ne 0 ]]; then
  fail 'برخی مراحل با هشدار تمام شدند — خروجی را بررسی کنید'
  exit 1
fi

echo '✨ عملیات با موفقیت به پایان رسید.'
