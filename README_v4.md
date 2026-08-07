# 🇮🇷 کودک ایران v4.1 — نسخه فوق‌گرافیکی و QA

> این مستندات وضعیت محصول را توصیف می‌کنند؛ ادعای انتشار نهایی فقط بعد از
> اجرای build release، تست روی دستگاه واقعی و اتصال SDK پرداخت قابل قبول است.
>
> تست خودکار:
> `flutter analyze` · `flutter test` · `flutter build appbundle --release`

## 👤 سازنده و پشتیبانی

- **سازنده/ناشر:** فرشاد پارسا
- **ایمیل:** [farshadparsa2019@gmail.com](mailto:farshadparsa2019@gmail.com)
- **تلگرام:** [@Parsaappsadmin](https://t.me/Parsaappsadmin)

## ✨ چه چیزهایی جدیده؟

### 🎨 سیستم گرافیکی کاملاً جدید
- **Star Field Background** — پس‌زمینه ستاره‌ای متحرک
- **Glassmorphism Cards** — کارت‌های شیشه‌ای مدرن
- **Particle Effects** — افکت‌های ذرات برای جشن‌ها
- **Parallax Scrolling** — اسکرول پارالاکس در صفحه اصلی
- **Gradient System** — سیستم گرادیانت حرفه‌ای

### 🌰 فندقی v3 — مربی و داور مرکزی
- حضور بزرگ فندقی از Splash و onboarding تا داشبورد
- حباب پاپ‌آپ سراسری روی تمام routeها، بدون مسدودکردن لمس بازی
- پیام جداگانه برای آموزش، پاسخ درست، پاسخ غلط، تشویق، داوری و نتیجه مسابقه
- انیمیشن شناور، پلک‌زدن، حالت‌های خوشحال/هیجان‌زده/فکری/خواب/چشمک
- لمس فندقی در داشبورد برای دریافت راهنمایی دوباره

### 🚀 Splash Screen
- پس‌زمینه آسمان شب با ستاره‌های متحرک
- ذرات مداری دور لوگو
- متن شیمر طلایی
- انیمیشن‌های ورودی staggered

### 🏠 Home Screen حرفه‌ای
- App Bar با افکت پارالاکس
- دایره‌های تزئینی شناور
- نوار پیشرفت لول با درخشش
- دسته‌بندی‌های رنگی با گرادیانت
- ماموریت‌های روزانه با progress bar

### 🎮 بازی Flame — ستاره‌گیری
- موتور بازی Flame Engine
- آیتم‌های در حال سقوط با فیزیک
- سبد قابل کنترل با drag
- افکت‌های لرزش (Haptic Feedback)
- سیستم امتیاز و جان
- افزایش تدریجی سختی

---

## 🏗️ معماری جدید

```
lib/
├── main.dart                    # نقطه ورود
├── app/
│   ├── app_colors.dart         # سیستم رنگ
│   └── app_theme.dart          # تم Material 3
├── core/
│   ├── game_data.dart          # ذخیره‌سازی
│   ├── fandoghi_coach.dart     # کانال پیام مربی سراسری
│   ├── fandoghi_models.dart    # حالت‌های فندقی
│   ├── ai_system.dart          # هوش مصنوعی
│   └── ...
├── features/
│   ├── splash/                 # splash کوتاه و بدون network
│   ├── onboarding/             # لقب اختیاری و سن تقریبی
│   ├── home/
│   │   ├── home_screen.dart
│   │   └── widgets/dashboard_tab.dart
│   └── games/
│       ├── learning_quiz/      # مقصد واقعی موضوعات نقشه
│       ├── drawing/             # بوم نقاشی آفلاین
│       ├── memory_match/
│       ├── bubble_pop/
│       └── star_catch/
├── test/                       # تست منطق پیشرفت و smoke UI
└── shared/
    └── widgets/
        ├── fandoghi_v2.dart
        ├── glass_card.dart
        ├── particle_celebration.dart
        └── star_field.dart
```

---

## 📦 پکیج‌ها

| پکیج | کاربرد |
|---|---|
| `flame` | موتور بازی 2D |
| `flutter_animate` | انیمیشن‌های ساده |
| `google_fonts` | فونت فارسی |
| `shared_preferences` | ذخیره‌سازی محلی مقاوم و آفلاین |

---

## 🚀 نحوه اجرا

```bash
flutter pub get
flutter run
```

---

## 🎯 نقشه راه

- [ ] صفحه جزیره یادگیری با Custom Painter
- [ ] نقشه مراحل با مسیر winding
- [ ] بازی‌های بیشتر با Flame
- [ ] انیمیشن‌های Rive برای فندقی
- [ ] صفحه پروفایل حرفه‌ای
- [ ] فروشگاه با انیمیشن
- [ ] پنل والدین با نمودار

---

**ساخته‌شده با ❤️ توسط فرشاد پارسا**
