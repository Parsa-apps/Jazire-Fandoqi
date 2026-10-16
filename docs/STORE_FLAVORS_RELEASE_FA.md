# 🏪 انتشار در کافه‌بازار و مایکت — راهنمای کامل (جداسازی در زمان build)

**نسخه:** ۷.۵.۰+۲۲ · **package:** `com.parsaapps.amoozesh_fandoghi` · **شناسهٔ محصول:** `full_version`

این سند تمام چیزی را که برای انتشار **دو خروجی اندرویدِ مستقل** لازم داری
یک‌جا جمع می‌کند: معماری، دستورات ساخت، تنظیمات هر فروشگاه، وابستگی‌ها،
تست روی دستگاه واقعی، و وضعیت استقلال خرید بین دو فروشگاه.

---

## ۱) معماری: یک کدبیس، دو خروجی مستقل

اپ از **یک** کدبیس ساخته می‌شود، ولی هر فروشگاه **آرتیفکت خودش** را می‌گیرد و
در آن آرتیفکت **فقط SDK پرداخت همان فروشگاه** وجود دارد.

```
کدبیس مشترک (lib/ + android/app/src/main)
        │
        ├── flavor «bazaar»  →  Poolakey (کافه‌بازار)
        │      ├── وابستگی: bazaarImplementation "com.github.cafebazaar.Poolakey:poolakey:2.2.0"
        │      ├── source set: android/app/src/bazaar/kotlin/...
        │      ├── کلید: BuildConfig.BAZAAR_RSA_PUBLIC_KEY
        │      └── مجوز: com.farsitel.bazaar.permission.PAY_THROUGH_BAZAAR
        │
        └── flavor «myket»   →  Myket Billing Client (مایکت)
               ├── وابستگی: myketImplementation "com.github.myketstore:myket-billing-client:1.19"
               ├── source set: android/app/src/myket/kotlin/...
               ├── کلید: BuildConfig.MYKET_RSA_PUBLIC_KEY
               └── مجوز: ir.mservices.market.BILLING
```

### چرا این‌قدر جداست؟

فروشگاه‌ها اپ را با «سرویس پرداخت» خودشان بررسی می‌کنند. اگر آرتیفکت مایکت
داخلش SDK بازار باشد، مایکت می‌تواند آن را به‌عنوان «پرداخت از مسیر دیگر» رد
کند. بنابراین جداسازی **در سطح بایت‌های آرتیفکت** انجام می‌شود، نه در سطح UI:

| | آرتیفکت کافه‌بازار | آرتیفکت مایکت |
|---|---|---|
| کلاس‌های SDK رقیب در DEX | ❌ وجود ندارد | ❌ وجود ندارد |
| سرویس billing رقیب در manifest | ❌ | ❌ |
| مجوز پرداخت رقیب | ❌ (صریحاً `tools:node="remove"`) | ❌ (صریحاً `tools:node="remove"`) |
| کلید عمومی RSA رقیب در BuildConfig | ❌ | ❌ |
| پکیج رقیب در `<queries>` | ❌ | ❌ |
| اینتنت/URI فروشگاه رقیب در کد | ❌ | ❌ |

این را می‌توان با اسکریپت زیر **اثبات** کرد (بند ۵).

### منبعِ حقیقت: کانال ساخت

`BuildConfig.STORE_CHANNEL` (تنظیم‌شده در `productFlavors`) تنها مرجع فروشگاهِ
هر بیلد است:

- لایهٔ نیتیو: `MainActivity.storeId` → متد `storeVendor` روی MethodChannel
- لایهٔ دارت: `--dart-define=STORE_CHANNEL=bazaar|myket` → `StoreDetector.buildChannel`
- در صورت نبود dart-define، دارت از نیتیو می‌پرسد (`StoreDetector.detect()`).

تشخیص زمان‌اجرای «نصب‌کننده» فقط برای **نمایش** باقی مانده و هرگز مسیر
پرداخت را تعیین نمی‌کند.

---

## ۲) ساختار فایل‌ها

### لایهٔ دارت (مشترک)

