import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:jazireh_fandoghi/core/startup/startup_coordinator.dart';

/// 🚀 تست‌های «پیشرفت واقعی» راه‌اندازی.
///
/// نوار پیشرفت اسپلش فقط زمانی باید بالا برود که یک مرحلهٔ واقعی تمام
/// شده باشد؛ این تست‌ها همان قرارداد را قفل می‌کنند:
///  - درصد = مجموع وزن مراحلِ تمام‌شده، نه یک تایمر تزئینی
///  - شکست/گیر کردن یک مرحله هرگز برنامه را روی اسپلش قفل نمی‌کند
///  - بررسی امنیتی همیشه fail-closed است
void main() {
  test('progress reflects completed real steps and completes only at the end',
      () async {
    final gate = Completer<void>();
    final coordinator = StartupCoordinator(
      securityCheck: false,
      steps: <StartupStep>[
        StartupStep(id: 'one', weight: 0.6, run: () async {}),
        StartupStep(id: 'two', weight: 0.4, run: () => gate.future),
      ],
    );

    final done = coordinator.ensureStarted();
    await Future<void>.delayed(const Duration(milliseconds: 30));

    expect(coordinator.isComplete, isFalse);
    expect(coordinator.progress, closeTo(0.6, 0.001));

    gate.complete();
    await done;

    expect(coordinator.isComplete, isTrue);
    expect(coordinator.progress, 1.0);
    expect(coordinator.degraded, isFalse);
    coordinator.dispose();
  });

  test('a failed step uses its fallback and never blocks startup', () async {
    var fallbackUsed = false;
    final coordinator = StartupCoordinator(
      securityCheck: false,
      steps: <StartupStep>[
        StartupStep(
          id: 'broken',
          weight: 1,
          run: () async => throw StateError('storage is broken'),
          onFailure: (Object error, StackTrace stack) {
            fallbackUsed = true;
          },
        ),
      ],
    );

    await coordinator.ensureStarted();

    expect(fallbackUsed, isTrue);
    expect(coordinator.degraded, isTrue);
    expect(coordinator.isComplete, isTrue);
    expect(coordinator.progress, 1.0);
    coordinator.dispose();
  });

  test('a hung step is bounded by its timeout instead of hanging forever',
      () async {
    final coordinator = StartupCoordinator(
      securityCheck: false,
      steps: <StartupStep>[
        StartupStep(
          id: 'hung',
          weight: 1,
          timeout: const Duration(milliseconds: 25),
          run: () => Completer<void>().future,
        ),
      ],
    );

    await coordinator.ensureStarted();

    expect(coordinator.isComplete, isTrue);
    expect(coordinator.degraded, isTrue);
    expect(coordinator.failedSteps, contains('hung'));
    coordinator.dispose();
  });

  test('security result is fail-closed when the probe reports tampering',
      () async {
    final coordinator = StartupCoordinator(
      steps: const <StartupStep>[],
      securityCheck: true,
      securityProbe: () async => true,
    );

    await coordinator.ensureStarted();

    expect(coordinator.isComplete, isTrue);
    expect(coordinator.blocked, isTrue);
    coordinator.dispose();
  });

  test('a throwing security probe is treated as tampered, never as trusted',
      () async {
    final coordinator = StartupCoordinator(
      steps: const <StartupStep>[],
      securityCheck: true,
      securityProbe: () async => throw StateError('native channel missing'),
    );

    await coordinator.ensureStarted();

    expect(coordinator.blocked, isTrue);
    coordinator.dispose();
  });

  test('hard deadline finishes startup with a degraded outcome', () async {
    final coordinator = StartupCoordinator(
      securityCheck: false,
      hardDeadline: const Duration(milliseconds: 30),
      steps: <StartupStep>[
        StartupStep(
          id: 'very-slow',
          weight: 1,
          timeout: const Duration(milliseconds: 200),
          run: () => Completer<void>().future,
        ),
      ],
    );

    await coordinator.ensureStarted();

    expect(coordinator.isComplete, isTrue);
    expect(coordinator.hadTimeout, isTrue);
    expect(coordinator.progress, 1.0);
    coordinator.dispose();
    // به مرحلهٔ رهاشده فرصت می‌دهیم تا تایمرِ سقفش تمام شود و تست
    // هیچ تایمرِ معلقی جا نگذارد.
    await Future<void>.delayed(const Duration(milliseconds: 250));
  });
}
