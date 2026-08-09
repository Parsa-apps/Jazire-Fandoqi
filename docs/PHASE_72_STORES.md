# 🏪 فاز ۷۲ — راهنمای اتصال کافه‌بازار و مایکت (دو استور در یک کد)

## روش پیشنهادی: productFlavors

وقتی SDKهای رسمی اضافه شدند، `android/app/build.gradle` این‌طور flavor می‌گیرد:

```gradle
android {
    flavorDimensions "market"
    productFlavors {
        bazaar {
            dimension "market"
            applicationIdSuffix ".bazaar"
            buildConfigField "String", "BILLING_SDK", "\"cafebazaar\""
        }
        myket {
            dimension "market"
            applicationIdSuffix ".myket"
            buildConfigField "String", "BILLING_SDK", "\"myket\""
        }
    }
}
```

و در Kotlin بریج (فاز ۷۱)، بر اساس `BuildConfig.BILLING_SDK` کلاس پرداخت مناسب
نمونه‌سازی می‌شود.

## وابستگی‌های پیشنهادی (پس از دریافت از پنل توسعه‌دهنده)

- کافه‌بازار: `com.cafebazaar.android:external:1.0.7` + ریپازیتوری اختصاصی
- مایکت: `ir.msdk:sdk:...` + ریپازیتوری اختصاصی

## نکات مهم
- دو اپلیکیشن با applicationId متفاوت = دو انتشار جداگانه در دو استور.
- کد Dart یکسان است؛ فقط `BillingService` (MethodChannel) به بریج نیتیو می‌رسد.
- در release هر دو باید بدون `sandboxFallback` بیلد شوند.
- قبل از انتشار: تست خرید واقعی با حساب تستی هر استور + تست consume.