| فایل | نقش |
|---|---|
| `lib/core/billing_service.dart` | پل `MethodChannel` با نام `kudake_iran/billing` |
| `lib/core/monetization.dart` | اعطای دسترسی خرید کامل + گرنت Keystore |
| `lib/core/store_vendor.dart` | `StoreVendor` + `StoreDetector` (کانال ساخت) |
| `lib/core/store_listing.dart` | لینک صفحهٔ اپ در فروشگاهِ خودِ بیلد |
| `lib/core/content_access_policy.dart` | مرز رایگان/پولی محتوا |
| `lib/features/shop/full_version_paywall.dart` | صفحهٔ خرید (با قفل PIN والد) |

### لایهٔ نیتیو

| فایل | نقش |
|---|---|
| `android/app/src/main/kotlin/.../StoreBilling.kt` | قرارداد مشترک درگاه (بدون هیچ SDK‌ای) |
| `android/app/src/main/kotlin/.../BillingHostActivity.kt` | **تمام منطق مشترک** (کانال‌ها، خرید، بازیابی، بکاپ، امنیت) |
| `android/app/src/main/kotlin/.../BillingOutcome.kt` | DTO نتیجهٔ خرید |
| `android/app/src/bazaar/kotlin/.../MainActivity.kt` | فعالیت نسخهٔ بازار |
| `android/app/src/bazaar/kotlin/.../BazaarBilling.kt` | درگاه Poolakey |
| `android/app/src/myket/kotlin/.../MainActivity.kt` | فعالیت نسخهٔ مایکت |
| `android/app/src/myket/kotlin/.../MyketBilling.kt` | درگاه Myket Billing Client |
| `android/app/src/bazaar/AndroidManifest.xml` | مجوز بازار + حذف صریح مجوز مایکت |
| `android/app/src/myket/AndroidManifest.xml` | مجوز مایکت + حذف صریح مجوز بازار |

> `MainActivity` دیگر در `src/main` نیست؛ در هر flavor نسخهٔ خودش را دارد و
> `src/main` فقط کلاس پایهٔ `BillingHostActivity` را نگه می‌دارد. به همین دلیل
> `android:name=".MainActivity"` در manifest بدون تغییر کار می‌کند.

---

## ۳) دستورات ساخت

### پیش‌نیازها
- Flutter `3.24.3` (همان نسخه‌ای که CI استفاده می‌کند) · Dart ≥ 3.0
- JDK 17 · Android SDK با compileSdk 35 · NDK `27.3.13750724`
- `android/key.properties` + `android/release.keystore` برای خروجی release
- `android/billing.properties` (کلیدهای عمومی RSA دو فروشگاه)

### کافه‌بازار

```bash
# APK (اگر فروشگاه APK می‌خواهد)
flutter build apk --flavor bazaar --release \
  --dart-define=STORE_CHANNEL=bazaar

# AAB (فرمت پیشنهادی برای کافه‌بازار)
flutter build appbundle --flavor bazaar --release \
  --dart-define=STORE_CHANNEL=bazaar
```

**خروجی‌ها:**
- `build/app/outputs/flutter-apk/app-bazaar-release.apk`
- `build/app/outputs/bundle/bazaarRelease/app-bazaar-release.aab`

### مایکت

```bash
flutter build apk --flavor myket --release \
  --dart-define=STORE_CHANNEL=myket

flutter build appbundle --flavor myket --release \
  --dart-define=STORE_CHANNEL=myket
```

**خروجی‌ها:**
- `build/app/outputs/flutter-apk/app-myket-release.apk`
- `build/app/outputs/bundle/myketRelease/app-myket-release.aab`

### اسکریپت خودکار (پیشنهادی)

```bash
STORE_FLAVOR=bazaar BUILD_MODE=release ./build.sh
STORE_FLAVOR=myket  BUILD_MODE=release ./build.sh
```

اسکریپت علاوه بر ساخت، `analyze`، تست‌ها، بررسی حجم، بررسی امضا و
**بررسی جداسازی فروشگاه** را هم انجام می‌دهد.

