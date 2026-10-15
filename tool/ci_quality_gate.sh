#!/usr/bin/env bash
set -uo pipefail

# TEMP DIAGNOSTIC (arena): run analyzer + tests, annotate every analyzer error
# line and test failure so the exact red-build cause is visible via the API.
# This variant deliberately continues to tests even when analysis fails so a
# single CI run reports the complete picture.

mkdir -p qa-gate-log

diag_analyze() {
  local log_file
  log_file="$(mktemp)"
  set +e
  flutter analyze --no-fatal-warnings --no-fatal-infos 2>&1 | tee "$log_file"
  local status=${PIPESTATUS[0]}
  set -e
  cp "$log_file" "qa-gate-log/Flutter_analyzer.log"
  python3 - "$log_file" <<'PYEOF' || true
import sys
raw = open(sys.argv[1], encoding="utf-8", errors="replace").read()
lines = raw.splitlines()
errs = [l.strip() for l in lines if "error •" in l or l.startswith("Error:") or ": Error:" in l]
def esc(t):
    return t.replace("%", "%25").replace("\r", "%0D").replace("\n", "%0A")
print(f"::error title=diag analyze::status-err-lines={len(errs)} total-lines={len(lines)}", flush=True)
for i, l in enumerate(errs[:8]):
    print(f"::error title=diag analyze error {i+1}/{len(errs)}::{esc(l)}", flush=True)
PYEOF
  rm -f "$log_file"
  return "$status"
}

diag_tests() {
  local log_file
  log_file="$(mktemp)"
  set +e
  timeout --signal=TERM --kill-after=30s 12m \
    flutter test --reporter expanded --timeout 2m 2>&1 | tee "$log_file"
  local status=${PIPESTATUS[0]}
  set -e
  cp "$log_file" "qa-gate-log/Flutter_tests.log"
  if command -v python3 >/dev/null 2>&1 && [[ -f tool/ci_annotate.py ]]; then
    python3 tool/ci_annotate.py 'Flutter automated tests failed' "$log_file" || true
  fi
  python3 - "$log_file" <<'PYEOF' || true
import sys
lines = open(sys.argv[1], encoding="utf-8", errors="replace").read().splitlines()
fails = [l.strip() for l in lines if l.strip().endswith("[E]") or "Some tests failed" in l or "Test failed." in l]
def esc(t):
    return t.replace("%", "%25").replace("\r", "%0D").replace("\n", "%0A")
print(f"::error title=diag tests::fail-markers={len(fails)} total-lines={len(lines)}", flush=True)
for i, l in enumerate(fails[:8]):
    print(f"::error title=diag test fail {i+1}/{len(fails)}::{esc(l)}", flush=True)
PYEOF
  rm -f "$log_file"
  return "$status"
}

set +e
diag_analyze
a=$?
diag_tests
t=$?
set -e
echo "diag summary: analyze=$a tests=$t"
[[ $a -eq 0 && $t -eq 0 ]]
