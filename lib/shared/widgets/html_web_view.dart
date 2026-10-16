import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// یک ویجت سبک برای نمایش یک فایل HTML از assets داخل اپ.
///
/// روی اندروید از یک PlatformView (WebView بومی) استفاده می‌کند تا
/// فایل‌های HTML پیوست‌شده (لایو والپیپر فوق حرفه‌ای و اپلیکیشن
/// جادویی حیرت‌انگیز) بدون وابستگی به پکیج خارجی خوانده و روی
/// صفحات اصلی اعمال شوند. روی سایر پلتفرم‌ها یک جایگزین خالی برمی‌گرداند.
class HtmlWebView extends StatelessWidget {
  const HtmlWebView({
    super.key,
    required this.assetPath,
  });

  /// مسیر asset نسبت به ریشهٔ پروژه، مثلاً `assets/web/live_wallpaper.html`.
  final String assetPath;

  @override
  Widget build(BuildContext context) {
    if (defaultTargetPlatform != TargetPlatform.android) {
      return const SizedBox.shrink();
    }
    return AndroidView(
      viewType: 'html_webview',
      creationParams: <String, dynamic>{'assetPath': assetPath},
      creationParamsCodec: const StandardMessageCodec(),
    );
  }
}