### ❌ هرگز این‌ها را استفاده نکنید

```bash
flutter build apk --release            # ⛔ نام بدون flavor، خروجی مایکت است
flutter build appbundle --release      # ⛔ نام بدون flavor، خروجی بازار است
```

این نام‌ها فقط برای سازگاری با اسکریپت‌های قدیمی باقی مانده‌اند و **نامشان
گمراه‌کننده است**. فایل بدون flavor را در هیچ پنلی آپلود نکنید.

---

## ۴) تنظیمات موردنیاز هر فروشگاه

### مشترک (دو پنل)

| مورد | مقدار |
|---|---|
| نام بسته (application id) | `com.parsaapps.amoozesh_fandoghi` |
| نسخه | `7.5.0` (versionCode `22`) |
| حداقل SDK | 21 (اندروید ۵) |
| targetSdk | 35 |
| کلید امضا | همان `android/release.keystore` با alias `fandoghi` |
| شناسهٔ محصول | `full_version` (نوع: دائمی / غیرمصرفی) |
| کلید عمومی RSA | در `android/billing.properties` → `bazaarRsaPublicKey` / `myketRsaPublicKey` |

> ⚠️ **کلید RSA باید متعلق به همان حساب فروشگاهی باشد که اپ را در آن ثبت
> می‌کنید.** اگر کلید اشتباه باشد، امضای رسید رد می‌شود و خرید شکست می‌خورد.
> اگر کلید خالی باشد، SDK اصلاً راه‌اندازی نمی‌شود و خرید با پیام
> «کلید عمومی فروشگاه پیکربندی نشده است» رد می‌شود (و **هیچ دسترسی پولی
> فعال نمی‌شود**).

### کافه‌بازار

| مورد | مقدار |
|---|---|
| نوع انتشار | APK یا AAB (هر دو پشتیبانی می‌شوند) |
| محصول | `full_version` → در پنل: پرداخت درون‌برنامه‌ای → «غیرمصرفی/دائمی» |
| مجوز در آرتیفکت | `com.farsitel.bazaar.permission.PAY_THROUGH_BAZAAR` |
| SDK | Poolakey 2.2.0 (متن‌باز رسمی) |
| صفحهٔ برنامه | `bazaar://details?id=com.parsaapps.amoozesh_fandoghi` |
| امتیازدهی | `bazaar://details?id=...` با `ACTION_EDIT` |
| سرصفحهٔ ۵×۲ | دارد (`store/bazaar/header_5x2.png`) |
| مجوز رقیب | **نباید** باشد (`ir.mservices.market.BILLING`) |

### مایکت

| مورد | مقدار |
|---|---|
| نوع انتشار | APK (AAB هم ساخته می‌شود، اما مایکت معمولاً APK می‌گیرد) |
| محصول | `full_version` → در پنل توسعه‌دهنده: «دائمی» |
| مجوز در آرتیفکت | `ir.mservices.market.BILLING` |
| SDK | Myket Billing Client 1.19 (متن‌باز رسمی) |
| صفحهٔ برنامه | `myket://details?id=com.parsaapps.amoozesh_fandoghi` |
| امتیازدهی | `myket://comment?id=...` با `ACTION_EDIT` |
| سرصفحهٔ ۵×۲ | ندارد |
| مجوز رقیب | **نباید** باشد (`com.farsitel.bazaar.permission.PAY_THROUGH_BAZAAR`) |
| نکتهٔ قانونی | مایکت برای برنامه‌های درون‌پرداخت لینک به وب‌سایت ناشر را نمی‌پذیرد؛ صفحهٔ «درباره» باید نام و لینک **مایکت** را نشان دهد (کد این کار را انجام می‌دهد). |

### کلید عمومی RSA

`android/billing.properties` (در Git نادیده گرفته می‌شود):

```properties
bazaarRsaPublicKey=MIHNMA0GCSqGSIb3DQEBAQUAA4G7ADCBtwKBrwDLA+9s91...==
myketRsaPublicKey=MIGfMA0GCSqGSIb3DQEBAQUAA4GNADCBiQKBgQCRqGv0UUrh0Ur...
```

