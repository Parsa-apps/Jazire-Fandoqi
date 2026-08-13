# PROJECT CONTEXT — kudake_iran (جزیره فندقی)

تو در حال ادامه توسعه پروژه Flutter اپ آموزش کودکان «جزیره فندقی» هستی.

مخزن:
farshadkurd/kudake_iran

تکنولوژی:
- Flutter
- Dart
- Clean Architecture + Feature First
- Riverpod
- Hive
- just_audio
- Flame
- video_player

موضوع اپ:
آموزش و سرگرمی کودکان ۳ تا ۸ سال
شامل:
- بازی‌های آموزشی
- داستان
- لالایی
- کارتون
- پنل والدین
- سیستم پیشرفت کودک
- شخصیت راهنما (فندقی)

=========================
وضعیت امنیت Android Release
=========================

مشکل قبلی:
keystore قبلی در معرض خطر بود.

اقدام انجام شده:
- keystore جدید ساخته شد.
- نوع: PKCS12
- الگوریتم: RSA-4096
- alias: fandoghi
- اعتبار: 10000 روز

keystore:
- هرگز داخل Git commit نشود.
- خارج از repository نگهداری شود.

GitHub Actions:
Workflow امضای Release اصلاح شده.

شامل:
- Configure release signing
- Verify release signing APK

GitHub Secrets فعال:
- KEYSTORE_B64
- KEYSTORE_PASSWORD

آخرین وضعیت:
CI موفق شده.
APK ساخته شده.
apksigner امضای Release را تأیید کرده.

=========================
قوانین مهم توسعه
=========================

1- قبل از هر تغییر کد:
ابتدا تحلیل کن و گزارش بده.

2- بدون اجازه:
- UI تغییر نده.
- Feature جدید اضافه نکن.
- معماری را عوض نکن.

3- هدف فعلی:
بهبود کیفیت پروژه طبق گزارش Audit.

اولویت‌ها:

Critical:
C1 امنیت keystore انجام شد.
C2 بررسی امنیت سیستم پخش کارتون و حذف fallback خطرناک.

High:
H1 مهاجرت تدریجی GameData به Riverpod
H2 کاهش زمان startup
H3 بهبود CI/CD
H4 حذف routeهای رشته‌ای و معماری بهتر
H5 کاهش حجم APK
H6 بهینه‌سازی Animation و RepaintBoundary
H7 مدیریت حافظه تصاویر

=========================
روش کار
=========================

قبل از اجرا:
1- فایل‌های مرتبط را بررسی کن.
2- مشکل را توضیح بده.
3- راه‌حل پیشنهادی بده.
4- بعد از تأیید تغییر اعمال کن.

هدف:
تبدیل پروژه به یک اپ کودک حرفه‌ای، امن، سریع و آماده انتشار.