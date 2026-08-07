import 'package:flutter_test/flutter_test.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:kudakeiran/core/game_data.dart';
import 'package:kudakeiran/features/home/home_screen.dart';

void main() {
  testWidgets('home dashboard renders the core child actions', (tester) async {
    GoogleFonts.config.allowRuntimeFetching = false;
    GameData.resetForTesting();
    GameData.onboardingSeen = true;

    await tester.pumpWidget(const MaterialApp(home: HomeScreen()));
    await tester.pump(const Duration(milliseconds: 250));

    expect(find.text('ماموریت‌های امروز'), findsOneWidget);
    expect(find.text('بازی‌های سریع'), findsOneWidget);
    expect(find.text('دسته‌بندی بازی‌ها'), findsOneWidget);
  });
}
