package com.parsaapps.amoozesh_fandoghi

import android.app.Activity
import android.content.Context
import ir.myket.billingclient.IabHelper
import ir.myket.billingclient.util.IabResult
import ir.myket.billingclient.util.Purchase

/**
 * 🏪 درگاه پرداخت مایکت.
 *
 * هم‌شکلِ [BazaarBilling] عمل می‌کند تا [MainActivity] بدون دانستن نام
 * فروشگاه فقط یکی از این دو را صدا بزند.
 *
 * نکتهٔ مهم امنیتی: کلید عمومی RSA در سازندهٔ [IabHelper] داده می‌شود و
 * خود SDK امضای رسید را محلی بررسی می‌کند. اگر کلید خالی باشد، پرداخت
 * راه‌اندازی نمی‌شود (مثل رفتار Poolakey در سمت کافه‌بازار).
 */
class MyketBilling(context: Context, private val publicKey: String) {

    private var helper: IabHelper? = null
    private var setupDone = false
    private var setupFailed = false

    val isConfigured: Boolean get() = publicKey.isNotBlank()

    init {
        if (isConfigured) {
            helper = IabHelper(context, publicKey).apply {
                enableDebugLogging(false)
            }
        }
    }

    /** اتصال تنبل: فقط یک‌بار setup می‌شود و نتیجه کش می‌ماند. */
    private fun ensureSetup(onReady: (Boolean) -> Unit) {
        val client = helper
        if (client == null) {
            onReady(false)
            return
        }
        if (setupDone) {
            onReady(true)
            return
        }
        if (setupFailed) {
            onReady(false)
            return
        }
        try {
            client.startSetup { result: IabResult ->
                setupDone = result.isSuccess
                setupFailed = !result.isSuccess
                onReady(result.isSuccess)
            }
        } catch (_: Exception) {
            setupFailed = true
            onReady(false)
        }
    }

    fun purchase(
        activity: Activity,
        productId: String,
        payload: String,
        callback: (BillingOutcome) -> Unit,
    ) {
        ensureSetup { ready ->
            if (!ready) {
                callback(BillingOutcome.failure("اتصال به فروشگاه برقرار نیست؛ دوباره تلاش کنید"))
                return@ensureSetup
            }
            try {
                helper?.launchPurchaseFlow(
                    activity,
                    productId,
                    IabHelper.ITEM_TYPE_INAPP,
                    { result: IabResult, purchase: Purchase? ->
                        when {
                            result.isSuccess && purchase != null -> {
                                if (purchase.sku != productId) {
                                    callback(BillingOutcome.failure("شناسه محصول با رسید فروشگاه هم‌خوان نیست"))
                                } else {
                                    callback(
                                        BillingOutcome.success(
                                            token = purchase.token,
                                            orderId = purchase.orderId,
                                            message = "پرداخت تأیید شد",
                                        )
                                    )
                                }
                            }
                            result.response == IabHelper.IABHELPER_USER_CANCELLED ||
                                result.response == IabHelper.BILLING_RESPONSE_RESULT_USER_CANCELED ->
                                callback(BillingOutcome.failure("پرداخت لغو شد"))
                            result.response == IabHelper.BILLING_RESPONSE_RESULT_ITEM_ALREADY_OWNED ->
                                // قبلاً خریده؛ مسیر درست «بازیابی خرید» است.
                                callback(BillingOutcome.failure("این محصول قبلاً خریداری شده؛ «بازیابی خرید قبلی» را بزنید"))
                            result.response == IabHelper.IABHELPER_VERIFICATION_FAILED ->
                                callback(BillingOutcome.failure("امضای رسید خرید معتبر نیست"))
                            else ->
                                callback(BillingOutcome.failure("پرداخت توسط فروشگاه تأیید نشد"))
                        }
                    },
                    payload,
                )
            } catch (_: Exception) {
                callback(BillingOutcome.failure("شروع پرداخت ممکن نیست"))
            }
        }
    }

    fun restore(productId: String, callback: (BillingOutcome) -> Unit) {
        ensureSetup { ready ->
            if (!ready) {
                callback(BillingOutcome.failure("اتصال به فروشگاه برقرار نیست؛ دوباره تلاش کنید"))
                return@ensureSetup
            }
            try {
                helper?.queryInventoryAsync(false, null) { result, inventory ->
                    if (!result.isSuccess || inventory == null) {
                        callback(BillingOutcome.failure("بازیابی خرید از فروشگاه انجام نشد"))
                        return@queryInventoryAsync
                    }
                    val purchase = inventory.getPurchase(productId)
                    if (purchase == null) {
                        callback(BillingOutcome.failure("خرید نسخه کامل یافت نشد"))
                    } else {
                        callback(
                            BillingOutcome.success(
                                token = purchase.token,
                                orderId = purchase.orderId,
                                message = "خرید بازیابی شد",
                            )
                        )
                    }
                }
            } catch (_: Exception) {
                callback(BillingOutcome.failure("بازیابی خرید از فروشگاه انجام نشد"))
            }
        }
    }

    fun consume(purchaseToken: String, callback: (BillingOutcome) -> Unit) {
        ensureSetup { ready ->
            if (!ready) {
                callback(BillingOutcome.failure("اتصال به فروشگاه برقرار نیست؛ دوباره تلاش کنید"))
                return@ensureSetup
            }
            try {
                // Myket فقط شیء Purchase را مصرف می‌کند، پس اول از انبار پیدایش می‌کنیم.
                helper?.queryInventoryAsync(false, null) { result, inventory ->
                    val target = inventory
                        ?.allPurchases
                        ?.firstOrNull { it.token == purchaseToken }
                    if (!result.isSuccess || target == null) {
                        callback(BillingOutcome.failure("مصرف خرید تأیید نشد"))
                        return@queryInventoryAsync
                    }
                    helper?.consumeAsync(target) { _, consumeResult ->
                        if (consumeResult.isSuccess) {
                            callback(BillingOutcome.success(message = "خرید مصرف شد"))
                        } else {
                            callback(BillingOutcome.failure("مصرف خرید تأیید نشد"))
                        }
                    }
                }
            } catch (_: Exception) {
                callback(BillingOutcome.failure("مصرف خرید تأیید نشد"))
            }
        }
    }

    fun dispose() {
        try {
            helper?.dispose()
        } catch (_: Exception) {
            // اتصال ممکن است قبلاً بسته شده باشد
        }
        helper = null
        setupDone = false
    }
}
