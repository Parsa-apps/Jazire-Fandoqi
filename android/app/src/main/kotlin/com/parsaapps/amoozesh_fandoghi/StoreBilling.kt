package com.parsaapps.amoozesh_fandoghi

import io.flutter.embedding.android.FlutterFragmentActivity

/**
 * 🏪 قرارداد مشترکِ درگاه پرداخت این بیلد.
 *
 * هر آرتیفکت فقط **یک** پیاده‌سازی دارد و آن پیاده‌سازی در source set همان
 * flavor زندگی می‌کند:
 *
 *  • flavor «bazaar» → [BazaarBilling] روی Poolakey (کافه‌بازار)
 *  • flavor «myket»  → [MyketBilling] روی Myket Billing Client (مایکت)
 *
 * این اینترفیس عمداً **هیچ نوعی از SDK فروشگاه** را در امضای خود ندارد.
 * به همین دلیل کلاس‌های `ir.cafebazaar.poolakey.*` و `ir.myket.billingclient.*`
 * فقط در بیلدِ همان فروشگاه کامپایل می‌شوند و در آرتیفکت فروشگاه دیگر
 * وجود ندارند — یعنی مسیر پرداخت فروشگاه رقیب نه فقط پنهان، بلکه غیرقابل
 * استفاده است.
 *
 * منطق تأیید خرید (بررسی امضای RSA رسید توسط خود SDK فروشگاه) در همین
 * دو پیاده‌سازی و بدون تغییر باقی مانده است.
 */
interface StoreBilling {
    /**
     * اتصال اولیه به سرویس فروشگاه.
     *
     * در Poolakey اتصال صریح دارد؛ در Myket Billing Client اتصال «تنبل» است
     * و در نخستین خرید انجام می‌شود، پس آنجا این متد عمداً بی‌اثر است.
     */
    fun connect()

    /**
     * خرید یک محصول.
     *
     * @param activity فعالیت میزبان؛ Poolakey برای باز کردن فلوی پرداخت بازار
     *   به `ActivityResultRegistry` همین فعالیت نیاز دارد.
     * @param payload دادهٔ دلخواه که فروشگاه در رسید برمی‌گرداند.
     */
    fun purchase(
        activity: FlutterFragmentActivity,
        productId: String,
        payload: String,
        callback: (BillingOutcome) -> Unit,
    )

    /** بازیابی خریدهای قبلی کاربر (پشتیبانی می‌شود). */
    fun restore(productId: String, callback: (BillingOutcome) -> Unit)

    /** مصرف‌کردن یک خرید مصرف‌شدنی. */
    fun consume(purchaseToken: String, callback: (BillingOutcome) -> Unit)

    /** آزادسازی منابع (اتصال، listenerها). */
    fun dispose()
}
