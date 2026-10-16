package com.parsaapps.amoozesh_fandoghi

import androidx.activity.result.ActivityResultRegistry
import io.flutter.embedding.android.FlutterFragmentActivity
import ir.cafebazaar.poolakey.Connection
import ir.cafebazaar.poolakey.ConnectionState
import ir.cafebazaar.poolakey.Payment
import ir.cafebazaar.poolakey.callback.PurchaseCallback
import ir.cafebazaar.poolakey.config.PaymentConfiguration
import ir.cafebazaar.poolakey.config.SecurityCheck
import ir.cafebazaar.poolakey.request.PurchaseRequest

/**
 * 🏪 درگاه پرداخت کافه‌بازار (Poolakey).
 *
 * این فایل **فقط** در flavor «bazaar» کامپایل می‌شود؛ بنابراین کلاس‌های
 * `ir.cafebazaar.poolakey.*` فقط در آرتیفکت کافه‌بازار وجود دارند و در
 * آرتیفکت مایکت اصلاً حاضر نیستند.
 *
 * رفتار خرید نسبت به نسخهٔ قبلی **عیناً حفظ شده است**: خرید release فقط
 * بعد از تأیید امضای RSA توسط Poolakey پذیرفته می‌شود.
 */
class BazaarBilling(
    private val activity: FlutterFragmentActivity,
    publicKey: String,
) : StoreBilling {
    private var connection: Connection? = null

    private val payment: Payment? = publicKey.takeIf { it.isNotBlank() }?.let { key ->
        Payment(
            activity,
            PaymentConfiguration(localSecurityCheck = SecurityCheck.Enable(key)),
        )
    }

    val isConfigured: Boolean get() = payment != null

    override fun connect() {
        connection?.disconnect()
        connection = payment?.connect { /* وضعیت اتصال هنگام نیاز خوانده می‌شود */ }
    }

    private fun availablePayment(callback: (BillingOutcome) -> Unit): Payment? {
        val client = payment
        if (client == null) {
            callback(BillingOutcome.failure("کلید عمومی فروشگاه پیکربندی نشده است"))
            return null
        }
        if (connection?.getState() != ConnectionState.Connected) {
            connect()
            callback(BillingOutcome.failure("اتصال به فروشگاه برقرار نیست؛ دوباره تلاش کنید"))
            return null
        }
        return client
    }

    override fun purchase(
        activity: FlutterFragmentActivity,
        productId: String,
        payload: String,
        callback: (BillingOutcome) -> Unit,
    ) {
        val client = availablePayment(callback) ?: return
        val request = PurchaseRequest(productId = productId, payload = payload)
        val poolakeyCallback: PurchaseCallback.() -> Unit = {
            purchaseSucceed { info ->
                if (info.productId != productId) {
                    callback(BillingOutcome.failure("شناسه محصول با رسید فروشگاه هم‌خوان نیست"))
                } else {
                    callback(
                        BillingOutcome.success(
                            token = info.purchaseToken,
                            orderId = info.orderId,
                            message = "پرداخت تأیید شد",
                        )
                    )
                }
            }
            purchaseCanceled { callback(BillingOutcome.failure("پرداخت لغو شد")) }
            purchaseFailed { callback(BillingOutcome.failure("پرداخت توسط فروشگاه تأیید نشد")) }
            failedToBeginFlow { callback(BillingOutcome.failure("شروع پرداخت ممکن نیست")) }
        }
        // Poolakey برای باز کردن فلوی پرداخت بازار به ActivityResultRegistry
        // فعالیت میزبان نیاز دارد (به همین دلیل میزبان FlutterFragmentActivity است).
        client.purchaseProduct(activity.activityResultRegistry, request, poolakeyCallback)
    }

    override fun restore(productId: String, callback: (BillingOutcome) -> Unit) {
        val client = availablePayment(callback) ?: return
        client.getPurchasedProducts {
            querySucceed { purchases ->
                val active = purchases.firstOrNull { it.productId == productId }
                if (active == null) {
                    callback(BillingOutcome.failure("خرید نسخه کامل یافت نشد"))
                } else {
                    callback(
                        BillingOutcome.success(
                            token = active.purchaseToken,
                            orderId = active.orderId,
                            message = "خرید بازیابی شد",
                        )
                    )
                }
            }
            queryFailed { callback(BillingOutcome.failure("بازیابی خرید از فروشگاه انجام نشد")) }
        }
    }

    override fun consume(purchaseToken: String, callback: (BillingOutcome) -> Unit) {
        val client = availablePayment(callback) ?: return
        client.consumeProduct(purchaseToken) {
            consumeSucceed { callback(BillingOutcome.success(message = "خرید مصرف شد")) }
            consumeFailed { callback(BillingOutcome.failure("مصرف خرید تأیید نشد")) }
        }
    }

    override fun dispose() {
        connection?.disconnect()
        connection = null
    }
}
