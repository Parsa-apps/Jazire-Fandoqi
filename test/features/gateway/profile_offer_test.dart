import 'package:flutter/material.dart';
import '../../support/paywall_test_store.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:jazireh_fandoghi/core/fandoghi_coach.dart';
import 'package:jazireh_fandoghi/core/game_data.dart';
import 'package:jazireh_fandoghi/features/gateway/app_gateway_screen.dart';

void main() {
  setUpUnpurchasedStore();
  setUp(() {
    GoogleFonts.config.allowRuntimeFetching = false;
    GameData.resetForTesting();
  });

  tearDown(() {
    FandoghiCoach.clear();
    FandoghiCoach.disablePersistentPresence();
  });

  testWidgets('first guide completion offers profile setup politely',
      (tester) async {
    await tester.pumpWidget(
      ProviderScope(
        child: const MaterialApp(
          home: AppGatewayScreen(offerProfileSetup: true),
        ),
      ),
    );
    await tester.pump(const Duration(milliseconds: 500));

    expect(find.text('یک سؤال کوچک، با اجازهٔ شما 🌰'), findsOneWidget);
    expect(
      find.text('آیا مایل هستید همین حالا نام و مشخصات کودکتان را وارد کنید؟'),
      findsOneWidget,
    );
    expect(find.byKey(const ValueKey('profile_offer_accept')), findsOneWidget);
    expect(find.byKey(const ValueKey('profile_offer_later')), findsOneWidget);

    // محتوای دیالوگ اسکرول‌شدنی است و در قابِ کوتاهِ تست، دکمهٔ «فعلاً نه»
    // پایین‌تر از دید می‌افتد؛ بدون ensureVisible لمس روی آن نمی‌نشیند و
    // دیالوگ باز می‌ماند.
    final later = find.byKey(const ValueKey('profile_offer_later'));
    await tester.ensureVisible(later);
    await tester.pump();
    await tester.tap(later);
    // The dismissal animation only starts ticking on the frame after the tap,
    // so the route is still on screen after a single pump: advance a couple of
    // bounded frames (the island behind the dialog animates forever, which
    // rules out pumpAndSettle) and then assert it is gone.
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 400));
    await tester.pump(const Duration(milliseconds: 100));
    expect(find.text('یک سؤال کوچک، با اجازهٔ شما 🌰'), findsNothing);

    await tester.pumpWidget(const SizedBox.shrink());
  });

  testWidgets('profile setup contains 20 bundled avatars and no gallery action',
      (tester) async {
    await tester.pumpWidget(
      ProviderScope(
        child: const MaterialApp(
          home: AppGatewayScreen(offerProfileSetup: true),
        ),
      ),
    );
    await tester.pump(const Duration(milliseconds: 500));
    final accept = find.byKey(const ValueKey('profile_offer_accept'));
    await tester.ensureVisible(accept);
    await tester.pump();
    await tester.tap(accept);
    await tester.pump(const Duration(milliseconds: 500));

    expect(find.text('یکی از ۲۰ آواتار بامزه را انتخاب کنید'), findsOneWidget);
    expect(find.byKey(const ValueKey('profile_avatar_0')), findsOneWidget);
    expect(find.byKey(const ValueKey('profile_avatar_19')), findsOneWidget);
    expect(find.byIcon(Icons.camera_alt_rounded), findsNothing);
    expect(find.textContaining('گالری'), findsNothing);

    await tester.pumpWidget(const SizedBox.shrink());
  });
}
