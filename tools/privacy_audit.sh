#!/usr/bin/env bash
# 🔒 ممیزی حریم خصوصی و امنیت انتشار
# شبکه فقط برای کارتون‌های آپارات و لینک پشتیبانی تلگرام مجاز است؛
# دادهٔ کودک نباید به هیچ endpoint دیگری ارسال شود.
set -Eeuo pipefail

FAILED=0

check_grep() {
  local label="$1"
  local pattern="$2"
  shift 2
  local hits
  hits=$(grep -RInE --include='*.dart' "$pattern" "$@" 2>/dev/null || true)
  if [[ -n "$hits" ]]; then
    echo "❌ [$label] پیدا شد:"
    printf '%s\n' "$hits" | head -20
    FAILED=1
  else
    echo "✅ [$label] پاک است"
  fi
}

echo '═══════════════════════════════════════════'
echo '🔒 ممیزی حریم خصوصی و انتشار — جزیره فندقی'
echo '═══════════════════════════════════════════'

# هیچ tracker یا SDK تحلیلی آنلاین در اپ کودک مجاز نیست.
check_grep \
  'ترکرها' \
  'firebase|mixpanel|amplitude_|segment\.io|google_analytics|sentry|crashlytics' \
  lib

# بک‌دور فعال‌سازی محلی نسخه کامل نباید دوباره وارد سورس یا تست شود.
check_grep \
  'فعال‌سازی ناامن نسخه کامل' \
  'DEV-UNLOCK-BLOCK|activateWithCode|hasDevUnlock|_devUnlockCodes|dev_unlocked_code' \
  lib test

# تنها AparatService حق استفاده مستقیم از کلاینت HTTP را دارد.
network_imports=$(grep -RInE --include='*.dart' \
  "package:(http/http\.dart|dio|graphql|web_socket_channel|firebase_)" lib 2>/dev/null \
  | grep -v '^lib/core/cartoons/aparat_service\.dart:.*package:http/http\.dart' || true)
if [[ -n "$network_imports" ]]; then
  echo '❌ [کلاینت شبکه خارج از سرویس کارتون] پیدا شد:'
  printf '%s\n' "$network_imports" | head -20
  FAILED=1
else
  echo '✅ [کلاینت شبکه] فقط در سرویس کارتون آپارات است'
fi

# همه URLهای واقعی را parse کن؛ فقط HTTPS و دامنه‌های مشخص مجازند.
if ! python3 - <<'PY'
from pathlib import Path
import re
from urllib.parse import urlparse

allowed_hosts = {'aparat.com', 'www.aparat.com', 'api.aparat.com', 't.me'}
url_pattern = re.compile(r"https?://[^\s'\"<>)}]+")
violations = []
for path in Path('lib').rglob('*.dart'):
    for line_no, line in enumerate(path.read_text(encoding='utf-8').splitlines(), 1):
        for raw_url in url_pattern.findall(line):
            parsed = urlparse(raw_url)
            # `https://` used only as an input validation prefix has no host.
            if not parsed.hostname:
                continue
            if parsed.scheme != 'https' or parsed.hostname not in allowed_hosts:
                violations.append(f'{path}:{line_no}:{raw_url}')

if violations:
    print('❌ [URL خارج از allowlist] پیدا شد:')
    print('\n'.join(violations[:20]))
    raise SystemExit(1)
print('✅ [URLها] فقط HTTPS آپارات و تلگرام مجاز هستند')
PY
then
  FAILED=1
fi

# IP ثابت می‌تواند allowlist دامنه را دور بزند.
check_grep \
  'آدرس IP ثابت' \
  "['\"]https?://([0-9]{1,3}\.){3}[0-9]{1,3}" \
  lib

if [[ $FAILED -ne 0 ]]; then
  echo '──'
  echo '⚠️  ممیزی ناموفق است — موارد بالا باید قبل از انتشار رفع شوند.'
  exit 1
fi

echo '──'
echo '🎉 ممیزی موفق: endpoint ناشناس یا مسیر فعال‌سازی ناامن پیدا نشد.'
