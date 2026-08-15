# 🔬 ممیزی عمیق — بخش دوم: تحلیل لایه‌به‌لایه «جزیره فندقی»

> **تاریخ:** ۲۰۲۶-۰۸-۱۳ | **وضعیت:** فقط تحلیل — هیچ کدی تغییر نکرده است
> **مکمل:** این سند ادامهٔ `CODE_REVIEW_REPORT.md` است و یافته‌های آن را با دادهٔ اندازه‌گیری‌شده (تعداد import، خطوط کد، فرکانس صدا، ابعاد تصاویر، نسخهٔ روز پکیج‌ها) عمیق می‌کند.

---

## A. مهم‌ترین یافتهٔ جدید: Keystore لو رفته، ضد-هک CRITICAL-1 شما را خنثی می‌کند

مخزن حاوی `SECURITY_AUDIT_REPORT.md` (نسخه ۶.۳، تاریخ ۲۰۲۶-۰۸-۱۲) است که یک ممیزی امنیتی عالی و صادقانه انجام داده و یافتهٔ CRITICAL-1 آن «بسته‌بندی مجدد و توزیع نسخهٔ آلوده» را با **بررسی امضای APK در زمان اجرا** (`EXPECTED_SIGNING_SHA256` در BuildConfig) رفع کرده است.

**اما یک حفره در خودِ طراحی وجود دارد که در آن گزارش دیده نشده:**

```
حملهٔ repackaging با کلید واقعی:
1. مهاجم از ریپازیتوری عمومی clone می‌گیرد
2. android/release.keystore + رمزهای key.properties را برمی‌دارد
3. کد را دستکاری می‌کند (مثلاً تبلیغ/بدافزار تزریق می‌کند)
4. با «همان کلید رسمی» بیلد و امضا می‌کند
5. SHA-256 امضا با BuildConfig یکی است ✅ → TamperBlockScreen هرگز نمایش داده نمی‌شود
```

یعنی تا زمانی که keystore عمومی است، لایهٔ «صحت بیلد» عملاً تزئینی است؛ مهاجم نیازی به دور زدن آن ندارد چون **با امضای قانونی وارد می‌شود**. حتی چک‌لیست انتشارِ همان گزارش (`key.properties با keystore واقعی وجود دارد`) این وضعیت را به‌عنوان طراحی عادی فرض کرده است.

**نتیجه:** اولویت C1 در گزارش اصلی نه‌تنها پابرجاست، بلکه وزنتی بیشتر پیدا می‌کند: بدون چرخش کلید، کل سرمایه‌گذاری anti-tamper نسخه ۶.۳ بی‌اثر است. راهنمای عملی: `KEYSTORE_ROTATION_GUIDE.md`.

---

## B. تحلیل جفت‌شدگی (Coupling) با اعداد واقعی

### B1. پرارجاع‌ترین ماژول‌ها (inbound imports)

| ماژول | تعداد فایل‌های واردکننده | تفسیر |
|---|---|---|
| `core/game_data.dart` | **۶۸ فایل** | نقطه شکست متمرکز؛ هر تغییر API آن ۶۸ فایل را لمس می‌کند |
| `core/fandoghi_coach.dart` | ۴۰ فایل | نفوذ زیاد مسکات در همه فیچرها (خوب برای محصول، بد برای تست) |
| `core/audio_service.dart` | ۳۵ فایل | سرویس صوتی سراسری |
| `core/growth/growth.dart` | ۱۸ فایل | باریکهٔ رشد/والدین |
| `core/monetization.dart` | ۳ فایل | خوشبختانه محدود (درگاه پرداخت ایزوله) ✅ |
| `core/asset_manager.dart` | **۱ فایل!** | 🔴 زیرساخت ساخته‌شده ولی رهاشده (بندر B2) |

### B2. زیرساخت‌های مرده/نیمه‌مرده (Dead Infrastructure)

این الگو در چند نقطه تکرار شده: سیستمی حرفه‌ای ساخته می‌شود ولی مصرف‌کننده پیدا نمی‌کند:

1. **`AssetManager` + `FandoghiImage` + `SafeAssetImage`:** سیستم lazy-load + LRU + کیفیت فیلتر — فقط در **۱ فایل** (`illustration_tile.dart`) import شده و `FandoghiImage`/`SafeAssetImage` جمعاً **۲ بار** استفاده شده‌اند. بقیهٔ اپ (۲۵+ نقطه) مستقیم `Image.asset` صدا می‌زند. نتیجه: حافظه عملاً با استراتژی پیش‌فرض فلاتر (سقف ۱۰۰MB) مدیریت می‌شود، نه استراتژی «گوشی ۱GB RAM» که در کامنت‌ها وعده داده شده.
2. **Riverpod + Clean Architecture:** `domain/` (entities/usecases/repository) و `presentation/providers` وجود دارد ولی فقط زنجیرهٔ «پروفایل بازیکن» از آن عبور می‌کند؛ ۷۱ فایل همچنان `GameData.*` استاتیک می‌خوانند.
3. **`CloudSyncService`:** خودش صادقانه stub است (مستند) — تنها نمونهٔ «درست» از این الگو.
4. **BGM در `AudioService`:** پلر و ۳ متد خالی برای موسیقی پس‌زمینهٔ خاموش.
5. **نسخه‌های تکراری premium widgets** (گزارش اصلی، M1) — مصرف بین دو نسخه تقسیم شده و هر دو نیمه‌مرده‌اند.

**توصیه:** قبل از ساخت زیرساخت جدید، یا مصرف زیرساخت‌های موجود را اجباری کنید (مهاجرت همهٔ تصویرها به `AssetManager`) یا آن‌ها را حذف کنید تا بار شناختی کد کم شود.

### B3. نقشهٔ وابستگی — الگوی غالب

```
features/* ──→ core/game_data (استاتیک، ۶۸ ورودی)
features/* ──→ core/audio_service
features/* ──→ core/fandoghi_coach
features/* ──→ core/growth/growth
   │
   └─ فقط features/profile (جزئی) ──→ domain/usecases ──→ data/repositories ──→ hive_player_store
```

یعنی **۹۵٪ ترافیک دادهٔ اپ از لایهٔ domain/data عبور نمی‌کند**؛ آن لایه یک جزیره است.

---

## C. نقاط داغ کارایی (با شواهد فایل/خط)

### C1. زنجیرهٔ استارت — ثانیه‌به‌ثانیه

| ترتیب | فراخوانی | فایل:خط | نوع |
|---|---|---|---|
| ۱ | `Hive.initFlutter()` | main.dart:77 | ضروری قبل از runApp |
| ۲ | `Hive.openBox('playerBox')` | main.dart:78 | قابل موازی‌سازی با ۳ و ۴ |
| ۳ | `AudioService.init()` (شامل `_tts.setLanguage/setPitch/setSpeechRate/setVolume`) | main.dart:79 → audio_service.dart:110 | **غیرضروری قبل از فریم اول** — اولین صدا ثانیه‌ها بعد زده می‌شود |
| ۴ | `GameData.load()` + `FandoghiCoach.rememberChild` + `GrowthStore.load()` | main.dart:94-103 | قابل اجرا بعد از اولین فریم (splash فوری) |
| ۵ | `SecurityHardeningService.assess()` (MethodChannel + بررسی امضا/Frida/root) | main.dart:115-118 | سنگین‌ترین مورد؛ حتماً بعد از فریم اول |

**پیشنهاد بازچینش (بدون تغییر امنیت):** runApp با splash فوری → در `addPostFrameCallback`: موازی‌سازی (Hive box، Audio init، Security assess) → سپس GameData/Growth → کوئچ امنیتی اگر tampered بود به `/security-blocked`. کاربر کودک به‌جای ۱–۳ ثانیه صفحه launch، در <۵۰۰ms انیمیشن فندقی را می‌بیند و بررسی امنیتی همچنان قبل از هر تعامل با داده اجرا شده است.

