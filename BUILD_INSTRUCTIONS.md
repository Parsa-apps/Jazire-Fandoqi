# راهنمای ساخت APK - جزیره فندقی

این راهنما برای ساخت نسخه‌ی قابل نصب اپلیکیشن **جزیره فندقی** است.

## 📋 پیش‌نیازها

قبل از شروع، مطمئن شوید این‌ها نصب هستند:

1. **Flutter SDK** (نسخه 3.24.3+):
   - دانلود از [flutter.dev](https://docs.flutter.dev/get-started/install)
   - پس از نصب: `flutter doctor` اجرا کنید تا مطمئن شوید همه چیز درست است

2. **Android Studio** یا **Android SDK + Java JDK 17+**:
   - Android Studio از [developer.android.com](https://developer.android.com/studio)
   - یا فقط Android SDK Command-line Tools

3. **Git** (برای clone کردن)

## 🔧 مراحل ساخت

### ۱. دریافت کد

```bash
git clone https://github.com/farshadkurd/kudake_iran.git
cd kudake_iran
git checkout main   # یا شاخهٔ کاری موردنظر
```

### ۲. نصب وابستگی‌ها

```bash
flutter pub get
```

### ۳. ساخت آیکون‌های پلتفرم

این دستور فایل‌های آیکون را برای Android و iOS می‌سازد:

```bash
flutter pub run flutter_launcher_icons
```

### ۴. پیکربندی امضای انتشار

برای انتشار واقعی در کافه‌بازار یا گوگل‌پلی، یک keystore خصوصی بسازید و **هرگز**
آن را وارد Git نکنید. سپس فایل `android/key.properties` محلی را بسازید:

```properties
storeFile=../release.keystore
storePassword=رمز-keystore
keyAlias=نام-key
keyPassword=رمز-key
```

فایل keystore را در `android/release.keystore` بگذارید. `key.properties` و فایل‌های
keystore در `.gitignore` قرار دارند.

> **امنیت امضای انتشار:** ساخت release محلی بدون `key.properties` عمداً متوقف
> می‌شود تا خروجی امضاشده با کلید debug اشتباهاً به استور ارسال نشود. برای تست
> روی گوشی از `flutter build apk --flavor myket --debug` استفاده کنید. محیط GitHub Actions فقط
> برای راستی‌آزمایی کامپایل اجازهٔ امضای debug دارد و خروجی آن قابل انتشار نیست.

> **🛡️ ضد دستکاری خودکار (v6.3):** هنگام ساخت release واقعی، SHA-256 گواهی
> امضای keystore به‌طور خودکار داخل `BuildConfig.EXPECTED_SIGNING_SHA256` ثبت
> می‌شود. اپ در اجرای release امضای خودش را با این مقدار مقایسه می‌کند و اگر
> APK با کلید دیگری بسته/repackage شده باشد، اجرا را متوقف می‌کند. برای
> راستی‌آزمایی مقدار ثبت‌شده:
>
> ```bash
> tools/print_cert_sha256.sh android/release.keystore نام-کلید رمز-کیاستور
> keytool -printcert -jarfile build/app/outputs/flutter-apk/app-myket-release.apk | grep "SHA256:"   # فقط هگز بعد از SHA256:
> ```
>
> دو مقدار باید برابر باشند. (بیلدهای CI که با کلید debug امضا می‌شوند مقدار
> خالی دارند و این بررسی در آن‌ها غیرفعال است — آن خروجی‌ها قابل انتشار نیستند.)

### ۵. ساخت APK مخصوص هر فروشگاه

هر فروشگاه باید خروجی مخصوص خودش را دریافت کند؛ در غیر این صورت مجوز پرداخت
فروشگاه رقیب باعث ردشدن APK می‌شود.

```bash
# خروجی قابل ارسال به مایکت (بدون PAY_THROUGH_BAZAAR)
flutter build apk --flavor myket --release

# خروجی قابل ارسال به کافه‌بازار (بدون مجوز پرداخت مایکت)
flutter build apk --flavor bazaar --release
```

برای تست سریع نیز flavor را مشخص کنید:

```bash
flutter build apk --flavor myket --debug
```

### ۶. یافتن فایل APK

- **مایکت release:** `build/app/outputs/flutter-apk/app-myket-release.apk`
- **بازار release:** `build/app/outputs/flutter-apk/app-bazaar-release.apk`
- **مایکت debug:** `build/app/outputs/flutter-apk/app-myket-debug.apk`

فایل بدون flavor مثل `app-release.apk` را در هیچ‌یک از دو فروشگاه بارگذاری نکنید.

## 📱 نصب روی گوشی

### روش ۱: انتقال فایل
1. فایل APK را به گوشی منتقل کنید
2. در گوشی، Settings → Security → "Install from unknown sources" را فعال کنید
3. روی فایل APK بزنید و نصب کنید

### روش ۲: ADB (برای توسعه‌دهندگان)
```bash
adb install build/app/outputs/flutter-apk/app-myket-release.apk
```

## 🎨 آیکون جدید

اپ با آیکون v3 Pro ساخته می‌شود که شامل:
- 🐰 فندقی بزرگ در مرکز
- حروف الفبا (الف ب پ) به ترتیب
- اعداد (1 2 3)
- پس‌زمینه‌ی گرادیان سبز-آبی

## 🆕 تغییرات این نسخه

1. **نام اپ**: «جزیره فندقی»
2. **آیکون جدید**: فندقی با حروف و اعداد
3. **انیمیشن خوش‌آمدگویی**: فندقی در اولین ورود می‌پره و خودش را معرفی می‌کنه
4. **خرگوش قابل کشیدن**: بچه می‌تونه فندقی را با انگشت به هرجای صفحه بکشه
5. **بازی‌های بهبودیافته**:
   - آکادمی الفبا: صفحه‌ی نوشتن جداگانه (بدون conflict با scroll)
   - بازی حباب: هدف بین ۱-۴ ترکاندن عوض می‌شه
   - بازی ستاره: سیستم هدف واقعی اضافه شد
6. **فونت کودکانه Baloo Bhaijaan 2** برای همه‌ی متن‌ها

## 🐛 رفع مشکلات رایج

### خطای `License for Android SDK not accepted`:
```bash
flutter doctor --android-licenses
```

### خطای `Gradle build failed`:
```bash
cd android
./gradlew clean
cd ..
flutter clean
flutter pub get
flutter build apk --flavor myket --release
```

### خطای `Java not found`:
مطمئن شوید Java JDK 17 یا بالاتر نصب است:
```bash
java -version
```

### خطای `Installation failed - parser did not find any certificates`:
این خطا یعنی APK بدون امضا ساخته شده است.
**راه حل فوری:**
```bash
# روش ۱: دیباگ بساز (همیشه قابل نصب است)
flutter build apk --flavor myket --debug
adb install build/app/outputs/flutter-apk/app-myket-debug.apk

# روش ۲: فقط برای تأیید release-mode و هرگز برای انتشار:
ALLOW_VERIFICATION_SIGNING=1 BUILD_MODE=release ./build.sh
# خروجی این حالت با کلید debug امضا می‌شود و باید صرفاً برای QA استفاده شود.
```
**برای انتشار اصلی در کافه‌بازار:**
```bash
keytool -genkey -v -keystore android/release.keystore -alias fandoghi -keyalg RSA -keysize 4096 -validity 10000
# بعد فایل android/key.properties را بسازید و دوباره build کنید
```

### خطای `App not installed` بعد از نصب قبلی:
اگر نسخه قبلی با کلید دیگری امضا شده بود:
```bash
adb uninstall com.parsaapps.amoozesh_fandoghi
adb install build/app/outputs/flutter-apk/app-myket-release.apk
```

## 📞 پشتیبانی

- توسعه‌دهنده: فرشاد پارسا
- ایمیل: farshadparsa2019@gmail.com
- تلگرام: @Parsaappsadmin