هر کلید فقط در flavor خودش داخل `BuildConfig` تزریق می‌شود.

---

## ۵) اثبات جداسازی (اجباری قبل از انتشار)

اسکریپت زیر آرتیفکت ساخته‌شده را باز می‌کند و بررسی می‌کند که SDK و مجوز
فروشگاه رقیب در آن نیست:

```bash
bash tool/verify_store_isolation.sh \
  build/app/outputs/flutter-apk/app-bazaar-release.apk bazaar
bash tool/verify_store_isolation.sh \
  build/app/outputs/flutter-apk/app-myket-release.apk myket
bash tool/verify_store_isolation.sh \
  build/app/outputs/bundle/bazaarRelease/app-bazaar-release.aab bazaar
bash tool/verify_store_isolation.sh \
  build/app/outputs/bundle/myketRelease/app-myket-release.aab myket
```

اگر حتی یکی از این بررسی‌ها خطا بدهد، **آرتیفکت نباید منتشر شود**.
همین بررسی در ورک‌فلو CI هم اجرا می‌شود (`Verify store isolation`) و
شکستش، ران را قرمز می‌کند.

### گزارش خودکار جداسازی روی PR

ورک‌فلو `Build APK & AAB` نتیجهٔ چهار بررسی را به‌صورت یک گزارش فارسی
منتشر می‌کند:

* در **خلاصهٔ ران** (`Summary` در صفحهٔ Actions) — برای هر کدام از چهار
  آرتیفکت، وضعیت DEX و manifest و نتیجهٔ نهایی (✅/❌) نوشته می‌شود.
* به‌صورت **کامنت روی PR** — همان گزارش (با نشان‌گر
  `<!-- store-isolation-report -->`) به‌روز می‌شود تا آخرین نتیجه همیشه
  در یک نگاه قابل بازرسی باشد و نیازی به باز کردن لاگ خام نباشد.

> گام بررسی، در صورت نقض جداسازی، `::error::` ثبت می‌کند و کل ران را
> قرمز می‌کند؛ یعنی انتشار آرتیفکت معیوب به‌صورت خودکار متوقف می‌شود.

بررسی دستی (اختیاری، اگر `aapt2` دارید):

```bash
$ANDROID_HOME/build-tools/*/aapt2 dump permissions app-myket-release.apk
# نباید هیچ خطی شامل com.farsitel.bazaar باشد
```

---

## ۶) وابستگی‌ها

### اندروید (Gradle)

| وابستگی | دامنه | نسخه | توضیح |
|---|---|---|---|
| `com.github.cafebazaar.Poolakey:poolakey` | `bazaarImplementation` | `2.2.0` | SDK رسمی متن‌باز کافه‌بازار (JitPack) |
| `com.github.myketstore:myket-billing-client` | `myketImplementation` | `1.19` | SDK رسمی متن‌باز مایکت (JitPack) |
| `com.google.android.material:material` | `implementation` | `1.12.0` | BottomSheet نصب مایکت + تم پلاگین‌ها |
| `androidx.appcompat:appcompat` | `implementation` | `1.7.0` | uCrop و تم |
| `androidx.annotation:annotation` | `implementation` | `1.7.1` | — |

- مخزن JitPack در `android/build.gradle` اضافه شده است.
- `play-services-ads-identifier` از SDK مایکت **حذف** شده (اپ کودک است و وعدهٔ
  «بدون شناسه تبلیغاتی» می‌دهد).

### ⚠️ چرا تسک `repackMyketAar` حذف شد؟

قبلاً هر دو SDK در یک کلاس‌پات بودند و هر دو کلاس AIDL
`com.android.vending.billing.IInAppBillingService` را حمل می‌کردند → خطای
`checkReleaseDuplicateClasses`. راه‌حل قدیمی: حذف کلاس‌های AIDL از AAR مایکت.

**حالا که SDKها جدا شدند، این کار خطرناک است:** در flavor مایکت دیگر Poolakey
نیست که کلاس‌های AIDL را تأمین کند؛ اگر بازبسته‌بندی ادامه پیدا می‌کرد، هر
خرید مایکت با `NoClassDefFoundError` می‌شکست. بنابراین:

