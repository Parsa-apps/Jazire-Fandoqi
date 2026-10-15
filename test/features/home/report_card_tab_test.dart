import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:jazireh_fandoghi/core/game_data.dart';
import 'package:jazireh_fandoghi/core/growth/growth.dart';
import 'package:jazireh_fandoghi/features/home/widgets/report_card_tab.dart';

void main() {
  setUp(() {
    GoogleFonts.config.allowRuntimeFetching = false;
    GameData.resetForTesting();
  });

  tearDown(GameData.resetForTesting);

  testWidgets('report card remains readable on a narrow phone', (tester) async {
    tester.view.physicalSize = const Size(320, 568);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    GameData.totalCorrect = 8;
    GameData.totalWrong = 2;
    GameData.todayPlaySeconds = 90 * 60;
    GameData.skills['alphabet'] = 10;

    await tester.pumpWidget(
      const ProviderScope(
        child: MaterialApp(home: ReportCardTab()),
      ),
    );
    await tester.pump(const Duration(milliseconds: 300));

    expect(find.text('کارنامه پیشرفت تحصیلی'), findsOneWidget);
    // دقت کلی داخل جملهٔ هدر می‌آید («میزان دقت و تسلط کلی: ۸۰٪ ⭐»).
    expect(find.textContaining('${PersianDigits.toFa(80)}٪'), findsOneWidget);
    expect(find.text('فارسی و الفبا'), findsOneWidget);
    expect(find.text('${PersianDigits.toFa(50)}٪'), findsOneWidget);
    expect(
      find.text('مشاهده گزارش تفصیلی والدین'),
      findsOneWidget,
    );
    expect(find.byType(LinearProgressIndicator), findsNWidgets(7));
    expect(tester.takeException(), isNull);

    await tester.pumpWidget(const SizedBox.shrink());
  });
}
