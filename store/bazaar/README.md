# پیشخان کافه‌بازار — جزیره فندقی

این پوشه مخصوص انتشار **نسخهٔ کافه‌بازار** است. artifact باید از flavor
`bazaar` ساخته شود (`flutter build appbundle --release --flavor bazaar` یا
`STORE_FLAVOR=bazaar ./build.sh`) تا فقط Poolakey و مجوز
`PAY_THROUGH_BAZAAR` داخل آن باشد. جزئیات، قیمت و چک‌لیست:
[`docs/BAZAAR_EDITION_7_5_6_FA.md`](../../docs/BAZAAR_EDITION_7_5_6_FA.md).

## فایل‌های تصویری پیشخان کافه‌بازار

اسکرین‌شات‌های نهایی از **تصاویر واقعی خود برنامه** ساخته شده‌اند؛ هر فایل `1080×1920`، عمودی و کم‌حجم است.

## ترتیب آپلود

فایل‌های پوشه `store/bazaar/upload/` را دقیقاً با این ترتیب بارگذاری کنید:

1. `1_home.png` — یادگیری فارسی با بازی و قصه
2. `2_learning.png` — تمرین واقعی شنیداری و املا
3. `3_games.png` — بازی‌های هدفمند
4. `4_stories.png` — قصه‌های تعاملی و شنیدنی
5. `5_progress.png` — کارنامه رشد و پیشرفت
6. `6_missions.png` — مأموریت‌ها و جایزه‌های روزانه
7. `7_profile.png` — پروفایل و آواتار کودک
8. `8_safe.png` — محیط امن و بدون تبلیغ

همین هشت فایل برای **مایکت** نیز قابل استفاده‌اند و نیازی به کپی جداگانه نیست.

## سایر فایل‌ها

| فیلد | فایل |
|---|---|
| آیکون | `store/bazaar/icon_512.png` |
| سرصفحه بازار | `store/bazaar/header_5x2.png` |
| پیش‌نمایش یک‌جا (فقط برای بازبینی، نه آپلود) | `store/bazaar/screenshots_preview.jpg` |

## ساخت دوباره تصاویر

منبع خام در `assets/screeen/` نگهداری می‌شود. برای بازسازی خروجی‌ها:

```bash
python3 -m venv .venv
.venv/bin/pip install -r tools/requirements-store-assets.txt
.venv/bin/python tools/build_store_screenshots.py
```

اسکریپت فایل‌های قدیمی پوشه آپلود را حذف می‌کند تا تصویر اضافه‌ای اشتباهی در پیشخان بارگذاری نشود.
