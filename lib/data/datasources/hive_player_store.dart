import 'package:hive_flutter/hive_flutter.dart';

/// ────────────────────────────────────────────────────────────
/// 💾 فاز ۴: دیتابیس آفلاین Hive با Migration خودکار
///
/// - `state_v1` = اسنپ‌شات کامل وضعیت بازیکن (نوشته‌شده از GameData)
/// - `schema_version` = نسخه اسکیمای دیتابیس؛ اگر بالاتر رفت،
///   نسخه‌های قدیمی با Migration تدریجی ارتقا می‌یابند
/// - روش خواندن: Hive اول، SharedPreferences (قدیمی) دوم به‌عنوان Fallback
/// ────────────────────────────────────────────────────────────
class HivePlayerStore {
  HivePlayerStore._();

  static const String boxName = 'playerBox';
  static const String _dataKey = 'state_v1';
  static const String _schemaVersionKey = 'schema_version';
  static const int schemaVersion = 1;

  static Box<dynamic>? _box;

  static Future<Box<dynamic>> _getBox() async {
    if (_box != null && _box!.isOpen) return _box!;
    final box = Hive.isBoxOpen(boxName)
        ? Hive.box(boxName)
        : await Hive.openBox(boxName);
    _box = box;
    return box;
  }

  /// اسنپ‌شات کامل وضعیت؛ در صورت نبود یا نسخه قدیمی `null` برمی‌گرداند
  /// تا فراخوان برود سراغ منبع قدیمی (SharedPreferences) و Migration کند.
  static Future<Map<String, Object?>?> readSnapshot() async {
    try {
      final box = await _getBox();
      final version = (box.get(_schemaVersionKey, defaultValue: 0) as num?)?.toInt() ?? 0;
      if (version < schemaVersion) return null;
      final raw = box.get(_dataKey);
      if (raw is! Map) return null;
      final result = <String, Object?>{};
      raw.forEach((key, value) {
        if (key is String) result[key] = value;
      });
      return result;
    } catch (_) {
      return null;
    }
  }

  /// نوشتن اسنپ‌شات + ثبت نسخه اسکیما.
  static Future<void> writeSnapshot(Map<String, Object?> snapshot) async {
    try {
      final box = await _getBox();
      await box.put(_dataKey, snapshot);
      await box.put(_schemaVersionKey, schemaVersion);
    } catch (_) {
      // ذخیره‌سازی best-effort است؛ بازی متوقف نمی‌شود.
    }
  }

  /// مقدار ساده (برای داده‌های غیر از وضعیت بازی مثل توکن اشتراک).
  static Future<Object?> readValue(String key) async {
    try {
      final box = await _getBox();
      return box.get(key);
    } catch (_) {
      return null;
    }
  }

  static Future<void> writeValue(String key, Object? value) async {
    try {
      final box = await _getBox();
      await box.put(key, value);
    } catch (_) {
      // best-effort
    }
  }
}
