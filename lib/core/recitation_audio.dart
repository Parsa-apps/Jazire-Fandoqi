import 'package:flutter/services.dart';

/// ═══════════════════════════════════════════════════════
/// 🎧 RECITATION AUDIO — بررسی وجود فایل‌های خوانش/تلاوت باندل‌شده
///
/// صفحه‌های شعر و قرآن خودشان یک `AudioPlayer` دارند (مثل پلیر
/// لالایی)؛ این هلپر تنها کاری که می‌کند جست‌وجوی واقعیِ وجود فایل
/// در asset bundle است تا قبل از `setAsset` خطای just_audio رخ ندهد.
///
/// قانون خط‌مشی:
///  • شعر → اگر فایل نبود، TTS فارسی مجاز است.
///  • قرآن → اگر فایل نبود، هیچ صدایی پخش نمی‌شود (هرگز TTS عربی).
/// ═══════════════════════════════════════════════════════
abstract final class RecitationAudio {
  /// کش نتیجهٔ بررسی تا در هر صفحه فقط یک‌بار rootBundle خوانده شود.
  static final Map<String, bool> _existsCache = <String, bool>{};

  /// آیا فایل صوتی داخل اپ باندل شده است؟
  static Future<bool> exists(String assetPath) async {
    final cached = _existsCache[assetPath];
    if (cached != null) return cached;
    try {
      await rootBundle.load(assetPath);
      _existsCache[assetPath] = true;
      return true;
    } catch (_) {
      _existsCache[assetPath] = false;
      return false;
    }
  }

  /// فقط برای تست‌ها پاک می‌شود.
  static void debugClearCache() => _existsCache.clear();
}
