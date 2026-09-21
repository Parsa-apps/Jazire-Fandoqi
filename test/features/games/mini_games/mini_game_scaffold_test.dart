import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:jazireh_fandoghi/app/app_colors.dart';
import 'package:jazireh_fandoghi/core/fandoghi_coach.dart';
import 'package:jazireh_fandoghi/core/game_data.dart';
import 'package:jazireh_fandoghi/features/games/mini_games/mini_game_models.dart';
import 'package:jazireh_fandoghi/features/games/mini_games/mini_game_scaffold.dart';

const _spec = MiniGameSpec(
  title: 'بازی آزمایشی 🧪',
  gameId: 'بازی آزمایشی',
  skill: 'logic',
  missionId: 'logic',
  gradient: AppGradients.primary,
  introCoach: 'سلام! شروع کنیم',
  rewardCoach: 'تمام شد!',
  rounds: 3,
);

List<MiniGameRound> _fixedRounds() => <MiniGameRound>[
      MiniGameRound(
        prompt: '۱ + ۱ چند می‌شود؟',
        scene: '🧪',
        options: [
          MiniGameOption('۲', correct: true),
          MiniGameOption('۳'),
        ],
        hint: 'دوتا یکی دیگه اضافه کن',
      ),
      MiniGameRound(
        prompt: 'کدام میوه است؟',
        scene: '🍽️',
        options: [
          MiniGameOption('🍌', correct: true),
          MiniGameOption('🐱'),
        ],
        hint: 'زرد و خوشمزه!',
      ),
      MiniGameRound(
        prompt: 'همهٔ میوه‌ها را بگذار داخل سبد',
        scene: '🧺',
        options: [
          MiniGameOption('🍎', correct: true),
          MiniGameOption('🍌', correct: true),
          MiniGameOption('🐶'),
        ],
        hint: 'سیب و موز میوه‌اند',
        multiSelect: true,
      ),
    ];

Future<void> _pump(WidgetTester tester) async {
  await tester.pumpWidget(
    MaterialApp(
      locale: const Locale('fa'),
      supportedLocales: const [Locale('fa')],
      home: MiniGameScaffold(
        spec: _spec,
        roundFactory: _fixedRounds,
      ),
    ),
  );
  await tester.pump(const Duration(milliseconds: 100));
}

