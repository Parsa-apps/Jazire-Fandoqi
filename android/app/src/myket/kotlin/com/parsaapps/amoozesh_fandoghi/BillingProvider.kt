package com.parsaapps.amoozesh_fandoghi

import io.flutter.embedding.android.FlutterFragmentActivity

/**
 * تنها نقطه‌ای که flavor «myket» SDK پرداخت را می‌سازد.
 *
 * کلید RSA از `BuildConfig.STORE_RSA_PUBLIC_KEY` می‌آید که برای این flavor
 * فقط با کلید پنل مایکت پر می‌شود. بقیهٔ کد اپ (MainActivity) هیچ ارجاعی به
 * کلاس‌های Myket Billing یا Poolakey ندارد.
 */
internal object BillingProvider {
    val storePublicKey: String = BuildConfig.STORE_RSA_PUBLIC_KEY

    fun create(activity: FlutterFragmentActivity): StoreBilling =
        MyketBilling(activity.applicationContext, storePublicKey)
}
