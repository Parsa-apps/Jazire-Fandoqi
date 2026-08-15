import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:jazireh_fandoghi/core/game_data.dart';
import 'package:jazireh_fandoghi/features/onboarding/onboarding_screen.dart';
import 'package:jazireh_fandoghi/features/splash/splash_screen.dart';
import 'package:jazireh_fandoghi/features/tutorial/app_tutorial_screen.dart';
import 'package:jazireh_fandoghi/main.dart';

/// تست میزبان برای رندر پوستهٔ برنامه و عبور زمان‌بندی‌شده از اسپلش.
void main() {
  setUp(() {
    GoogleFonts.config.allowRuntimeFetching = false;
    GameData.resetForTesting();
  });

  testWidgets('app shell starts and reaches onboarding after splash',
      (tester) async {
    await tester.pumpWidget(
      const ProviderScope(child: JazirehFandoghiApp()),
    );
    await tester.pump();

    expect(find.byType(JazirehFandoghiApp), findsOneWidget);
    expect(find.byType(SplashScreen), findsOneWidget);

    // SplashScreen intentionally owns repeating premium animations, so
    // pumpAndSettle can never complete. Advance its navigation timer and route
    // transition by bounded durations instead.
    await tester.pump(const Duration(seconds: 3));
    await tester.pump(const Duration(milliseconds: 500));

    expect(find.byType(OnboardingScreen), findsOneWidget);
    expect(tester.takeException(), isNull);

    // Dispose app-level periodic timers before the host test exits.
    await tester.pumpWidget(const SizedBox.shrink());
  });

  testWidgets('returning user sees tutorial until choosing do not show',
      (tester) async {
    GameData.onboardingSeen = true;
    GameData.tutorialDoNotShow = false;

    await tester.pumpWidget(
      const ProviderScope(child: JazirehFandoghiApp()),
    );
    await tester.pump(const Duration(seconds: 3));
    await tester.pump(const Duration(milliseconds: 500));

    expect(find.byType(AppTutorialScreen), findsOneWidget);
    expect(find.text('من فندقی‌ام؛ راهنمای همیشگی تو'), findsOneWidget);
    expect(tester.takeException(), isNull);

    await tester.pumpWidget(const SizedBox.shrink());
  });
}
