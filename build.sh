#!/usr/bin/env bash
# 🚀 KUDAKE IRAN — Professional Multi-Stage Build Script
set -Eeuo pipefail

BUILD_MODE="${BUILD_MODE:-debug}"
PROJECT_NAME="amoozesh_fandoghi"

printf '===========================================================\n'
printf '🐰 کودک ایران — سیستم بیلد حرفه‌ای (حالت: %s)\n' "$BUILD_MODE"
printf '===========================================================\n'

# 1. Check Flutter environment
if ! command -v flutter >/dev/null 2>&1; then
  echo '❌ خطا: فلاتر نصب نیست.' >&2
  exit 1
fi

# 2. Ensure Android project exists
if [[ ! -d android ]]; then
  echo '📦 در حال ایجاد ساختار اندروید...'
  flutter create . --platforms android --project-name $PROJECT_NAME --org com.parsaapps
fi

# 3. Get Dependencies
echo '📥 دریافت کتابخانه‌ها...'
flutter pub get

# 4. Generate Assets/Icons
echo '🎨 تولید آیکون‌های اپلیکیشن...'
flutter pub run flutter_launcher_icons

# 5. Static Analysis (Audit)
echo '🔍 در حال تحلیل کد (Static Analysis)...'
flutter analyze --no-fatal-infos

# 6. Run Tests with Coverage
echo '🧪 در حال اجرای تست‌ها...'
flutter test --coverage

# 7. Build and Size Check
if [[ "$BUILD_MODE" == "release" ]]; then
  echo '🚀 ساخت نسخه نهایی (Release)...'
  flutter build apk --release --split-per-abi
  flutter build appbundle --release
  
  APK_PATH="build/app/outputs/flutter-apk/app-release.apk"
  if [[ -f "$APK_PATH" ]]; then
    SIZE=$(du -h "$APK_PATH" | cut -f1)
    echo "✅ بیلد موفقیت‌آمیز بود. حجم APK: $SIZE"
  fi
else
  echo '🛠️ ساخت نسخه آزمایشی (Debug)...'
  flutter build apk --debug
fi

echo '✨ عملیات با موفقیت به پایان رسید.'
