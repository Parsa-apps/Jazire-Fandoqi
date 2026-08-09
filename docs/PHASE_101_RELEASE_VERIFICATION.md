# فاز ۱۰۱ — راستی‌آزمایی انتشار

**تاریخ:** ۹ اوت ۲۰۲۶  
**هدف:** جلوگیری از انتشار artifact ناامن و قابل‌تشخیص‌کردن پیش‌نیازهای انتشار واقعی.

## اقدامات انجام‌شده

- پیکربندی Android بازبینی شد: `minSdk=21`، `targetSdk=35`، Java 11 و Java 17 در CI.
- امضای debug از build نوع `release` حذف شد. اکنون امضای release فقط از
  `android/key.properties` (فایل local و نادیده‌گرفته‌شده توسط Git) خوانده می‌شود.
- CI می‌تواند با secrets زیر `key.properties` را در زمان build تولید کند:
  `RELEASE_KEYSTORE_BASE64`، `RELEASE_KEY_ALIAS`، `RELEASE_KEY_PASSWORD` و
  `RELEASE_STORE_PASSWORD`.
- CI اکنون برای `main` و `arena/**` اجرا می‌شود و شامل `flutter analyze`،
  `flutter test`، APK و AAB است.
- `usesCleartextTraffic=true` حذف شد و resolver پخش کارتون فقط URLهای HTTPS را
  قابل‌پخش می‌داند.
- راهنمای build با فرایند signing واقعی هماهنگ شد.

## وضعیت اعتبارسنجی در این محیط

Flutter SDK در sandbox حاضر نصب نیست؛ بنابراین `flutter analyze`، `flutter test`
و build Android اینجا اجرا نشدند. CI پس از push باید منبع معتبر این سه بررسی باشد.

## Definition of Done برای انتشار در استور

- [ ] secrets امضای release در GitHub Actions ثبت شده‌اند یا `key.properties` محلی معتبر است.
- [ ] CI برای کامیت release سبز است.
- [ ] APK/AAB با certificate انتشار امضا و با `apksigner verify --print-certs` بررسی شده است.
- [ ] نصب و جریان‌های حیاتی روی دستگاه واقعی تست شده‌اند.
- [ ] SDK پرداخت واقعی کافه‌بازار/مایکت به جای استاب فعلی متصل و با حساب sandbox آزموده شده است.

## مانع شناخته‌شده

`MainActivity.kt` عمداً پرداخت را در release رد می‌کند تا پیش از اتصال SDK رسمی،
دسترسی پولی ناخواسته فعال نشود. بنابراین پرداخت/اشتراک هنوز برای انتشار تجاری
آماده نیست؛ این یک محافظ امنیتی است، نه خطای build.