### C2. انیمیشن‌های بی‌وقفه — پرهزینه‌ترین ترکیب

- **۵۷ فراخوانی `.repeat()`** در پروژه.
- تمرکز کنترلرها: splash (۵)، fandoghi_welcome (۴)، draggable_fandoghi (۴)، premium/glass_card (۳)، shop (۳)، profile (۳).
- **`island_screen.dart` خطوط ۴۴–۸۹:** دو کنترلر `repeat` که از طریق `AnimatedBuilder` سه لایه `CustomPaint` (آسمان/آب/جزیره) را **هر فریم** بازpaint می‌کنند — بدون `RepaintBoundary`. روی GPUهای ضعیف این صفحه می‌تواند به ۳۰–۴۰fps سقوط کند درحالی‌که کودک فقط نگاه می‌کند.
- **`splash_screen.dart`:** `_glowCtrl.repeat(reverse:true)` و `_orbitCtrl.repeat()` — splash معمولاً ۱–۲ ثانیه است، پس قابل چشم‌پوشی؛ اما الگو در صفحه‌های ماندگار تکرار شده.

**قانون پیشنهادی برای این پروژه:** هر `repeat()` ماندگار باید داخل `RepaintBoundary` باشد یا با `Timer` کم‌فرکانس (۵۰۰ms+) جایگزین شود؛ و یک setting «حرکت کمتر» در پنل والدین (الگوی `textScale` موجود است) اضافه شود.

### C3. تایمرهای دائمی (main.dart:436-486 `_PlayTimeTracker`)

| تایمر | دوره | رفتار فعلی | بهینه |
|---|---|---|---|
| شمارش زمان بازی | ۱ ثانیه | `GameData.addPlayTime()` هر ثانیه (mutate استاتیک) | تجمیع در متغیر محلی + flush هر ۳۰ ثانیه |
| ذخیرهٔ خودکار | ۱۰ ثانیه | `GameData.save()` + `GrowthStore.save()` **حتی بدون تغییر** | flag کثیف (dirty) + save فقط هنگام تغییر |

### C4. Rebuildهای داشبورد

`dashboard_tab.dart:457,484` — دو مورد `setState(() {})` تهی در کال‌بک‌های پروفایل/پایل. این‌ها زیردرخت ~۱۲۰۰ خطی داشبورد (شامل لیست بازی‌ها، هدر آواتار با هاله، نوار رشد) را کامل rebuild می‌کنند. راه‌حل: استخراج آن دو بخش به ویجت جدا با `ValueListenableBuilder` روی همان داده‌ای که تغییر کرده.

### C5. کارتون‌ها

- `_timeout = 18s` برای resolve لینک آپارات — کودک ۱۸ ثانیه spinner می‌بیند؛ پیشنهاد: ۶ ثانیه + retry خودکار یک‌بار + پیام «بعداً امتحان کن».
- کش فقط در RAM با TTL دو ساعته؛ با بستن اپ از بین می‌رود. کش دیسک پوسترها (حتی ۲MB) تجربهٔ هاب کارتون را آفلاین-مانند می‌کند.

---

## D. ریاضیات دقیق کاهش حجم

### D1. صدا (WAV → OGG/Opus) — اندازه‌گیری واقعی

| گروه | مدت کل | حجم فعلی | برآورد Opus (32kbps mono) | صرفه‌جویی |
|---|---|---|---|---|
| `sfx` (۲۱ افکت، ۴۴٫۱kHz/16bit) | ۹ ثانیه | ۷۳۶KB | ~۴۵KB | **۹۴٪** |
| `learning/colors` (۱۲ صوت، ۲۴kHz) | ۲۳ ثانیه | ۱۰۷۳KB | ~۹۵KB | **۹۱٪** |
| `learning/shapes` (۱۰ صوت) | ۲۰ ثانیه | ۹۴۳KB | ~۸۵KB | **۹۱٪** |
| جمع | ۵۲ ثانیه | **۲٫۷۵MB** | **~۰٫۲۳MB** | **~۲٫۵MB** |

