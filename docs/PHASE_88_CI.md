# 🤖 فاز ۸۸ — CI/CD حرفه‌ای (GitHub Actions)

> ⚠️ اعمال این ورک‌فلو نیاز به مجوز `workflows` دارد و باید توسط
> **مالک مخزن** انجام شود (ربات Arena این مجوز را ندارد).
> فایل آماده در انتهای این سند است.

## چرا؟
- تحلیل استاتیک (analyze) در هر push
- تست‌های واحد/ویجت با پوشش
- ممیزی حریم خصوصی (فاز ۴۹/۶۳)
- ساخت APK (split-per-abi) + AAB
- آپلود آرتیفکت‌ها

## فایل پیشنهادی: `.github/workflows/build-apk.yml`

```yaml
name: Build APK & AAB - کودک دانا v3

on:
  push:
    branches: [ main, master ]
  workflow_dispatch:

jobs:
  build:
    runs-on: ubuntu-latest

    steps:
      - name: Checkout
        uses: actions/checkout@v4

      - name: Setup Java 17
        uses: actions/setup-java@v4
        with:
          distribution: 'temurin'
          java-version: '17'

      - name: Setup Flutter
        uses: subosito/flutter-action@v2
        with:
          flutter-version: '3.24.3'
          channel: 'stable'
          cache: true

      - name: Ensure Android folder exists
        run: |
          if [ ! -d "android" ]; then
            flutter create . --platforms android
          fi

      - name: Flutter pub get
        run: flutter pub get

      - name: Generate launcher icons
        run: flutter pub run flutter_launcher_icons

      - name: Static Analysis
        run: flutter analyze

      - name: Unit & Widget Tests
        run: flutter test --coverage

      - name: Privacy Audit (100% Offline)
        run: bash tools/privacy_audit.sh

      - name: Build APK (Release)
        run: flutter build apk --release --split-per-abi

      - name: Build AAB (Release)
        run: flutter build appbundle --release

      - name: Upload APK
        uses: actions/upload-artifact@v4
        with:
          name: kudake_iran_apk
          path: build/app/outputs/flutter-apk/*.apk

      - name: Upload AAB
        uses: actions/upload-artifact@v4
        with:
          name: kudake_iran_aab
          path: build/app/outputs/bundle/release/app-release.aab
```

## برای مالک مخزن
```bash
git checkout main
# محتوای بالا را در .github/workflows/build-apk.yml قرار دهید و:
git add .github/workflows/build-apk.yml
git commit -m "ci: فاز ۸۸ — analyze + test + privacy audit + build"
git push
```
