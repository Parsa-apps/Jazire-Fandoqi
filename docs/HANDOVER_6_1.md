# 📦 تحویل نهایی 6.1.0 پریمیوم — راهنمای انتشار

> برای فرشاد پارسا — یک دستور = انتشار

### 1. نسخه
- `pubspec.yaml`: `version: 6.1.0+12` (از 6.0.0+11) — +1 minor برای 50+10 فیچر

### 2. بیلد نهایی
```bash
BUILD_MODE=release ./build.sh
# خروجی: build/app/outputs/flutter-apk/app-arm64-v8a-release.apk (26MB)
# و build/app/outputs/bundle/release/app-release.aab (84MB)
```

### 3. تست قبل ارسال
- `docs/FINAL_QA_6_1_PREMIUM.md` 30 مورد — تیک همه ✅

### 4. کافه‌بازار
- 8 اسکرین‌شات از `STORE_ASO_PREMIUM_V2.md` + ویدیو 30ث
- توضیح 420 کلمه + دسته آموزش > کودک + برچسب 3-8 سال
- AAB را آپلود کن — پرداخت با `full_version` (تست sandbox قبل)

### 5. تگ
```bash
git tag v6.1.0-premium
git push origin v6.1.0-premium
```

### 6. پشتیبانی
- تلگرام @Parsaappsadmin — پاسخ 24 ساعته
- بکاپ .parsa برای انتقال گوشی

---

**وضعیت:** 62/50 — فراتر از قرارداد، آماده انتشار — با ❤️
