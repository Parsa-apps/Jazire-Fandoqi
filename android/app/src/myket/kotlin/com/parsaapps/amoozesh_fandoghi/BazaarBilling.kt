package com.parsaapps.amoozesh_fandoghi

import androidx.activity.result.ActivityResultRegistry
import io.flutter.embedding.android.FlutterFragmentActivity

/**
 * 🏪 جایگزینِ درگاه کافه‌بازار در بیلد مایکت.
 *
 * در flavor مایکت کتابخانهٔ Poolakey عمداً وارد بیلد نمی‌شود تا APK حاوی
 * permission اختصاصی پرداخت بازار نباشد (`com.farsitel.bazaar.permission.
 * PAY_THROUGH_BAZAAR` — مایکت APKهای دارای این دسترسی را رد می‌کند).
 *
 * این کلاس همان API کلاسِ اصلی `BazaarBilling` (در `src/bazaar/kotlin`) را
 * دارد تا [MainActivity] بدون تغییر کامپایل شود. در عمل هیچ‌وقت صدا زده
 * نمی‌شود، چون در بیلد release مایکت `StoreVendor.resolve` همیشه MYKET
 * برمی‌گرداند؛ اگر هم به هر دلیل صدا زده شود، پاسخ شکست روشنی می‌دهد.
 */
class BazaarBilling(
    @Suppress("unused") private val activity: FlutterFragmentActivity,
    @Suppress("unused") publicKey: String,
) {
    val isConfigured: Boolean get() = false

    fun connect() {
        // هیچ اتصالی در بیلد مایکت وجود ندارد.
    }

    fun purchase(
        @Suppress("unused") registry: ActivityResultRegistry,
        @Suppress("unused") productId: String,
        @Suppress("unused") payload: String,
        callback: (BillingOutcome) -> Unit,
    ) {
        callback(BillingOutcome.failure(notBuiltForBazaarMessage()))
    }

    fun restore(
        @Suppress("unused") productId: String,
        callback: (BillingOutcome) -> Unit,
    ) {
        callback(BillingOutcome.failure(notBuiltForBazaarMessage()))
    }

    fun consume(
        @Suppress("unused") purchaseToken: String,
        callback: (BillingOutcome) -> Unit,
    ) {
        callback(BillingOutcome.failure(notBuiltForBazaarMessage()))
    }

    fun dispose() {
        // چیزی برای آزادکردن نیست.
    }

    private fun notBuiltForBazaarMessage(): String =
        "این نسخه برای کافه‌بازار ساخته نشده است؛ از فروشگاهی که برنامه را " +
            "از آن دریافت کرده‌اید خرید کنید."
}
