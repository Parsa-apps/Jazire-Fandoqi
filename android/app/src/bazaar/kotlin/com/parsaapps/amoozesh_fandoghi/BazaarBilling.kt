package com.parsaapps.amoozesh_fandoghi

import android.app.Activity
import androidx.activity.result.ActivityResultRegistry
import io.flutter.embedding.android.FlutterFragmentActivity
import ir.cafebazaar.poolakey.Connection
import ir.cafebazaar.poolakey.Payment
import ir.cafebazaar.poolakey.callback.PurchaseCallback
import ir.cafebazaar.poolakey.config.PaymentConfiguration
import ir.cafebazaar.poolakey.config.SecurityCheck
import ir.cafebazaar.poolakey.request.PurchaseRequest

/**
 * 🏪 درگاه پرداخت کافه‌بازار (Poolakey) — فقط در flavor «bazaar».
 *
 * SDK مایکت حتی به classpath این بیلد اضافه نمی‌شود؛ پس APK بازار نه مجوز
 * پرداخت فروشگاه دیگر را دارد و نه کد آن را. تمام خرید/بازیابی/مصرف از
 * همان سرویس رسمی بازار انجام می‌شود.
 *
 * اتصال Poolakey asynchronous است. درخواست‌هایی که پیش از آماده‌شدن اتصال
 * برسند در صف می‌مانند و بعد از موفقیت/شکست اتصال یک‌بار جواب می‌گیرند؛
 * بنابراین اولین لمس دکمهٔ خرید همیشه یا صفحهٔ پرداخت را باز می‌کند یا پیام
 * روشن «اتصال برقرار نشد» می‌دهد، نه شکست بی‌دلیل.
 */
class BazaarBilling(
    private val activity: FlutterFragmentActivity,
    override val publicKey: String,
) : StoreBilling {

    private val receiptVerifier = StoreReceiptVerifier(
        activity.packageName, mapOf(StoreVendor.BAZAAR to publicKey),
    )

    private val payment: Payment? = publicKey.takeIf { it.isNotBlank() }?.let { key ->
        Payment(
            activity,
            PaymentConfiguration(localSecurityCheck = SecurityCheck.Enable(key)),
        )
    }

    val isConfigured: Boolean get() = payment != null

    private var connection: Connection? = null
    private var connected = false
    private var connecting = false
    private val waiting = ArrayDeque<(Boolean) -> Unit>()

    /**
     * اجرای عملیات فقط بعد از اتصال. [callback] با `true` یعنی اتصال آماده
     * است؛ با `false` یعنی Poolakey پیکربندی نشده یا اتصال شکست خورد.
     */
    private fun withConnection(callback: (Boolean) -> Unit) {
        val client = payment
        if (client == null) {
            callback(false)
            return
        }
        if (connected) {
            callback(true)
            return
        }
        waiting.addLast(callback)
        if (connecting) return
        connecting = true
        try {
            connection?.disconnect()
            connection = client.connect {
                connectionSucceed {
                    connected = true
                    connecting = false
                    drain(true)
                }
                connectionFailed {
                    connected = false
                    connecting = false
                    drain(false)
                }
                disconnected {
                    connected = false
                }
            }
        } catch (_: Exception) {
            connected = false
            connecting = false
            drain(false)
        }
    }

    private fun drain(ready: Boolean) {
        while (waiting.isNotEmpty()) {
            waiting.removeFirst().invoke(ready)
        }
    }

    private fun connectionFailedMessage() =
        if (payment == null) {
            "کلید عمومی فروشگاه پیکربندی نشده است"
        } else {
            "اتصال به فروشگاه برقرار نیست؛ دوباره تلاش کنید"
        }

    override fun purchase(
        _activity: Activity,
        registry: ActivityResultRegistry,
        productId: String,
        payload: String,
        callback: (BillingOutcome) -> Unit,
    ) {
        withConnection { ready ->
            val client = payment
            if (!ready || client == null) {
                callback(BillingOutcome.failure(connectionFailedMessage()))
                return@withConnection
            }
            val request = PurchaseRequest(productId = productId, payload = payload)
            val poolakeyCallback: PurchaseCallback.() -> Unit = {
                purchaseSucceed { info ->
                    if (info.productId != productId) {
                        callback(BillingOutcome.failure("شناسه محصول با رسید فروشگاه هم‌خوان نیست"))
                    } else {
                        callback(
                            receiptVerifier.verify(
                                StoreVendor.BAZAAR,
                                info.originalJson,
                                info.dataSignature,
                                productId,
                            )
                        )
                    }
                }
                purchaseCanceled { callback(BillingOutcome.failure("پرداخت لغو شد")) }
                purchaseFailed { callback(BillingOutcome.failure("پرداخت توسط فروشگاه تأیید نشد")) }
                failedToBeginFlow { callback(BillingOutcome.failure("شروع پرداخت ممکن نیست")) }
            }
            try {
                // registry همان ActivityResultRegistry میزبان Flutter است؛
                // Poolakey با آن Activity نتیجهٔ پرداخت بازار را می‌گیرد.
                client.purchaseProduct(registry, request, poolakeyCallback)
            } catch (_: Exception) {
                callback(BillingOutcome.failure("شروع پرداخت ممکن نیست"))
            }
        }
    }

    override fun restore(productId: String, callback: (BillingOutcome) -> Unit) {
        withConnection { ready ->
            val client = payment
            if (!ready || client == null) {
                callback(BillingOutcome.failure(connectionFailedMessage()))
                return@withConnection
            }
            try {
                client.getPurchasedProducts {
                    querySucceed { purchases ->
                        val active = purchases.firstOrNull { it.productId == productId }
                        if (active == null) {
                            callback(BillingOutcome.notOwned())
                        } else {
                            callback(
                                receiptVerifier.verify(
                                    StoreVendor.BAZAAR,
                                    active.originalJson,
                                    active.dataSignature,
                                    productId,
                                )
                            )
                        }
                    }
                    queryFailed { callback(BillingOutcome.failure("بازیابی خرید از فروشگاه انجام نشد")) }
                }
            } catch (_: Exception) {
                callback(BillingOutcome.failure("بازیابی خرید از فروشگاه انجام نشد"))
            }
        }
    }

    override fun consume(purchaseToken: String, callback: (BillingOutcome) -> Unit) {
        withConnection { ready ->
            val client = payment
            if (!ready || client == null) {
                callback(BillingOutcome.failure(connectionFailedMessage()))
                return@withConnection
            }
            try {
                client.consumeProduct(purchaseToken) {
                    consumeSucceed { callback(BillingOutcome.success(message = "خرید مصرف شد")) }
                    consumeFailed { callback(BillingOutcome.failure("مصرف خرید تأیید نشد")) }
                }
            } catch (_: Exception) {
                callback(BillingOutcome.failure("مصرف خرید تأیید نشد"))
            }
        }
    }

    override fun dispose() {
        connected = false
        connecting = false
        drain(false)
        connection?.disconnect()
        connection = null
    }
}
