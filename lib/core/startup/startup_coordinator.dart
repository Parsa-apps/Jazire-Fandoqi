import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/foundation.dart';
import '../../data/datasources/hive_player_store.dart';
import '../fandoghi_coach.dart';
import '../game_data.dart';
import '../growth/growth_store.dart';
import '../logger_service.dart';
import '../security/security_hardening.dart';

/// یک مرحلهٔ واقعی از آماده‌سازی برنامه.
///
/// [weight] سهم این مرحله از نوار پیشرفت است؛ مجموع وزن‌ها ۱ می‌شود، پس
/// درصدِ نمایش‌داده‌شده همان درصدِ کارِ انجام‌شده است، نه یک عدد تزئینی.
class StartupStep {
  const StartupStep({
    required this.id,
    required this.weight,
    required this.run,
    this.timeout = const Duration(seconds: 6),
    this.onFailure,
  });

  final String id;
  final double weight;
  final Future<void> Function() run;
  final Duration timeout;

  /// مسیر جایگزین وقتی مرحله شکست می‌خورد (مثلاً حافظهٔ درون‌برنامه‌ای).
  /// هرگز باعث توقف کودک روی صفحهٔ بارگذاری نمی‌شود.
  final void Function(Object error, StackTrace stack)? onFailure;
}

/// ═══════════════════════════════════════════════════════════════
/// 🚀 StartupCoordinator — پیشرفتِ واقعیِ آماده‌سازی برنامه
///
/// پیش از این، همهٔ کارهای سنگین در `main()` و *قبل از* `runApp` انجام
/// می‌شد؛ یعنی کاربر تا پایان آن‌ها فقط اسپلش سیستمی را می‌دید و
/// انیمیشن آغازین تازه بعد از آن شروع می‌شد. حالا اولین فریم فوراً
/// نمایش داده می‌شود و همین مراحل، پشت صحنهٔ اسپلش سینمایی اجرا
/// می‌شوند و نوار پیشرفت دقیقاً به آن‌ها متصل است.
///
/// • هر مرحله سقف زمانی دارد؛ خطا به «حالت ایمن» تبدیل می‌شود، نه توقف.
/// • بررسی امنیتی هم‌زمان با بقیه اجرا می‌شود، ولی تا مشخص‌نشدن نتیجه
///   اجازهٔ ورود به برنامه داده نمی‌شود (fail-closed مثل قبل).
/// • یک نگهبان کلّی تضمین می‌کند صفحهٔ آغازین هرگز برای همیشه نماند.
/// ═══════════════════════════════════════════════════════════════
class StartupCoordinator extends ChangeNotifier {
  StartupCoordinator({
    List<StartupStep>? steps,
    bool? securityCheck,
    this.hardDeadline = const Duration(seconds: 12),
    this.securityWeight = 0.18,
    this.securityProbe,
  })  : _steps = steps ?? _defaultSteps(),
        securityCheck = securityCheck ?? kReleaseMode;

  final List<StartupStep> _steps;
  final bool securityCheck;
  final double securityWeight;

  /// سقف مطلق کل راه‌اندازی؛ بعد از آن، برنامه با وضعیت فعلی جلو می‌رود.
  final Duration hardDeadline;

  /// فقط برای تست: جایگزین بررسی امنیتی بومی. مقدار `true` یعنی بیلد
  /// دستکاری‌شده. در برنامهٔ واقعی همیشه از SecurityHardeningService
  /// استفاده می‌شود.
  @visibleForTesting
  final Future<bool> Function()? securityProbe;

  double _progress = 0;
  double _completedWeight = 0;
  double _totalWeight = 1;
  bool _running = false;
  bool _complete = false;
  bool _blocked = false;
  bool _disposed = false;
  bool _securitySettled = false;
  bool _timedOut = false;
  bool _finalizing = false;
  Future<void>? _startFuture;
  Future<bool>? _securityFuture;
  Timer? _watchdog;
  final List<String> _failedSteps = <String>[];
  DateTime? _lastAdvanceAt;

  /// درصد واقعی کارِ انجام‌شده، از ۰ تا ۱.
  double get progress => _progress;

