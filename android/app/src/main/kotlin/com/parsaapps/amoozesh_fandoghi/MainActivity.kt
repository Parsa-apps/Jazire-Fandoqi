package com.parsaapps.amoozesh_fandoghi

import android.content.Intent
import android.content.pm.ApplicationInfo
import android.net.Uri
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel
import ir.cafebazaar.poolakey.Connection
import ir.cafebazaar.poolakey.ConnectionState
import ir.cafebazaar.poolakey.Payment
import ir.cafebazaar.poolakey.callback.PurchaseQueryCallback
import ir.cafebazaar.poolakey.config.PaymentConfiguration
import ir.cafebazaar.poolakey.config.SecurityCheck
import ir.cafebazaar.poolakey.request.PurchaseRequest
import java.util.UUID

/** Native Cafe Bazaar billing bridge. Product IDs are owned by the store dashboard.
 * A release purchase is accepted only after Poolakey's RSA signature validation.
 */
class MainActivity : FlutterActivity() {
    private val channelName = "kudake_iran/billing"
    private var paymentConnection: Connection? = null
    private var purchaseInProgress = false

    private val payment: Payment? by lazy(LazyThreadSafetyMode.NONE) {
        BuildConfig.BAZAAR_RSA_PUBLIC_KEY.takeIf { it.isNotBlank() }?.let { publicKey ->
            Payment(this, PaymentConfiguration(localSecurityCheck = SecurityCheck.Enable(publicKey)))
        }
    }

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        connectBazaar()
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, channelName)
            .setMethodCallHandler { call, result ->
                when (call.method) {
                    "purchase" -> purchase(call.arguments as? Map<*, *>, result)
                    "consume" -> consume(call.arguments as? Map<*, *>, result)
                    "restore" -> restore(result)
                    "openBazaarReview" -> openBazaarReview(result)
                    else -> result.notImplemented()
                }
            }
    }

    private fun connectBazaar() {
        paymentConnection?.disconnect()
        paymentConnection = payment?.connect { /* callbacks expose connection state when needed */ }
    }

    private fun purchase(arguments: Map<*, *>?, result: MethodChannel.Result) {
        val productId = arguments?.get("productId") as? String
        val consumable = arguments?.get("consumable") as? Boolean ?: false
        if (productId.isNullOrBlank()) {
            result.success(failure("شناسه محصول نامعتبر است"))
            return
        }
        if (isDebuggable()) {
            result.success(success("sandbox-token", "sandbox-order", "خرید آزمایشی"))
            return
        }
        val client = availablePayment(result) ?: return
        if (purchaseInProgress) {
            result.success(failure("یک پرداخت دیگر در حال انجام است"))
            return
        }
        purchaseInProgress = true
        val request = PurchaseRequest(productId = productId, payload = UUID.randomUUID().toString())
        val callback: ir.cafebazaar.poolakey.callback.PurchaseCallback.() -> Unit = {
            purchaseSucceed { info ->
                purchaseInProgress = false
                result.success(success(info.purchaseToken, info.orderId, "پرداخت تأیید شد"))
            }
            purchaseCanceled {
                purchaseInProgress = false
                result.success(failure("پرداخت لغو شد"))
            }
            purchaseFailed {
                purchaseInProgress = false
                result.success(failure("پرداخت توسط استور تأیید نشد"))
            }
            failedToBeginFlow {
                purchaseInProgress = false
                result.success(failure("شروع پرداخت ممکن نیست"))
            }
        }
        if (consumable) {
            client.purchaseProduct(activityResultRegistry, request, callback)
        } else {
            client.purchaseProduct(activityResultRegistry, request, callback)
        }
    }

    private fun consume(arguments: Map<*, *>?, result: MethodChannel.Result) {
        val token = arguments?.get("purchaseToken") as? String
        if (token.isNullOrBlank()) {
            result.success(failure("توکن خرید نامعتبر است"))
            return
        }
        if (isDebuggable()) {
            result.success(success(message = "مصرف آزمایشی انجام شد"))
            return
        }
        val client = availablePayment(result) ?: return
        client.consumeProduct(token) {
            consumeSucceed { result.success(success(message = "خرید مصرف شد")) }
            consumeFailed { result.success(failure("مصرف خرید تأیید نشد")) }
        }
    }

    private fun restore(result: MethodChannel.Result) {
        if (isDebuggable()) {
            result.success(failure("خرید فعالی در سندباکس نیست"))
            return
        }
        val client = availablePayment(result) ?: return
        client.getPurchasedProducts(queryCallback(result))
    }

    private fun queryCallback(result: MethodChannel.Result): PurchaseQueryCallback.() -> Unit = {
        querySucceed { purchases ->
            val active = purchases.firstOrNull()
            if (active == null) result.success(failure("اشتراک فعالی یافت نشد"))
            else result.success(success(active.purchaseToken, active.orderId, "اشتراک بازیابی شد"))
        }
        queryFailed { result.success(failure("بازیابی خرید از استور انجام نشد")) }
    }

    private fun availablePayment(result: MethodChannel.Result): Payment? {
        val client = payment
        if (client == null) {
            result.success(failure("کلید عمومی کافه‌بازار پیکربندی نشده است"))
            return null
        }
        if (paymentConnection?.getState() != ConnectionState.Connected) {
            connectBazaar()
            result.success(failure("اتصال به کافه‌بازار برقرار نیست؛ دوباره تلاش کنید"))
            return null
        }
        return client
    }

    private fun openBazaarReview(result: MethodChannel.Result) {
        try {
            startActivity(Intent(Intent.ACTION_EDIT, Uri.parse("bazaar://details?id=$packageName")).apply {
                setPackage("com.farsitel.bazaar")
                addFlags(Intent.FLAG_ACTIVITY_NEW_TASK)
            })
            result.success(true)
        } catch (_: Exception) {
            try {
                startActivity(Intent(Intent.ACTION_VIEW, Uri.parse("https://cafebazaar.ir/app/$packageName")).apply {
                    addFlags(Intent.FLAG_ACTIVITY_NEW_TASK)
                })
                result.success(true)
            } catch (_: Exception) { result.success(false) }
        }
    }

    private fun isDebuggable() = (applicationInfo.flags and ApplicationInfo.FLAG_DEBUGGABLE) != 0
    private fun success(token: String? = null, orderId: String? = null, message: String) = mapOf(
        "success" to true, "purchaseToken" to token, "orderId" to orderId, "message" to message
    )
    private fun failure(message: String) = mapOf("success" to false, "message" to message)

    override fun onDestroy() {
        paymentConnection?.disconnect()
        super.onDestroy()
    }
}
