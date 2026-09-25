import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:jazireh_fandoghi/core/game_data.dart';
import 'package:jazireh_fandoghi/features/cartoons/online_cartoon_gate.dart';

/// ═══════════════════════════════════════════════════════════════
/// 🌐 تست دروازهٔ شفاف ورود به کارتون‌کده — قانون Offline-First
///
/// محتوای آنلاین (dummy child) فقط بعد از تأیید ساخته می‌شود؛
/// اعلان در هر اجرای برنامه یک‌بار فعال است و «بازگشت به جزیره»
/// بدون ساخت هیچ محتوای آنلاین کار می‌کند.
/// ═══════════════════════════════════════════════════════════════
void main() {
  setUp(() {
    // کانال SecureStore در محیط تست هندلر نیتیو ندارد؛ بدون mock،
    // فراخوانیِ read داخل GameData.load هرگز complete نمی‌شود و
    // «await GameData.reload()» تا ابد آویزان می‌ماند (همان الگویی که
    // parent_pin_gate_test برای همین کانال استفاده می‌کند).
    final binding = TestWidgetsFlutterBinding.ensureInitialized();
    binding.defaultBinaryMessenger.setMockMethodCallHandler(
      const MethodChannel('kudake_iran/secure_store'),
      (call) async => null,
    );
    GameData.resetForTesting();
    OnlineCartoonGate.resetForTesting();
  });

  Widget host() => MaterialApp(
        home: Scaffold(
          body: Builder(
            builder: (homeContext) => Center(
              child: FilledButton(
                onPressed: () => Navigator.of(homeContext).push(
                  MaterialPageRoute<void>(
                    builder: (routeContext) => OnlineCartoonGate(
                      child: Builder(
                        builder: (hubContext) => Scaffold(
                          body: Center(
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Text('HUB_CONTENT'),
                                OutlinedButton(
                                  onPressed: () =>
                                      Navigator.of(hubContext).pop(),
                                  child: const Text('HUB_BACK'),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
                child: const Text('OPEN_GATE'),
              ),
            ),
          ),
        ),
      );

  Future<void> openGate(WidgetTester tester) async {
    await tester.tap(find.text('OPEN_GATE'));
    await tester.pumpAndSettle();
  }

  testWidgets('نخستین ورود: اطلاعیهٔ کامل والدین «پیش از ورود» نمایش داده می‌شود و محتوای آنلاین ساخته نمی‌شود', (tester) async {
    await tester.pumpWidget(host());
    await openGate(tester);

    expect(find.text('HUB_CONTENT'), findsNothing);
    expect(find.text('اطلاعیه به والدین عزیز — پیش از ورود'), findsOneWidget);
    expect(find.textContaining('تنها بخش آنلاین اپ است'), findsOneWidget);
    expect(find.textContaining('آپارات'), findsOneWidget);
  });

  testWidgets('بازگشت بدون تأیید: به جزیره برمی‌گردیم و محتوای آنلاین هرگز ساخته نمی‌شود', (tester) async {
    await tester.pumpWidget(host());
    await openGate(tester);

    await tester.tap(find.text('بازگشت به جزیره 🏝️'));
    await tester.pumpAndSettle();

    expect(find.text('HUB_CONTENT'), findsNothing);
    expect(find.text('OPEN_GATE'), findsOneWidget);
    expect(OnlineCartoonGate.acknowledgedThisRun, isFalse);
  });

  testWidgets('تأیید: ورود به کارتون‌کده و ثبت تأییدِ همین اجرا', (tester) async {
    await tester.pumpWidget(host());
    await openGate(tester);

    await tester.tap(find.text('ورود به کارتون‌کده'));
    await tester.pumpAndSettle();

    expect(find.text('HUB_CONTENT'), findsOneWidget);
    expect(OnlineCartoonGate.acknowledgedThisRun, isTrue);
  });

  testWidgets('ورود دوباره در همان اجرا: بدون اعلان تکراری', (tester) async {
    await tester.pumpWidget(host());
    await openGate(tester);
    await tester.tap(find.text('ورود به کارتون‌کده'));
    await tester.pumpAndSettle();

    // بازگشت به جزیره و ورود دوباره در همان اجرای برنامه
    await tester.tap(find.text('HUB_BACK'));
    await tester.pumpAndSettle();
    await openGate(tester);

    expect(find.text('HUB_CONTENT'), findsOneWidget);
    expect(find.text('ورود به کارتون‌کده'), findsNothing);
    expect(find.text('بازگشت به جزیره 🏝️'), findsNothing);
  });

  testWidgets('اجرای تازهٔ برنامه: اعلان دوباره فعال می‌شود', (tester) async {
    await tester.pumpWidget(host());
    await openGate(tester);
    await tester.tap(find.text('ورود به کارتون‌کده'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('HUB_BACK'));
    await tester.pumpAndSettle();

    // بستن و باز کردن دوبارهٔ برنامه
    OnlineCartoonGate.resetForTesting();
    await openGate(tester);

    expect(find.text('HUB_CONTENT'), findsNothing);
    expect(find.text('بازگشت به جزیره 🏝️'), findsOneWidget);
    expect(OnlineCartoonGate.acknowledgedThisRun, isFalse);
  });

  testWidgets('کاربر قدیمی (اطلاعیهٔ والدین دیده‌شده): اعلان کوتاهِ آنلاین به‌جای اطلاعیهٔ کامل', (tester) async {
    SharedPreferences.setMockInitialValues(
      {'cartoon_parent_disclosure_shown': true},
    );
    await GameData.reload();

    await tester.pumpWidget(host());
    await openGate(tester);

    expect(find.text('اطلاعیه به والدین عزیز — پیش از ورود'), findsNothing);
    expect(find.text('کارتون‌کده بخش آنلاین بازی است'), findsOneWidget);
    expect(find.textContaining('تمام جزیرهٔ فندقی همیشه آفلاین'), findsOneWidget);
  });
}
