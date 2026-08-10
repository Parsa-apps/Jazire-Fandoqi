import 'package:flutter/foundation.dart';

/// ────────────────────────────────────────────────────────────
/// ☁️ CLOUD SYNC SERVICE — سرویس وضعیت همگام‌سازی ابری
///
/// این اپ کاملاً آفلاین است و داده‌ها روی خود دستگاه ذخیره می‌شوند.
/// این سرویس یک stub آماده برای اتصال آینده به سرویس ابری است تا
/// ویجت‌های نشان‌دهندهٔ وضعیت (CloudSyncIndicator) بدون خطا
/// کامپایل شوند و در صورت فعال‌شدن سرویس واقعی، همان‌جا تکمیل شود.
///
/// وضعیت‌ها:
/// - isSyncing: در حال همگام‌سازی
/// - lastSyncTime: زمان آخرین همگام‌سازی موفق (یا null)
/// - lastSyncError: پیام خطای آخرین تلاش (یا null)
/// ────────────────────────────────────────────────────────────
class CloudSyncService extends ChangeNotifier {
  bool _isSyncing = false;
  DateTime? _lastSyncTime;
  String? _lastSyncError;

  /// آیا در حال همگام‌سازی هستیم؟
  bool get isSyncing => _isSyncing;

  /// زمان آخرین همگام‌سازی موفق — null اگر تاکنون انجام نشده باشد.
  DateTime? get lastSyncTime => _lastSyncTime;

  /// پیام خطای آخرین تلاش — null اگر خطایی نبوده باشد.
  String? get lastSyncError => _lastSyncError;

  /// شروع همگام‌سازی (در حال حاضر فقط وضعیت را به‌روز می‌کند؛
  /// اتصال واقعی ابری در فازهای بعدی به این‌جا اضافه می‌شود).
  Future<void> sync() async {
    _isSyncing = true;
    _lastSyncError = null;
    notifyListeners();
    try {
      // در نسخه آفلاین، همگام‌سازی محلی فوری موفق است.
      await Future<void>.delayed(const Duration(milliseconds: 300));
      _lastSyncTime = DateTime.now();
    } catch (error) {
      _lastSyncError = error.toString();
    } finally {
      _isSyncing = false;
      notifyListeners();
    }
  }

  /// بازنشانی خطا و وضعیت.
  void reset() {
    _isSyncing = false;
    _lastSyncError = null;
    notifyListeners();
  }
}
