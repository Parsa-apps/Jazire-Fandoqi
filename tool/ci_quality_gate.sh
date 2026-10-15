#!/usr/bin/env bash
set -uo pipefail

# Runs inside the Android release build on GitHub Actions. Besides keeping the
# full console output, publish the useful part of a failing check as chunked
# check annotations so it stays diagnosable when the raw Actions log backend is
# unavailable.
run_check() {
  local title="$1"
  shift
  local log_file
  log_file="$(mktemp)"

  set +e
  "$@" 2>&1 | tee "$log_file"
  local status=${PIPESTATUS[0]}
  set -e

  # لاگ کامل را نگه می‌داریم تا ورک‌فلو (در صورت شکست) به‌عنوان artifact
  # آپلودش کند؛ annotation سقف دارد و لاگ‌های بلند را کامل پوشش نمی‌دهد.
  mkdir -p qa-gate-log
  cp "$log_file" "qa-gate-log/$(echo "$title" | tr ' ' '_').log"

  if [[ $status -ne 0 ]]; then
    if command -v python3 >/dev/null 2>&1 && [[ -f tool/ci_annotate.py ]]; then
      python3 tool/ci_annotate.py "$title" "$log_file" || true
    else
      # Fallback (no python3): one escaped annotation, as before.
      local details
      details="$(tail -c 6000 "$log_file")"
      details="${details//'%'/'%25'}"
      details="${details//$'\r'/'%0D'}"
      details="${details//$'\n'/'%0A'}"
      printf '::error title=%s::%s\n' "$title" "$details"
    fi
    rm -f "$log_file"
    return "$status"
  fi

  rm -f "$log_file"
}

run_check 'Flutter analyzer failed' \
  bash -c 'flutter analyze --no-fatal-warnings --no-fatal-infos; echo "ANALYZE_EXIT_CODE=$?"'
run_check 'Flutter automated tests failed' \
  timeout --signal=TERM --kill-after=30s 12m \
  flutter test --reporter expanded --timeout 2m
