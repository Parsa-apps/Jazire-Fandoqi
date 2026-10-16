package com.parsaapps.amoozesh_fandoghi

import android.content.Intent
import android.net.Uri

/**
 * 🏪 فعالیت نسخهٔ **مایکت**.
 *
 * این کلاس فقط در flavor «myket» کامپایل می‌شود؛ یعنی در آرتیفکت کافه‌بازار
 * اصلاً وجود ندارد. درگاه پرداخت این نسخه **فقط** Myket Billing Client است
 * و Poolakey نه در کلاس‌پات این بیلد هست و نه در manifest نهایی.
 *
 * `STORE_CHANNEL` از `productFlavors` می‌آید و تنها مرجع فروشگاهِ این بیلد
 * است؛ تشخیص زمان‌اجرای نصب‌کننده دیگر انجام نمی‌شود.
 */
class MainActivity : BillingHostActivity() {
    override val storeId: String get() = BuildConfig.STORE_CHANNEL

    override fun createBilling(): StoreBilling =
        MyketBilling(applicationContext, BuildConfig.MYKET_RSA_PUBLIC_KEY)

    /**
     * صفحهٔ امتیازدهی مایکت.
     *
     * مایکت برای ثبت نظر/امتیاز اینتنت رسمی `myket://comment?id=` را با
     * `Intent.ACTION_EDIT` باز می‌کند.
     */
    override fun buildStoreReviewIntent(): Intent = Intent(
        Intent.ACTION_EDIT,
        Uri.parse("myket://comment?id=$packageName"),
    ).setPackage("ir.mservices.market")

    /**
     * صفحهٔ اطلاعات برنامه در مایکت.
     *
     * مایکت برای برنامه‌های درون‌پرداخت اجازهٔ لینک به وب‌سایت ناشر را
     * نمی‌دهد و اینتنت رسمی `myket://details?id=` را می‌خواهد:
     * https://myket.ir/kb/pages/open-application-page-in-myket/
     */
    override fun buildStoreDetailsIntent(): Intent = Intent(
        Intent.ACTION_VIEW,
        Uri.parse("myket://details?id=$packageName"),
    ).setPackage("ir.mservices.market")

    /** نشانی وبِ صفحهٔ برنامه در مایکت (نه وب‌سایت ناشر). */
    override fun storeWebUrl(): String = "https://myket.ir/app/$packageName"
}
