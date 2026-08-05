#!/bin/bash
# ═══════════════════════════════════════════════
# 🚀 KUDAKE IRAN — Build Script
# ═══════════════════════════════════════════════

set -e

echo "═══════════════════════════════════════"
echo "🚀 کودک ایران v4.0 — Build Script"
echo "═══════════════════════════════════════"
echo ""

# Check Flutter
if ! command -v flutter &> /dev/null; then
    echo "❌ Flutter نصب نیست!"
    echo "از https://flutter.dev نصب کن"
    exit 1
fi

echo "✅ Flutter: $(flutter --version | head -1)"
echo ""

# Step 1: Clean
echo "🧹 مرحله ۱: پاکسازی..."
flutter clean
echo "✅ پاکسازی انجام شد"
echo ""

# Step 2: Get dependencies
echo "📦 مرحله ۲: نصب پکیج‌ها..."
flutter pub get
echo "✅ پکیج‌ها نصب شد"
echo ""

# Step 3: Analyze
echo "🔍 مرحله ۳: بررسی کد..."
flutter analyze --no-fatal-infos 2>&1 | tail -20
echo ""

# Step 4: Build APK
echo "📱 مرحله ۴: بیلد APK..."
flutter build apk --debug
echo ""

if [ -f build/app/outputs/flutter-apk/app-debug.apk ]; then
    echo "═══════════════════════════════════════"
    echo "✅ بیلد موفق!"
    echo "═══════════════════════════════════════"
    echo ""
    echo "📱 APK: build/app/outputs/flutter-apk/app-debug.apk"
    echo "📏 حجم: $(du -h build/app/outputs/flutter-apk/app-debug.apk | cut -f1)"
    echo ""
    echo "برای نصب روی دستگاه:"
    echo "  flutter install"
    echo ""
    echo "برای اجرا روی شبیه‌ساز:"
    echo "  flutter run"
else
    echo "❌ بیلد ناموفق!"
    echo "خروجی بالا رو بررسی کن"
fi
