#!/usr/bin/env bash
# Temporary diagnostic helper: run one test file and publish its full log as
# chunked check annotations (the raw Actions log backend is not always
# reachable from our tooling, while the annotations API is).
#
# Usage: tool/diag_tests.sh <test-file>
set -uo pipefail

file="${1:?usage: diag_tests.sh <test-file>}"
log_file="$(mktemp)"
started="$(date +%s)"

set +e
timeout --signal=TERM --kill-after=30s 15m \
  flutter test --reporter expanded --timeout 90s "$file" 2>&1 | tee "$log_file"
status=${PIPESTATUS[0]}
set -e

{
  echo
  echo "--- diagnostic ---"
  echo "file: $file"
  echo "exit: $status (124 = killed by the 15m watchdog)"
  echo "elapsed: $(( $(date +%s) - started ))s"
} >> "$log_file"

python3 tool/ci_annotate.py "$(basename "$file")" "$log_file" || true
rm -f "$log_file"
exit "$status"