void main() {
  setUp(GameData.resetForTesting);

  tearDown(() {
    FandoghiCoach.clear();
    FandoghiCoach.disablePersistentPresence();
  });

  testWidgets('جریان کامل: پاسخ درست → دور بعد؛ اشتباه بدون شکست', (tester) async {
    await _pump(tester);

    // دور ۱ — اول یک اشتباه (گزینهٔ ۳) سپس درست (۲)
    expect(find.text('۱ + ۱ چند می‌شود؟'), findsOneWidget);
    await tester.tap(find.text('۳'));
    await tester.pump(const Duration(milliseconds: 300));
    // دور عوض نشده؛ کودک می‌تواند دوباره امتحان کند
    expect(find.text('۱ + ۱ چند می‌شود؟'), findsOneWidget);

    await tester.tap(find.text('۲'));
    await tester.pump(const Duration(milliseconds: 300));
    // XP: تلاش ۱ + درست ۲ = ۳ — تلاش هم پاداش دارد
    expect(GameData.xp, 3);

    // دور ۲
    await tester.pump(const Duration(milliseconds: 1200));
    expect(find.text('کدام میوه است؟'), findsOneWidget);
    await tester.tap(find.text('🍌'));
    await tester.pump(const Duration(milliseconds: 300));

    // دور ۳ — چندانتخابی
    await tester.pump(const Duration(milliseconds: 1200));
    expect(find.text('همهٔ میوه‌ها را بگذار داخل سبد'), findsOneWidget);
    await tester.tap(find.text('🍎'));
    await tester.pump(const Duration(milliseconds: 200));
    await tester.tap(find.text('🐶')); // مزاحم
    await tester.pump(const Duration(milliseconds: 200));
    await tester.tap(find.text('گذاشتم! ۲ تا 🧺'));
    await tester.pump(const Duration(milliseconds: 400));
    // هنوز در همان دور — بازخورد مثبتِ «تقریباً»
    expect(find.text('همهٔ میوه‌ها را بگذار داخل سبد'), findsOneWidget);

    // انتخاب درست: میوه‌ها
    await tester.tap(find.text('🐶')); // برداشتن مزاحم
    await tester.pump(const Duration(milliseconds: 200));
    await tester.tap(find.text('🍌'));
    await tester.pump(const Duration(milliseconds: 200));
    await tester.tap(find.text('گذاشتم! ۲ تا 🧺'));
    await tester.pump(const Duration(milliseconds: 400));

    // صفحهٔ نتیجه
    await tester.pump(const Duration(milliseconds: 1500));
    expect(find.text('بازی آزمایشی 🧪'), findsOneWidget);
    expect(find.text('دور جدید 🔄'), findsOneWidget);
  });

  testWidgets('مأموریت، مهارت و آمار بازی ثبت می‌شود', (tester) async {
    await _pump(tester);

    await tester.tap(find.text('۲'));
    await tester.pump(const Duration(milliseconds: 400));
    await tester.pump(const Duration(milliseconds: 1200));
    await tester.tap(find.text('🍌'));
    await tester.pump(const Duration(milliseconds: 400));
    await tester.pump(const Duration(milliseconds: 1200));

    // سبد: هر دو میوه
    await tester.tap(find.text('🍎'));
    await tester.pump();
    await tester.tap(find.text('🍌'));
    await tester.pump();
    await tester.tap(find.text('گذاشتم! ۲ تا 🧺'));
    await tester.pump(const Duration(milliseconds: 1200));

    expect(GameData.playedGames, contains('بازی آزمایشی'));
    // سه پاسخ درست داده شد ولی سقف مأموریت logic برابر ۲ است
    expect(GameData.missionValue('logic'), 2);
    expect(GameData.skills['logic'], greaterThanOrEqualTo(3));
    // XP: ۲+۲+۲ (پاسخ‌های درست) + ۵ (پایان بازی)
    expect(GameData.xp, 11);
  });

  testWidgets('Hint ظریف بعد از ۱۰ ثانیه بی‌حرکتی فعال می‌شود (بدون کرش)',
      (tester) async {
    await _pump(tester);
    // تایمر Hint از postFrame شروع می‌شود
    await tester.pump(const Duration(seconds: 11));
    expect(find.text('۱ + ۱ چند می‌شود؟'), findsOneWidget);
    // فندقی راهنما را گفته و بازی پایدار مانده
    expect(tester.takeException(), isNull);
  });

  testWidgets('دور جدید دوباره از اول شروع می‌شود', (tester) async {
    await _pump(tester);
    // سه دور را کامل کن
    await tester.tap(find.text('۲'));
    await tester.pump(const Duration(milliseconds: 1200));
    await tester.pump(const Duration(milliseconds: 1200));
    await tester.tap(find.text('🍌'));
    await tester.pump(const Duration(milliseconds: 1200));
    await tester.pump(const Duration(milliseconds: 1200));
    await tester.tap(find.text('🍎'));
    await tester.pump(const Duration(milliseconds: 200));
    await tester.tap(find.text('🍌'));
    await tester.pump(const Duration(milliseconds: 200));
    await tester.tap(find.text('گذاشتم! ۲ تا 🧺'));
    await tester.pump(const Duration(milliseconds: 1200));
    await tester.pump(const Duration(milliseconds: 1200));

    await tester.tap(find.text('دور جدید 🔄'));
    await tester.pump(const Duration(milliseconds: 300));
    expect(find.text('۱ + ۱ چند می‌شود؟'), findsOneWidget);
  });
}
