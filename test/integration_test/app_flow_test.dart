import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:jazireh_fandoghi/core/fandoghi_coach.dart';
import 'package:jazireh_fandoghi/core/game_data.dart';
import 'package:jazireh_fandoghi/core/growth/growth_store.dart';
import 'package:jazireh_fandoghi/features/gateway/app_gateway_screen.dart';
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
    // The splash now fades itself out (340ms) before swapping routes, and a
    // timer only starts the fade at the end of the minimum-visible window;
    // several short frames are needed for the fade + route transition.
    await tester.pump(const Duration(seconds: 3));
    for (var frame = 0; frame < 5; frame++) {
      await tester.pump(const Duration(milliseconds: 200));
    }

    expect(find.byType(AppTutorialScreen), findsOneWidget);
    expect(find.text('به جزیره فندقی خوش آمدی'), findsOneWidget);
    expect(tester.takeException(), isNull);

    await tester.pumpWidget(const SizedBox.shrink());
  });

  testWidgets('returning user skips tutorial and goes to main page',
      (tester) async {
    // کاربر قبلاً آموزش را دیده است
    GameData.onboardingSeen = true;

    await tester.pumpWidget(
      const ProviderScope(child: JazirehFandoghiApp()),
    );
    await tester.pump(const Duration(seconds: 3));
    for (var frame = 0; frame < 5; frame++) {
      await tester.pump(const Duration(milliseconds: 200));
    }

    // آموزش نمایش داده نمی‌شود — مستقیم به دروازه (صفحه اصلی) می‌رود
    expect(find.byType(AppTutorialScreen), findsNothing);
    expect(find.byType(AppGatewayScreen), findsOneWidget);
    expect(tester.takeException(), isNull);

    // جزیره فندقی به کودک خوش‌آمد می‌گوید؛ تایمرِ حبابِ فندقی یک کانالِ
    // سراسری است و باید پیش از پایانِ تست آزاد شود، وگرنه به‌عنوان
    // «تایمر معلق بعد از تخریب درخت ویجت» گزارش می‌شود.
    // تایمرهای یکبارهٔ صفحهٔ اصلی (حبابِ فندقی، بنرها و انیمیشن‌های
    // زمان‌بندی‌شده) باید پیش از تخریبِ درخت تمام شوند؛ وگرنه flutter_test
    // آن‌ها را «تایمر معلق بعد از تخریب درخت ویجت» می‌بیند.
    await tester.pump(const Duration(seconds: 8));
    FandoghiCoach.clear();
    FandoghiCoach.cancelSmartHint();
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
    for (var frame = 0; frame < 5; frame++) {
      await tester.pump(const Duration(milliseconds: 200));
    }

    // تازه‌های نسخه روی صفحه است (نه آموزش)
    expect(find.byType(WhatsNewScreen), findsOneWidget);
    expect(find.byType(AppTutorialScreen), findsNothing);
    expect(tester.takeException(), isNull);

    // با زدن «بزن بریم بازی کنیم» به مقصد اصلی (آموزش) می‌رود
    // دکمه داخل ListView تنب است و پایین صفحه می‌افتد؛ اول اسکرول می‌کنیم.
    // `scrollUntilVisible` تا «ساخته‌شدن» ویجت اسکرول می‌کند و ممکن است دکمه
    // هنوز بیرون قاب باشد، پس با `ensureVisible` کامل داخل قاب می‌آید؛ وگرنه
    // لمس روی دکمه نمی‌افتد و ناوبری انجام نمی‌شود.
    final startButton = find.text('بزن بریم بازی کنیم 🎮');
    await tester.scrollUntilVisible(startButton, 200);
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
