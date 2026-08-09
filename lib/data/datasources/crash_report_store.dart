import 'package:hive_flutter/hive_flutter.dart';

/// ────────────────────────────────────────────────────────────
/// 🛠️ فاز ۸: ذخیره‌سازی آفلاین خطاها (Crash Report Store)
///
/// خطاهای غیرمنتظره و لاگ‌های مهم بدون اینترنت در Hive ذخیره
/// می‌شوند تا والد بتواند در پنل والدین ببیند و برای دیباگ
/// (مثلاً ارسال دستی به توسعه‌دهنده) استفاده کند.
///
/// حداکثر ۵۰ ورودی آخر نگه داشته می‌شود (فایل دیسک سبک).
/// ────────────────────────────────────────────────────────────
class CrashReportStore {
  CrashReportStore._();

  static const String _boxName = 'crash_logs';
  static const int maxEntries = 50;

  static Box<dynamic>? _box;

  static Future<Box<dynamic>> _getBox() async {
    if (_box != null && _box!.isOpen) return _box!;
    final box = Hive.isBoxOpen(_boxName)
        ? Hive.box(_boxName)
        : await Hive.openBox(_boxName);
    _box = box;
    return box;
  }

  static Future<void> logError(
    String message, {
    String? stackTrace,
    String source = 'runtime',
  }) async {
    try {
      final box = await _getBox();
      final entry = <String, Object?>{
        'time': DateTime.now().toIso8601String(),
        'message': message.length > 500 ? message.substring(0, 500) : message,
        'stack': stackTrace == null
            ? ''
            : (stackTrace.length > 2000 ? stackTrace.substring(0, 2000) : stackTrace),
        'source': source,
      };
      await box.put(DateTime.now().microsecondsSinceEpoch.toString(), entry);

      // حذف ورودی‌های اضافه (فقط ۵۰ تای آخر می‌ماند)
      final keys = box.keys.toList()..sort();
      if (keys.length > maxEntries) {
        for (final key in keys.take(keys.length - maxEntries)) {
          await box.delete(key);
        }
      }
    } catch (_) {
      // ذخیره خطا هم نتوانست — بی‌صدا رد شو
    }
  }

  static Future<List<Map<String, Object?>>> getLogs() async {
    try {
      final box = await _getBox();
      final keys = box.keys.toList()..sort();
      final logs = <Map<String, Object?>>[];
      for (final key in keys.reversed) {
        final raw = box.get(key);
        if (raw is Map) {
          logs.add(Map<String, Object?>.from(raw));
        }
        if (logs.length >= maxEntries) break;
      }
      return logs;
    } catch (_) {
      return <Map<String, Object?>>[];
    }
  }

  static Future<void> clearLogs() async {
    try {
      final box = await _getBox();
      await box.clear();
    } catch (_) {
      // ignore
    }
  }
}
