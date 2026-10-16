package com.parsaapps.amoozesh_fandoghi

import android.content.Context
import android.view.View
import android.webkit.WebSettings
import android.webkit.WebView
import io.flutter.plugin.common.StandardMessageCodec
import io.flutter.plugin.platform.PlatformView
import io.flutter.plugin.platform.PlatformViewFactory

/**
 * یک PlatformView ساده که یک فایل HTML داخل assets فلاتر را در یک
 * WebView اندرویدی نمایش می‌دهد. این کار به اپ اجازه می‌دهد فایل‌های
 * HTML پیوست‌شده (مانند لایو والپیپر و اپ جادویی) را بخواند و روی
 * صفحات اصلی اعمال کند، بدون وابستگی به پکیج خارجی.
 */
class HtmlWebViewFactory(private val appContext: Context) :
    PlatformViewFactory(StandardMessageCodec.INSTANCE) {
    override fun create(context: Context, viewId: Int, args: Any?): PlatformView {
        val params = args as? Map<*, *>
        val assetPath = params?.get("assetPath") as? String ?: ""
        return HtmlWebView(appContext, assetPath)
    }
}

class HtmlWebView(private val appContext: Context, private val assetPath: String) : PlatformView {
    private val webView: WebView = WebView(appContext).apply {
        settings.javaScriptEnabled = true
        settings.domStorageEnabled = true
        settings.allowFileAccess = true
        settings.allowContentAccess = true
        settings.loadsImagesAutomatically = true
        settings.mixedContentMode = WebSettings.MIXED_CONTENT_ALWAYS_ALLOW
        settings.cacheMode = WebSettings.LOAD_DEFAULT
        setBackgroundColor(android.graphics.Color.TRANSPARENT)
        if (assetPath.isNotBlank()) {
            loadUrl("file:///android_asset/flutter_assets/$assetPath")
        }
    }

    override fun getView(): View = webView

    override fun dispose() {
        webView.stopLoading()
        webView.destroy()
    }
}
