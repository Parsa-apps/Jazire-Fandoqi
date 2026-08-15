import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:jazireh_fandoghi/core/fandoghi_coach.dart';
import 'package:jazireh_fandoghi/core/game_data.dart';
import 'package:jazireh_fandoghi/features/gateway/app_gateway_screen.dart';

void main() {
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

    await tester.tap(find.byKey(const ValueKey('profile_offer_later')));
    await tester.pump(const Duration(milliseconds: 400));
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
    await tester.tap(find.byKey(const ValueKey('profile_offer_accept')));
    await tester.pump(const Duration(milliseconds: 500));

    expect(find.text('یکی از ۲۰ آواتار بامزه را انتخاب کنید'), findsOneWidget);
    expect(find.byKey(const ValueKey('profile_avatar_0')), findsOneWidget);
    expect(find.byKey(const ValueKey('profile_avatar_19')), findsOneWidget);
    expect(find.byIcon(Icons.camera_alt_rounded), findsNothing);
    expect(find.textContaining('گالری'), findsNothing);

    await tester.pumpWidget(const SizedBox.shrink());
  });
}
