package com.parsaapps.amoozesh_fandoghi

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

// ℹ️ قبلاً enum نیتیوِ `StoreVendor` (با شاخه‌های BAZAAR/MYKET/UNKNOWN) در همین
// فایل بود و در زمان اجرا بستهٔ نصب‌کننده را از سیستم‌عامل می‌پرسید تا درگاه
// را انتخاب کند.
//
// با جداسازی در زمان build دیگر چنین مسیری نیست:
//  • هر آرتیفکت فقط یک درگاه دارد و آن درگاه در source set همان flavor است.
//  • فروشگاهِ بیلد از روی `BuildConfig.STORE_CHANNEL` معلوم است و به
//    `MainActivity.storeId` (که همان `STORE_CHANNEL` را برمی‌گرداند) و سپس به
//    متد `storeVendor` کانال Dart منتقل می‌شود.
// بنابراین شاخهٔ «تشخیص نصب‌کننده» که می‌توانست درگاه فروشگاه رقیب را فعال
// کند حذف شد؛ `installerPackage` فقط به‌عنوان مقدار تشخیصی باقی ماند.
