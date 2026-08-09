# راهنمای ساخت APK - آموزش فندقی

این راهنما برای ساخت نسخه‌ی قابل نصب اپلیکیشن **آموزش فندقی** است.

## 📋 پیش‌نیازها

قبل از شروع، مطمئن شوید این‌ها نصب هستند:

1. **Flutter SDK** (نسخه 3.0+):
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
storeFile=release.keystore
storePassword=رمز-keystore
keyAlias=نام-key
keyPassword=رمز-key
```

فایل keystore را در `android/release.keystore` بگذارید. `key.properties` و فایل‌های
keystore در `.gitignore` قرار دارند.

> **فیکس ارور "The parser did not find any certificates":**
> نسخه قبلی اگر `key.properties` نبود، APK را بدون امضا می‌ساخت که در اندروید ۱۳+ نصب نمی‌شود.
> الان اگر `key.properties` نباشد، APK ریلیز با کلید دیباگ امضا می‌شود تا قابل نصب برای تست باشد.
> این برای تست روی گوشی کافی است، اما برای کافه‌بازار باید حتماً keystore اصلی بسازید.

### ۵. ساخت APK

برای نسخه‌ی دیباگ (سریع‌تر، برای تست):
```bash
flutter build apk --debug
```

برای نسخه‌ی release (بهینه‌تر، برای انتشار):
```bash
flutter build apk --release
```

### ۶. یافتن فایل APK

فایل APK در این مسیرها قرار دارد:

- **دیباگ**: `build/app/outputs/flutter-apk/app-debug.apk`
- **release**: `build/app/outputs/flutter-apk/app-release.apk`

## 📱 نصب روی گوشی

### روش ۱: انتقال فایل
1. فایل APK را به گوشی منتقل کنید
2. در گوشی، Settings → Security → "Install from unknown sources" را فعال کنید
3. روی فایل APK بزنید و نصب کنید

### روش ۲: ADB (برای توسعه‌دهندگان)
```bash
adb install build/app/outputs/flutter-apk/app-release.apk
```

## 🎨 آیکون جدید

اپ با آیکون v3 Pro ساخته می‌شود که شامل:
- 🐰 فندقی بزرگ در مرکز
- حروف الفبا (الف ب پ) به ترتیب
- اعداد (1 2 3)
- پس‌زمینه‌ی گرادیان سبز-آبی

## 🆕 تغییرات این نسخه

1. **نام اپ**: «آموزش فندقی» (قبلاً «کودک ایران»)
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
flutter build apk --release
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
flutter build apk --debug
adb install build/app/outputs/flutter-apk/app-debug.apk

# روش ۲: ریلیز با امضای دیباگ (بعد از فیکس v6.0.0+12):
flutter build apk --release
# الان این APK هم با کلید دیباگ امضا می‌شود و نصب می‌شود
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
adb install build/app/outputs/flutter-apk/app-release.apk
```

## 📞 پشتیبانی

- توسعه‌دهنده: فرشاد پارسا
- ایمیل: farshadparsa2019@gmail.com
- تلگرام: @Parsaappsadmin
