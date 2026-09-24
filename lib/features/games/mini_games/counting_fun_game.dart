import 'dart:math';

import 'package:flutter/material.dart';

import '../../../app/app_colors.dart';
import '../../../core/ai_system.dart';
import '../../../core/growth/persian_digits.dart';
import 'mini_game_models.dart';
import 'mini_game_scaffold.dart';

/// ═══════════════════════════════════════════════════════════════
/// 🔢 شمارش خوش — بازی ۳ از دنیای بازی‌های تازه (نسخه ۷.۰.۰)
///
/// گروهی از اشیای آشنا نمایش داده می‌شود و کودک تعداد را
/// از بین اعداد فارسی انتخاب می‌کند؛ پایهٔ عددشناسی.
/// مهارت: counting | مأموریت: counting
/// ═══════════════════════════════════════════════════════════════
class CountingFunGame extends StatelessWidget {
  const CountingFunGame({super.key});

  static const MiniGameSpec spec = MiniGameSpec(
    title: 'شمارش خوش 🔢',
    gameId: 'شمارش خوش',
    skill: 'counting',
    missionId: 'counting',
    gradient: AppGradients.candy,
    introCoach: 'بیابố بشماریم! چند تا می‌بینی؟ با انگشت هم می‌توانی بشماری ☝️',
    rewardCoach: 'چطور شمارنده‌ای! اعداد دوست تو شدند 🔢💛',
    rounds: 6,
  );

  static const Map<String, String> objects = <String, String>{
    'سیب': '🍎',
    'ستاره': '⭐',
    'ماهی': '🐟',
    'بادکنک': '🎈',
    'گل': '🌸',
    'کفشدوزک': '🐞',
    'موز': '🍌',
  };

  /// ساخت دورها — خالص و قابل تست واحد.
  /// [optionCount] تعداد گزینه‌های عددی (۲ تا ۴) است.
  static List<MiniGameRound> buildRounds({
    int count = 6,
    int optionCount = 3,
    Random? rng,
  }) {
    final random = rng ?? Random();
    final names = objects.keys.toList()..shuffle(random);
    final rounds = <MiniGameRound>[];
    for (var i = 0; i < count; i++) {
      // سطح‌بندی نرم: از ۱ تا حداکثر ۹
      final maxN = 3 + optionCount * 2; // ۷..۹ بسته به سختی
      final n = 1 + random.nextInt(maxN.clamp(4, 9));
      final name = names[i % names.length];
      final emoji = objects[name]!;
      final scene = List.filled(n, emoji).join(' ');
      final correct = n;
      // گزینه‌های انحرافی: مجموعهٔ قطعی از همسایه‌های عدد درست — بدون
      // حلقهٔ باز (QA: قبلاً برای correct=1 ممکن بود بی‌پایان شود).
      final need = (optionCount - 1).clamp(1, 5);
      final candidates = <int>{
        for (var d = max(1, correct - 3);
            d <= min(12, correct + 3);
            d++)
          if (d != correct) d,
      }.toList()
        ..shuffle(random);
      final options = <MiniGameOption>[
        MiniGameOption(PersianDigits.toFa(correct), correct: true),
        for (final d in candidates.take(need)) MiniGameOption(PersianDigits.toFa(d)),
      ]..shuffle(random);
      rounds.add(MiniGameRound(
        prompt: 'چند تا $name است؟',
        scene: scene,
        sceneFontSize: 38,
        options: options,
        hint: 'با انگشت‌هایت یکی‌یکی بشمار: یک، دو، سه... 😉',
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
