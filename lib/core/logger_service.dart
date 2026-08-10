import 'package:flutter/foundation.dart';
import 'package:talker/talker.dart';

import '../data/datasources/crash_report_store.dart';

/// ────────────────────────────────────────────────────────────
/// 🛠️ فاز ۸: لاگر حرفه‌ای + گزارش کرش آفلاین
///
/// - talker برای کنسول و history درون‌حافظه
/// - خطاهای مهم به‌صورت خودکار در Hive (CrashReportStore) ذخیره می‌شوند
///   تا والد بدون اینترنت بتواند آن‌ها را ببیند
/// - پیشنهاد پریمیوم ۱۰: لاگ دو‌سطحی — در release فقط error ثبت می‌شود
///   (اطلاعات کودک هرگز لو نمی‌رود)، در debug همه‌چیز.
/// ────────────────────────────────────────────────────────────
class LoggerService {
  /// در release: کنسول خاموش، فقط خطاها در Hive می‌مانند.
  static final Talker talker = Talker(
    settings: TalkerSettings(
      useConsoleLogs: !kReleaseMode,
      useHistory: !kReleaseMode,
      maxHistoryItems: 100,
    ),
  );

  static void i(String message) {
    if (kReleaseMode) return;
    talker.info(message);
  }

  static void w(String message) {
    if (kReleaseMode) return;
    talker.warning(message);
  }

  static void e(
    String message, [
    dynamic error,
    StackTrace? stackTrace,
  ]) {
    talker.handle(error ?? message, stackTrace, message);
    // فاز ۸: ثبت دائمی آفلاین برای خطاهای runtime — در release هم باید بماند
    unawaitedPersist(message, stackTrace, source: 'runtime');
  }

  /// ثبت خطای غیرمنتظره سراسری (از FlutterError.onError).
  static void reportCrash(
    Object error,
    StackTrace stackTrace, {
    String source = 'flutter',
  }) {
    talker.handle(error, stackTrace);
    unawaitedPersist(error.toString(), stackTrace, source: source);
  }

  static void unawaitedPersist(
    String message,
    StackTrace? stackTrace, {
    required String source,
  }) {
    // fire-and-forget با catch داخلی — هرگز کرش جدید نمی‌سازد
    Future<void>(() async {
      await CrashReportStore.logError(
        message,
        stackTrace: stackTrace?.toString(),
        source: source,
      );
    });
  }

  static String getHistory() {
    // ⚠️ در talker 4.0.0 متد صحیح generateTextMessage است
    // (متد generateTextField در این نسخه وجود ندارد و بیلد را خراب می‌کند)
    return talker.history.map((e) => e.generateTextMessage()).join('\n');
  }

  /// آنالیتیکس حرفه‌ای — ثبت رویداد ساختاریافته برای تحلیل رفتار کودک
  static void event({
    required String event,
    Map<String, dynamic>? properties,
  }) {
    // در release رویدادهای آنالیتیکس هم در حافظه نمی‌مانند (حریم خصوصی)
    if (kReleaseMode) return;
    final propsStr = properties?.entries.map((e) => '${e.key}:${e.value}').join(',') ?? '';
    talker.info('[EVENT] $event | $propsStr');
    unawaitedPersist('[EVENT] $event | $propsStr', null, source: 'analytics');
  }
}
