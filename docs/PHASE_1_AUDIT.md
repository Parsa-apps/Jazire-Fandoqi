# 🔍 گزارش فاز ۱ — Audit کامل کد (Foundation Reset)

> تاریخ اجرا: ۹ اوت ۲۰۲۶ | بررسی‌کننده: Senior Flutter Agent
> محدوده: تمام `lib/` (۹۰ فایل، ~۹٬۴۰۰ خط) + `test/` (۴ فایل) + کانفیگ

---

## 📊 نمای کلی وضعیت

| بخش | وضعیت |
|-----|-------|
| ساختار پوشه‌ها | ✅ لایه‌های `app/core/data/domain/features/presentation/shared` برقرار است |
| امنیت و آفلاین | ✅ هیچ `http` / tracker در کد نیست؛ ذخیره‌سازی محلی است |
| مدیریت State | 🟡 `GameData` سیستاتیک + `ValueNotifier` در ۴ فایل؛ Riverpod فقط برای پروفایل |
| ذخیره‌سازی | 🟡 `SharedPreferences` به‌صورت متمرکز در `GameData` (خوب) ولی `monetization.dart` مستقیم `SharedPreferences` دارد |
| صدا | 🟡 `print()` به‌جای لاگر در `audio_service.dart` |
| فونت | ✅ wrapper امن `AppFonts` (fallback بی‌کرش) |
| تم | ✅ `CardThemeData` سازگار با Flutter 3.24.3 |
| تست | 🟡 ۴ فایل تست — باید تا فاز ۸۱ به ۸۰٪ پوشش برسد |

---

## 🗑️ کد مرده حذف‌شده (Dead Code Removed)

اسکن ارجاع‌ها نشان داد ۳ فایل هیچ‌جا import نشده‌اند و تکراری/مرده هستند:

| فایل حذف‌شده | دلیل |
|---------------|------|
| `lib/core/animate_ext.dart` | اکستنشن `FloatExtension` هرگز استفاده نشده بود (dead code) |
| `lib/core/premium_router.dart` | روت‌ر دومی که کپی‌برداری از `main.dart` بود؛ هیچ‌جا استفاده نمی‌شد — منبع حقیقت `main.dart` است |
| `lib/features/profile/achievements_screen.dart` | صفحه دستاوردها به‌صورت inline در `profile_screen.dart` هست؛ این صفحه دوباره‌سازی بود |

## 🔧 اصلاحات کیفی

| مورد | قبل | بعد |
|------|-----|-----|
| `audio_service.dart` | `print("Error playing effect: ...")` | `LoggerService.e(...)` (talker) — لاگر وارد چرخه واقعی شد |
| `main.dart` | `debugPrint` در catch ذخیره‌سازی | به `LoggerService` ارتقا یافت تا در history آفلاین ثبت شود |

## 📌 بدهی فنی شناسایی‌شده (برای فازهای بعدی)

1. **فاز ۲:** `GameData` هنوز یک «God Object» است (~۷۸۰ خط) → استخراج UseCaseهای خالص از آن.
2. **فاز ۳:** `ValueNotifier<int> changes` در `game_data.dart` + `fandoghi_coach.dart` + `fandoghi_welcome.dart` + `draggable_fandoghi.dart` → مهاجرت به Riverpod.
3. **فاز ۴:** `monetization.dart` با `SharedPreferences` مستقیم → انتقال کامل به Hive با migration خودکار.
4. **فاز ۵:** `asset_manager.dart` ساخته شده ولی هیچ‌جا استفاده نمی‌شود → اتصال به تصاویر صفحه‌ها + کش حافظه واقعی.
5. **فاز ۶:** `AudioService` فقط TTS پایه دارد؛ بدون SFX asset، بدون نوبت/صف، بدون مدیریت خطای TTS.
6. **فاز ۸:** `LoggerService` فقط کنسول/history است؛ ذخیره آفلاین خطاها (فایل/Hive) ندارد.
7. **فاز ۹:** `build.sh` خوب است ولی چک ۷ مرحله‌ای با توقف شفاف + خروجی لاگ ندارد.
8. **فاز ۱۱-۲۰:** هیچ مولفه‌ای اندازه لمس ۶۴px را رعایت نکرده، بدون `Semantics` فارسی، بدون پروفایل چپ‌دست.
9. **فاز ۲۱-۳۰:** محتوای اعداد/رنگ/شکل/حیوان فقط در کوییز است؛ آکادمی مستقل وجود ندارد.
10. **فاز ۳۱-۴۰:** Memory تایمر `while` دارد؛ BubblePop بدون `HasTappable`؛ Drawing بدون بهینه‌سازی `Path`؛ StarCatch UI قلب‌ها ۳تاست ولی جان ۵.
11. **فاز ۶۳:** ممیزی حریم خصوصی باید به‌صورت خودکار (اسکن `http`/permission) در CI بیاید.
12. **فاز ۸۶:** APK فعلی شامل ۳ ABI است؛ `--split-per-abi` و حذف فونت اضافه در پیش‌رو.
13. **فاز ۷۱-۷۲:** `BillingService` MethodChannel آماده است ولی SDK بازار/مایکت به پروژه اضافه نشده.

---

## ✅ نتیجه فاز ۱

- [x] تحلیل خط‌به‌خط `lib/` انجام شد
- [x] لیست بدهی فنی (۱۳ مورد) استخراج شد
- [x] کد مرده حذف شد (۳ فایل، ~۲۱۰ خط)
- [x] چک `AI_PROJECT_RULES.md` — رعایت می‌شود
- [x] کامیت مجزا برای این فاز ساخته شد
