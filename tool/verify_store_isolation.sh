#!/usr/bin/env bash
# =============================================================================
# 🏪 بررسی جداسازی فروشگاه در یک آرتیفکت ساخته‌شده (APK یا AAB)
#
#   bash tool/verify_store_isolation.sh <artifact> <bazaar|myket>
#
# هدف: اثبات اینکه آرتیفکت هر فروشگاه فقط SDK و قرارداد پرداخت **همان**
# فروشگاه را حمل می‌کند و SDK فروشگاه رقیب نه در DEX هست، نه در manifest،
# نه در مجوزها. این همان چیزی است که فروشگاه‌ها بررسی می‌کنند و صرفِ
# «پنهان‌کردن دکمهٔ پرداخت» هرگز کافی نیست.
#
# بدون هیچ وابستگی بیرونی (فقط unzip + strings) کار می‌کند؛ اگر aapt2 در
# دسترس باشد، بررسی manifest را دقیق‌تر هم می‌کند.
#
# خروجی: در صورت موفقیت exit=0، در صورت نقض جداسازی exit=1.
# =============================================================================
set -Eeuo pipefail

ARTIFACT="${1:-}"
EXPECTED="${2:-}"

if [[ -z "$ARTIFACT" || -z "$EXPECTED" ]]; then
  echo "usage: $0 <artifact.apk|artifact.aab> <bazaar|myket>" >&2
  exit 2
fi
if [[ ! -f "$ARTIFACT" ]]; then
  echo "❌ آرتیفکت پیدا نشد: $ARTIFACT" >&2
  exit 2
fi
if [[ "$EXPECTED" != "bazaar" && "$EXPECTED" != "myket" ]]; then
  echo "❌ فروشگاه باید 'bazaar' یا 'myket' باشد (داده: $EXPECTED)" >&2
  exit 2
fi

FAILED=0
ok()   { printf '✅ %s\n' "$1"; }
bad()  { printf '❌ %s\n' "$1"; FAILED=1; }
info() { printf 'ℹ️  %s\n' "$1"; }

# ── نشانه‌های فنی هر SDK ────────────────────────────────────────────────────
BAZAAR_DEX_MARKER="ir/cafebazaar/poolakey"
BAZAAR_PERMISSION="com.farsitel.bazaar.permission.PAY_THROUGH_BAZAAR"
BAZAAR_PACKAGE="com.farsitel.bazaar"

MYKET_DEX_MARKER="ir/myket/billingclient"
MYKET_PERMISSION="ir.mservices.market.BILLING"
MYKET_PACKAGE="ir.mservices.market"
MYKET_SERVICE="ir.mservices.market.InAppBillingService"

# ── استخراج متن از DEX و manifest ───────────────────────────────────────────
is_bundle=false
[[ "$ARTIFACT" == *.aab || "$ARTIFACT" == *.bundle ]] && is_bundle=true

if $is_bundle; then
  DEX_PATTERN='base/dex/*.dex'
else
  DEX_PATTERN='classes*.dex'
fi

dex_strings() {
  # نام کلاس‌ها در DEX به‌صورت رشته ذخیره می‌شوند؛ strings آن‌ها را برمی‌گرداند.
  unzip -p "$ARTIFACT" "$DEX_PATTERN" 2>/dev/null | strings -a || true
}

manifest_strings() {
  # manifest نهایی باینری است؛ رشته‌ها در string pool هستند (UTF-8 یا UTF-16LE).
  unzip -p "$ARTIFACT" AndroidManifest.xml 2>/dev/null | strings -a  || true
  unzip -p "$ARTIFACT" AndroidManifest.xml 2>/dev/null | strings -el || true
}

DEX_TEXT="$(dex_strings)"
MANIFEST_TEXT="$(manifest_strings)"

info "آرتیفکت: $ARTIFACT"
info "فروشگاه مورد انتظار: $EXPECTED"

# ── ۱) بررسی manifest با aapt2 (دقیق‌تر) ─────────────────────────────────
AAPT2="$(command -v aapt2 || true)"
if [[ -z "$AAPT2" ]] && [[ -n "${ANDROID_HOME:-}" ]]; then
  AAPT2="$(ls -1 "${ANDROID_HOME}"/build-tools/*/aapt2 2>/dev/null | sort -V | tail -1 || true)"
