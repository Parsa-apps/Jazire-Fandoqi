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
         * 🏪 از نسخهٔ 6.2.1+2 هر بیلد release مخصوص یک فروشگاه ساخته می‌شود
         * (flavor). در این حالت flavor ملاک قطعی است: بیلد مایکت اصلاً
         * Poolakey را ندارد و هرگز نباید به درگاه بازار مسیردهی شود — حتی
         * اگر کاربر بازار را هم نصب داشته باشد (در غیر این صورت به کلاس‌هایی
         * می‌رسد که در این بیلد وجود ندارند).
         *
         * در debug و بیلدهای بدون flavor (راستی‌آزمایی)، مثل قبل: اول بستهٔ
         * نصب‌کننده ملاک است؛ اگر ناشناخته بود (نصب مستقیم APK) و فقط یکی از
         * دو فروشگاه روی دستگاه نصب باشد، همان انتخاب می‌شود.
         */
        fun resolve(context: Context): StoreVendor {
            if (!BuildConfig.DEBUG) {
                return when (BuildConfig.STORE_FLAVOR) {
                    "bazaar" -> BAZAAR
                    "myket" -> MYKET
                    else -> fallbackResolve(context)
                }
            }
            return fallbackResolve(context)
        }

        private fun fallbackResolve(context: Context): StoreVendor {
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
