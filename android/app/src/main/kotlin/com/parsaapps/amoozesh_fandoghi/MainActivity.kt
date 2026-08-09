package com.parsaapps.amoozesh_fandoghi

import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

/**
 * 🛒 فاز ۷۱: پل پرداخت کافه‌بازار/مایکت (MethodChannel: kudake_iran/billing)
 *
 * این بریج فعلاً یک «استاب امن» است:
 *  - در debug: خرید به‌صورت sandbox موفق برمی‌گردد تا کل فلوی اپ تست شود
 *    (Dart side هم sandboxFallback دارد؛ اینجا فقط برای هماهنگی است).
 *  - در release: همیشه failure برمی‌گرداند تا هیچ‌وقت دسترسیِ پولیِ
 *    تأییدنشده فعال نشود.
 *
 * برای اتصال SDK واقعی (کافه‌بازار `com.cafebazaar.android:external` یا
 * مایکت)، باید داخل متدهای `purchase`/`consume`/`restore`، با همان
 * قرارداد Dart (doc لایه Dart را ببینید) تماس واقعی برقرار شود.
 */
class MainActivity : FlutterActivity() {
    private val channelName = "kudake_iran/billing"

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, channelName)
            .setMethodCallHandler { call, result ->
                when (call.method) {
                    "purchase" -> {
                        // TODO(فاز ۷۱ کامل): فراخوانی SDK کافه‌بازار/مایکت
                        // فعلاً فقط sandbox debug موفق است.
                        val isDebug = (applicationInfo.flags and
                                android.content.pm.ApplicationInfo.FLAG_DEBUGGABLE) != 0
                        if (isDebug) {
                            result.success(
                                mapOf(
                                    "success" to true,
                                    "purchaseToken" to "sandbox-token",
                                    "orderId" to "sandbox-order",
                                    "message" to "خرید آزمایشی (حالت سندباکس)"
                                )
                            )
                        } else {
                            result.success(
                                mapOf(
                                    "success" to false,
                                    "message" to "ماژول پرداخت نهایی هنوز متصل نشده است"
                                )
                            )
                        }
                    }
                    "consume" -> {
                        // در sandbox هیچ مصرفی لازم نیست؛ موفق برمی‌گردد.
                        result.success(
                            mapOf("success" to true, "message" to "consumed")
                        )
                    }
                    "restore" -> {
                        result.success(
                            mapOf(
                                "success" to false,
                                "message" to "هیچ اشتراک فعالی یافت نشد"
                            )
                        )
                    }
                    "openBazaarReview" -> {
                        try {
                            val intent = android.content.Intent(
                                android.content.Intent.ACTION_EDIT,
                                android.net.Uri.parse("bazaar://details?id=$packageName")
                            )
                            intent.setPackage("com.farsitel.bazaar")
                            intent.addFlags(android.content.Intent.FLAG_ACTIVITY_NEW_TASK)
                            startActivity(intent)
                            result.success(true)
                        } catch (e: Exception) {
                            try {
                                val fallback = android.content.Intent(
                                    android.content.Intent.ACTION_VIEW,
                                    android.net.Uri.parse("https://cafebazaar.ir/app/$packageName")
                                )
                                fallback.addFlags(android.content.Intent.FLAG_ACTIVITY_NEW_TASK)
                                startActivity(fallback)
                                result.success(true)
                            } catch (e2: Exception) {
                                result.success(false)
                            }
                        }
                    }
                    else -> result.notImplemented()
                }
            }
    }
}
