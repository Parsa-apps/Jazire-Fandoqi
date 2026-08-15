#!/usr/bin/env bash
# 🔑 گذاشتن کلید عمومی RSA فروشگاه در android/billing.properties
#
# کاربرد:
#   tools/set_store_rsa_key.sh myket  "MIHNMA0GCS...AQAB"
#   tools/set_store_rsa_key.sh bazaar "MIHNMA0GCS...AQAB"
#   pbpaste | tools/set_store_rsa_key.sh myket -      # خواندن از ورودی استاندارد
#
# کلید مایکت را از پنل توسعه‌دهندگان مایکت بگیرید:
#   https://developer.myket.ir  →  منوی «برنامه‌ها» → آیکن کلید روی باکس برنامه
#   (یا داخل برنامه: پرداخت درون‌برنامه‌ای → کلید عمومی / شناسه پرداخت)
# کلید کافه‌بازار: پنل بازار → پرداخت درون‌برنامه‌ای → تنظیمات → کلید RSA
#
# اسکریپت قبل از نوشتن، کلید را با openssl اعتبارسنجی می‌کند تا کلید ناقص یا
# اشتباه (مثلاً کلید فروشگاه دیگر یا رشتهٔ بریده‌شده) وارد بیلد نشود.

set -euo pipefail

REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
PROPS="$REPO_ROOT/android/billing.properties"
EXAMPLE="$REPO_ROOT/android/billing.properties.example"

usage() {
  cat >&2 <<'EOF'
usage: tools/set_store_rsa_key.sh <myket|bazaar> <BASE64_RSA_PUBLIC_KEY|->

  myket   کلید پنل توسعه‌دهندگان مایکت  (developer.myket.ir)
  bazaar  کلید پنل توسعه‌دهندگان کافه‌بازار (pishkhan.cafebazaar.ir)
  -       کلید از stdin خوانده می‌شود
EOF
  exit 2
}

[ $# -eq 2 ] || usage

case "$1" in
  myket)  PROP_KEY="myketRsaPublicKey";  STORE="مایکت" ;;
  bazaar) PROP_KEY="bazaarRsaPublicKey"; STORE="کافه‌بازار" ;;
  *) usage ;;
esac

RAW="$2"
if [ "$RAW" = "-" ]; then
  RAW="$(cat)"
fi

# پاکسازی: حذف فاصله/خط جدید، حذف هدر PEM در صورت کپی شدن.
KEY="$(printf '%s' "$RAW" \
  | tr -d ' \t\r\n' \
  | sed -e 's/-----BEGINPUBLICKEY-----//g' -e 's/-----ENDPUBLICKEY-----//g')"

if [ -z "$KEY" ]; then
  echo "خطا: کلید خالی است." >&2
  exit 1
fi

if ! printf '%s' "$KEY" | grep -Eq '^[A-Za-z0-9+/]+={0,2}$'; then
  echo "خطا: کلید base64 معتبر نیست (کاراکتر غیرمجاز دارد)." >&2
  exit 1
fi

# اعتبارسنجی ساختاری با openssl (کلید فروشگاه‌ها X.509 SubjectPublicKeyInfo است).
if command -v openssl >/dev/null 2>&1; then
  if ! printf -- "-----BEGIN PUBLIC KEY-----\n%s\n-----END PUBLIC KEY-----\n" \
        "$(printf '%s' "$KEY" | fold -w 64)" \
      | openssl pkey -pubin -noout >/dev/null 2>&1; then
    echo "خطا: این رشته یک کلید عمومی RSA معتبر نیست (احتمالاً ناقص کپی شده)." >&2
    exit 1
  fi
else
  echo "هشدار: openssl نصب نیست؛ از اعتبارسنجی ساختاری صرف‌نظر شد." >&2
fi

if [ ! -f "$PROPS" ]; then
  cp "$EXAMPLE" "$PROPS"
  echo "android/billing.properties از روی نمونه ساخته شد."
fi

TMP="$(mktemp)"
trap 'rm -f "$TMP"' EXIT
if grep -q "^${PROP_KEY}=" "$PROPS"; then
  awk -v k="$PROP_KEY" -v v="$KEY" \
    '{ if ($0 ~ "^"k"=") print k"="v; else print }' "$PROPS" > "$TMP"
else
  cat "$PROPS" > "$TMP"
  printf '%s=%s\n' "$PROP_KEY" "$KEY" >> "$TMP"
fi
cat "$TMP" > "$PROPS"

echo "✅ کلید $STORE ثبت شد: ${PROP_KEY}=${KEY:0:16}…${KEY: -8} (${#KEY} کاراکتر)"
echo "   فایل: android/billing.properties (در .gitignore است و کامیت نمی‌شود)"