`just_audio` از Opus/OGG پشتیبانی کامل دارد؛ کیفیت گفتار در ۳۲kbps Opus برای گوش کودک غیرقابل تشخیص از WAV است. اسکریپت یک‌خطی با `ffmpeg -c:a libopus -b:a 32k` کافی است (الگوی اسکریپتی `tools/optimize_images.py` و `tools/generate_sfx.py` در پروژه موجود است).

نکتهٔ فنی: Android فایل‌های صوتی داخل assets را **فشرده‌نشده** در APK ذخیره می‌کند؛ پس هر بایت WAV مستقیماً یک بایت APK است.

### D2. تصویر

- فقط **یک** تصویر بیش از ۱۶۰۰px پیدا شد (`coral_island_bg.webp` ۱۰۸۰×۱۹۲۰) که پس‌زمینه تمام‌صفحه است و منطقی است. ✅
- پوسترهای کارتونی ۱۴۰۸×۷۶۸ با حجم ۲۰۰–۳۵۰KB؛ برای کاشی‌های لیست (نمایش ~۳۰۰px) بیش از حد سنگین‌اند. دو نسخه (thumb ~384px + full) یا re-encode با quality ۷۰–۷۵ → برآورد **۱٫۲–۱٫۵MB** صرفه‌جویی در `cartoons/` + `lullabies/` + `stories/`.
- `app_icon.png` (۷۱۱KB) + `app_icon_foreground.png` (۶۶۵KB): فقط خوراک تولید آیکون‌اند؛ حذف از بخش `flutter: assets` → **۱٫۳۷MB** صرفه‌جویی خالص.

### D3. بیلد

| اقدام | برآورد تأثیر روی APK نهایی |
|---|---|
| `--split-per-abi` در CI (به‌جای Fat) | −۱۵ تا ۲۰MB |
| حذف آیکون‌های بزرگ از assets | −۱٫۳۷MB |
| WAV → Opus | −۲٫۵MB |
| re-encode پوسترها | −۱٫۲MB |
| جمع | **تک‌ABI شدن + ~۵MB سبک‌تر از آن** |

---

## E. بدهی وابستگی‌ها (نسخهٔ نصب‌شده در برابر آخرین نسخهٔ شناخته‌شده)

