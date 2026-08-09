# 📦 فاز ۸۶ — بهینه‌سازی حجم APK

## هدف
- هر ABI زیر ۳۵MB (روش: `flutter build apk --release --split-per-abi`)

## اقدامات انجام‌شده
- split-per-abi در build.sh (arm, arm64, x86_64 جدا)
- بدون فونت سنگین اضافه (AppFonts fallback سیستمی + google_fonts بدون bundle)
- تصاویر WebP از قبل (نه PNG سنگین)

## اقدامات بعدی (هنگام بیلد واقعی)
- [ ] حذف `assets/premium/` تصاویر استفاده‌نشده (در صورت وجود)
- [ ] بررسی حجم `flutter build apk --release --split-per-abi` خروجی‌ها
- [ ] اگر arm > 35MB: فشرده‌سازی بیشتر WebP به 60% کیفیت
- [ ] فعال‌سازی R8/ProGuard در release buildType
- [ ] استفاده از `android:extractNativeLibs=false` + `useLegacyPackaging=false`
