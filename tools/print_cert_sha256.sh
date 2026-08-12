#!/usr/bin/env bash
# 🛡️ Print the SHA-256 (hex, lowercase) of a signing certificate so it can be
# checked against the anti-tamper BuildConfig field EXPECTED_SIGNING_SHA256.
#
# Usage:
#   tools/print_cert_sha256.sh <keystore-file> <alias> <store-password>
#
# The value is embedded automatically at build time from android/key.properties;
# this script exists so you can verify what was embedded and compare it with
# the APK you actually ship:
#   keytool -printcert -jarfile app-release.apk | grep "SHA256:"
# (keep only the hex part after "SHA256:" and lowercase it)
set -euo pipefail

KEYSTORE="${1:?keystore file required}"
ALIAS="${2:?alias required}"
PASSWORD="${3:?store password required}"

if ! command -v keytool >/dev/null 2>&1; then
  echo "keytool not found (needs a JDK)" >&2
  exit 1
fi

keytool -exportcert -keystore "$KEYSTORE" -alias "$ALIAS" -storepass "$PASSWORD" 2>/dev/null \
  | sha256sum \
  | awk '{print $1}'
