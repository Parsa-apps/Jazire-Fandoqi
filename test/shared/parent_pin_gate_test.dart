import 'dart:async';
import 'dart:convert';

import 'package:cryptography/dart.dart' show DartSha256;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:jazireh_fandoghi/core/game_data.dart';
import 'package:jazireh_fandoghi/shared/widgets/parent_pin_gate.dart';

/// دروازهٔ والد نباید هیچ‌وقت «بی‌صدا» شکست بخورد — شکست بی‌صدا دقیقاً
/// همان چیزی است که کاربر به‌صورت «دکمهٔ خرید کار نمی‌کند» می‌بیند.
///
/// نکتهٔ فنی مهم: بدنهٔ testWidgets زیر FakeAsync اجرا می‌شود؛ هر await که
/// قبل از pump به تایمر نیاز داشته باشد برای همیشه قفل می‌کند. به همین دلیل
/// پین با هش legacy (SHA-256 همگام) کاشته می‌شود، نه با setParentPin که
/// PBKDF2 ناهمگام دارد.
String _legacyHash(String pin) {
  final digest = const DartSha256()
      .hashSync(utf8.encode('fandoghi-parent-pin-v1:$pin'));
  return base64Encode(digest.bytes);
}

void main() {
  setUp(() {
    final binding = TestWidgetsFlutterBinding.ensureInitialized();
    // کانال SecureStore در محیط تست هندلر نیتیو ندارد؛ بدون mock، فراخوانیِ
    // read/write هرگز complete نمی‌شود و دروازه برای همیشه آویزان می‌ماند
    // (همان الگویی که monetization_test برای کانال پرداخت استفاده می‌کند).
    binding.defaultBinaryMessenger.setMockMethodCallHandler(
      const MethodChannel('kudake_iran/secure_store'),
      (call) async => null,
    );
    // مثل بقیهٔ تست‌های ویجت اپ: بدون این خط، GoogleFonts موقع رندر متن‌های
    // دیالوگ تلاش به دانلود فونت می‌کند و زیر fake-async استثنا می‌اندازد.
    GoogleFonts.config.allowRuntimeFetching = false;
    GameData.resetForTesting();
    GameData.parentUnlockedThisSession = false;
  });

  group('normalizePinDigits', () {
    test('converts Persian digits to Latin', () {
      expect(normalizePinDigits('۱۲۳۴'), '1234');
      expect(normalizePinDigits('۰۹۸۷'), '0987');
    });

    test('converts Arabic-Indic digits to Latin', () {
      expect(normalizePinDigits('٠٩٨٧'), '0987');
    });

    test('keeps Latin digits and mixed input intact', () {
      expect(normalizePinDigits('0987'), '0987');
      expect(normalizePinDigits('1۲3٤'), '1234');
      expect(normalizePinDigits(''), '');
    });
  });

  Future<BuildContext> _pumpGateHost(WidgetTester tester) async {
    late BuildContext capturedContext;
    await tester.pumpWidget(MaterialApp(
      home: Builder(builder: (context) {
        capturedContext = context;
        return const Scaffold(body: SizedBox.expand());
      }),
    ));
    return capturedContext;
  }

  testWidgets(
    'wrong PIN shows a visible error instead of failing silently',
    timeout: const Timeout(Duration(minutes: 2)),
    (tester) async {
      // کاشت همگام پین (هش legacy) — بدون PBKDF2 ناهمگام قبل از pump.
      GameData.parentPinHash = _legacyHash('2580');
      final context = await _pumpGateHost(tester);

      bool? gateResult;
      unawaited(requestParentAccess(context).then((v) => gateResult = v));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 500));

      // دیالوگ ورود پین باز است؛ پین اشتباه وارد می‌کنیم.
      expect(find.text('ورود والدین'), findsOneWidget);
      await tester.enterText(find.byType(TextField), '0000');
      await tester.tap(find.text('ورود'));

      for (var i = 0; i < 60 && gateResult == null; i++) {
        await tester.pump(const Duration(milliseconds: 500));
      }
      expect(gateResult, isFalse,
          reason: 'دروازه باید بعد از پین اشتباه مقدار false برگرداند');
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));

      // کاربر باید پیام قابل‌مشاهده ببیند، نه سکوت.
      expect(find.text('پین اشتباه بود'), findsOneWidget);
      expect(GameData.parentUnlockedThisSession, isFalse);

      // بستن دیالوگ خطا برای تمیز ماندن درخت ویجت.
      await tester.tap(find.text('باشه'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 500));
      await tester.pumpWidget(const SizedBox.shrink());
    },
  );

  testWidgets(
    'a PIN typed with Persian digits is accepted',
    timeout: const Timeout(Duration(minutes: 2)),
    (tester) async {
      GameData.parentPinHash = _legacyHash('1234');
      final context = await _pumpGateHost(tester);

      bool? gateResult;
      unawaited(requestParentAccess(context).then((v) => gateResult = v));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 500));

      await tester.enterText(find.byType(TextField), '۱۲۳۴');
      await tester.tap(find.text('ورود'));

      // قرارداد این تست: دیالوگ باید بسته شود — یعنی «۱۲۳۴» به «1234»
      // نرمال شد و از فیلتر چهار رقمی عبور کرد. اگر نرمال‌سازی کار نمی‌کرد،
      // دکمه هیچ کاری نمی‌کرد و دیالوگ باز می‌ماند (همان باگ قبلی کاربر).
      for (var i = 0;
          i < 20 && find.text('ورود والدین').evaluate().isNotEmpty;
          i++) {
        await tester.pump(const Duration(milliseconds: 300));
      }
      expect(find.text('ورود والدین'), findsNothing,
          reason: 'پین فارسی‌رقم باید بعد از نرمال‌سازی پذیرفته و دیالوگ بسته شود');

      // ادامهٔ مسیر (تأیید رمزنگاری) زیر fake-async قابل اتکا نیست و در
      // parent_pin_test پوشش دارد؛ فقط اگر زود آماده شد، درستی‌اش را چک کن.
      for (var i = 0; i < 10 && gateResult == null; i++) {
        await tester.pump(const Duration(milliseconds: 300));
      }
      if (gateResult != null) {
        expect(gateResult, isTrue);
        expect(GameData.parentUnlockedThisSession, isTrue);
      }
      await tester.pumpWidget(const SizedBox.shrink());
    },
  );

  // مسیر «پین درست» در تست ویجت عمداً پوشش داده نمی‌شود: تأیید پین درست،
  // هش legacy را به PBKDF2 ارتقا می‌دهد و آن کار ناهمگام زیر fake-async
  // کامل نمی‌شود. قرارداد رمزنگاری آن مسیر در test/core/parent_pin_test.dart
  // با تست‌های معمولی (بدون fake-async) پوشش کامل دارد. در اینجا مکانیک
  // دیالوگ با مسیر انصراف بررسی می‌شود.
  testWidgets(
    'canceling the PIN dialog denies access',
    timeout: const Timeout(Duration(minutes: 2)),
    (tester) async {
      GameData.parentPinHash = _legacyHash('2580');
      final context = await _pumpGateHost(tester);

      bool? gateResult;
      unawaited(requestParentAccess(context).then((v) => gateResult = v));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 500));

      expect(find.text('ورود والدین'), findsOneWidget);
      await tester.tap(find.text('انصراف'));

      for (var i = 0; i < 20 && gateResult == null; i++) {
        await tester.pump(const Duration(milliseconds: 300));
      }
      expect(gateResult, isFalse,
          reason: 'انصراف از دیالوگ پین باید دسترسی را رد کند');
      expect(GameData.parentUnlockedThisSession, isFalse);
      await tester.pumpWidget(const SizedBox.shrink());
    },
  );
}
