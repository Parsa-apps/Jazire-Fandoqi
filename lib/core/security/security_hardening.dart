import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

import '../logger_service.dart';

/// نتیجهٔ بررسی امنیتی در نسخهٔ release.
///
/// سیاست (policy) در این کلاس متمرکز است:
///  - [tampered] (قطعی): بیلد دستکاری/جعل‌شده → اجرا مسدود می‌شود.
///  - [instrumented]: فریم‌ورک‌های هوک (Frida/Xposed) → فقط ثبت و هشدار.
///  - [rooted]/[emulator]/[customRom]: سیگنال‌های نرم → فقط اطلاع‌رسانی،
///    کاربر عادی هرگز بلاک نمی‌شود.
class SecurityAssessment {
  const SecurityAssessment({
    this.tampered = false,
    this.instrumented = false,
    this.rooted = false,
    this.customRom = false,
    this.emulator = false,
    this.signatureSha256 = '',
    this.expectedSignatureSha256 = '',
    this.installerPackage = '',
  });

  /// امضای APK نصب‌شده با امضای رسمی release نمی‌خواند، یا بیلد release
  /// به‌صورت debuggable ساخته شده، یا دیباگر وصل است، یا ماژول امنیتی
  /// از بیلد حذف شده است (نشانهٔ دستکاری).
  final bool tampered;

  /// Frida/Xposed در فرایند اپ شناسایی شده است.
  final bool instrumented;

  final bool rooted;
  final bool customRom;
  final bool emulator;

  /// SHA-256 (hex) امضای واقعی APK و امضای انتظاررفتهٔ ثبت‌شده در BuildConfig.
  final String signatureSha256;
  final String expectedSignatureSha256;

  /// بستهٔ نصب‌کننده (مثلاً com.farsitel.bazaar) — خالی یعنی sideload.
  final String installerPackage;
}

/// سرویس بررسی امنیتی زمان اجرا.
///
/// در حالت release هنگام راه‌اندازی فراخوانی می‌شود؛ اگر نتیجه [tampered]
/// باشد، اپ به صفحهٔ «نسخه قابل تأیید نیست» هدایت می‌شود. در حالت debug
/// این بررسی به‌صورت خودکار خاموش است تا توسعه‌دهنده اذیت نشود.
class SecurityHardeningService {
  SecurityHardeningService._();

  static const MethodChannel _channel = MethodChannel('kudake_iran/security');

  static SecurityAssessment? _assessment;

  static SecurityAssessment? get assessment => _assessment;

  /// آیا اپ از اجرا خودداری می‌کند؟
  static bool get blocked => _assessment?.tampered ?? false;

  static Future<SecurityAssessment> assess() async {
    if (_assessment != null) return _assessment!;
    if (!kReleaseMode) {
      _assessment = const SecurityAssessment();
      return _assessment!;
    }

    SecurityAssessment result;
    try {
      final raw = await _channel
          .invokeMethod<Map<Object?, Object?>>('snapshot')
          .timeout(const Duration(seconds: 6));

      final debuggable = raw?['debuggable'] == true;
      final debuggerConnected = raw?['debuggerConnected'] == true;
      // native هم خودش مقایسه را انجام می‌دهد؛ null یعنی «غیرفعال» (CI).
      final signatureMatch = raw?['signatureMatch'] != false;

      result = SecurityAssessment(
        tampered: debuggable || debuggerConnected || !signatureMatch,
        instrumented: raw?['fridaDetected'] == true ||
            raw?['xposedDetected'] == true,
        rooted: raw?['rooted'] == true,
        customRom: raw?['customRom'] == true,
        emulator: raw?['emulator'] == true,
        signatureSha256: raw?['signatureSha256']?.toString() ?? '',
        expectedSignatureSha256:
            raw?['expectedSignatureSha256']?.toString() ?? '',
        installerPackage: raw?['installerPackage']?.toString() ?? '',
      );
    } on MissingPluginException {
      // ماژول امنیتی در همهٔ بیلدهای رسمی کامپایل می‌شود؛ release ای که
      // جواب نمی‌دهد حذف/جایگزین شده است → بلاک (fail-closed).
      result = const SecurityAssessment(tampered: true);
    } on TimeoutException {
      result = const SecurityAssessment(tampered: true);
    } catch (_) {
      result = const SecurityAssessment(tampered: true);
    }

    _assessment = result;
    if (result.tampered) {
      LoggerService.e(
        'Security: tampered build detected '
        '(sig=${result.signatureSha256.isNotEmpty ? 'mismatch' : 'missing'})',
      );
    } else if (result.instrumented) {
      LoggerService.w('Security: instrumentation framework detected');
    }
    return result;
  }
}
