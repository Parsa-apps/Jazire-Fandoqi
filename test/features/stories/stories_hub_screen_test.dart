import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:jazireh_fandoghi/core/fandoghi_coach.dart';
import 'package:jazireh_fandoghi/core/game_data.dart';
import 'package:jazireh_fandoghi/features/stories/stories_hub_screen.dart';

void main() {
  setUp(() {
    GoogleFonts.config.allowRuntimeFetching = false;
    GameData.resetForTesting();
  });

  tearDown(() {
    FandoghiCoach.clear();
    FandoghiCoach.disablePersistentPresence();
  });

  testWidgets('story hub shows the class-1 reader card and the first platform',
      (tester) async {
    tester.view.physicalSize = const Size(390, 1200);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(
      const MaterialApp(home: StoriesHubScreen()),
    );
    await tester.pump(const Duration(milliseconds: 600));

    expect(find.text('قصه‌خانه'), findsWidgets);
    expect(find.byKey(const ValueKey('decodable_today_card')), findsOneWidget);
    expect(find.byKey(const ValueKey('story_platform_0')), findsOneWidget);

    await tester.pumpWidget(const SizedBox.shrink());
    FandoghiCoach.clear();
    FandoghiCoach.cancelSmartHint();
    FandoghiCoach.disablePersistentPresence();
  });
}
