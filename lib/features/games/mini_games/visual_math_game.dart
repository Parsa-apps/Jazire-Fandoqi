import 'dart:math';

import 'package:flutter/material.dart';

import '../../../app/app_colors.dart';
import '../../../core/ai_system.dart';
import '../../../core/growth/persian_digits.dart';
import '../mini_game_models.dart';
import '../mini_game_scaffold.dart';

/// ═══════════════════════════════════════════════════════════════
/// ➕ جمع تصویری — بازی ۴ از دنیای بازی‌های تازه (نسخه ۷.۰.۰)
///
/// جمعِ ملموس با تصویر: «۲ تا سیب به‌علاوهٔ ۳ تا سیب چند می‌شود؟»
/// مفهوم جمع قبل از نماد ریاضی.
/// مهارت: math | مأموریت: math
/// ═══════════════════════════════════════════════════════════════
class VisualMathGame extends StatelessWidget {
  const VisualMathGame({super.key});

  static const MiniGameSpec spec = MiniGameSpec(
    title: 'جمع تصویری ➕',
    gameId: 'جمع تصویری',
    skill: 'math',
    missionId: 'math',
    gradient: AppGradients.island,
    introCoach: 'سیب‌ها جمع می‌شوند! دو دسته را با هم بشمار ➕',
    rewardCoach: 'تو جمع را با تصویر یاد گرفتی؛ چه ریاضیدان کوچکی! 🧮',
    rounds: 6,
  );

  static const Map<String, String> objects = <String, String>{
    'سیب': '🍎',
    'ستاره': '⭐',
    'ماهی': '🐟',
    'اردک': '🦆',
    'گیلاس': '🍒',
    'هویج': '🥕',
  };

  /// ساخت دورها — خالص و قابل تست واحد.
  static List<MiniGameRound> buildRounds({
    int count = 6,
    int optionCount = 3,
    Random? rng,
  }) {
    final random = rng ?? Random();
    final names = objects.keys.toList()..shuffle(random);
    final rounds = <MiniGameRound>[];
    for (var i = 0; i < count; i++) {
      // سطح‌بندی نرم: سخت‌تر → جمع تا ۱۰
      final cap = optionCount >= 4 ? 10 : (optionCount == 3 ? 8 : 5);
      final a = 1 + random.nextInt(cap ~/ 2);
      final b = 1 + random.nextInt((cap - a).clamp(1, cap ~/ 2));
      final sum = a + b;
      final name = names[i % names.length];
      final emoji = objects[name]!;
      final groupA = List.filled(a, emoji).join('');
      final groupB = List.filled(b, emoji).join('');
      final scene = '$groupA  +  $groupB';
      final correct = sum;
      // گزینه‌های انحرافی: مجموعهٔ قطعی از همسایه‌های نتیجه — بدون حلقهٔ باز
      // (QA: قبلاً برای sum=2 ممکن بود بی‌پایان شود).
      final need = (optionCount - 1).clamp(1, 5);
      final candidates = <int>{
        for (var d = max(2, sum - 3); d <= min(12, sum + 3); d++)
          if (d != sum) d,
      }.toList()
        ..shuffle(random);
      final options = <MiniGameOption>[
        MiniGameOption(PersianDigits.toFa(correct), correct: true),
        for (final d in candidates.take(need)) MiniGameOption(PersianDigits.toFa(d)),
      ]..shuffle(random);
      rounds.add(MiniGameRound(
        prompt: 'همهٔ $name‌ها با هم چند تا می‌شوند؟',
        scene: scene,
        sceneFontSize: 34,
        options: options,
        hint: 'اول یکی از دسته‌ها را بشمار، بعد دیگری را؛ با هم جمع کن 😉',
      ));
    }
    return rounds;
  }

  @override
  Widget build(BuildContext context) {
    return MiniGameScaffold(
      spec: spec,
      roundFactory: () => buildRounds(optionCount: AI.difficulty() + 1),
    );
  }
}
