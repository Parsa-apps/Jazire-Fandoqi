#!/usr/bin/env bash
# Generate a local release keystore. Passwords must come from the environment
# so a shared default is never committed or printed.
set -euo pipefail

KEYSTORE_PATH="android/release.keystore"
PROP_PATH="android/key.properties"
STORE_PASSWORD="${STORE_PASSWORD:-}"
KEY_PASSWORD="${KEY_PASSWORD:-$STORE_PASSWORD}"
KEY_ALIAS="${KEY_ALIAS:-fandoghi}"

if [[ -z "$STORE_PASSWORD" ]]; then
  echo "STORE_PASSWORD is required. Optionally set KEY_PASSWORD and KEY_ALIAS."
  echo "Example: STORE_PASSWORD='…' KEY_PASSWORD='…' ./tools/generate_release_keystore.sh"
  exit 1
fi

if [[ -f "$KEYSTORE_PATH" ]]; then
  echo "Keystore already exists at $KEYSTORE_PATH"
else
  echo "Creating $KEYSTORE_PATH"
  keytool -genkey -v \
    -keystore "$KEYSTORE_PATH" \
    -alias "$KEY_ALIAS" \
    -keyalg RSA -keysize 4096 -validity 10000 \
    -storepass "$STORE_PASSWORD" -keypass "$KEY_PASSWORD" \
    -dname "CN=Fandoghi, OU=ParsaApps, O=ParsaApps, L=Tehran, S=Tehran, C=IR"
fi

if [[ -f "$PROP_PATH" ]]; then
  echo "$PROP_PATH already exists (not overwritten)"
else
  cat > "$PROP_PATH" <<EOF
storeFile=../release.keystore
storePassword=$STORE_PASSWORD
keyAlias=$KEY_ALIAS
keyPassword=$KEY_PASSWORD
EOF
  echo "Wrote $PROP_PATH (gitignored)"
fi

echo "Done. Build for Myket with: flutter build apk --flavor myket --release"
echo "Or build for Bazaar with: flutter build apk --flavor bazaar --release"
