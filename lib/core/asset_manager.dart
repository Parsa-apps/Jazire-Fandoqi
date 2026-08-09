import 'package:flutter/material.dart';

/// ────────────────────────────────────────────────────────────
/// 🖼️ فاز ۵: سیستم Asset Manager حرفه‌ای
///
/// - لود تنبل (Lazy): هیچ تصویری پیش از نیاز decode نمی‌شود
/// - کش حافظه با بودجه محدود (LRU ساده): برای گوشی‌های ۱GB RAM
/// - `filterQuality` قابل تنظیم: در دستگاه ضعیف `low` (سریع‌تر، کم‌مصرف‌تر)
/// - پشتیبانی از «ریزنس» (scale) برای حفظ شارپ‌نس در صفحه‌های بزرگ
///
/// ⚠️ نکته مهندسی: Flutter موتور (Skia/Impeller) در نسخه 3.24 از دیکد
/// AVIF پشتیبانی نمی‌کند، بنابراین فرمت پایه WebP بهینه‌شده باقی می‌ماند؛
/// بهینه‌سازی واقعی از طریق lazy + cache + filterQuality انجام می‌شود.
/// ────────────────────────────────────────────────────────────
class AssetManager {
  AssetManager._();

  static const String illustrationsPath = 'assets/illustrations/';
  static const String mascotPath = 'assets/mascot/';
  static const String premiumPath = 'assets/premium/';

  /// بودجه کش حافظه (تعداد ورودی). عدد پایین = گوشی ضعیف روان‌تر.
  static const int _maxCacheEntries = 24;

  /// کیفیت فیلتر پیش‌فرض. در دستگاه‌های ضعیف روی `low` تنظیم کنید
  /// (می‌تواند از `AssetManager.filterQuality = FilterQuality.low`).
  static FilterQuality filterQuality = FilterQuality.medium;

  /// نگاشت نام → زمان آخرین استفاده برای حذف LRU.
  static final Map<String, ImageProvider> _cache = <String, ImageProvider>{};
  static final Map<String, int> _lastUsed = <String, int>{};
  static int _clock = 0;

  /// مسیر واقعی asset را برمی‌گرداند (پشتیبانی از زیرپوشه‌ها).
  static String _resolvePath(String name) {
    if (name.contains('/')) return name;
    return '$illustrationsPath$name';
  }

  static ImageProvider getImage(String name) {
    final key = name;
    final cached = _cache[key];
    if (cached != null) {
      _lastUsed[key] = ++_clock;
      return cached;
    }

    final provider = AssetImage(_resolvePath(name));
    _cache[key] = provider;
    _lastUsed[key] = ++_clock;
    _evictIfNeeded();
    return provider;
  }

  /// حذف قدیمی‌ترین ورودی‌ها وقتی کش از بودجه رد می‌شود.
  static void _evictIfNeeded() {
    while (_cache.length > _maxCacheEntries) {
      String? oldestKey;
      var oldestTime = 1 << 30;
      _lastUsed.forEach((key, time) {
        if (time < oldestTime) {
          oldestTime = time;
          oldestKey = key;
        }
      });
      if (oldestKey == null) break;
      _cache.remove(oldestKey);
      _lastUsed.remove(oldestKey);
    }
  }

  static void precache(BuildContext context, List<String> names) {
    for (final name in names) {
      precacheImage(getImage(name), context);
    }
  }

  static void clearCache() {
    _cache.clear();
    _lastUsed.clear();
  }
}

/// یک wrapper امن دور [Image] با کش [AssetManager]، فید fade-in،
/// حالت خطا و فیلتر کیفیت سازگار با گوشی ضعیف.
class FandoghiImage extends StatelessWidget {
  final String name;
  final double? width;
  final double? height;
  final BoxFit fit;
  final FilterQuality? quality;
  final Alignment alignment;

  const FandoghiImage(
    this.name, {
    super.key,
    this.width,
    this.height,
    this.fit = BoxFit.contain,
    this.quality,
    this.alignment = Alignment.center,
  });

  @override
  Widget build(BuildContext context) {
    return Image(
      image: AssetManager.getImage(name),
      width: width,
      height: height,
      fit: fit,
      alignment: alignment,
      filterQuality: quality ?? AssetManager.filterQuality,
      errorBuilder: (context, error, stackTrace) => Container(
        width: width,
        height: height,
        color: Colors.grey[200],
        alignment: Alignment.center,
        child: const Icon(Icons.broken_image, color: Colors.grey),
      ),
      frameBuilder: (context, child, frame, wasSynchronouslyLoaded) {
        if (wasSynchronouslyLoaded) return child;
        return AnimatedOpacity(
          opacity: frame == null ? 0 : 1,
          duration: const Duration(milliseconds: 400),
          curve: Curves.easeOut,
          child: child,
        );
      },
    );
  }
}

/// کاشی تزئینی کشیده‌شده (بدون نیاز به فایل تصویر) برای پس‌زمینه‌ها —
/// صفر هزینه decode.
class DecorativePainterTile extends StatelessWidget {
  final Color color;
  final double size;

  const DecorativePainterTile({
    super.key,
    required this.color,
    this.size = 24,
  });

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      size: Size.square(size),
      painter: _DotPainter(color),
    );
  }
}

class _DotPainter extends CustomPainter {
  final Color color;
  _DotPainter(this.color);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = color;
    final r = size.width / 2;
    canvas.drawCircle(Offset(r, r), r * 0.85, paint);
  }

  @override
  bool shouldRepaint(_DotPainter oldDelegate) => oldDelegate.color != color;
}

/// نسخه آفلاین-امن از [Image.asset] که فقط وقتی asset واقعاً در
/// pubspec تعریف شده باشد render می‌کند؛ در غیر این صورت placeholder.
class SafeAssetImage extends StatelessWidget {
  final String path;
  final double? width;
  final double? height;
  final BoxFit fit;

  const SafeAssetImage({
    super.key,
    required this.path,
    this.width,
    this.height,
    this.fit = BoxFit.cover,
  });

  @override
  Widget build(BuildContext context) {
    return Image.asset(
      path,
      width: width,
      height: height,
      fit: fit,
      filterQuality: AssetManager.filterQuality,
      errorBuilder: (context, error, stackTrace) => Container(
        width: width,
        height: height,
        color: const Color(0xFFE8EAF6),
        alignment: Alignment.center,
        child: const Icon(Icons.image_not_supported_outlined, color: Colors.grey),
      ),
    );
  }
}

/// راهنمای مصرف حافظه تصویر در گوشی ۱GB RAM (برای دیباگ).
class AssetMemoryDebug {
  AssetMemoryDebug._();

  static int get cacheEntries => AssetManager._cache.length;

  static String summary() {
    final entries = cacheEntries;
    final estimated = entries * 512 * 512 * 4; // تقریب خام: 512x512 RGBA
    final kb = (estimated / 1024).round();
    return 'assets cached: $entries (~$kb KB raw)';
  }

  /// برای افزودن به گزارش والدین در فاز ۹۵.
  static String toJsonString() =>
      '{"cached_assets":${AssetManager._cache.length}}';
}
