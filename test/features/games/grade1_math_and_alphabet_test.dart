import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:jazireh_fandoghi/features/games/alphabet_academy/alphabet_academy_game.dart';
import 'package:jazireh_fandoghi/features/games/math/tally_marks_game.dart';
import 'package:jazireh_fandoghi/features/games/math/place_value_game.dart';
import 'package:jazireh_fandoghi/features/games/math/number_line_game.dart';
import 'package:jazireh_fandoghi/features/games/math/symmetry_game.dart';

void main() {
  testWidgets('AlphabetAcademyGame renders Grade 1 mode and letters', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: AlphabetAcademyGame(),
      ),
    );
    await tester.pump(const Duration(milliseconds: 200));

    expect(find.text('آکادمی الفبا و اول دبستان 🔤'), findsOneWidget);
    expect(find.text('کتاب اول دبستان 📚'), findsOneWidget);
    expect(find.text('الفبایی سنتی 🔤'), findsOneWidget);
  });

  testWidgets('TallyMarksGame renders target and action button', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: TallyMarksGame(),
      ),
    );
    await tester.pump(const Duration(milliseconds: 200));

    expect(find.text('بازی چوب‌خط اول دبستان 🥢'), findsOneWidget);
    expect(find.text('چوب‌خط بکش 🥢 (+۱)'), findsOneWidget);
  });

  testWidgets('PlaceValueGame renders place value columns', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: PlaceValueGame(),
      ),
    );
    await tester.pump(const Duration(milliseconds: 200));

    expect(find.text('جدول ارزش مکانی 🧮'), findsOneWidget);
    expect(find.text('ده‌تایی‌ها (۱۰)'), findsOneWidget);
    expect(find.text('یکی‌ها (۱)'), findsOneWidget);
  });

  testWidgets('NumberLineGame renders jumping number line', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: NumberLineGame(),
      ),
    );
    await tester.pump(const Duration(milliseconds: 200));

    expect(find.text('محور اعداد جهنده 🐸'), findsOneWidget);
    expect(find.text('جهش به جلو (+۱)'), findsOneWidget);
    expect(find.text('جهش به عقب (-۱)'), findsOneWidget);
  });

  testWidgets('SymmetryGame renders symmetry grid and red line', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: SymmetryGame(),
      ),
    );
    await tester.pump(const Duration(milliseconds: 200));

    expect(find.text('بازی تقارن اول دبستان 🦋'), findsOneWidget);
  });
}
