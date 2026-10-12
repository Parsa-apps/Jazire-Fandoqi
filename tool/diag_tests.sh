#!/usr/bin/env bash
# Temporary diagnostic helper: run one test file and publish its full log as
# chunked check annotations (the raw Actions log backend is not always
# reachable from our tooling, while the annotations API is).
#
# Usage: tool/diag_tests.sh <test-file> [watchdog]
set -uo pipefail

file="${1:?usage: diag_tests.sh <test-file|ALL> [watchdog]}"
watchdog="${2:-15m}"
log_file="$(mktemp)"
started="$(date +%s)"

# "ALL" = کل مجموعهٔ تست‌ها، دقیقاً مثل دروازهٔ QA خودِ بیلد.
targets=()
if [[ "$file" != "ALL" ]]; then
  targets=("$file")
fi

set +e
# مثل دروازهٔ QA خودِ بیلد: تایم‌اوت هر تست ۲ دقیقه تا قفل‌شدن‌ها سریع دیده شوند.
timeout --signal=TERM --kill-after=30s "$watchdog" \
  flutter test --reporter expanded --timeout 2m "${targets[@]}" 2>&1 | tee "$log_file"
status=${PIPESTATUS[0]}
set -e

{
  echo
  echo "--- diagnostic ---"
  echo "file: $file"
  echo "exit: $status (124 = killed by the $watchdog watchdog)"
  echo "elapsed: $(( $(date +%s) - started ))s"
  echo
  echo "--- failing test names ---"
  grep -E '\[E\]$' "$log_file" \
    | sed -E 's/^[0-9]{2}:[0-9]{2} \+[0-9]+ -[0-9]+: //; s/ \[E\]$//' \
    | sort -u
} >> "$log_file"

python3 tool/ci_annotate.py "$(basename "$file")" "$log_file" || true
rm -f "$log_file"
exit "$status"
