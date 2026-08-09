# چک انتشار نسخه ۶.۰.۰+۱۱

## سازگاری به‌روزرسانی Android

- `applicationId`: `com.parsaapps.amoozesh_fandoghi` — **نباید تغییر کند**.
- `versionName`: `6.0.0`.
- `versionCode`: `11` — بزرگ‌تر از نسخهٔ ۵.۰.۰+۱۰ است.
- برای انتشار update در کافه‌بازار/مایکت، AAB/APK باید با **همان release keystore** نسخهٔ نصب‌شدهٔ کاربران امضا شود.

## پیش از بارگذاری

1. `android/key.properties` را با keystore انتشار اصلی تنظیم کنید.
2. `android/billing.properties` را با RSA key کافه‌بازار تنظیم کنید.
3. `flutter pub get`، `flutter analyze` و `flutter test` را اجرا کنید.
4. `flutter build appbundle --release` بسازید.
5. روی دستگاهی که نسخهٔ ۵ نصب است، APK/AAB امضاشده را به‌عنوان update نصب و حفظ پروفایل، پیشرفت و خرید کامل را آزمایش کنید.

> Flutter در sandbox حاضر موجود نیست؛ این مراحل باید در CI دارای signing secrets یا دستگاه توسعه انجام شود.
