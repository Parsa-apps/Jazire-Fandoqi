# 🇮🇷 کودک ایران v4.0 — نسخه فوق‌گرافیکی

## ✨ چه چیزهایی جدیده؟

### 🎨 سیستم گرافیکی کاملاً جدید
- **Star Field Background** — پس‌زمینه ستاره‌ای متحرک
- **Glassmorphism Cards** — کارت‌های شیشه‌ای مدرن
- **Particle Effects** — افکت‌های ذرات برای جشن‌ها
- **Parallax Scrolling** — اسکرول پارالاکس در صفحه اصلی
- **Gradient System** — سیستم گرادیانت حرفه‌ای

### 🌰 فندقی v2 — شخصیت راهنما
- انیمیشن شناور و پلک زدن
- حالت‌های مختلف (خوشحال، هیجان‌زده، فکری، خواب)
- بازوها و سایه
- حباب گفتار

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
│   ├── ai_system.dart          # هوش مصنوعی
│   └── ...
├── features/
│   ├── splash/
│   │   └── splash_screen.dart
│   ├── home/
│   │   ├── home_screen.dart
│   │   └── widgets/
│   │       └── dashboard_tab.dart
│   └── games/
│       └── star_catch/
│           └── star_catch_game.dart
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
| `shimmer` | افکت شیمر |
| `confetti` | افکت کانفتی |
| `shared_preferences` | ذخیره‌سازی محلی |

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

**ساخته شده با ❤️ توسط Parsa Apps™**
