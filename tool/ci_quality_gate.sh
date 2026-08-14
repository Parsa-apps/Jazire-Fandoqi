#!/usr/bin/env bash
set -uo pipefail

# Runs inside the Android release build on GitHub Actions. Besides keeping the
# full console output, publish the useful tail as a check annotation so a failed
# test remains diagnosable when the raw Actions log backend is unavailable.
run_check() {
  local title="$1"
  shift
  local log_file
  log_file="$(mktemp)"

  set +e
  "$@" 2>&1 | tee "$log_file"
  local status=${PIPESTATUS[0]}
  set -e

  if [[ $status -ne 0 ]]; then
    local diagnostics details
    diagnostics="$(grep -E '(^|[[:space:]])error •|Error:|FAIL|TestFailure|Some tests failed|EXCEPTION CAUGHT|\[E\]' "$log_file" | tail -n 40 || true)"
    details="${diagnostics}"$'\n\n--- final output ---\n'"$(tail -n 35 "$log_file")"
    details="$(printf '%s' "$details" | tail -c 7000)"
    details="${details//'%'/'%25'}"
    details="${details//$'\r'/'%0D'}"
    details="${details//$'\n'/'%0A'}"
    printf '::error title=%s::%s\n' "$title" "$details"
    rm -f "$log_file"
    return "$status"
  fi

  rm -f "$log_file"
}

run_check 'Flutter analyzer failed' \
  flutter analyze --no-fatal-warnings --no-fatal-infos
run_check 'Flutter automated tests failed' \
  flutter test --reporter expanded
