import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:jazireh_fandoghi/core/game_data.dart';
import 'package:jazireh_fandoghi/core/growth/growth_store.dart';
import 'package:jazireh_fandoghi/features/growth/whats_new_screen.dart';
import 'package:jazireh_fandoghi/features/splash/splash_screen.dart';
import 'package:jazireh_fandoghi/features/tutorial/app_tutorial_screen.dart';
import 'package:jazireh_fandoghi/main.dart';

/// تست میزبان برای رندر پوستهٔ برنامه و عبور زمان‌بندی‌شده از اسپلش.
void main() {
  setUp(() {
    GoogleFonts.config.allowRuntimeFetching = false;
    GameData.resetForTesting();
    // نسخه ۷: کاربرِ به‌روز «تازه‌های نسخه» را دیده است؛ اسپلش مستقیم
    // به آموزش/دروازه می‌رود. (حالت آپدیت جداگانه پایین‌تر تست می‌شود.)
    GrowthStore.lastWhatsNewVersion = GrowthStore.appVersion;
  });

  testWidgets('fresh install reaches tutorial directly after splash',
      (tester) async {
    await tester.pumpWidget(
      const ProviderScope(child: JazirehFandoghiApp()),
    );
    await tester.pump();

    expect(find.byType(JazirehFandoghiApp), findsOneWidget);
    expect(find.byType(SplashScreen), findsOneWidget);

    // SplashScreen and tutorial intentionally own repeating animations, so
    // pumpAndSettle can never complete. Advance by bounded durations instead.
    await tester.pump(const Duration(seconds: 3));
    await tester.pump(const Duration(milliseconds: 500));

    expect(find.byType(AppTutorialScreen), findsOneWidget);
    expect(find.text('من فندقی‌ام؛ راهنمای همیشگی تو'), findsOneWidget);
    expect(tester.takeException(), isNull);

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

  testWidgets(
      'نسخه ۷: بعد از آپدیت، تازه‌های نسخه یک‌بار و سپس آموزش نمایش داده می‌شود',
      (tester) async {
    // کاربر نسخهٔ ۶.۲.۶: تازه‌های ۷.۰.۰ را هنوز ندیده است
    GrowthStore.lastWhatsNewVersion = '6.2.6';

    await tester.pumpWidget(
      const ProviderScope(child: JazirehFandoghiApp()),
    );
    await tester.pump(const Duration(seconds: 3));
    await tester.pump(const Duration(milliseconds: 500));

    // تازه‌های نسخه روی صفحه است (نه آموزش)
    expect(find.byType(WhatsNewScreen), findsOneWidget);
    expect(find.byType(AppTutorialScreen), findsNothing);
    expect(tester.takeException(), isNull);

    // با زدن «بزن بریم بازی کنیم» به مقصد اصلی (آموزش) می‌رود
    // دکمه داخل ListView تنب است و پایین صفحه می‌افتد؛ اول اسکرول می‌کنیم.
    final startButton = find.text('بزن بریم بازی کنیم 🎮');
    await tester.scrollUntilVisible(startButton, 200);
    // ممکن است فقط تکهٔ بالای دکمه داخل دید باشد ( ListView با
    // cacheExtent می‌سازدش)؛ برای لمسِ مرکز، کامل داخل دید می‌آوریم.
    await tester.ensureVisible(startButton);
    // دکمه با fadeIn(delay: 500ms) ظاهر می‌شود؛ تا پیش از کامل‌شدن
    // انیمیشن، opacity صفر است و لمس آن از دست می‌رود (warnIfMissed).
    await tester.pump(const Duration(milliseconds: 1000));
    await tester.tap(startButton);
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 600));

    expect(find.byType(AppTutorialScreen), findsOneWidget);
    expect(GrowthStore.shouldShowWhatsNew, isFalse);

    await tester.pumpWidget(const SizedBox.shrink());
  });

}
