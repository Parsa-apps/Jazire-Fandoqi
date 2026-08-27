package com.parsaapps.amoozesh_fandoghi

import android.content.Intent
import android.content.pm.ApplicationInfo
import android.net.Uri
import android.view.WindowManager
import androidx.activity.result.contract.ActivityResultContracts
import java.io.File
import io.flutter.embedding.android.FlutterFragmentActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel
import java.util.UUID

/** Native multi-store billing bridge (Cafe Bazaar + Myket).
 *
 * The app ships to several Iranian stores. Each artifact is built for a
 * specific store via a Gradle flavor, and [BuildConfig.STORE_CHANNEL] is the
 * authoritative store for that build ("myket" APK → Myket, "bazaar" AAB →
 * Bazaar). At runtime [StoreVendor.fromChannel] reads that channel and routes
 * every billing call to the matching gateway — Poolakey for Bazaar, Myket
 * Billing Client for Myket. OS installer detection ([StoreVendor.resolve]) is
 * kept only as a fallback for builds whose channel is unknown. The store name
 * is never shown to the user and is never chosen by hand.
 *
 * A release purchase is accepted only after the store SDK validates the RSA
 * signature of the receipt.
 *
 * This must stay a [FlutterFragmentActivity]: plain FlutterActivity extends
 * android.app.Activity and has no ActivityResultRegistry, which Poolakey needs
 * to launch Bazaar's payment flow.
 */
class MainActivity : FlutterFragmentActivity() {
    private val channelName = "kudake_iran/billing"
    private val backupChannelName = "kudake_iran/backup"
    private val fullVersionProductId = "full_version"
    private var purchaseInProgress = false
    private var pendingBackupResult: MethodChannel.Result? = null

    /**
     * فروشگاهِ این بیلد؛ یک‌بار محاسبه و کش می‌شود.
     *
     * منبعِ قطعی کانال ساخت (`BuildConfig.STORE_CHANNEL`) است: هر قطعهٔ
     * ارسالی به یک فروشگاه مشخص می‌رود (APKهای flavor «myket» → مایکت،
     * AABهای flavor «bazaar» → کافه‌بازار)، پس تشخیص زمان‌اجرا فقط به
     * عنوان fallback نگه داشته می‌شود. این کار جلوی مسدودشدن خرید را در
     * مواردی می‌گیرد که تشخیص نصب‌کننده مبهم می‌شود (مثلاً نصب از سوی
     * مکانیزمی که `installingPackageName` دقیقاً بستهٔ فروشگاه نیست، یا
     * دستگاهی که هر دو اپِ بازار و مایکت را دارد).
     */
    private val vendor: StoreVendor by lazy(LazyThreadSafetyMode.NONE) {
        StoreVendor.fromChannel(BuildConfig.STORE_CHANNEL)
            ?: StoreVendor.resolve(applicationContext)
    }

    private val bazaar: BazaarBilling by lazy(LazyThreadSafetyMode.NONE) {
        BazaarBilling(this, BuildConfig.BAZAAR_RSA_PUBLIC_KEY)
    }

    private val myket: MyketBilling by lazy(LazyThreadSafetyMode.NONE) {
        MyketBilling(applicationContext, BuildConfig.MYKET_RSA_PUBLIC_KEY)
    }

