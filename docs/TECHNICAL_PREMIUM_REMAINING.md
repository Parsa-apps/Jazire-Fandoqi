# 🔧 فنی پریمیوم — ۱۷ پیشنهاد باقی‌مانده (اجرای خودکار)

> این سند فنی برای تکمیل 50 پیشنهاد ویژه است — هر مورد با Definition of Done

### 1 Flutter 3.27 + Impeller
- ارتقا به 3.27، حذف `image_cropper_platform_interface` پین، فعال‌سازی `CardThemeData`

### 3 CrashReport پیشرفته
- `CrashReportStore` + `LoggerService` + کارت والد «گزارش خطاهای دستگاه» — پیاده شد

### 4 CI/CD فول‌اتومات
- `build.sh` 7 مرحله‌ای + `.github/workflows/build-apk.yml` (نیاز به مجوز workflows مالک)

### 6 Riverpod CodeGen + Freezed
- `gameStateProvider` + `freezed` برای `PlayerProfile` — type-safe

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

### 16 Skeleton
- `ProfessionalSkeleton` شیمر — در حال ارتقا به پریمیوم

### 17 Accessibility AAA
- `Semantics` + Slider 0.85-1.4 + کنتراست 4.5:1 — پیاده شد

### 19 Dashboard تطبیقی
- 3 حالت سنی در DashboardTab — پیاده شد (توضیح در `dashboard_tab`)

### 49 Backup
- `BackupService` .parsa — پیاده شد

> همه این‌ها با کد موجود پوشش داده شده یا با یک ارتقای کوچک نسخه Flutter کامل می‌شود.
