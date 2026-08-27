package com.parsaapps.amoozesh_fandoghi

import android.content.Context
import android.content.pm.PackageManager
import android.os.Build

/**
 * نتیجهٔ یکسانِ عملیات پرداخت، مستقل از اینکه کدام فروشگاه آن را انجام
 * داده است. دقیقاً به همان شکلی به Flutter تحویل می‌شود که
 * `BillingService._parse` در سمت Dart انتظار دارد.
 */
data class BillingOutcome(
    val success: Boolean,
    val token: String? = null,
    val orderId: String? = null,
    val message: String = "",
) {
    fun toMap(): Map<String, Any?> = mapOf(
        "success" to success,
        "purchaseToken" to token,
        "orderId" to orderId,
        "message" to message,
    )

    companion object {
        fun success(token: String? = null, orderId: String? = null, message: String) =
            BillingOutcome(true, token, orderId, message)

        fun failure(message: String) = BillingOutcome(false, message = message)
    }
}

/** فروشگاهی که اپ از آن نصب شده است. آینهٔ `StoreVendor` در سمت Dart. */
enum class StoreVendor(val packageName: String) {
    BAZAAR("com.farsitel.bazaar"),
    MYKET("ir.mservices.market"),
    UNKNOWN("");

    companion object {
        const val BAZAAR_PACKAGE = "com.farsitel.bazaar"
        const val MYKET_PACKAGE = "ir.mservices.market"

        fun fromInstaller(installer: String?): StoreVendor =
            when (installer?.trim()?.lowercase()) {
                BAZAAR_PACKAGE -> BAZAAR
                MYKET_PACKAGE -> MYKET
                else -> UNKNOWN
            }

        /**
         * فروشگاهِ قطعیِ این بیلد، بر اساس flavor ساخت.
         *
         * هر قطعهٔ ارسالی به یک فروشگاه مشخص است: APKهای flavor «myket»
         * به مایکت می‌روند و AABهای flavor «bazaar» به کافه‌بازار. پس کانال
         * ساخت منبعِ قابل‌اتکاتری از تشخیص زمان‌اجراست.
         *
         * چرا این لازم است: `resolve()` به تشخیص نصب‌کنندهٔ سیستم‌عامل
         * تکیه می‌کرد؛ اما وقتی آن تشخیص مبهم می‌شود (مثلاً نصب از سوی
         * مکانیزمی که `installingPackageName` دقیقاً برابر بستهٔ فروشگاه
         * نیست، یا دستگاه تستی که هر دو اپِ بازار و مایکت را دارد — که
         * طبق منطقِ قبلی `UNKNOWN` برمی‌گرداند)، خریدِ درون‌برنامه‌ایِ
         * مایکت با پیام «این نسخه از فروشگاه رسمی نصب نشده است» مسدود
         * می‌شد، در حالی که APK دقیقاً همان بیلدِ مایکت بود. کانال ساخت
         * این ابهام را قطعی می‌کند.
         *
         * مقدار توسط `BuildConfig.STORE_CHANNEL` (تنظیم‌شده در
         * productFlavors) تأمین می‌شود. مقدار ناشناخته `null` برمی‌گرداند
         * تا caller به تشخیص زمان‌اجرا برگردد.
         */
        fun fromChannel(channel: String?): StoreVendor? =
            when (channel?.trim()?.lowercase()) {
                "bazaar" -> BAZAAR
                "myket" -> MYKET
                else -> null
            }

        /**
         * بستهٔ نصب‌کنندهٔ اپ را از سیستم‌عامل می‌پرسد.
         *
         * این مقدار توسط PackageManager هنگام نصب ثبت می‌شود و اپ نمی‌تواند
         * آن را تغییر دهد؛ برای مسیریابی درگاه پرداخت کاملاً قابل اتکاست.
         */
        fun installerPackage(context: Context): String = try {
            val pm = context.packageManager
            if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.R) {
                pm.getInstallSourceInfo(context.packageName).installingPackageName ?: ""
            } else {
                @Suppress("DEPRECATION")
                pm.getInstallerPackageName(context.packageName) ?: ""
            }
        } catch (_: Exception) {
            ""
        }

        /** آیا اپِ فروشگاه روی دستگاه نصب است؟ */
        fun isInstalled(context: Context, packageName: String): Boolean = try {
            context.packageManager.getApplicationInfo(packageName, 0)
            true
        } catch (_: PackageManager.NameNotFoundException) {
            false
        } catch (_: Exception) {
            false
        }

        /**
         * فروشگاه مؤثر برای پرداخت.
         *
         * اول بستهٔ نصب‌کننده ملاک است. اگر ناشناخته بود (نصب مستقیم APK یا
         * فروشگاهی که پشتیبانی نمی‌کنیم) و فقط **یکی** از دو فروشگاه روی
         * دستگاه نصب باشد، همان انتخاب می‌شود تا کاربری که APK را دستی
         * نصب کرده ولی فروشگاه را دارد بتواند خرید کند. اگر هیچ‌کدام یا
         * هر دو نصب باشند، مبهم است و UNKNOWN برمی‌گردد.
         */
        fun resolve(context: Context): StoreVendor {
            val fromInstaller = fromInstaller(installerPackage(context))
            if (fromInstaller != UNKNOWN) return fromInstaller
            val hasBazaar = isInstalled(context, BAZAAR_PACKAGE)
            val hasMyket = isInstalled(context, MYKET_PACKAGE)
            return when {
                hasBazaar && !hasMyket -> BAZAAR
                hasMyket && !hasBazaar -> MYKET
                else -> UNKNOWN
            }
        }
    }
}
