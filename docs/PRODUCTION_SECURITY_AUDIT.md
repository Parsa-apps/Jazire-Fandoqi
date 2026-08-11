# گزارش ممیزی امنیت پیش از انتشار

- **پروژه:** جزیره فندقی (`jazireh_fandoghi`) — اپلیکیشن Flutter/Android آموزشی کودکان
- **تاریخ:** ۱۱ اوت ۲۰۲۶
- **استانداردهای مرجع:** OWASP MASVS، OWASP Mobile Top 10، اصل حداقل دسترسی
- **دامنه:** کد Dart، لایه نیتیو Android/Poolakey، Manifest، CI، اسکریپت امضا، ذخیره‌سازی محلی
- **حکم اولیه (قبل از رفع‌ها):** 🔴 **NOT SAFE FOR PRODUCTION**
- **حکم پس از رفع P0/P1 در همین شاخه:** 🟡 **READY AFTER REQUIRED FIXES** — باقی‌مانده بیشتر پیکربندی انتشار (کلید واقعی استور، RSA بازار) است نه باگ منطقی باز

---

## ۱. مدل پروژه و مرز اعتماد

| مورد | واقعیت پروژه |
|---|---|
| نوع | اپ موبایل آفلاین‌اول، تک‌پروفایل روی دستگاه |
| حساب کاربری ابری | ندارد |
| داده حساس | لقب کودک، سن، عکس پروفایل، PIN والدین، پیشرفت بازی، توکن خرید |
| پرداخت | کافه‌بازار / Poolakey — محصول `full_version` |
| شبکه | فقط کارتون آپارات روی HTTPS |
| اعتماد | کلاینت قابل دستکاری است؛ خرید باید از استور بیاید؛ کنترل والدین باید بعد از ری‌استارت باقی بماند |

ورودی‌های غیرقابل اعتماد: فایل `.parsa`، پاسخ JSON آپارات، MethodChannel، SharedPreferences/Hive روی دستگاه روت‌شده، Intentها.

---

## ۲. یافته‌ها

### Finding SEC-001 — PIN والدین ذخیره نمی‌شود (دور زدن کنترل والدین)

**Priority:** P0  
**Location:** `lib/core/game_data.dart` — `parentPin`, `setParentPin()`, `_buildSnapshot()`, `_applySnapshot()`, `_writeAll()`, `_loadInternal()`  
`lib/features/parent/parent_panel.dart` — `initState`: `_isUnlocked = !GameData.hasParentPin()`

**Evidence:** فیلد `parentPin` فقط در حافظه است. در اسنپ‌شات Hive و SharedPreferences نه نوشته می‌شود نه خوانده می‌شود. بعد از کشته‌شدن پروسه، `hasParentPin()` برابر false است و پنل والدین کاملاً باز می‌شود.

**Why it matters:** محدودیت زمان، بکاپ، حذف PIN و تنظیمات والد برای کودک قابل دور زدن است. برای اپ کودک و سیاست خانوادهٔ استورها این یک بلاکر انتشار است.

**Realistic attack:** کودک اپ را از Recent Apps می‌بندد و دوباره باز می‌کند → پنل والدین بدون PIN.

**Minimal fix:** هش PIN چهاررقمی را persist کن؛ پنل را همیشه قفل شروع کن.

**Status:** رفع شد در همین شاخه.

---

### Finding SEC-002 — بازیابی خرید بدون تطبیق `productId`

**Priority:** P1  
**Location:** `android/.../MainActivity.kt` — `queryCallback`

**Evidence:** `purchases.firstOrNull()` هر خرید فعال را به‌عنوان نسخه کامل برمی‌گرداند.

**Why it matters:** اگر بعداً محصول مصرفی ارزان‌تر اضافه شود، restore نسخه کامل را رایگان می‌دهد.

**Minimal fix:** فقط `productId == "full_version"`.

**Status:** رفع شد.

---

### Finding SEC-003 — پشتیبان Android پیش‌فرض فعال است

**Priority:** P1  
**Location:** `android/app/src/main/AndroidManifest.xml` — تگ `<application>` بدون `allowBackup`

**Evidence:** پیش‌فرض اندروید `allowBackup=true` است. Hive/SharedPreferences شامل نام کودک، مسیر عکس و (پس از SEC-001) هش PIN است.

**Minimal fix:** `allowBackup="false"` + قوانین استخراج داده.

**Status:** رفع شد.

---

### Finding SEC-004 — کلید رمز بکاپ داخل سورس هاردکد است

**Priority:** P1  
**Location:** `lib/core/backup_service.dart` — `_appKey = utf8.encode('kudake-iran-fandoghi-2025-backup-secret')`  
فرمت v1 فقط Base64 معکوس + checksum ضعیف است.

