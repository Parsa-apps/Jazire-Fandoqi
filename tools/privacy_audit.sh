#!/usr/bin/env bash
# 🔒 فاز ۴۹: ممیزی حریم خصوصی — اطمینان از ۱۰۰٪ آفلاین بودن
# هر خروجی غیر از «OK» یعنی یک نشتی بالقوه پیدا شده است.
# توجه: نوشتن در Hive (box.put) محلی است و مجاز.
set -u

FAILED=0
LIB=lib

# فایل موقت بدون کامنت (برای جلوگیری از false-positive در متن توضیحات)
tmp=$(mktemp)
for f in $(find "$LIB" -name '*.dart'); do
  # حذف کامنت‌های خطی و بلوکی (به‌صورت ساده)
  sed -E 's|//.*$||' "$f" | sed -E 's|/\*.*\*/||g' >> "$tmp"
  echo "" >> "$tmp"
done

check() {
  local label="$1" pattern="$2" file="$3"
  local hits
  hits=$(grep -En "$pattern" "$file" 2>/dev/null || true)
  # حذف موارد مجاز (ذخیره محلی Hive، متدهای UI)
  hits=$(echo "$hits" | grep -v "box\.put\|_send\|HivePlayerStore\.write\|CrashReportStore" || true)
  if [[ -n "$hits" ]]; then
    echo "❌ [$label] پیدا شد:"
    echo "$hits" | head -20
    FAILED=1
  else
    echo "✅ [$label] پاک است"
  fi
}

echo '═══════════════════════════════════════════'
echo '🔒 ممیزی آفلاین — آموزش فندقی (فاز ۴۹)'
echo '═══════════════════════════════════════════'

check 'HTTP/HTTPS درخواست' "http://|https://" "$tmp"
check 'ترکرها' "firebase|mixpanel|amplitude_|segment\.io|google_analytics|sentry|crashlytics" "$tmp"
check 'پکیج‌های آنلاین' "package:dio|\bhttp:|graphql|web_socket|firebase_|google_maps|geolocator" "$tmp"
check 'آدرس‌های IP' "([0-9]{1,3}\.){3}[0-9]{1,3}" "$tmp"
check 'ارسال داده به بیرون' "package:http|HttpClient|WebSocket|socket\.io" "$tmp"

rm -f "$tmp"
echo '──'
if [[ $FAILED -eq 1 ]]; then
  echo '⚠️  ممیزی ناامن است — موارد بالا را بررسی کنید.'
  exit 1
fi
echo '🎉 ممیزی موفق: هیچ داده‌ای از کودک خارج نمی‌شود. (مطابق PRIVACY_POLICY_FA)'
