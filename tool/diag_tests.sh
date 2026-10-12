#!/usr/bin/env bash
# Temporary diagnostic helper: runs only the test files that are currently red
# and publishes their failure output as check annotations (chunked, because
# GitHub caps annotations per step).
set -uo pipefail

FILES=(
  test/features/tutorial/app_tutorial_screen_test.dart
  test/features/gateway/profile_offer_test.dart
  test/features/cartoons/online_cartoon_gate_test.dart
  test/features/games/mini_games/mini_game_scaffold_test.dart
  test/integration_test/app_flow_test.dart
)

for file in "${FILES[@]}"; do
  log="$(mktemp)"
  echo "::group::flutter test $file"
  flutter test --reporter expanded --timeout 2m "$file" 2>&1 | tee "$log"
  status=${PIPESTATUS[0]}
  echo "::endgroup::"
  if [[ $status -ne 0 ]]; then
    python3 tool/diag_annotate.py "$(basename "$file")" "$log" || true
  fi
  rm -f "$log"
done

exit 0
