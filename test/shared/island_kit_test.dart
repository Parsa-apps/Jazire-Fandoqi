import 'package:flutter/material.dart';
import 'package:flutter/semantics.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:jazireh_fandoghi/features/home/widgets/island_map/island_node.dart';
import 'package:jazireh_fandoghi/shared/widgets/island_kit.dart';

/// تست‌های کیت طراحی مشترک «دنیای جزیره»: دکمهٔ کودک باید با یک لمس
/// دقیقاً یک بار عمل کند، حالت غیرفعال هرگز عمل نکند و سکوی مجهز به
/// چراغ راهنما ستارهٔ «پیشنهاد امروز» را نشان بدهد.
void main() {
  testWidgets('kid button shows its label and fires exactly one tap',
      (tester) async {
    var taps = 0;
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: Center(
            child: IslandKidButton(
              label: 'شروع بازی',
              icon: Icons.play_arrow_rounded,
              onPressed: () => taps++,
            ),
          ),
        ),
      ),
    );
    await tester.pump();

    expect(find.text('شروع بازی'), findsOneWidget);

    await tester.tap(find.byType(IslandKidButton));
    await tester.pump();
    expect(taps, 1);

    // بازگشت فنری دکمه تمام شود تا تایمر معلقی نماند
    await tester.pump(const Duration(milliseconds: 400));
    await tester.pumpWidget(const SizedBox.shrink());
  });

  testWidgets('disabled kid button never fires', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: Center(
            child: IslandKidButton(label: 'صبر کن', onPressed: null),
          ),
        ),
      ),
    );
    await tester.pump();

    await tester.tap(find.byType(IslandKidButton));
    await tester.pump();

    final semantics = tester.getSemantics(
      find.descendant(
        of: find.byType(IslandKidButton),
        matching: find.byType(Semantics),
      ),
    );
    expect(semantics.hasFlag(SemanticsFlag.isButton), isTrue);
    expect(semantics.hasFlag(SemanticsFlag.isEnabled), isFalse);

    await tester.pumpWidget(const SizedBox.shrink());
  });

  testWidgets('panel and stat chip render their content', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: IslandPanel(
            child: IslandStatChip(
              icon: Icons.star_rounded,
              color: Color(0xFFFFB300),
              value: '۴۲',
              semanticLabel: '۴۲ ستاره',
            ),
          ),
        ),
      ),
    );
    await tester.pump();

    expect(find.text('۴۲'), findsOneWidget);
    expect(find.byIcon(Icons.star_rounded), findsOneWidget);

    await tester.pumpWidget(const SizedBox.shrink());
  });

  testWidgets('highlighted island node wears the guide star beacon',
      (tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: Center(
            child: IslandNode(
              asset: 'assets/theme_map/island_game.png',
              label: 'بازی‌ها',
              width: 170,
              floatPhase: 0,
              floatAnimation: AlwaysStoppedAnimation<double>(0.25),
              highlight: true,
              onTap: _noop,
            ),
          ),
        ),
      ),
    );
    await tester.pump(const Duration(milliseconds: 900));

    expect(
      find.descendant(
        of: find.byType(IslandNode),
        matching: find.byIcon(Icons.star_rounded),
      ),
      findsOneWidget,
    );

    await tester.pumpWidget(const SizedBox.shrink());
  });

  testWidgets('plain island node has no guide star', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: Center(
            child: IslandNode(
              asset: 'assets/theme_map/island_game.png',
              label: 'بازی‌ها',
              width: 170,
              floatPhase: 0,
              floatAnimation: AlwaysStoppedAnimation<double>(0.25),
              onTap: _noop,
            ),
          ),
        ),
      ),
    );
    await tester.pump(const Duration(milliseconds: 900));

    expect(
      find.descendant(
        of: find.byType(IslandNode),
        matching: find.byIcon(Icons.star_rounded),
      ),
      findsNothing,
    );

    await tester.pumpWidget(const SizedBox.shrink());
  });
}

void _noop() {}
