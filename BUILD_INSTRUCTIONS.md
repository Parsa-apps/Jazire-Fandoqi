# ساخت انتشار رسمی — جزیره فندقی (کافه‌بازار و مایکت)

**نسخهٔ فعلی: ۷.۵.۶+۲۹** (`pubspec.yaml`: `version: 7.5.6+29`)

این نسخه همان قانون **نصف رایگان، نصف قفل** را دارد. ورود به هاب‌های دارای
محتوای رایگان باز می‌ماند؛ دکمهٔ خرید و نشان قفل در نقشه و مرکز والدین دیده
می‌شوند و قفلِ آیتم‌های پولی داخل مجموعه‌ها است. نسخهٔ کامل فقط با خرید
تکمیل‌شدهٔ `full_version` و رسید معتبر **فروشگاهی که همان بیلد برایش ساخته
شده** فعال می‌شود. حالت دمو/آزمایشی، فلگ محلی یا رسید فروشگاه دیگر مجوز
دسترسی نیست.

## دو بیلد جدا، یک کد

| | کافه‌بازار | مایکت |
|---|---|---|
| flavor | `bazaar` | `myket` |
| SDK | Poolakey 2.2.0 | Myket Billing Client 1.19 |
| مجوز پرداخت | `PAY_THROUGH_BAZAAR` | `ir.mservices.market.BILLING` |
| خروجی APK | `app-bazaar-release.apk` | `app-myket-release.apk` |
| خروجی AAB | `app-bazaar-release.aab` | `app-myket-release.aab` |
| نام فروشگاه در UI | کافه‌بازار | مایکت |

هر flavor فقط SDK فروشگاه خودش را کامپایل می‌کند
(`android/app/src/bazaar/kotlin` و `android/app/src/myket/kotlin`)، پس APK
بازار نه کد مایکت را دارد و نه مجوزش را — و برعکس. جزئیات نسخهٔ بازار:
[docs/BAZAAR_EDITION_7_5_6_FA.md](docs/BAZAAR_EDITION_7_5_6_FA.md).

## پیش‌نیازها

- Flutter **3.24.3**، Android SDK 35 و JDK 17.
- keystore **اصلی انتشار همین برنامه**، خارج از Git. برای به‌روزرسانی کلید
  جدید نسازید؛ امضا باید با نصب قبلی سازگار باشد (هر دو فروشگاه از همین
  کلید استفاده می‌کنند).
- کلید عمومی RSA فروشگاه مقصد در `android/billing.properties`:
  - `bazaarRsaPublicKey` برای بیلد بازار
  - `myketRsaPublicKey` برای بیلد مایکت
- کلید عمومی جایگزین کلید امضای APK نیست.

## امضای انتشار

keystore در `android/release.keystore` و تنظیمات محلی در
`android/key.properties`:

```properties
storeFile=release.keystore
storePassword=رمز-محلی-keystore
keyAlias=fandoghi
keyPassword=رمز-محلی-key
```

این فایل‌ها در `.gitignore` هستند؛ هرگز آن‌ها یا رمزها را commit نکنید.
SHA-256 گواهی انتشار هنگام ساخت در `BuildConfig.EXPECTED_SIGNING_SHA256`
ثبت می‌شود. Native billing همان گواهی را روی APK نصب‌شده بررسی می‌کند و
debug/profile، `testOnly`، گواهی خالی یا ناهماهنگ را رد می‌کند.

**بدون کلید رسمی یا با کلید Android Debug، ساخت انتشار متوقف می‌شود.
fallback امضای آزمایشی و `ALLOW_VERIFICATION_SIGNING` وجود ندارند.**

## تست و ساخت

```bash
flutter pub get
flutter analyze
flutter test
python3 -m unittest discover -s tool -p 'test_verify_production_apk.py' -v

# ── نسخهٔ کافه‌بازار ──────────────────────────────
(cd android && ./gradlew testBazaarReleaseUnitTest)
flutter build apk --release --flavor bazaar
flutter build appbundle --release --flavor bazaar
# یا:
BUILD_MODE=release STORE_FLAVOR=bazaar ./build.sh

# ── نسخهٔ مایکت ───────────────────────────────────
(cd android && ./gradlew testMyketReleaseUnitTest)
flutter build apk --release --flavor myket
flutter build appbundle --release --flavor myket
# یا:
BUILD_MODE=release STORE_FLAVOR=myket ./build.sh
```

