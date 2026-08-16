#!/usr/bin/env bash
# 🚀 JAZIREH FANDOGHI — Professional Multi-Stage Build Script (فاز ۹)
# چک ۷ مرحله‌ای با توقف شفاف: analyze → test → coverage → build → size → icon
set -Eeuo pipefail

BUILD_MODE="${BUILD_MODE:-debug}"
# 🏪 فروشگاه هدف بیلد release: bazaar (پیش‌فرض) یا myket.
# بیلد مایکت باید جدا ساخته شود تا permission پرداخت بازار در APK نباشد
# (مایکت APKهای دارای com.farsitel.bazaar.permission.PAY_THROUGH_BAZAAR را رد می‌کند):
#   STORE_FLAVOR=myket BUILD_MODE=release ./build.sh
STORE_FLAVOR="${STORE_FLAVOR:-bazaar}"
PROJECT_NAME="amoozesh_fandoghi"
FAILED=0

log()  { printf '▶ %s\n' "$1"; }
ok()   { printf '✅ %s\n' "$1"; }
fail() { printf '❌ %s\n' "$1"; FAILED=1; }

printf '===========================================================\n'
printf '🐰 جزیره فندقی — سیستم بیلد حرفه‌ای (حالت: %s)\n' "$BUILD_MODE"
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
  if [[ ! -f android/key.properties ]]; then
    if [[ "${ALLOW_VERIFICATION_SIGNING:-0}" == "1" ]]; then
      log '⚠️  خروجی تأیید CI با کلید debug ساخته می‌شود و قابل انتشار نیست.'
      export ORG_GRADLE_PROJECT_allowVerificationSigning=true
    else
      fail 'فایل android/key.properties پیدا نشد؛ ساخت خروجی release متوقف شد.'
      log 'برای انتشار، keystore اصلی و android/key.properties را طبق BUILD_INSTRUCTIONS.md تنظیم کن.'
      log 'فقط برای آرتیفکت غیرقابل‌انتشار CI: ALLOW_VERIFICATION_SIGNING=1'
      exit 1
    fi
  else
    ok 'فایل امضای انتشار پیدا شد → استفاده از کلید اصلی'
  fi

  log "ساخت APK (flavor=${STORE_FLAVOR}, split per ABI + obfuscation)..."
  if ! flutter build apk --release --flavor "$STORE_FLAVOR" --split-per-abi --obfuscate --split-debug-info=build/symbols; then
    fail 'ساخت APK شکست خورد'
    exit 1
  fi
  log 'ساخت AAB...'
  if ! flutter build appbundle --release --flavor "$STORE_FLAVOR" --obfuscate --split-debug-info=build/symbols; then
    fail 'ساخت AAB شکست خورد'
    exit 1
  fi
  if [[ "$STORE_FLAVOR" == "myket" ]]; then
    # اطمینان نهایی: permission پرداخت بازار نباید در APK مایکت باشد.
    BAD_PERM=$(for apk in build/app/outputs/flutter-apk/*.apk; do
      unzip -p "$apk" AndroidManifest.xml 2>/dev/null | strings | grep -i "PAY_THROUGH_BAZAAR" || true
    done)
    if [[ -n "$BAD_PERM" ]]; then
      fail 'دسترسی پرداخت کافه‌بازار در APK مایکت پیدا شد — این فایل در مایکت رد می‌شود!'
      exit 1
    fi
    ok 'APK مایکت بدون دسترسی پرداخت بازار است'
  fi

  TOTAL=0
  for apk in build/app/outputs/flutter-apk/*.apk; do
    SIZE=$(du -m "$apk" | cut -f1)
    TOTAL=$((TOTAL + SIZE))
    ok "APK: $(basename "$apk") → ${SIZE}MB"
    if (( SIZE >= 35 )); then
      fail "حجم APK از سقف ۳۵MB بیشتر است: $(basename "$apk")"
      exit 1
    fi
    # Verify signature exists
    if command -v apksigner >/dev/null 2>&1; then
      apksigner verify --print-certs "$apk" >/dev/null 2>&1 && ok "امضا تایید شد: $(basename "$apk")" || fail "APK بدون امضا است: $(basename "$apk")"
    elif command -v jarsigner >/dev/null 2>&1; then
      jarsigner -verify "$apk" >/dev/null 2>&1 && ok "امضا (jarsigner) تایید شد" || log "هشدار: تایید امضا ممکن نیست"
    fi
  done
  ok "حجم کل APKها: ${TOTAL}MB (هدف < ۳۵MB برای هر ABI)"
else
  log 'ساخت نسخه آزمایشی (Debug)...'
  if ! flutter build apk --debug; then
    fail 'ساخت Debug شکست خورد'
    exit 1
  fi
  ok 'APK دیباگ با کلید دیباگ امضا شد و قابل نصب است'
fi

if [[ $FAILED -ne 0 ]]; then
  fail 'برخی مراحل با هشدار تمام شدند — خروجی را بررسی کنید'
  exit 1
fi

echo '✨ عملیات با موفقیت به پایان رسید.'
