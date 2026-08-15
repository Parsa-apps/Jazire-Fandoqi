# 🔧 فنی پریمیوم — وضعیت اجرا و موارد محیطی

> موارد امنیتی قابل اجرا در مخزن تکمیل شده‌اند. تنظیم keystore و کلید RSA وظیفهٔ محیط انتشار است؛ تغییر workflow نیز به مجوز `workflows` مالک نیاز دارد.

### 1 Flutter 3.27 + Impeller — در انتظار ارتقای هماهنگ CI
- پروژه فعلاً روی Flutter 3.24.3 می‌ماند. وابستگی‌های انتخاب و برش عکس حذف شده‌اند و اپ هیچ دسترسی گالری درخواست نمی‌کند.

### 3 CrashReport پیشرفته
- `CrashReportStore` + `LoggerService` + کارت والد «گزارش خطاهای دستگاه» — پیاده شد

### 4 CI/CD فول‌اتومات — بخش مخزن تکمیل، workflow در انتظار مجوز
- `build.sh` هفت‌مرحله‌ای و ممیزی امنیت آماده است؛ افزودن gateهای analyze/test/privacy به workflow به مجوز `workflows` مالک نیاز دارد.

### 6 Riverpod CodeGen + Freezed — اختیاری
- `gameStateProvider` و `PlayerProfile` اکنون type-safe هستند؛ افزودن CodeGen/Freezed بدون نیاز رفتاری، هزینهٔ build_runner و فایل‌های تولیدی را بالا می‌برد و به ارتقای مستقل موکول شده است.

### 7 Lazy + AVIF
- `AssetManager` LRU 24 + `FandoghiImage` fade-in — AVIF بعد از 3.27

### 8 باتری و گرما
- `WidgetsBindingObserver` pause Flame + کاهش FPS به 30 در background — پیاده شد (فاز 65)

### 9 Coverage 80%
- تست‌های `game_data_test` استرس 500 + `child_touch_target_test` 64px — پیاده شد

### 10 Logging دو سطحی
- `talker` فقط error در release — پیاده شد

### 13 فصلی
- `SeasonalTokens` نوروز/یلدا/مهرگان — در Onboarding و DesignTokens پیاده شد

### 14 تبلت + چپ‌دست
- `AppBreakpoints` + `isLeftHanded` در ParentPanel — پیاده شد

### 16 Skeleton — تکمیل شد
- `ProfessionalSkeleton` با شیمر، Design Tokens و سه حالت card/circle/text.

### 17 Accessibility AAA
- `Semantics` + Slider 0.85-1.4 + کنتراست 4.5:1 — پیاده شد

### 19 Dashboard تطبیقی
- 3 حالت سنی در DashboardTab — پیاده شد (توضیح در `dashboard_tab`)

### 49 Backup
- `BackupService` .parsa — پیاده شد

> باقی‌ماندهٔ واقعی کدنویسی این دور رفع شد؛ موارد فوق که به ابزار/مجوز مالک وابسته‌اند باید در یک ارتقای هماهنگ جداگانه انجام شوند.
