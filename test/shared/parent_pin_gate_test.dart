import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:jazireh_fandoghi/core/game_data.dart';
import 'package:jazireh_fandoghi/shared/widgets/parent_pin_gate.dart';

/// دروازهٔ والد نباید هیچ‌وقت «بی‌صدا» شکست بخورد — شکست بی‌صدا دقیقاً
/// همان چیزی است که کاربر به‌صورت «دکمهٔ خرید کار نمی‌کند» می‌بیند.
///
/// نکتهٔ فنی تست‌ها: نتیجهٔ دروازه با `.then` در یک متغیر ثبت و با پامپ‌های
/// کرانداز poll می‌شود؛ هیچ `await` بلاک‌کننده‌ای روی futureِ دروازه نیست تا
/// اگر کاری در CI طول کشید، تست سریع و روشن شکست بخورد نه اینکه آویزان بماند.
void main() {
  setUp(() {
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

  /// دروازه را باز می‌کند و نتیجه‌اش را غیربلاک‌کننده ثبت می‌کند.
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
      expect(await GameData.setParentPin('2580'), isTrue);
      final context = await _pumpGateHost(tester);

      bool? gateResult;
      unawaited(requestParentAccess(context).then((v) => gateResult = v));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 500));

      // دیالوگ ورود پین باز است؛ پین اشتباه وارد می‌کنیم.
      expect(find.text('ورود والدین'), findsOneWidget);
      await tester.enterText(find.byType(TextField), '0000');
      await tester.tap(find.text('ورود'));

      // پامپ‌های کرانداز: اگر verify طول کشید، زمان فیک جلو می‌رود.
      for (var i = 0; i < 40 && gateResult == null; i++) {
        await tester.pump(const Duration(milliseconds: 500));
      }
      expect(gateResult, isFalse,
          reason: 'دروازه باید بعد از پین اشتباه مقدار false برگرداند');
      await tester.pump(const Duration(milliseconds: 500));

      // کاربر باید پیام قابل‌مشاهده ببیند، نه سکوت.
      expect(find.text('پین اشتباه بود'), findsOneWidget);
      expect(GameData.parentUnlockedThisSession, isFalse);

      // بستن دیالوگ خطا برای تمیز ماندن درخت ویجت.
      await tester.tap(find.text('باشه'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 500));
    },
  );

  testWidgets(
    'a PIN typed with Persian digits is accepted',
    timeout: const Timeout(Duration(minutes: 2)),
    (tester) async {
      expect(await GameData.setParentPin('1234'), isTrue);
      final context = await _pumpGateHost(tester);

      bool? gateResult;
      unawaited(requestParentAccess(context).then((v) => gateResult = v));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 500));

      await tester.enterText(find.byType(TextField), '۱۲۳۴');
      await tester.tap(find.text('ورود'));

      for (var i = 0; i < 40 && gateResult == null; i++) {
        await tester.pump(const Duration(milliseconds: 500));
      }
      expect(gateResult, isTrue,
          reason: 'پین فارسی‌رقم باید بعد از نرمال‌سازی پذیرفته شود');
      expect(GameData.parentUnlockedThisSession, isTrue);
    },
  );

  testWidgets(
    'a correct ASCII PIN unlocks on the first try',
    timeout: const Timeout(Duration(minutes: 2)),
    (tester) async {
      expect(await GameData.setParentPin('2580'), isTrue);
      final context = await _pumpGateHost(tester);

      bool? gateResult;
      unawaited(requestParentAccess(context).then((v) => gateResult = v));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 500));

      await tester.enterText(find.byType(TextField), '2580');
      await tester.tap(find.text('ورود'));

      for (var i = 0; i < 40 && gateResult == null; i++) {
        await tester.pump(const Duration(milliseconds: 500));
      }
      expect(gateResult, isTrue);
      expect(GameData.parentUnlockedThisSession, isTrue);
    },
  );
}
