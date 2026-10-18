package com.parsaapps.amoozesh_fandoghi

import android.app.Activity
import androidx.activity.result.ActivityResultRegistry

/**
 * 🏪 قرارداد مشترک درگاه پرداختِ همین بیلد.
 *
 * هر flavor دقیقاً یک پیاده‌سازی دارد: `bazaar` → `BazaarBilling` (Poolakey)
 * و `myket` → `MyketBilling`. کد مشترک ([MainActivity]) هیچ‌وقت نام SDK یا
 * کلاس فروشگاه را نمی‌شناسد، پس APK هر فروشگاه SDK فروشگاه دیگر را در خود
 * ندارد و قوانین دو فروشگاه با هم تداخل نمی‌کند.
 *
 * تمام callbackها باید دقیقاً یک‌بار و روی ترد UI صدا زده شوند؛
 * [MainActivity.singleReply] هم یک لایهٔ محافظ دیگر دارد.
 */
interface StoreBilling {
    /** کلید عمومی RSA همین فروشگاه؛ خالی یعنی پرداخت پیکربندی نشده است. */
    val publicKey: String

    fun purchase(
        activity: Activity,
        registry: ActivityResultRegistry,
        productId: String,
        payload: String,
        callback: (BillingOutcome) -> Unit,
    )

    fun restore(productId: String, callback: (BillingOutcome) -> Unit)

    fun consume(purchaseToken: String, callback: (BillingOutcome) -> Unit)

    fun dispose()
}
