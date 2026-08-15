import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:jazireh_fandoghi/core/fandoghi_coach.dart';
import 'package:jazireh_fandoghi/core/game_data.dart';
import 'package:jazireh_fandoghi/core/learning_content/lullabies_data.dart';
import 'package:jazireh_fandoghi/features/lullabies/lullaby_hub_screen.dart';

void main() {
  setUp(() {
    GoogleFonts.config.allowRuntimeFetching = false;
    GameData.resetForTesting();
  });

  tearDown(() {
    FandoghiCoach.clear();
    FandoghiCoach.disablePersistentPresence();
  });

  testWidgets('lullaby hub presents one island platform per lullaby',
      (tester) async {
    tester.view.physicalSize = const Size(390, 844);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(
      const MaterialApp(home: LullabyHubScreen()),
    );
    await tester.pump(const Duration(milliseconds: 600));

    final lastIndex = LullabiesData.all.length - 1;

    expect(find.text('لالایی‌ها'), findsOneWidget);
    expect(find.byKey(const ValueKey('lullaby_platform_0')), findsOneWidget);
    expect(
      find.byKey(ValueKey('lullaby_platform_$lastIndex')),
      findsOneWidget,
    );
    // همان قرارداد قصه‌خانه/کارتون‌کده: بدون جستجو، فیلتر و دکمهٔ شناور.
    expect(find.byType(TextField), findsNothing);
    expect(find.byType(FilterChip), findsNothing);
    expect(find.byType(FloatingActionButton), findsNothing);
    expect(find.byType(GridView), findsNothing);
    expect(tester.takeException(), isNull);

    await tester.scrollUntilVisible(
      find.byKey(ValueKey('lullaby_platform_$lastIndex')),
      500,
      scrollable: find.byType(Scrollable).last,
    );
    await tester.pump(const Duration(milliseconds: 300));
    expect(tester.takeException(), isNull);

    await tester.pumpWidget(const SizedBox.shrink());
    FandoghiCoach.clear();
    FandoghiCoach.cancelSmartHint();
    FandoghiCoach.disablePersistentPresence();
  });

  test('lullaby listen + favorite state mirrors the story/cartoon contract',
      () {
    GameData.resetForTesting();
    final first = LullabiesData.all.first.id;

    expect(GameData.hasListenedLullaby(first), isFalse);
    expect(GameData.markLullabyListened(first), isTrue);
    expect(GameData.hasListenedLullaby(first), isTrue);
    // پاداش/مهارت فقط یک‌بار برای هر لالایی
    expect(GameData.markLullabyListened(first), isFalse);
    expect(GameData.skills['lullaby'], 1);

    expect(GameData.isLullabyFavorite(first), isFalse);
    GameData.toggleLullabyFavorite(first);
    expect(GameData.isLullabyFavorite(first), isTrue);
    GameData.toggleLullabyFavorite(first);
    expect(GameData.isLullabyFavorite(first), isFalse);
  });
}