| پکیج | در پروژه | آخرین (اوت ۲۰۲۶) | فاصله | ریسک |
|---|---|---|---|---|
| Flutter SDK (CI) | 3.24.3 | stable جدیدتر | ~۲ سال | 🔴 عامل `dependency_overrides` |
| `flutter_riverpod` | 2.5.1 | **3.4.2** [3](https://pub.dev/packages/flutter_riverpod) | یک major | 🟠 StateNotifier در v3 منسوخ |
| `flame` | 1.18.0 | **~5.x** [1](https://pub.dev/packages/flame_riverpod/versions/2.0.0) | چهار major | 🔴 اگر بازی‌ها رشد کنند |
| `just_audio` | 0.9.40 | **0.10.6** [2](https://pub.dev/packages/just_audio/versions) | minor | 🟡 |
| `google_fonts` | 6.2.1 | **8.1.0** [2](https://fluttergems.dev/packages/google_fonts/) | دو major | 🟡 (کلاً قابل حذف) |
| `hive` / `hive_flutter` | 2.2.3 | **نگهداری نمی‌شود** (~۲+ سال بدون آپدیت) | — | 🔴 راه‌حل: مهاجرت به `hive_ce` (جایگزین سازگار) یا drift [1](https://www.reddit.com/r/FlutterDev/comments/1f5k33g/is_the_hive_nosql_database_package_still_under/)[3](https://github.com/IO-Design-Team/hive_ce) |
| `talker` | 4.0.0 | — | — | 🟢 فقط لاگ |

**دو ریسک مستقل از نسخه:**
1. `hive` نگهداری‌نشده یعنی باگ‌های آیندهٔ سازگاری (مثلاً با Flutter بعدی) وصله رسمی نخواهند داشت. چون `playerBox` تنها مسیر ذخیرهٔ پیشرفت کودک است، این یک ریسک دادهٔ کاربر است. `hive_ce` ادعای سازگاری drop-in با boxها و adapterهای Hive v2 را دارد — کم‌هزینه‌ترین مسیر.
2. وابستگی `image_cropper` و پین آن حذف شده است؛ پروفایل فقط از ۲۰ آواتار داخلی و بدون دسترسی گالری استفاده می‌کند.

**پیشنهاد ترتیب:** اول آپگرید Flutter (یک PR جدا، با تست کامل) → حذف override → سپس پکیج‌ها یکی‌یکی؛ `hive→hive_ce` قبل از بقیه چون ریسک داده دارد.

---

## F. ماتریس پوشش تست (۲۲ فایل)

### پوشیده‌شده ✅
| حوزه | تست‌ها |
|---|---|
| منطق هسته | game_data, parent_pin, monetization, achievement, ai_system, audio, cartoon_data, catalog_search, coach, growth (خانواده/ارقام/store), jalali, life_skills_data, weekly_engine |
| فیچر | puzzle_game، learning_library، full_version_paywall، child_touch_target، draggable_fandoghi |
| سیستمی | app_smoke_test، integration/app_flow |

### پوشش‌نداده 🔴 (به ترتیب ریسک)
1. **مسیریابی و `_gameFor`** — شکننده‌ترین کد پروژه (تطبیق رشته فارسی) حتی یک تست ندارد.
2. **`GameAccessGate` / paywall flow** — مسیر پول؛ خطای اینجا = درآمد از دست رفته یا قفل خریدار.
3. **`backup_service` (v4 restore/import)** — از دست رفتن پیشرفت کودک در restore = فاجعهٔ پشتیبانی.
4. **`security_hardening` + `secure_store`** — منطق بلاک/اجازه بدون تست رگرسیون.
5. **story_reader / cartoon_player** — دو صفحهٔ ۱۲۰۰+ خطی با تایمر و ویدیو.
6. **gateway / hubها / island / profile / shop** — صفحات اصلی بدون widget test.

**پیشنهاد:** قبل از هر تغییر معماری، برای موارد ۱ تا ۴ «تست‌های حفاظ» (characterization tests) نوشته شود تا مهاجرت امن باشد.

---

## G. نقشهٔ ناوبری و عمق مسیر کودک

```
launch
└─ splash (انیمیشن ۵کنترلی)
   └─ onboarding (فقط بار اول)
      └─ gateway — سه دنیا: یادگیری / بازی / کاوش + کاشی‌های پروفایل/کارتون/لالایی/داستان
         ├─ learning-library → آکادمی‌ها (حیوانات/اعداد/مشاغل/مفاهیم/احساسات) → academy stage [عمق ۵]
         ├─ home (داشبورد) → ۱۶ بازی → stage [عمق ۵]
         ├─ stories → story_reader [عمق ۴]
         ├─ cartoons → cartoon_player [عمق ۴]
         ├─ lullabies → player [عمق ۴]
         ├─ island / stage_map / shop / stickers / buddy [عمق ۳]
         └─ parent (PIN) [عمق ۳ — درست برای والد]
```

**تحلیل بر اساس سن:**
- کودک **۳–۴ سال:** توان انتخاب بین بیش از ۴ گزینهٔ هم‌سطح را ندارد؛ gateway با ~۱۰ کاشی + سه دنیا برایش سنگین است. عمق ۵ (آکادمی→stage) عملاً بدون کمک والد طی نمی‌شود.
- کودک **۵–۶ سال:** gateway قابل درک است ولی «سه دنیا + ۱۶ بازی + نقشه ۵۰ مرحله‌ای» تصمیم‌گیری را کند می‌کند؛ مسیر «ادامهٔ بازی» (که در README ذکر شده) باید دکمهٔ غالب خانه باشد نه یک آیتم فرعی.
- کودک **۷–۸ سال:** مدل فعلی مناسب است.

**پیشنهاد اجرایی:** یک `HomeMode` مبتنی بر `childAge` (که امروز هم ذخیره می‌شود): برای ۳–۴ سال فقط ۴ دکمهٔ بزرگ (ادامه بده / الفبا / رنگ‌ها / قصه) مستقیم از gateway، بدون لایهٔ اضافی. این تغییر کم‌هزینه، بیشترین اثر UX را دارد.

---

## H. محتوا در کد کامپایل شده — مانع پلتفرم شدن

~۴۷۳۰ خط دادهٔ محتوایی داخل فایل‌های Dart:

| فایل | خط | محتوا |
|---|---|---|
| `cartoon_data.dart` | ۱۲۳۸ | ۱۸ کارتون + متادیتا |
| `children_stories_data.dart` | ۹۰۳ | قصه‌های کودکانه |
| `lullabies_data.dart` | ۳۲۱ | لالایی‌ها |
| `stories.dart` + `learning_topics.dart` + `life_skills_data.dart` | ۷۳۵ | داستان تعاملی/موضوع‌ها/مهارت زندگی |
| بخش‌های محتوایی `game_data.dart` | ~۳۰۰ | مأموریت‌ها/دستاوردها |

**پیامدها:**
- هر غلط املایی در قصه = انتشار نسخهٔ جدید اپ.
- افزودن ۵ قصهٔ جدید = بیلد کامل + آپلود استور + انتظار تأیید.
- امکان A/B یا محتوای فصلی وجود ندارد.

**معماری پیشنهادی (فاز اول، بدون سرور):** فایل‌های JSON رمزدار/امضاشده داخل assets + «بسته‌های محتوا» قابل دانلود با همان کانال امنی که برای بکاپ v4 ساخته‌اید (AES-GCM). کلید محتوا عمومی است و هدف فقط یکپارچگی است — پیچیدگی امنیتی ندارد. فاز دوم: CDN ساده برای بسته‌ها + manifest نسخه.

---

## I. جمع‌بندی دلتا نسبت به گزارش اول

| یافته | وضعیت در گزارش اول | وضعیت پس از تحلیل عمیق |
|---|---|---|
| نشت Keystore (C1) | بحرانی | بحرانی‌تر: ضد-هک CRITICAL-1 گزارش ۶.۳ را عملاً خنثی می‌کند |
| AssetManager | ذکر نشده بود | 🔴 زیرساخت مرده: ۱ import از ۱۸۱ فایل |
| Hive نگهداری‌نشده | ذکر نشده بود | 🔴 ریسک دادهٔ پیشرفت کودک؛ مهاجرت به hive_ce |
| flame ۴ major عقب | «وابستگی سنگین» | بدهی فنی بلندمدت؛ برای بازی‌های بعدی بازدارنده |
| تست مسیریابی/paywall/backup | «پوشش ناقص» | اولویت‌بندی دقیق در بخش F |
| کاهش حجم | برآورد کلی | اعداد اندازه‌گیری‌شده: ~۲٫۵MB صدا + ۱٫۳۷MB آیکون + ۱٫۲MB پوستر + split-per-abi |
| عمق ناوبری کودک | کیفی | نقشهٔ کامل + پیشنهاد HomeMode مبتنی بر سن |

> منابع وب استفاده‌شده برای نسخهٔ روز پکیج‌ها:
> [1](https://pub.dev/packages/flame_riverpod/versions/2.0.0) [2](https://pub.dev/packages/just_audio/versions) [3](https://pub.dev/packages/flutter_riverpod) — riverpod 3.4.2 و just_audio 0.10.6 و flame ~5.x؛ [google_fonts 8.1.0](https://fluttergems.dev/packages/google_fonts/)؛ وضعیت نگهداری hive: [Reddit r/FlutterDev](https://www.reddit.com/r/FlutterDev/comments/1f5k33g/is_the_hive_nosql_database_package_still_under/) و [hive_ce](https://github.com/IO-Design-Team/hive_ce).
