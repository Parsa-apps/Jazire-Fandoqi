package com.parsaapps.amoozesh_fandoghi

import android.content.Intent
import android.net.Uri

/**
 * 🏪 فعالیت نسخهٔ **کافه‌بازار**.
 *
 * این کلاس فقط در flavor «bazaar» کامپایل می‌شود؛ یعنی در آرتیفکت مایکت
 * اصلاً وجود ندارد. درگاه پرداخت این نسخه **فقط** Poolakey است و SDK مایکت
 * نه در کلاس‌پات این بیلد هست و نه در manifest نهایی.
 *
 * `STORE_CHANNEL` از `productFlavors` می‌آید و تنها مرجع فروشگاهِ این بیلد
 * است؛ تشخیص زمان‌اجرای نصب‌کننده دیگر انجام نمی‌شود.
 */
class MainActivity : BillingHostActivity() {
    override val storeId: String get() = BuildConfig.STORE_CHANNEL

    override fun createBilling(): StoreBilling =
        BazaarBilling(this, BuildConfig.BAZAAR_RSA_PUBLIC_KEY)

    /**
     * صفحهٔ امتیازدهی بازار.
     *
     * کافه‌بازار برای امتیازدهی همان صفحهٔ جزئیات برنامه را با
     * `Intent.ACTION_EDIT` باز می‌کند.
     */
    override fun buildStoreReviewIntent(): Intent = Intent(
        Intent.ACTION_EDIT,
        Uri.parse("bazaar://details?id=$packageName"),
    ).setPackage("com.farsitel.bazaar")

    /** صفحهٔ اطلاعات برنامه در بازار (پشتیبان). */
    override fun buildStoreDetailsIntent(): Intent = Intent(
        Intent.ACTION_VIEW,
        Uri.parse("bazaar://details?id=$packageName"),
    ).setPackage("com.farsitel.bazaar")

    /** نشانی وبِ صفحهٔ برنامه در کافه‌بازار (نه وب‌سایت ناشر). */
    override fun storeWebUrl(): String = "https://cafebazaar.ir/app/$packageName"
}
