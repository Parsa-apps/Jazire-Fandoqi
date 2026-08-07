#!/usr/bin/env bash
# کودک ایران — reproducible local/CI validation and build
set -Eeuo pipefail

BUILD_MODE="${BUILD_MODE:-debug}"

printf '=======================================\n'
printf 'کودک ایران — validation/build (%s)\n' "$BUILD_MODE"
printf '=======================================\n'

if ! command -v flutter >/dev/null 2>&1; then
  echo 'Flutter نصب نیست. از کانال stable Flutter 3.24+ استفاده کنید.' >&2
  exit 1
fi

flutter --version | head -1 || true

# The repository keeps platform folders out of the source snapshot. Generate
# the Android shell deterministically before any build command.
if [[ ! -d android ]]; then
  echo 'ساخت پوسته Android...'
  flutter create . --platforms android --project-name kudakeiran --org com.parsaapps
fi

echo 'دریافت وابستگی‌ها...'
flutter pub get

echo 'تولید آیکون‌ها...'
dart run flutter_launcher_icons

echo 'تحلیل ایستا...'
flutter analyze --no-fatal-infos

echo 'تست‌ها...'
flutter test

if [[ "$BUILD_MODE" == "release" ]]; then
  echo 'ساخت APK و AAB نسخه انتشار...'
  flutter build apk --release
  flutter build appbundle --release
  echo 'APK: build/app/outputs/flutter-apk/app-release.apk'
  echo 'AAB: build/app/outputs/bundle/release/app-release.aab'
else
  echo 'ساخت APK آزمایشی...'
  flutter build apk --debug
  echo 'APK: build/app/outputs/flutter-apk/app-debug.apk'
fi
