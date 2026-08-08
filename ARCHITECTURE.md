# 🏗️ معماری اپلیکیشن کودک ایران (Amoozesh Fandoghi)

## 📌 نمای کلی (Overview)
این پروژه از اصول **معماری پاک (Clean Architecture)** و **مدیریت وضعیت با Riverpod** پیروی می‌کند. هدف اصلی، جداسازی منطق بازی از رابط کاربری و مدیریت داده‌های آفلاین به صورت امن است.

## 📂 ساختار پوشه‌ها (Folder Structure)

```text
lib/
├── app/            # تنظیمات کلی اپ (تم، فونت، رنگ‌ها)
├── core/           # ابزارهای مشترک (صدا، لاگر، تنظیمات بازی)
├── data/           # پیاده‌سازی داده‌ها
│   ├── datasources/# منابع داده (Hive, SharedPreferences)
│   ├── models/     # مدل‌های داده (Data Transfer Objects)
│   └── repositories/# پیاده‌سازی ریپازیتوری‌ها
├── domain/         # لایه بیزینس منطق (مستقل از فریم‌ورک)
│   ├── entities/   # موجودیت‌های اصلی
│   ├── repositories/# تعاریف ریپازیتوری‌ها (Interface)
│   └── usecases/    # سناریوهای کاربر
├── features/       # ویژگی‌های اپ (بخش‌بندی شده بر اساس قابلیت)
│   ├── games/      # انواع بازی‌ها
│   ├── home/       # داشبورد اصلی
│   └── ...
├── presentation/   # منطق مشترک رابط کاربری
│   └── providers/  # وضعیت‌های Riverpod
└── shared/         # ویجت‌ها و ابزارهای مشترک UI
```

## 🔄 جریان داده (Data Flow)
1. **Presentation** ورودی را از کاربر می‌گیرد.
2. **Provider** یک **UseCase** یا **Repository** را فراخوانی می‌کند.
3. **Repository** داده را از **DataSource** (محلی) دریافت می‌کند.
4. داده‌ها به صورت **Entity** به لایه ارائه بازمی‌گردند.

## 🛠️ تکنولوژی‌های مورد استفاده
- **Framework:** Flutter 3.24.x
- **State Management:** Riverpod 2.x
- **Database:** Hive (Local Persistence)
- **Animation:** flutter_animate & Flame
- **Audio:** just_audio & flutter_tts

## 🔒 حریم خصوصی و امنیت
تمام داده‌ها به صورت ۱۰۰٪ آفلاین ذخیره می‌شوند و هیچ اطلاعاتی از کودک به سرورهای خارجی ارسال نمی‌گردد.