`build.sh` فقط release می‌سازد و `STORE_FLAVOR` را به `bazaar` یا `myket`
محدود می‌کند؛ APK دیباگ/تستی یا فروشگاه سوم تولید نمی‌شود. Android
debug/profile حتی با یک رسید واقعی، مجوز محتوای پولی نمی‌دهد.

## GitHub Actions

- `.github/workflows/build-bazaar.yml` → APK/AAB کافه‌بازار
  (`jazire_fandoqi_v7.5.6_bazaar_production_apk` و `_aab`).
- `.github/workflows/build-apk.yml` → APK/AAB مایکت
  (`jazire_fandoqi_v7.5.6_myket_production_apk` و `_aab`).
- `.github/workflows/island-qa.yml` → analyze، کل تست‌های Flutter و
  تست‌های JVM هر دو flavor (بدون انتشار APK آزمایشی).

Secretهای لازم: `KEYSTORE_B64` و `KEYSTORE_PASSWORD`. نبود Secret خطای
واقعی است و **هیچ APK آزمایشی جایگزین نمی‌شود**.

پیش از انتشار آرتیفکت:

1. تست‌های رفتار قفل و کل مجموعهٔ Flutter عبور می‌کنند.
2. رمزنگاری رسید و سیاست Native انتشار رسمی برای همان flavor تست می‌شوند؛
   کلید RSA همان فروشگاه نیز معتبر است.
3. `apksigner` صحت امضا را بررسی می‌کند؛ `tool/verify_production_apk.py`
   گواهی را با keystore رسمی مقایسه می‌کند.
4. از خود APK، package، versionName/versionCode، مجوز پرداخت همان فروشگاه
   و نبود مجوز فروشگاه رقیب، `debuggable` و `testOnly` بررسی می‌شود.

## تنظیمات پیشخوان کافه‌بازار

- محصول **غیرمصرف‌شدنی/دائمی** با شناسهٔ دقیق `full_version`، فعال و با
  قیمت **۴۹٬۰۰۰ تومان (۴۹۰٬۰۰۰ ریال)** — همان قیمت فعلی.
- بستهٔ `com.parsaapps.amoozesh_fandoghi`، گواهی APK و
  `bazaarRsaPublicKey` با همین برنامه در پیشخان بازار متناظر باشند.
- قیمت را از پنل بازار تغییر دهید، نه از کد؛ برنامه هیچ عددی hard-code
  نمی‌کند و مبلغ نهایی را پنجرهٔ پرداخت بازار نشان می‌دهد.

## تنظیمات پیشخوان مایکت

- محصول **غیرمصرف‌شدنی** `full_version`، فعال و دارای قیمت صحیح.
- بسته، گواهی APK و `myketRsaPublicKey` متناظر باشند.
- اگر حساب/محصول آزمایشی تعریف شده، پیش از تست پرداخت واقعی غیرفعال شود.

رسید معتبر، پاسخ امضاشدهٔ همان فروشگاه را اثبات می‌کند؛ تنظیمات حساب
آزمایشی سمت سرور فروشگاه با تغییر کد عوض نمی‌شود. چک‌لیست تراکنش واقعی
مایکت: [docs/MYKET_PRODUCTION_7_5_4_FA.md](docs/MYKET_PRODUCTION_7_5_4_FA.md).
چک‌لیست بازار: [docs/BAZAAR_EDITION_7_5_6_FA.md](docs/BAZAAR_EDITION_7_5_6_FA.md).

## نصب بدون حذف پیشرفت

```bash
# کافه‌بازار
adb install -r build/app/outputs/flutter-apk/app-bazaar-release.apk

# مایکت
adb install -r build/app/outputs/flutter-apk/app-myket-release.apk
```

روی گوشی نیز APK را به‌صورت به‌روزرسانی نصب کنید. اگر خطای امضا/نصب گرفتید،
**برنامه را حذف نکنید**؛ ابتدا گواهی نصب قبلی، APK جدید و پشتیبان پیشرفت
بررسی شود. `adb uninstall` راه‌حل پیش‌فرض این پروژه نیست.

خریدار قبلی همان فروشگاه می‌تواند «بازیابی خرید نسخهٔ کامل» را بزند؛ پرداخت
دوباره لازم نیست. پس از تأیید، رسید معتبر رمز‌شده برای استفادهٔ آفلاین نگه
داشته می‌شود. پیشرفت، پین و امتیازها مستقل‌اند و با تغییر مجوز پاک نمی‌شوند.