fi
if [[ -n "$AAPT2" && -x "$AAPT2" ]]; then
  info "aapt2: $AAPT2"
  if $is_bundle; then
    # AAB manifest باینری نیست؛ aapt2 روی AAB کار نمی‌کند. بررسی DEX کافی است.
    info "aapt2 روی AAB قابل استفاده نیست؛ بررسی manifest از روی string pool انجام می‌شود."
  else
    PERMS="$("$AAPT2" dump permissions "$ARTIFACT" 2>/dev/null || true)"
    if $is_bundle; then :; else
      if [[ "$EXPECTED" == "bazaar" ]]; then
        grep -q "$BAZAAR_PERMISSION" <<<"$PERMS" \
          && ok "مجوز بازار در manifest هست" \
          || bad "مجوز بازار در manifest پیدا نشد"
        grep -q "$MYKET_PERMISSION" <<<"$PERMS" \
          && bad "مجوز مایکت در آرتیفکت بازار وجود دارد!" \
          || ok "مجوز مایکت در آرتیفکت بازار وجود ندارد"
      else
        grep -q "$MYKET_PERMISSION" <<<"$PERMS" \
          && ok "مجوز مایکت در manifest هست" \
          || bad "مجوز مایکت در manifest پیدا نشد"
        grep -q "$BAZAAR_PERMISSION" <<<"$PERMS" \
          && bad "مجوز بازار در آرتیفکت مایکت وجود دارد!" \
          || ok "مجوز بازار در آرتیفکت مایکت وجود ندارد"
      fi
    fi
  fi
else
  info "aapt2 در دسترس نیست؛ بررسی manifest از روی string pool انجام می‌شود."
fi

# ── ۲) بررسی SDK رقیب در DEX ────────────────────────────────────────────────
if [[ "$EXPECTED" == "bazaar" ]]; then
  OWN_MARKER="$BAZAAR_DEX_MARKER"; OWN_PERM="$BAZAAR_PERMISSION"; OWN_PKG="$BAZAAR_PACKAGE"
  RIVAL_MARKER="$MYKET_DEX_MARKER"; RIVAL_PERM="$MYKET_PERMISSION"; RIVAL_PKG="$MYKET_PACKAGE"; RIVAL_SERVICE="$MYKET_SERVICE"
else
  OWN_MARKER="$MYKET_DEX_MARKER"; OWN_PERM="$MYKET_PERMISSION"; OWN_PKG="$MYKET_PACKAGE"
  RIVAL_MARKER="$BAZAAR_DEX_MARKER"; RIVAL_PERM="$BAZAAR_PERMISSION"; RIVAL_PKG="$BAZAAR_PACKAGE"; RIVAL_SERVICE="com.farsitel.bazaar"
fi

if grep -q "$OWN_MARKER" <<<"$DEX_TEXT"; then
  ok "SDK خودِ این فروشگاه در DEX حاضر است ($OWN_MARKER)"
else
  bad "SDK خودِ این فروشگاه در DEX پیدا نشد ($OWN_MARKER)"
fi

if grep -q "$RIVAL_MARKER" <<<"$DEX_TEXT"; then
  bad "SDK فروشگاه رقیب در DEX وجود دارد ($RIVAL_MARKER) — جداسازی نقض شده!"
else
  ok "SDK فروشگاه رقیب در DEX وجود ندارد ($RIVAL_MARKER)"
fi

# ── ۳) بررسی manifest از روی string pool ───────────────────────────────────
if grep -q "$OWN_PERM" <<<"$MANIFEST_TEXT"; then
  ok "مجوز خودِ فروشگاه در manifest هست ($OWN_PERM)"
else
  bad "مجوز خودِ فروشگاه در manifest پیدا نشد ($OWN_PERM)"
fi

if grep -q "$RIVAL_PERM" <<<"$MANIFEST_TEXT"; then
  bad "مجوز فروشگاه رقیب در manifest وجود دارد ($RIVAL_PERM) — جداسازی نقض شده!"
else
  ok "مجوز فروشگاه رقیب در manifest وجود ندارد ($RIVAL_PERM)"
fi

if grep -q "$RIVAL_SERVICE" <<<"$MANIFEST_TEXT"; then
  bad "سرویس billing فروشگاه رقیب در manifest اعلام شده ($RIVAL_SERVICE) — جداسازی نقض شده!"
else
  ok "سرویس billing فروشگاه رقیب در manifest نیست"
fi

# بستهٔ فروشگاه رقیب نباید در manifest باشد (نه <queries>، نه سرویس، نه مجوز)
if grep -q "$RIVAL_PKG" <<<"$MANIFEST_TEXT"; then
  bad "بستهٔ فروشگاه رقیب در manifest آمده ($RIVAL_PKG) — جداسازی نقض شده!"
else
  ok "بستهٔ فروشگاه رقیب در manifest نیست ($RIVAL_PKG)"
fi

if grep -q "$OWN_PKG" <<<"$MANIFEST_TEXT"; then
  ok "بستهٔ خودِ فروشگاه در manifest هست ($OWN_PKG)"
else
  bad "بستهٔ خودِ فروشگاه در manifest پیدا نشد ($OWN_PKG)"
fi

# ── نتیجه ───────────────────────────────────────────────────────────────────
if [[ $FAILED -ne 0 ]]; then
  echo "❌ جداسازی فروشگاه در $ARTIFACT نقض شد." >&2
  exit 1
fi
echo "✅ جداسازی فروشگاه در $ARTIFACT تأیید شد (فروشگاه: $EXPECTED)."
exit 0
