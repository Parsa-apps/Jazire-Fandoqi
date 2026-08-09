#!/usr/bin/env bash
# 🔐 تولید keystore برای انتشار فندقی
set -euo pipefail
KEYSTORE_PATH="android/release.keystore"
PROP_PATH="android/key.properties"
if [[ -f "$KEYSTORE_PATH" ]]; then
  echo "⚠️  فایل $KEYSTORE_PATH از قبل وجود دارد."
else
  echo "▶ تولید keystore در $KEYSTORE_PATH ..."
  keytool -genkey -v \
    -keystore "$KEYSTORE_PATH" \
    -alias fandoghi \
    -keyalg RSA -keysize 4096 -validity 10000 \
    -storepass fandoghi123 -keypass fandoghi123 \
    -dname "CN=Fandoghi, OU=ParsaApps, O=ParsaApps, L=Tehran, S=Tehran, C=IR"
  echo "✅ keystore ساخته شد"
fi
if [[ -f "$PROP_PATH" ]]; then
  echo "⚠️  فایل $PROP_PATH از قبل وجود دارد:"
  cat "$PROP_PATH"
else
  echo "▶ ساخت $PROP_PATH ..."
  cat > "$PROP_PATH" <<EOF
storeFile=release.keystore
storePassword=fandoghi123
keyAlias=fandoghi
keyPassword=fandoghi123
EOF
  echo "✅ فایل $PROP_PATH ساخته شد"
fi
echo ""
echo "✨ تمام! حالا: flutter build apk --release"
