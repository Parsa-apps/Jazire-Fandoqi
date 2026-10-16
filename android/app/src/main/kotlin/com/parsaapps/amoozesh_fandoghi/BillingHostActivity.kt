package com.parsaapps.amoozesh_fandoghi

import android.content.Intent
import android.content.pm.ApplicationInfo
import android.net.Uri
import android.os.Build
import android.view.WindowManager
import androidx.activity.result.contract.ActivityResultContracts
import io.flutter.embedding.android.FlutterFragmentActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel
import java.io.File
import java.util.UUID

/**
 * 🏪 میزبانِ مشترکِ فعالیت اندروید — تمام منطقِ **مستقل از فروشگاه**.
 *
 * این کلاس همان کاری را می‌کند که `MainActivity` قبلاً می‌کرد، با این تفاوت
 * که دیگر **هیچ SDK فروشگاهی** را نمی‌شناسد. درگاه پرداخت از طریق
 * [StoreBilling] و متد انتزاعی [createBilling] تزریق می‌شود و پیاده‌سازی
 * آن در source set همان flavor قرار دارد:
 *
 *  • `src/bazaar/kotlin/.../MainActivity.kt` → Poolakey (کافه‌بازار)
 *  • `src/myket/kotlin/.../MainActivity.kt`  → Myket Billing Client
 *
 * نتیجه: در آرتیفکت کافه‌بازار هیچ کلاس، سرویس، مجوز یا مسیر پرداختی از
 * مایکت وجود ندارد و برعکس. مسیریابی زمان‌اجرا (تشخیص نصب‌کنندهٔ
 * سیستم‌عامل) حذف شده است: **کانال ساخت** (`BuildConfig.STORE_CHANNEL`)
 * تنها مرجع فروشگاهِ این بیلد است.
 *
 * این کلاس باید `FlutterFragmentActivity` باشد (نه `FlutterActivity`) چون
 * `FlutterActivity` از `android.app.Activity` ارث می‌برد و
 * `ActivityResultRegistry` ندارد؛ در حالی که Poolakey برای باز کردن فلوی
 * پرداخت بازار به آن نیاز دارد.
 */
abstract class BillingHostActivity : FlutterFragmentActivity() {
    private val channelName = "kudake_iran/billing"
    private val backupChannelName = "kudake_iran/backup"
    private val fullVersionProductId = "full_version"
    private var purchaseInProgress = false
    private var pendingBackupResult: MethodChannel.Result? = null

    // ── نقطهٔ اتصال flavor ────────────────────────────────────────────────

    /**
     * درگاه پرداختِ این بیلد. تنها یکی وجود دارد و SDK رقیب در این
     * آرتیفکت حاضر نیست.
     */
    protected abstract fun createBilling(): StoreBilling

    /**
     * شناسهٔ فروشگاهِ این بیلد (`bazaar` یا `myket`).
     *
     * منبعِ قطعی، `BuildConfig.STORE_CHANNEL` است که در `productFlavors`
     * تعریف شده؛ همین مقدار به Dart هم داده می‌شود تا نام فروشگاه در UI
     * با بیلد هم‌خوان بماند.
     */
    protected abstract val storeId: String

    /** اینتنت صفحهٔ ثبت نظر/امتیاز در فروشگاهِ همین بیلد. */
    protected abstract fun buildStoreReviewIntent(): Intent

    /** اینتنت صفحهٔ اطلاعات برنامه در فروشگاهِ همین بیلد. */
    protected abstract fun buildStoreDetailsIntent(): Intent

    /** نشانی وبِ صفحهٔ برنامه در فروشگاهِ همین بیلد (پشتیبان). */
    protected abstract fun storeWebUrl(): String

    // ── چرخهٔ عمر درگاه ───────────────────────────────────────────────────

    private val billingDelegate = lazy(LazyThreadSafetyMode.NONE) { createBilling() }
    private val billing: StoreBilling by billingDelegate

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
                    "installerPackage" -> result.success(installerPackage())
                    "storeVendor" -> result.success(storeId)
                    "openStoreReview" -> openStoreReview(result)
                    // نام قدیمی، برای سازگاری با نسخه‌های قبلی Dart.
                    "openBazaarReview" -> openStoreReview(result)
                    "openStoreDetails" -> openStoreDetails(result)
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

