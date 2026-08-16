# 🔴 → 🟢 رفع قرمزی CI بعد از افزودن flavorها

## علت خرابی

از کامیت `2051b8f` (افزودن product flavorها) هر اجرای ورک‌فلو دقیقاً در همین
مرحله می‌افتد:

```
X Build APK (Release)            ← flutter build apk --release
- Verify release signing (APK)   (اجرا نشد)
- Build AAB (Release)            (اجرا نشد)
Process completed with exit code 1
```

`android/app/build.gradle` حالا دو flavor دارد:

```gradle
flavorDimensions "store"
productFlavors { bazaar { … }  myket { … } }
```

با وجود flavor، Gradle دیگر تسک‌های `assembleRelease` / `bundleRelease` را
نمی‌سازد — فقط `assembleBazaarRelease`، `assembleMyketRelease`،
`bundleBazaarRelease`، `bundleMyketRelease`. پس دستور بدون `--flavor` در
`.github/workflows/build-apk.yml` با exit code 1 شکست می‌خورد. نام خروجی هم
دیگر `app-release.apk` نیست، بلکه `app-myket-release.apk` /
`app-bazaar-release.apk` است، بنابراین مراحل verify و upload هم با فایل
ناموجود می‌شکستند.

## چرا این فایل اینجاست و نه در `.github/workflows/`

توکن عامل (GitHub App) مجوز `workflows` ندارد؛ push روی مسیر
`.github/workflows/` با این خطا رد می‌شود:

```
! [remote rejected] refusing to allow a GitHub App to create or update
  workflow `.github/workflows/build-apk.yml` without `workflows` permission
```

پس نسخهٔ اصلاح‌شده در `ci/build-apk.flavorfix.yml` گذاشته شده تا با دسترسی
انسانی اعمال شود.

## نحوهٔ اعمال (یک دستور)

```bash
cp ci/build-apk.flavorfix.yml .github/workflows/build-apk.yml
git add .github/workflows/build-apk.yml
git commit -m "ci: build per-store flavors so the release job stops failing"
git push origin arena/01a00ab4-jazire-fandoqi
```

## تغییرات نسبت به ورک‌فلوی فعلی

| # | تغییر | چرا |
|---|---|---|
| 1 | `flutter build apk --release` → دو مرحلهٔ `--flavor myket` و `--flavor bazaar` | علت اصلی قرمزی؛ تسک بدون flavor دیگر وجود ندارد. |
| 2 | verify روی `app-myket-release.apk` و `app-bazaar-release.apk` | مسیر `app-release.apk` دیگر ساخته نمی‌شود. نبودِ فایل حالا خطای صریح است، نه سکوت. |
| 3 | مرحلهٔ جدید «Verify Myket APK carries no Cafe Bazaar reference» | مایکت APKهای دارای `PAY_THROUGH_BAZAAR` یا ارجاع `com.farsitel` را رد می‌کند؛ این گیت قبل از آپلود دستی می‌گیردشان. |
| 4 | `flutter build appbundle --release --flavor bazaar` | AAB خروجی رسمی کافه‌بازار است. |
| 5 | آرتیفکت‌ها: `jazireh_fandoghi_myket_apk` / `_bazaar_apk` / `_bazaar_aab` با `if-no-files-found: error` | نام‌ها با flavor هم‌راستا شد و آرتیفکت خالی دیگر بی‌صدا رد نمی‌شود. |
| 6 | `actions/setup-java@v4` → `@v5` | v4 منسوخ شده (هشدار در همهٔ ران‌ها). |

## نسبت این فایل با `ci/build-apk.proposed.yml`

`build-apk.proposed.yml` نسخهٔ کامل‌تر H3 است (analyze، test، split-per-abi،
obfuscate، debug symbols، گزارش حجم) و آن هم flavor-aware شده. اگر همان را
اعمال کنید، CI هم سبز می‌شود و هم ارتقا می‌یابد.

`build-apk.flavorfix.yml` عمداً حداقلی است: دقیقاً همان ورک‌فلوی فعلی، فقط
flavor-aware — برای وقتی که هدف صرفاً سبز کردن بیلد بدون تغییر رفتار دیگر
است. یکی از این دو را انتخاب کنید، نه هر دو را.