- تسک `repackMyketAar` **حذف** شد،
- flavor مایکت از **AAR اصلی و دست‌نخوردهٔ** SDK مایکت استفاده می‌کند (کلاس‌های
  AIDL خودش را می‌آورد).

### دارت

**هیچ پکیج پرداختی جدیدی اضافه نشده است.** `pubspec.yaml` همچنان هیچ
پکیج IAP ندارد؛ پرداخت همچنان بومی (Kotlin) است.

> دربارهٔ `iran_iap`: بررسی شد و **استفاده نشد** — آن پکیج `flutter >=3.44.0` و
> `dart ^3.12.0` و `minSdk 24` می‌خواهد، در حالی که این پروژه روی Flutter
> 3.24.3 و minSdk 21 است. مهاجرت یعنی ارتقای زنجیرهٔ ابزار و حذف پشتیبانی
> اندروید ۵/۶، با سود صفر. الگوی «جداسازی در زمان build» بومی پیاده شد.

---

## ۷) منطق خرید کامل (بدون تغییر)

منطق خرید و بازشدن بازی‌ها **عیناً حفظ شده** است:

1. **خرید** → `BillingService.purchaseNonConsumable('full_version')`
   → `MethodChannel('kudake_iran/billing').invokeMethod('purchase')`
   → درگاه flavorِ جاری.
2. **تأیید خرید**: خودِ SDK فروشگاه امضای RSA رسید را بررسی می‌کند
   (Poolakey با `SecurityCheck.Enable(key)`، مایکت با `IabHelper(context, key)`).
   علاوه بر آن، لایهٔ دارت در release موفقیتِ **بدون** `purchaseToken` را رد
   می‌کند.
3. **اعطای دسترسی**: `Monetization.activateFullVersion` در release بدون توکن
   رسید، دسترسی نمی‌دهد. با موفقیت، گرنت در **Android Keystore** ذخیره
   می‌شود (`entitlement.granted` / `entitlement.receipt_token`).
4. **لغو/شکست** → `success: false` → **هیچ دسترسی‌ای فعال نمی‌شود** و پیام
   واقعی فروشگاه به کاربر نشان داده می‌شود.
5. **بازیابی (restore)** پشتیبانی می‌شود:
   - بازار: `Poolakey.getPurchasedProducts`
   - مایکت: `IabHelper.queryInventoryAsync(false, null)`
   - در `Monetization.hasFullVersion()`، **فروشگاه مرجع است**: اگر فروشگاه بگوید
     «خریدی نداری» ⇒ قطعاً پریمیوم نیست (حتی اگر فایل‌های محلی دستکاری شده
     باشند). اگر فروشگاه در دسترس نباشد ⇒ فقط گرنت Keystore پذیرفته می‌شود؛
     فلگ متنی Hive **هرگز** مرجع نیست.
6. **بازشدن بازی‌ها**: `ContentAccessPolicy` مرز رایگان/پولی را تعیین می‌کند
   (۹/۱۹ کارتون، ۵/۱۰ قصه، ۵/۱۰ لالایی، ۵/۱۰ مهارت زندگی، ۱۶/۳۳ الفبا،
   ۴/۸ بسته، ۱–۱۰ اعداد، و فهرست هاب‌های رایگان). قفل‌ها با
   `content_lock.dart` نمایش داده می‌شوند و خرید فقط با **PIN والد** ممکن است.

---

## ۸) استقلال خرید بین دو فروشگاه

> **خرید بازار و خرید مایکت کاملاً مستقل‌اند.**

- هر فروشگاه رکورد خرید خودش را برای `com.parsaapps.amoozesh_fandoghi` و
  حساب کاربری خودش نگه می‌دارد. **انتقال خرید بین دو فروشگاه وجود ندارد.**
- کاربری که از کافه‌بازار خریده و بعد نسخهٔ مایکت را نصب می‌کند، **به‌صورت
  خودکار پریمیوم نمی‌شود** و باید در مایکت جداگانه خرید کند.