    /** فقط درگاهِ همین بیلد وصل می‌شود؛ درگاه فروشگاه رقیب اصلاً وجود ندارد. */
    private fun connectStore() {
        billing.connect()
    }

    // ℹ️ پیامِ «این نسخه از فروشگاه رسمی نصب نشده است» که در نسخهٔ قبلی
    // برای حالت `StoreVendor.UNKNOWN` وجود داشت، دیگر لازم نیست: در هر
    // آرتیفکت فقط **یک** فروشگاه وجود دارد و آن فروشگاه همیشه معلوم است.
    // اگر اپ از فروشگاه نصب نشده باشد، خودِ SDK فروشگاه پیام روشن
    // «اتصال به فروشگاه برقرار نیست» می‌دهد.

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
        billing.purchase(this, productId, payload, reply)
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
        billing.consume(token, reply)
    }

    private fun restore(result: MethodChannel.Result) {
        if (isDebuggable()) {
            result.success(failure("خرید فعالی در سندباکس نیست"))
            return
        }
        val reply = singleReply(result)
        billing.restore(fullVersionProductId, reply)
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

    /** صفحهٔ امتیازدهی همان فروشگاهی که این بیلد برایش ساخته شده است. */
    private fun openStoreReview(result: MethodChannel.Result) {
        result.success(openStoreIntent(buildStoreReviewIntent()))
    }

    /**
     * صفحهٔ اطلاعات برنامه در فروشگاهِ همین بیلد.
     *
     * مایکت برای برنامه‌های درون‌پرداخت اجازهٔ لینک به وب‌سایت ناشر را
     * نمی‌دهد و اینتنت رسمی `myket://details?id=` را می‌خواهد:
     * https://myket.ir/kb/pages/open-application-page-in-myket/
     */
    private fun openStoreDetails(result: MethodChannel.Result) {
        result.success(openStoreIntent(buildStoreDetailsIntent()))
    }

    /**
     * باز کردن اینتنت فروشگاه؛ اگر اپ فروشگاه روی دستگاه نبود، صفحهٔ وبِ
     * همان فروشگاه باز می‌شود (وب‌سایت ناشر هرگز باز نمی‌شود).
     */
    private fun openStoreIntent(intent: Intent): Boolean {
        return try {
            startActivity(intent.addFlags(Intent.FLAG_ACTIVITY_NEW_TASK))
            true
        } catch (_: Exception) {
            try {
                startActivity(
                    Intent(Intent.ACTION_VIEW, Uri.parse(storeWebUrl())).apply {
                        addFlags(Intent.FLAG_ACTIVITY_NEW_TASK)
                    }
                )
                true
            } catch (_: Exception) {
                false
            }
        }
    }

    /**
     * بستهٔ نصب‌کنندهٔ اپ را از سیستم‌عامل می‌پرسد.
     *
     * این مقدار فقط **تشخیصی** است و مسیر پرداخت را تعیین نمی‌کند:
     * فروشگاهِ این بیلد همیشه از روی کانال ساخت معلوم است.
     */
    private fun installerPackage(): String = try {
        val pm = packageManager
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.R) {
            pm.getInstallSourceInfo(packageName).installingPackageName ?: ""
        } else {
            @Suppress("DEPRECATION")
            pm.getInstallerPackageName(packageName) ?: ""
        }
    } catch (_: Exception) {
        ""
    }

    private fun isDebuggable() = (applicationInfo.flags and ApplicationInfo.FLAG_DEBUGGABLE) != 0
    private fun success(token: String? = null, orderId: String? = null, message: String) = mapOf(
        "success" to true, "purchaseToken" to token, "orderId" to orderId, "message" to message
    )
    private fun failure(message: String) = mapOf("success" to false, "message" to message)

    override fun onDestroy() {
        if (billingDelegate.isInitialized()) {
            billing.dispose()
        }
        super.onDestroy()
    }
}
