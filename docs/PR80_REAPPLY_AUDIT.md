# بازاجرای واقعی PR80 — ممیزی و اتصال به اپ

> تاریخ: ۱۱ اوت ۲۰۲۶ — شاخهٔ `arena/019fee00-kudake-iran`

PR80 تعداد زیادی فایل و مستند اضافه کرده بود، اما چند قابلیت فقط در سطح فایل باقی مانده بود و از مسیر واقعی اپ قابل دسترسی نبود. این بازاجرا روی **رفتار قابل مشاهده و مسیر داده** تمرکز دارد، نه تکرار صرفِ کامیت‌ها.

## مواردی که دوباره و واقعاً اعمال شدند

| مورد | مشکل در PR80 | اصلاح انجام‌شده |
|---|---|---|
| Onboarding V2 | Splash همیشه به Gateway می‌رفت و `/onboarding` هم Gateway بود | Splash بر اساس `GameData.onboardingSeen` تصمیم می‌گیرد و route واقعی به `OnboardingScreen` وصل شد؛ نصب تازه onboarding را می‌بیند |
| حیوانات، اعداد، شغل‌ها، مفاهیم و SEL | پنج صفحهٔ پریمیوم orphan بودند و هیچ route/CTA نداشتند | routeهای `/animals`, `/numbers`, `/jobs`, `/concepts`, `/sel` + `LearningLibraryScreen` + دکمهٔ قابل مشاهده در Gateway |
| Backup `.parsa` | سرویس وجود داشت اما ParentPanel آن را نشان نمی‌داد؛ import هم reload واقعی نداشت | کارت بکاپ در ParentPanel، native file picker اندروید، AES-GCM export/import و `GameData.reload()` |
| Persistence Hive | وقتی snapshot از Hive خوانده می‌شد، `_prefs == null` باعث می‌شد `save()` بی‌صدا هیچ کاری نکند | ذخیرهٔ مستقیم snapshot در Hive در حالت بدون SharedPreferences |
| قلب یخی Streak | `addCoins(-50)` هیچ سکه‌ای کم نمی‌کرد | `spendCoins` و `activateIceHeart` اتمیک با تست |
| صندوق مأموریت | UI صندوق را نشان می‌داد ولی callback و جلوگیری از دریافت تکراری نداشت | `claimDailyMissionChest`، قفل یک‌بار در روز و callback واقعی از Dashboard |
| مدال‌های Story/Lullaby | skillهای `stories` و `lullaby` در schema داده نبودند؛ مدال‌ها unreachable بودند | اضافه‌شدن skillها، migration امن snapshot و ثبت پیشرفت داستان/لالایی |
| ریتینگ هوشمند | `StoreRatingService` ساخته شده بود اما flow ثبت امتیاز از آن استفاده نمی‌کرد | ثبت prompt/rated از دیالوگ امتیاز والدین |
| Skeleton | `ProfessionalSkeleton` فایل بلااستفاده بود | در بارگذاری پوسترهای آنلاین کارتون به‌عنوان loading state استفاده شد |
| CI/CD و حجم | workflow فقط روی main اجرا می‌شد و analyze/test/size gate نداشت | workflow سه‌مرحله‌ای analyze → test/coverage → build، trigger برای PR و سقف APK زیر ۳۵MB |

## موارد PR80 که از قبل کد داشتند و دوباره حذف نشدند

- Design Tokens و تم فصلی
- Fandoghi Premium V4 و حضور آن در بازی‌ها/onboarding/splash
- Streak Calendar و Daily Missions
- رادار مهارت والدین
- دست‌خط، Animal data، SEL، بازی‌های Memory/Bubble/Math/Pattern/Sound/Body/Puzzle
- Island Builder چهارگانه، Wheel، Album و Paywall
- AES-256-GCM در `BackupService`

این موارد به‌جای بازنویسی غیرضروری، به مسیرهای واقعی اپ و storage متصل شدند.

## Definition of Done جدید

- [x] قابلیت‌های orphan شده route و CTA واقعی دارند.
- [x] rewardهای قلب یخی و صندوق مأموریت قابل تکرار/تقلب نیستند.
- [x] import بکاپ بعد از بازیابی state را واقعاً refresh می‌کند.
- [x] CI روی Pull Request هم analyze، test و build را اجرا می‌کند.
- [x] برای مسیرهای اصلی کتابخانه و منطق سکه تست اضافه شد.
- [ ] اجرای واقعی `flutter analyze`, `flutter test` و APK/AAB در این sandbox؛ ابزار Flutter/Dart در محیط نصب نیست.
- [ ] تأیید پرداخت بازار و تست دستگاه ضعیف؛ نیازمند کلید استور و دستگاه/CI واقعی است.