  bool get isRunning => _running;
  bool get isComplete => _complete;

  /// بیلد دستکاری‌شده است؛ فقط صفحهٔ امنیتی باید نمایش داده شود.
  bool get blocked => _blocked;

  /// دست‌کم یک مرحله شکست خورد و برنامه با مسیر جایگزین بالا آمد.
  bool get degraded => _failedSteps.isNotEmpty;

  bool get hadTimeout => _timedOut;

  List<String> get failedSteps => List<String>.unmodifiable(_failedSteps);

  /// آخرین لحظه‌ای که پیشرفت واقعی رخ داد؛ برای تشخیص «گیر کردن» و
  /// نمایش حالت نامعین (Indeterminate) به‌جای عدد ثابت.
  DateTime? get lastAdvanceAt => _lastAdvanceAt;

  Duration get stalledFor {
    final last = _lastAdvanceAt;
    if (last == null) return Duration.zero;
    return DateTime.now().difference(last);
  }

  /// فقط یک‌بار اجرا می‌شود؛ فراخوانی‌های بعدی همان Future را می‌گیرند.
  Future<void> ensureStarted() => _startFuture ??= _start();

  Future<void> _start() async {
    try {
      _running = true;
      _lastAdvanceAt = DateTime.now();
      _totalWeight = _steps.fold<double>(
        0,
        (sum, step) => sum + math.max(0.0, step.weight),
      );
      if (securityCheck) _totalWeight += math.max(0.0, securityWeight);
      if (_totalWeight <= 0) _totalWeight = 1;
      _notify();

      if (securityCheck) {
        _securityFuture = _runSecurity();
        unawaited(
          _securityFuture!.then<void>(
            (tampered) {
              _securitySettled = true;
              _blocked = tampered;
              _advance(securityWeight);
            },
            // خطای غیرمنتظرهٔ بررسی امنیتی = «نامطمئن»، هرگز «بی‌خطر».
            onError: (Object error, StackTrace stack) {
              _safeLog('Security check failed', error, stack);
              _securitySettled = true;
              _blocked = true;
              _advance(securityWeight);
            },
          ),
        );
      }

      // نگهبانِ سقف زمانی: اگر مرحله‌ای (مثلاً حافظهٔ معیوب) پاسخ نداد،
      // همین Future برنده می‌شود و برنامه با وضعیت فعلی جلو می‌رود. مراحلی
      // که دیرتر تمام شوند فقط دیگر روی پیشرفت اثری ندارند.
      final deadline = Completer<void>();
      _watchdog = Timer(hardDeadline, () {
        _timedOut = true;
        if (!deadline.isCompleted) deadline.complete();
      });

      final pipeline = _runPipeline().catchError(
        (Object error, StackTrace stack) {
          _failedSteps.add('pipeline');
          _safeLog('Startup pipeline failed', error, stack);
        },
      );
      await Future.any<void>(<Future<void>>[pipeline, deadline.future]);

      _watchdog?.cancel();
      _watchdog = null;
      await _finalize();
    } catch (error, stack) {
      // آخرین سنگر: حتی اگر همه‌چیز خراب شود، کودک روی اسپلش نمی‌ماند.
      _failedSteps.add('startup');
      _safeLog('Startup aborted', error, stack);
      _watchdog?.cancel();
      _watchdog = null;
      await _finalize();
    }
  }

  /// ثبت خطا هرگز نباید خودش منبع خطای تازه شود.
  static void _safeLog(String message, Object error, StackTrace stack) {
    try {
      LoggerService.e(message, error, stack);
    } catch (_) {
      // لاگ کردن ناموفق بود؛ مسیر بازیابی مهم‌تر است.
    }
  }

  Future<void> _runPipeline() async {
    for (final step in _steps) {
      if (_complete) break;
      await _runStep(step);
    }
    if (!_complete && securityCheck) {
      await _awaitSecurity();
    }
  }