- در برنامه هیچ اشتراک داده‌ای بین فروشگاه‌ها پیاده‌سازی نشده است؛ چون
  `applicationId` در هر دو یکی است، «بازیابی» از فروشگاهِ دیگر اصلاً معنا ندارد.
- اگر روزی خواستید دسترسی بین دو فروشگاه مشترک شود، این یک **طراحی جداگانه**
  است (سرور + احراز هویت + سیاست انتقال). تا وقتی طراحی و تأیید نشده، هیچ
  فرضی دربارهٔ اشتراک داده‌ای وجود ندارد.
- ⚠️ **پیامد عملی:** چون `applicationId` یکسان است، دو اپ **هم‌زمان روی یک
  دستگاه قابل نصب نیستند**؛ نصب یکی، دیگری را جایگزین می‌کند. برای تست هر دو
  فروشگاه روی یک گوشی، بین تست‌ها باید حذف و نصب مجدد شود. (تغییر
  `applicationId` برای هر فروشگاه نیازمند ثبت دو بستهٔ متفاوت در دو پنل است
  و در این تغییر انجام نشده است.)

---

## ۹) مراحل آزمایش روی دستگاه واقعی

### پیش‌نیاز
- یک گوشی اندرویدی (ترجیحاً Android 8+؛ یک دستگاه Android 5/6 برای
  اطمینان از minSdk 21).
- اپ **کافه‌بازار** و/or **مایکت** نصب و با حساب تست واردشده (سندباکس).
- محصول `full_version` در پنل سندباکس همان فروشگاه ساخته شده باشد.

### گام ۱ — نصب و صحت آرتیفکت

```bash
adb install -r build/app/outputs/flutter-apk/app-bazaar-release.apk
# یا
adb install -r build/app/outputs/flutter-apk/app-myket-release.apk
```

```bash
# مجوزهای مؤثر را ببینید
$ANDROID_HOME/build-tools/*/aapt2 dump permissions app-myket-release.apk
# نباید com.farsitel.bazaar داشته باشد
```

### گام ۲ — لاگ پرداخت

```bash
adb logcat | grep -i "\[Billing\]"
```

هر تلاش پرداخت یک خط `[Billing] purchase → success=… | <پیام>` می‌نویسد.
**توکن/رسید خرید هرگز لاگ نمی‌شود.**

### گام ۳ — سناریوهای اجباری برای هر فروشگاه

| # | سناریو | انتظار |
|---|---|---|
| ۱ | خرید موفق با حساب سندباکس | پیام «نسخه کامل فعال شد»، همهٔ بازی‌ها/کارتون‌ها باز می‌شوند |
| ۲ | **لغو** خرید در صفحهٔ فروشگاه | پیام «پرداخت لغو شد»؛ **دسترسی باز نشود** |
| ۳ | قطع اینترنت وسط پرداخت | خطای قابل‌فهم؛ **دسترسی باز نشود** |
| ۴ | موجودی ناکافی | خطای فروشگاه؛ **دسترسی باز نشود** |
| ۵ | خرید دوبارهٔ همان محصول | «این محصول قبلاً خریداری شده؛ «بازیابی خرید قبلی» را بزنید» (مایکت) |
| ۶ | **بازیابی خرید** (بعد از حذف داده‌های اپ) | خرید قبلی بازیابی و پریمیوم فعال می‌شود |
| ۷ | باز کردن اپ در حالت **آفلاین** | پریمیومِ قبلی برقرار می‌ماند (گرنت Keystore) |
| ۸ | حذف/ویرایش فایل‌های Hive توسط کاربر | پریمیوم جعل نمی‌شود (گرنت Keystore + مرجعیت فروشگاه) |
| ۹ | صفحهٔ «درباره» | فقط لینک **همان** فروشگاهِ همین بیلد نمایش داده می‌شود |
| ۱۰ | دکمهٔ امتیازدهی | صفحهٔ همان فروشگاه باز می‌شود (`bazaar://` یا `myket://`) |
| ۱۱ | نصب آرتیفکت **رقیب** روی همان گوشی | نصب جایگزین می‌شود؛ خرید فروشگاه قبلی **دست‌نخورده** می‌ماند (رکورد در فروشگاه است) |