    private val backupPicker = registerForActivityResult(
        ActivityResultContracts.OpenDocument(),
    ) { uri ->
        val result = pendingBackupResult
        pendingBackupResult = null
        if (result != null) {
            if (uri == null) {
                result.success(null)
            } else {
                try {
                    val target = File(cacheDir, "kudake_import_${System.currentTimeMillis()}.parsa")
                    val input = contentResolver.openInputStream(uri)
                        ?: throw IllegalStateException("Unable to read selected backup")
                    input.use { stream ->
                        target.outputStream().use { output -> stream.copyTo(output) }
                    }
                    result.success(target.absolutePath)
                } catch (_: Exception) {
                    result.success(null)
                }
            }
        }
    }

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        connectStore()
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, channelName)
            .setMethodCallHandler { call, result ->
                when (call.method) {
                    "purchase" -> purchase(call.arguments as? Map<*, *>, result)
                    "consume" -> consume(call.arguments as? Map<*, *>, result)
                    "restore" -> restore(result)
                    // Flutter از این برای انتخاب متن/رفتار مناسب استفاده می‌کند.
                    "installerPackage" -> result.success(StoreVendor.installerPackage(applicationContext))
                    "storeVendor" -> result.success(vendor.name.lowercase())
                    "openStoreReview" -> openStoreReview(result)
                    // نام قدیمی، برای سازگاری با نسخه‌های قبلی Dart.
                    "openBazaarReview" -> openStoreReview(result)
                    else -> result.notImplemented()
                }
            }
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, backupChannelName)
            .setMethodCallHandler { call, result ->
                when (call.method) {
                    "pickBackupFile" -> {
                        if (pendingBackupResult != null) {
                            result.error("backup_busy", "یک انتخاب فایل دیگر در حال انجام است", null)
                        } else {
                            pendingBackupResult = result
                            backupPicker.launch(arrayOf("application/octet-stream", "application/json", "*/*"))
                        }
                    }
                    else -> result.notImplemented()
                }
            }
        // 🔐 Anti-tamper / anti-instrumentation bridge (root, Frida, Xposed,
        // emulator, debugger, APK signature). Consumed by
        // SecurityHardeningService at startup in release builds.
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, "kudake_iran/security")
            .setMethodCallHandler { call, result ->
                when (call.method) {
                    "snapshot" -> result.success(SecurityModule(applicationContext).snapshot())
                    else -> result.notImplemented()
                }
            }
        // 🔐 Keystore-backed storage for high-value values (premium grant,
        // parent PIN hash). Consumed by lib/core/security/secure_store.dart.
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, "kudake_iran/secure_store")
            .setMethodCallHandler { call, result ->
                val store = SecureStore(applicationContext)
                when (call.method) {
                    "write" -> {
                        val key = call.argument<String>("key") ?: ""
                        val value = call.argument<String>("value") ?: ""
                        store.write(key, value)
                        result.success(null)
                    }
                    "read" -> {
                        val key = call.argument<String>("key") ?: ""
                        result.success(store.read(key))
                    }
                    "delete" -> {
                        val key = call.argument<String>("key") ?: ""
                        store.delete(key)
                        result.success(null)
                    }
                    else -> result.notImplemented()
                }
            }
        // 🛡️ FLAG_SECURE window protection for parent PIN / paywall / backup
        // screens: no screenshots, no screen recording, blank recents preview.
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, "kudake_iran/privacy")
            .setMethodCallHandler { call, result ->
                when (call.method) {
                    "setSecureWindow" -> {
                        val secure = call.argument<Boolean>("secure") == true
                        if (secure) {
                            window.addFlags(WindowManager.LayoutParams.FLAG_SECURE)
                        } else {
                            window.clearFlags(WindowManager.LayoutParams.FLAG_SECURE)
                        }
                        result.success(null)
                    }
                    else -> result.notImplemented()
                }
            }
    }

    // نکته: درگاه مایکت برخلاف TrivialDrive گوگل، requestCode و
    // handleActivityResult ندارد؛ نتیجهٔ خرید را SDK خودش با یک
    // ResultReceiver داخلی به listener می‌رساند، پس نیازی به
    // override کردن onActivityResult نیست. (Poolakey/کافه‌بازار هم از
    // ActivityResultRegistry خودش استفاده می‌کند.)
    /** فقط درگاهِ فروشگاهِ نصب‌کننده متصل می‌شود، نه هر دو. */
    private fun connectStore() {
        if (vendor == StoreVendor.BAZAAR) bazaar.connect()
        // مایکت اتصال تنبل دارد و هنگام اولین خرید setup می‌شود.
    }

    /** پیام یکسان وقتی اپ از هیچ فروشگاه پشتیبانی‌شده‌ای نصب نشده است. */
    private fun noStoreFailure() = failure(
        "این نسخه از فروشگاه رسمی نصب نشده است؛ برای خرید، برنامه را از فروشگاهی که آن را دریافت کرده‌اید نصب کنید."
    )

    private fun purchase(arguments: Map<*, *>?, result: MethodChannel.Result) {
        val productId = arguments?.get("productId") as? String
        if (productId.isNullOrBlank()) {
            result.success(failure("شناسه محصول نامعتبر است"))
            return
        }
        if (isDebuggable()) {
            result.success(success("sandbox-token", "sandbox-order", "خرید آزمایشی"))
            return
        }
        if (purchaseInProgress) {
            result.success(failure("یک پرداخت دیگر در حال انجام است"))
            return
        }
        // نکته: پرچم `consumable` عمداً روی نوع آیتم اثر ندارد. در هر دو
        // فروشگاه، آیتم مصرف‌شدنی هم با همان ITEM_TYPE_INAPP خریداری و بعداً
        // با فراخوانی جداگانهٔ `consume` مصرف می‌شود. (رفتار قبلی هم همین بود.)
        val payload = UUID.randomUUID().toString()
        purchaseInProgress = true
        // پاسخ فقط یک‌بار به Flutter برمی‌گردد، حتی اگر SDK دوبار callback بزند.
        val reply = singleReply(result) { purchaseInProgress = false }
        when (vendor) {
            StoreVendor.BAZAAR ->
                bazaar.purchase(activityResultRegistry, productId, payload, reply)
            StoreVendor.MYKET ->
                myket.purchase(this, productId, payload, reply)
            StoreVendor.UNKNOWN -> {
                purchaseInProgress = false
                result.success(noStoreFailure())
            }
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
        val reply = singleReply(result)
        when (vendor) {
            StoreVendor.BAZAAR -> bazaar.consume(token, reply)
            StoreVendor.MYKET -> myket.consume(token, reply)
            StoreVendor.UNKNOWN -> result.success(noStoreFailure())
        }
    }

    private fun restore(result: MethodChannel.Result) {
        if (isDebuggable()) {
            result.success(failure("خرید فعالی در سندباکس نیست"))
            return
        }
        val reply = singleReply(result)
        when (vendor) {
            StoreVendor.BAZAAR -> bazaar.restore(fullVersionProductId, reply)
            StoreVendor.MYKET -> myket.restore(fullVersionProductId, reply)
            StoreVendor.UNKNOWN -> result.success(noStoreFailure())
        }
    }

    /**
     * SDKهای فروشگاه گاهی بیش از یک callback می‌زنند (مثلاً cancel بعد از
     * failure). MethodChannel.Result دوبار پاسخ‌دادن را با استثنا رد می‌کند،
     * پس فقط اولین پاسخ عبور داده می‌شود.
     */
    private fun singleReply(
        result: MethodChannel.Result,
        onFirst: () -> Unit = {},
    ): (BillingOutcome) -> Unit {
        var replied = false
        return { outcome ->
            if (!replied) {
                replied = true
                onFirst()
                runOnUiThread { result.success(outcome.toMap()) }
            }
        }
    }

    /** صفحهٔ امتیازدهی همان فروشگاهی که اپ از آن نصب شده است. */
    private fun openStoreReview(result: MethodChannel.Result) {
        val opened = when (vendor) {
            StoreVendor.BAZAAR -> openStoreIntent(
                deepLink = "bazaar://details?id=$packageName",
                storePackage = StoreVendor.BAZAAR_PACKAGE,
                webUrl = "https://cafebazaar.ir/app/$packageName",
            )
            StoreVendor.MYKET -> openStoreIntent(
                deepLink = "myket://comment?id=$packageName",
                storePackage = StoreVendor.MYKET_PACKAGE,
                webUrl = "https://myket.ir/app/$packageName",
            )
            StoreVendor.UNKNOWN -> false
        }
        result.success(opened)
    }

    private fun openStoreIntent(deepLink: String, storePackage: String, webUrl: String): Boolean {
        return try {
            startActivity(
                Intent(Intent.ACTION_EDIT, Uri.parse(deepLink)).apply {
                    setPackage(storePackage)
                    addFlags(Intent.FLAG_ACTIVITY_NEW_TASK)
                }
            )
            true
        } catch (_: Exception) {
            try {
                startActivity(
                    Intent(Intent.ACTION_VIEW, Uri.parse(webUrl)).apply {
                        addFlags(Intent.FLAG_ACTIVITY_NEW_TASK)
                    }
                )
                true
            } catch (_: Exception) {
                false
            }
        }
    }

    private fun isDebuggable() = (applicationInfo.flags and ApplicationInfo.FLAG_DEBUGGABLE) != 0
    private fun success(token: String? = null, orderId: String? = null, message: String) = mapOf(
        "success" to true, "purchaseToken" to token, "orderId" to orderId, "message" to message
    )
    private fun failure(message: String) = mapOf("success" to false, "message" to message)

    override fun onDestroy() {
        bazaar.dispose()
        myket.dispose()
        super.onDestroy()
    }
}
