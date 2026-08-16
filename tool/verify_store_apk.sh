#!/usr/bin/env bash
# ✅ بررسی پیش‌از-آپلود APK مایکت
#
# مایکت هر APK حاوی دسترسی پرداخت کافه‌بازار را رد می‌کند:
#   com.farsitel.bazaar.permission.PAY_THROUGH_BAZAAR
#
# این اسکریپت دقیقاً روی همان فایلی که می‌خواهید آپلود کنید اجرا می‌شود و
# می‌گوید فایل مجاز است یا نه. همیشه قبل از آپلود اجرایش کنید.
#
# استفاده:
#   tool/verify_store_apk.sh [path/to/apk]
#   (پیش‌فرض: build/app/outputs/flutter-apk/app-myket-release.apk)
set -euo pipefail

APK="${1:-build/app/outputs/flutter-apk/app-myket-release.apk}"

if [[ ! -f "$APK" ]]; then
  echo "❌ فایل پیدا نشد: $APK"
  echo ""
  echo "   ابتدا بیلد مایکت را بسازید:"
  echo "   flutter clean && flutter pub get && flutter build apk --release --flavor myket"
  exit 1
fi

echo "📦 بررسی فایل: $APK"
echo ""

MANIFEST="$(unzip -p "$APK" AndroidManifest.xml 2>/dev/null | strings || true)"

# ── ۱) دسترسی پرداخت کافه‌بازار نباید وجود داشته باشد ────────────────
if echo "$MANIFEST" | grep -qi "PAY_THROUGH_BAZAAR"; then
  echo "❌ FAIL: دسترسی com.farsitel.bazaar.permission.PAY_THROUGH_BAZAAR در APK هست."
  echo ""
  echo "   این فایل در مایکت رد می‌شود — آن را آپلود نکنید."
  echo "   این یعنی فایل با flavor بازار (یا بیلد قدیمی قبل از flavorها) ساخته شده."
  echo "   از نو بسازید:"
  echo "   flutter clean && flutter pub get && flutter build apk --release --flavor myket"
  exit 1
fi
echo "✅ ۱) بدون دسترسی پرداخت کافه‌بازار"

# ── ۲) هیچ ارجاعی به پکیج بازار نباید در مانیفست باشد ───────────────
# مایکت اپ‌هایی را که از اینتنت‌های مارکت‌های دیگر استفاده می‌کنند تأیید
# نمی‌کند؛ query/ارجاع پکیج بازار هم مشمول همین سیاست است و فقط در بیلد
# بازار وجود دارد.
if echo "$MANIFEST" | grep -qi "com\.farsitel"; then
  echo "❌ FAIL: ارجاع به پکیج کافه‌بازار (com.farsitel) در مانیفست APK هست."
  echo ""
  echo "   مایکت اپ‌هایی را که از اینتنت‌های مارکت‌های دیگر استفاده می‌کنند تأیید"
  echo "   نمی‌کند. این فایل برای مایکت مناسب نیست؛ دوباره با --flavor myket بیلد بگیرید:"
  echo "   flutter clean && flutter pub get && flutter build apk --release --flavor myket"
  exit 1
fi
echo "✅ ۲) بدون ارجاع به پکیج/اینتنت کافه‌بازار"

# ── ۳) درگاه پرداخت مایکت باید حاضر باشد ─────────────────────────────
if echo "$MANIFEST" | grep -qi "ir.mservices.market.BILLING"; then
  echo "✅ ۳) درگاه پرداخت مایکت حاضر است (فایل واقعاً بیلد مایکت است)"
else
  echo "⚠️  ۳) هشدار: permission پرداخت مایکت در این فایل پیدا نشد."
  echo "     مطمئن شوید با --flavor myket ساخته‌اید؛ در غیر این صورت خرید درون‌برنامه‌ای کار نمی‌کند."
fi

echo ""
echo "✅ فایل برای آپلود در پنل مایکت آماده است:"
echo "   $(basename "$APK")"
echo ""
echo "   یادآوری: در پنل مایکت، نسخهٔ جدید را به‌عنوان «نسخهٔ جدید» ثبت کنید"
echo "   و همین فایل را ضمیمه کنید — پیام رد قبلی مربوط به فایل قبلی است."