### گام ۴ — تست جداگانهٔ فروشگاه‌ها
همان گام‌های بالا را برای فروشگاه دیگر هم تکرار کنید (با uninstall بین آن‌ها).

### گام ۵ — تست نسخهٔ release واقعی
نسخهٔ **debug** خرید را در سندباکسِ محلی موفق می‌کند. برای اطمینان از اتصال
واقعی به SDK فروشگاه، حتماً **release** را تست کنید.

---

## ۱۰) چک‌لیست نهایی انتشار

- [ ] `flutter analyze` و `flutter test` سبز (در CI: `tool/ci_quality_gate.sh`)
- [ ] هر دو flavor جداگانه build شده‌اند (`app-bazaar-release.*` و `app-myket-release.*`)
- [ ] `tool/verify_store_isolation.sh` برای هر چهار آرتیفکت **سبز** است
- [ ] امضای هر دو APK با `apksigner` تأیید شده و SHA-256 آن با کلید اصلی یکی است
- [ ] محصول `full_version` در **هر دو** پنل ساخته شده
- [ ] کلید RSA هر فروشگاه متعلق به همان حساب است
- [ ] تست دستگاه واقعی: خرید، لغو، قطع اینترنت، بازیابی، آفلاین
- [ ] متن پنل و لینک حریم خصوصی هاست‌شده
- [ ] فایل **بدون flavor** (`app-release.apk` / `app-release.aab`) آپلود نشده است

---

## ۱۱) عیب‌یابی

| پیام / رفتار | علت محتمل | راه‌حل |
|---|---|---|
| «کلید عمومی فروشگاه پیکربندی نشده است» | `billing.properties` خالی است یا کلید خوانده نشده | کلید را در `android/billing.properties` بگذارید و دوباره بسازید |
| «اتصال به فروشگاه برقرار نیست» | اپ فروشگاه نصب/وارد نشده یا اینترنت نیست | فروشگاه را نصب و با حساب تست وارد کنید |
| «امضای رسید خرید معتبر نیست» | کلید RSA متعلق به حساب دیگری است | کلید صادرشده از پنل همان حساب را بگذارید |
| «این نسخه از فروشگاه رسمی نصب نشده است» | نصب مستقیم APK (نه از فروشگاه) | اپ را از فروشگاه نصب کنید (این رفتار عمدی و امن است) |
| «این محصول قبلاً خریداری شده» | خرید قبلی وجود دارد | دکمهٔ «بازیابی خرید» را بزنید |
| فروشگاه می‌گوید مجوز/سرویس رقیب وجود دارد | آرتیفکت اشتباهی (بدون flavor) آپلود شده | با `tool/verify_store_isolation.sh` بررسی و آرتیفکت درست را آپلود کنید |
| `NoClassDefFoundError` هنگام خرید مایکت | آرتیفکت با AAR بازبسته‌بندی‌شده ساخته شده | از AAR اصلی استفاده کنید (تسک `repackMyketAar` باید حذف باشد) |

---

## ۱۲) تست‌های خودکار مرتبط

| فایل | چه چیزی را تضمین می‌کند |
|---|---|
| `test/core/store_isolation_contract_test.dart` | جداسازی در Gradle و source set‌ها (SDK، کلید، MainActivity، manifest) |
| `test/core/store_vendor_test.dart` | نگاشت کانال ساخت و بستهٔ نصب‌کننده |
| `test/core/store_listing_test.dart` | لینک صفحهٔ فروشگاه (بدون وب‌سایت ناشر) |
| `test/core/monetization_test.dart` | ردِ خرید ناموفق و بی‌اعتمادی به فلگ محلی در release |
| `test/core/store_neutral_ui_test.dart` | نام فروشگاه در متن قابل‌نمایش دیده نشود |
| `tool/verify_store_isolation.sh` | بررسی جداسازی روی آرتیفکت واقعی ساخته‌شده |
