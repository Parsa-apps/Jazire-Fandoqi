import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:jazireh_fandoghi/app/island_world_style.dart';
import 'package:jazireh_fandoghi/core/fandoghi_coach.dart';
import 'package:jazireh_fandoghi/shared/widgets/fandoghi_coach.dart';
import 'package:jazireh_fandoghi/shared/widgets/fandoghi_hazelnut_character.dart';

void main() {
  setUp(() {
    GoogleFonts.config.allowRuntimeFetching = false;
    FandoghiCoach.clear();
  });

  tearDown(FandoghiCoach.clear);

  testWidgets('success feedback uses the new celebration pose', (tester) async {
    FandoghiCoach.celebrate('آفرین!');

    await tester.pumpWidget(
      const MaterialApp(
        home: FandoghiCoachOverlay(child: SizedBox.shrink()),
      ),
    );
    await tester.pump();

    final image = tester.widget<Image>(find.byType(Image));
    expect(
      _assetImageFrom(image.image).assetName,
      IslandWorldAssets.fandoghiCelebrate,
    );

    await tester.pumpWidget(const SizedBox.shrink());
    // تایمر پنهان‌شدن پیام مربی (۳ ثانیه) باید پیش از پایان تست تخلیه
    // شود؛ همان الگوی کمکیِ app_smoke_test.
    FandoghiCoach.clear();
    await tester.pump(const Duration(seconds: 6));
  });

  testWidgets('non-success feedback keeps the animated character widget',
      (tester) async {
    FandoghiCoach.say('سلام!', tone: FandoghiCoachTone.neutral);

    await tester.pumpWidget(
      const MaterialApp(
        home: FandoghiCoachOverlay(child: SizedBox.shrink()),
      ),
    );
    await tester.pump();

    expect(find.byType(FandoghiHazelnutCharacter), findsOneWidget);
    expect(find.byType(Image), findsNothing);

    await tester.pumpWidget(const SizedBox.shrink());
    FandoghiCoach.clear();
    await tester.pump(const Duration(seconds: 6));
  });
}

AssetImage _assetImageFrom(ImageProvider<Object> provider) {
  if (provider is ResizeImage) {
    return _assetImageFrom(provider.imageProvider);
  }
  return provider as AssetImage;
}