  Future<void> _runStep(StartupStep step) async {
    try {
      await step.run().timeout(step.timeout);
    } catch (error, stack) {
      _failedSteps.add(step.id);
      _safeLog('Startup step "${step.id}" failed', error, stack);
      try {
        step.onFailure?.call(error, stack);
      } catch (fallbackError, fallbackStack) {
        _safeLog(
          'Startup fallback for "${step.id}" failed',
          fallbackError,
          fallbackStack,
        );
      }
    } finally {
      _advance(step.weight);
    }
  }

  Future<bool> _runSecurity() async {
    final probe = securityProbe;
    if (probe != null) {
      try {
        return await probe();
      } catch (error, stack) {
        _safeLog('Security probe failed', error, stack);
        return true;
      }
    }
    try {
      final assessment = await SecurityHardeningService.assess();
      return assessment.tampered;
    } catch (error, stack) {
      _safeLog('Security assessment failed', error, stack);
      // شکست بررسی امنیتی هرگز به «ورود آزاد» تبدیل نمی‌شود.
      return true;
    }
  }

  Future<void> _awaitSecurity() async {
    final future = _securityFuture;
    if (future == null) return;
    try {
      // `assess` خودش ۶ ثانیه سقف دارد؛ این سقف فقط برای اطمینان مضاعف است.
      _blocked = await future.timeout(const Duration(seconds: 8));
    } catch (error, stack) {
      _safeLog('Security check did not finish in time', error, stack);
      _blocked = true;
    }
    _securitySettled = true;
  }

  Future<void> _finalize() async {
    if (_complete || _finalizing) return;
    _finalizing = true;
    if (securityCheck && !_securitySettled) {
      // آخرین فرصت؛ اگر همین‌جا هم معلوم نشد، بیلد نامطمئن است.
      final future = _securityFuture;
      if (future != null) {
        try {
          _blocked = await future.timeout(const Duration(seconds: 2));
        } catch (_) {
          _blocked = true;
        }
        _securitySettled = true;
      }
    }
    _blocked = securityCheck && _blocked;
    _progress = 1;
    _complete = true;
    _running = false;
    _lastAdvanceAt = DateTime.now();
    _notify();
  }

  void _advance(double weight) {
    if (_complete || weight <= 0) {
      _notify();
      return;
    }
    _completedWeight += weight;
    final next = (_completedWeight / _totalWeight).clamp(0.0, 0.99);
    if (next > _progress) {
      // پیشرفت هرگز عقب نمی‌رود؛ نوار هم عقب نمی‌کشد.
      _progress = next.toDouble();
    }
    _lastAdvanceAt = DateTime.now();
    _notify();
  }

  void _notify() {
    if (_disposed) return;
    notifyListeners();
  }

  @override
  void dispose() {
    _disposed = true;
    _watchdog?.cancel();
    _watchdog = null;
    super.dispose();
  }

  // ─────────────────────────────────────────────────────────────
  // مراحل پیش‌فرض — همان کارهایی که قبلاً در main انجام می‌شد.
  // ─────────────────────────────────────────────────────────────

  static List<StartupStep> _defaultSteps() {
    return <StartupStep>[
      StartupStep(
        id: 'storage',
        weight: 0.18,
        timeout: const Duration(seconds: 5),
        run: _openStorage,
        onFailure: (error, stack) {
          // GameData خودش مسیر جایگزین حافظه را دارد؛ اینجا فقط ثبت می‌کنیم.
          LoggerService.w('Storage unavailable at startup: $error');
        },
      ),
      StartupStep(
        id: 'player-profile',
        weight: 0.40,
        timeout: const Duration(seconds: 6),
        run: () async {
          await GameData.load();
          // فندقی اسم کودک را در همان اجرا به یاد می‌آورد.
          FandoghiCoach.rememberChild(GameData.childName);
        },
        onFailure: (error, stack) {
          // ذخیره‌سازی خراب نباید به صفحهٔ سفید یا کرش تبدیل شود.
          GameData.useMemoryFallback();
        },
      ),
      StartupStep(
        id: 'family-settings',
        weight: 0.24,
        timeout: const Duration(seconds: 5),
        run: GrowthStore.load,
        onFailure: (error, stack) {
          GrowthStore.useMemoryFallback();
        },
      ),
    ];
  }

  static Future<void> _openStorage() => HivePlayerStore.openStorage();
}
