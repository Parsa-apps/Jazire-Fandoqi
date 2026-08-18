import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:jazireh_fandoghi/core/game_data.dart';
import 'package:jazireh_fandoghi/shared/widgets/parent_pin_gate.dart';

/// دروازهٔ والد نباید هیچ‌وقت «بی‌صدا» شکست بخورد — شکست بی‌صدا دقیقاً
/// همان چیزی است که کاربر به‌صورت «دکمهٔ خرید کار نمی‌کند» می‌بیند.
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

  testWidgets('wrong PIN shows a visible error instead of failing silently',
      (tester) async {
    expect(await GameData.setParentPin('2580'), isTrue);

    late BuildContext capturedContext;
    await tester.pumpWidget(MaterialApp(
      home: Builder(builder: (context) {
        capturedContext = context;
        return const Scaffold(body: SizedBox.expand());
      }),
    ));

    final access = requestParentAccess(capturedContext);
    await tester.pumpAndSettle();

    // دیالوگ ورود پین باز است؛ پین اشتباه وارد می‌کنیم.
    expect(find.text('ورود والدین'), findsOneWidget);
    await tester.enterText(find.byType(TextField), '0000');
    await tester.tap(find.text('ورود'));
    await tester.pumpAndSettle();

    // کاربر باید پیام قابل‌مشاهده ببیند، نه سکوت.
    expect(find.text('پین اشتباه بود'), findsOneWidget);
    await tester.tap(find.text('باشه'));
    await tester.pumpAndSettle();

    expect(await access, isFalse);
    expect(GameData.parentUnlockedThisSession, isFalse);
  });

  testWidgets('a PIN typed with Persian digits is accepted', (tester) async {
    expect(await GameData.setParentPin('1234'), isTrue);

    late BuildContext capturedContext;
    await tester.pumpWidget(MaterialApp(
      home: Builder(builder: (context) {
        capturedContext = context;
        return const Scaffold(body: SizedBox.expand());
      }),
    ));

    final access = requestParentAccess(capturedContext);
    await tester.pumpAndSettle();

    await tester.enterText(find.byType(TextField), '۱۲۳۴');
    await tester.tap(find.text('ورود'));
    await tester.pumpAndSettle();

    expect(await access, isTrue);
    expect(GameData.parentUnlockedThisSession, isTrue);
  });

  testWidgets('a correct ASCII PIN unlocks on the first try', (tester) async {
    expect(await GameData.setParentPin('2580'), isTrue);

    late BuildContext capturedContext;
    await tester.pumpWidget(MaterialApp(
      home: Builder(builder: (context) {
        capturedContext = context;
        return const Scaffold(body: SizedBox.expand());
      }),
    ));

    final access = requestParentAccess(capturedContext);
    await tester.pumpAndSettle();

    await tester.enterText(find.byType(TextField), '2580');
    await tester.tap(find.text('ورود'));
    await tester.pumpAndSettle();

    expect(await access, isTrue);
  });
}
