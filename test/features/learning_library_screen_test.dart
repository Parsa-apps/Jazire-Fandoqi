import 'package:flutter/material.dart';
import '../support/paywall_test_store.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:jazireh_fandoghi/core/fandoghi_coach.dart';
import 'package:jazireh_fandoghi/features/gateway/learning_library_screen.dart';
import 'package:jazireh_fandoghi/shared/widgets/fandoghi_premium.dart';

Future<void> _disposeAnimatedTree(WidgetTester tester) async {
  await tester.pumpWidget(const SizedBox.shrink());
  FandoghiCoach.cancelSmartHint();
  FandoghiCoach.disablePersistentPresence();
  // Let any already-created delayed animation callbacks expire after their
  // widgets have been disposed, without allowing them to schedule more work.
  await tester.pump(const Duration(seconds: 6));
}

void main() {
  setUpUnpurchasedStore();
  tearDown(() {
    FandoghiCoach.clear();
    FandoghiCoach.disablePersistentPresence();
  });

  testWidgets('PR80 learning hubs are discoverable from one library',
      (tester) async {
    await tester.pumpWidget(
      const MaterialApp(home: LearningLibraryScreen()),
    );
    await tester.pump(const Duration(milliseconds: 250));

    expect(find.text('کتابخانه یادگیری 📚'), findsOneWidget);
    expect(find.text('دانشنامه حیوانات ایران'), findsOneWidget);
    expect(find.text('دنیای اعداد'), findsOneWidget);

    // GridView builds cards lazily, so verify the lower entries after actually
    // scrolling them into the viewport rather than assuming off-screen cards
    // already exist in the element tree.
    await tester.scrollUntilVisible(
      find.text('شغل‌های قهرمانانه'),
      180,
      scrollable: find.byType(Scrollable).last,
    );
    expect(find.text('شغل‌های قهرمانانه'), findsOneWidget);
    expect(find.text('مفاهیم اولیه'), findsOneWidget);

    await tester.scrollUntilVisible(
      find.text('دنیای احساسات'),
      180,
      scrollable: find.byType(Scrollable).last,
    );
    expect(find.text('دنیای احساسات'), findsOneWidget);

    await _disposeAnimatedTree(tester);
  });

  testWidgets(
    'embedded backpack lays out on a narrow phone with reduced motion',
    (tester) async {
      tester.view.physicalSize = const Size(320, 568);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      await tester.pumpWidget(
        const MaterialApp(
          home: MediaQuery(
            data: MediaQueryData(
              size: Size(320, 568),
              disableAnimations: true,
            ),
            child: LearningLibraryScreen(embedded: true),
          ),
        ),
      );
      await tester.pump(const Duration(milliseconds: 300));

      expect(find.text('کوله‌پشتی یادگیری 🎒'), findsOneWidget);
      expect(find.text('دانشنامه حیوانات ایران'), findsOneWidget);
      expect(
        tester.widget<FandoghiPremium>(find.byType(FandoghiPremium)).animated,
        isFalse,
      );
      // برچسب دسترس‌پذیری کارت با زیرعنوانش یکی می‌شود؛ کافی است
      // عنوان در برچسب نهایی حضور داشته باشد.
      expect(
        find.bySemanticsLabel(RegExp('دانشنامه حیوانات ایران')),
        findsOneWidget,
      );
      expect(tester.takeException(), isNull);

      await _disposeAnimatedTree(tester);
    },
  );
}
