# ساخت انتشار رسمی مایکت — جزیره فندقی

**نسخهٔ فعلی: ۷.۵.۷+۳۰** (`pubspec.yaml`: `version: 7.5.7+30`)

این نسخه همان قانون **نصف رایگان، نصف قفل** را دارد. ورود به هاب‌های دارای محتوای رایگان باز می‌ماند؛ دکمهٔ خرید و نشان قفل در نقشه و مرکز والدین دیده می‌شوند و قفلِ آیتم‌های پولی داخل مجموعه‌ها است. نسخهٔ کامل فقط با خرید تکمیل‌شدهٔ `full_version` و رسید معتبر مایکت در APK رسمی انتشار فعال می‌شود. حالت دمو/آزمایشی، فلگ محلی یا رسید بازار مجوز دسترسی نیست.

## پیش‌نیازها

- Flutter **3.24.3**، Android SDK 35 و JDK 17.
- keystore **اصلی انتشار همین برنامه**، خارج از Git. برای به‌روزرسانی کلید جدید نسازید؛ امضا باید با نصب قبلی سازگار باشد.
- کلید عمومی RSA صحیح مایکت در `android/billing.properties`، متناظر با همین برنامه در پیشخوان مایکت. کلید عمومی، جایگزین کلید امضای APK نیست.

## امضای انتشار

keystore در `android/release.keystore` و تنظیمات محلی در `android/key.properties`:

```properties
storeFile=release.keystore
storePassword=رمز-محلی-keystore
keyAlias=fandoghi
keyPassword=رمز-محلی-key
```

این فایل‌ها در `.gitignore` هستند؛ هرگز آن‌ها یا رمزها را commit نکنید. SHA-256 گواهی انتشار هنگام ساخت در `BuildConfig.EXPECTED_SIGNING_SHA256` ثبت می‌شود. Native billing همان گواهی را روی APK نصب‌شده بررسی می‌کند و debug/profile، `testOnly`، گواهی خالی یا ناهماهنگ را رد می‌کند.

**بدون کلید رسمی یا با کلید Android Debug، ساخت انتشار متوقف می‌شود. fallback امضای آزمایشی و `ALLOW_VERIFICATION_SIGNING` حذف شده‌اند.**

## تست و ساخت

```bash
flutter pub get
flutter analyze
flutter test
python3 -m unittest discover -s tool -p 'test_verify_production_apk.py' -v
flutter build apk --release --flavor myket
(cd android && ./gradlew testMyketReleaseUnitTest)
flutter build appbundle --release --flavor myket
```

یا `BUILD_MODE=release STORE_FLAVOR=myket ./build.sh`. این helper دیگر APK دیباگ/تستی یا فروشگاه دیگر تولید نمی‌کند. برای توسعهٔ داخلی می‌توان تست‌های واحد/ویجت را اجرا کرد؛ هیچ‌یک در APK انتشار بسته‌بندی نمی‌شوند. Android debug/profile حتی با یک رسید واقعی، مجوز محتوای پولی نمی‌دهد.

خروجی‌های اصلی:

- APK: `build/app/outputs/flutter-apk/app-myket-release.apk`
- AAB: `build/app/outputs/bundle/myketRelease/app-myket-release.aab`

AAB و APK هر دو متعلق به **مایکت** هستند. خروجی قدیمی QA یا نسخهٔ قدیمی بازار، جایگزین این انتشار نیست.

## GitHub Actions

ورک‌فلو `.github/workflows/build-apk.yml` با Secretهای ازپیش‌تنظیم‌شدهٔ `KEYSTORE_B64` و `KEYSTORE_PASSWORD` کلید اصلی را بازیابی می‌کند. نبود Secret، خطای واقعی است و **هیچ APK آزمایشی جایگزین نمی‌شود**.

پیش از انتشار آرتیفکت:

1. تست‌های رفتار قفل و کل مجموعهٔ Flutter عبور می‌کنند.
2. رمزنگاری رسید و سیاست Native انتشار رسمی تست می‌شوند؛ کلید عمومی مایکت نیز RSA معتبر است.
3. `apksigner` صحت امضا را بررسی می‌کند؛ `tool/verify_production_apk.py` گواهی را با keystore رسمی مقایسه می‌کند.
4. از خود APK، package، versionName/versionCode، مجوز پرداخت مایکت و نبود debug/testOnly بررسی می‌شود.

آرتیفکت‌های نسخهٔ فعلی:

- `jazire_fandoqi_v7.5.7_myket_production_apk` — `app-myket-release.apk` + `build-info.txt`
- `jazire_fandoqi_v7.5.7_myket_production_aab`

QA مستقل فقط گزارش تست/تحلیل و نتایج JVM منتشر می‌کند؛ دیگر `island-qa-apk` ندارد.

## تنظیمات لازم در پیشخوان مایکت

- محصول **غیرمصرف‌شدنی** با شناسهٔ دقیق `full_version`، فعال و دارای قیمت صحیح باشد.
- بستهٔ `com.parsaapps.amoozesh_fandoghi`، گواهی APK و کلید RSA با تنظیمات انتشار همان برنامه متناظر باشند.
- اگر حساب/محصول آزمایشی در پیشخوان تعریف شده است، پیش از اعتبارسنجی پرداخت بانکی واقعی آن را غیرفعال کنید. این تنظیمات در سرور مایکت است و با تغییر کد این مخزن حذف نمی‌شود.

رسید معتبر پاسخ امضاشدهٔ مایکت را اثبات می‌کند؛ به‌تنهایی نمی‌تواند تنظیمات حساب آزمایشیِ سرور را تغییر دهد. تست‌های CI تراکنش بانکی واقعی نیستند؛ چک‌لیست تراکنش واقعی در [گزارش انتشار](docs/MYKET_PRODUCTION_7_5_4_FA.md) آمده است.

چک‌لیست قفل‌ها، راه خرید و وضعیت رسید روی گوشی: [راهنمای ۷.۵.۵](docs/PAYWALL_ENTRY_7_5_5_FA.md).

## نصب بدون حذف پیشرفت

```bash
adb install -r build/app/outputs/flutter-apk/app-myket-release.apk
```

روی گوشی نیز APK را به‌صورت به‌روزرسانی نصب کنید. اگر خطای امضا/نصب گرفتید، **برنامه را حذف نکنید**؛ ابتدا گواهی نصب قبلی، APK جدید و پشتیبان پیشرفت بررسی شود. `adb uninstall` راه‌حل پیش‌فرض این پروژه نیست.

خریدار واقعی قبلی مایکت می‌تواند «بازیابی خرید نسخهٔ کامل» را بزند؛ پرداخت دوباره لازم نیست. پس از تأیید، رسید معتبر رمز‌شده برای استفادهٔ آفلاین نگه داشته می‌شود. پیشرفت، پین و امتیازها مستقل‌اند و با تغییر مجوز پاک نمی‌شوند.