**Evidence:** هر کسی APK را باز کند همهٔ فایل‌های `.parsa` v2 را می‌خواند. v1 قابل جعل است.

**Minimal fix:** فرمت v3 با کلید مشتق از PIN؛ رد کردن v1؛ v2 فقط برای سازگاری قدیمی.

**Status:** رفع شد.

---

### Finding SEC-005 — رمز keystore آزمایشی در گیت

**Priority:** P1  
**Location:** `tools/generate_release_keystore.sh`

**Evidence:** `storepass/keypass` ثابت در اسکریپت و در `key.properties` تولیدی.

**Why it matters:** اگر همین اسکریپت برای کلید انتشار واقعی استفاده شده باشد، هر کسی می‌تواند APK را به‌نام اپ امضا کند. این را در runtime تأیید نکردیم.

**Minimal fix:** الزام متغیر محیطی؛ بدون رمز پیش‌فرض.

**Status:** رفع شد. **Needs runtime/infrastructure verification:** کلید واقعی استور را با این اسکریپت نساخته باشید.

---

### Finding SEC-006 — قفل‌نشدن PIN و نبود محدودسازی تلاش

**Priority:** P2  
**Location:** `lib/features/parent/parent_panel.dart` — `_showPinDialog`

**Evidence:** PIN چهاررقمی بدون lockout (حداکثر ۱۰۰۰۰ حالت).

**Status:** lockout پنج تلاش / ۳۰ ثانیه اضافه شد.

---

### Finding SEC-007 — ارسال گزارش کرش ممکن است مسیر/پیام خام داشته باشد

**Priority:** P2  
**Location:** `parent_panel.dart` — `_sendLogsToSupport`

**Evidence:** تا ۱۰ پیام خطا با `source` به اشتراک تلگرام می‌رود.

**Status:** فقط منبع و پیام کوتاه‌شده، بدون stack.

---

### Finding SEC-008 — CI در نبود `key.properties` با debug keystore امضا می‌کند

**Priority:** P2  
**Location:** `android/app/build.gradle` + `.github/workflows/build-apk.yml`

**Evidence:** fallback به `signingConfigs.debug`؛ آرتیفکت release واقعاً انتشار نیست.

**Minimal fix:** جدا کردن job تأیید از انتشار واقعی. در این دور تغییر معماری CI انجام نشد.

---

## ۳. مواردی که عمداً گزارش نشدند

- نبود certificate pinning / root detection — برای این اپ کودک لازم نیست.
- Hive بدون رمز دیسک — داده محلی بازی است؛ کنترل مهم‌تر PIN و backup است.
- `hasFullVersion()` در release همیشه به استور می‌زند — سخت‌گیرانه است، باگ امنیتی نیست (ممکن است آفلاین نسخه کامل را موقتاً نشان ندهد).
- فروشگاه سکه‌ای داخل بازی — پول واقعی نیست.

---

## ۴. حکم‌ها

### Executive Verdict

🟡 **READY AFTER REQUIRED FIXES**

منطق کنترل والدین، بکاپ و بازیابی خرید در کد اصلاح شد. قبل از آپلود استور باید کلید امضای واقعی و `billing.properties` روی ماشین/CI انتشار تنظیم شود.

### Release Blockers (P0)

- ~~PIN والدین persist نمی‌شد~~ — رفع شد

### High Priority (P1)

- ~~restore بدون productId~~ — رفع شد
- ~~allowBackup پیش‌فرض~~ — رفع شد
- ~~کلید بکاپ هاردکد / v1 ضعیف~~ — رفع شد
- ~~اسکریپت keystore با رمز ثابت~~ — رفع شد

### Recommended (P2)

- امضای CI با کلید انتشار واقعی
- `FLAG_SECURE` روی دیالوگ PIN (نیاز به فلگ نیتیو پنجره)

### User Isolation Verdict

**NOT APPLICABLE** — چندکاربرهٔ ابری وجود ندارد. یک پروفایل محلی روی دستگاه.

### Production Security Checklist

| Area | Status |
| --- | --- |
| Authentication (PIN والدین) | ✅ پس از رفع |
| Authorization (پنل والد / نسخه کامل) | ✅ |
| User Data Isolation | N/A |
| Input Validation | ✅ |
| Data Security (بکاپ) | ✅ |
| Secrets | ⚠️ کلید استور باید خارج از گیت بماند |
| API Security (آپارات HTTPS) | ✅ |
| Local Storage | ✅ |
| File Security | ✅ |
| Dependencies | ✅ پین شده در pubspec |
| Error Handling | ✅ |
| Production Configuration | ⚠️ امضا و RSA بازار روی محیط انتشار |
