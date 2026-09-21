import 'dart:math';

import 'package:flutter/material.dart';

import '../../../app/app_colors.dart';
import '../../../core/ai_system.dart';
import '../mini_game_models.dart';
import '../mini_game_scaffold.dart';

/// ═══════════════════════════════════════════════════════════════
/// 🔷 جورچین شکل‌ها — بازی ۶ از دنیای بازی‌های تازه (نسخه ۷.۰.۰)
///
/// شکل هدف در صحنه نمایش داده می‌شود (با نامش) و کودک همان
/// شکل را بین گزینه‌ها پیدا می‌کند؛ تشخیص شکل مستخلف از رنگ.
/// مهارت: shapes
/// ═══════════════════════════════════════════════════════════════
class ShapeMatchGame extends StatelessWidget {
  const ShapeMatchGame({super.key});

  static const MiniGameSpec spec = MiniGameSpec(
    title: 'جورچین شکل‌ها 🔷',
    gameId: 'جورچین شکل‌ها',
    skill: 'shapes',
    gradient: AppGradients.hero,
    introCoach: 'شکل‌ها قایموشک بازی کرده‌اند! همین شکل را پیدا کن 🔍',
    rewardCoach: 'تو همهٔ شکل‌ها را می‌شناسی! یک مهندس کوچک 📐',
    rounds: 6,
  );

  /// هر شکل چند ایموجی رنگی دارد تا تشخیص از روی «شکل» باشد نه رنگ.
  static const List<(String, List<String>)> shapes = <(String, List<String>)>[
    ('دایره', ['🔵', '🔴', '🟢', '🟡', '🟣', '🟠']),
    ('مثلث', ['🔺', '🔻']),
    ('مربع', ['🟥', '🟦', '🟩', '🟨', '🟪', '🟧']),
    ('لوزی', ['🔶', '🔷']),
    ('ستاره', ['⭐', '🌟']),
    ('قلب', ['❤️', '🧡', '💚', '💙', '💜', '🖤']),
  ];

  /// ساخت دورها — خالص و قابل تست واحد.
  static List<MiniGameRound> buildRounds({
    int count = 6,
    int optionCount = 3,
    Random? rng,
  }) {
    final random = rng ?? Random();
    final picked = <(String, List<String>)>[...shapes]..shuffle(random);
    final n = count < picked.length ? count : picked.length;
    final rounds = <MiniGameRound>[];
    for (var i = 0; i < n; i++) {
      final (name, emojis) = picked[i];
      // نمای هدف: یکی از ایموجی‌های همان شکل
      final target = emojis[random.nextInt(emojis.length)];
      // گزینهٔ درست: ایموجی دیگری از همان شکل (رنگ متفاوت!)
      final sameShape = emojis.where((e) => e != target).toList();
      final correctEmoji =
          sameShape.isNotEmpty ? sameShape[random.nextInt(sameShape.length)] : target;
      // گزینه‌های انحرافی: از شکل‌های دیگر
      final others = <String>[];
      for (final (otherName, otherEmojis) in shapes) {
        if (otherName == name) continue;
        others.addAll(otherEmojis);
      }
      others.shuffle(random);
      final options = <MiniGameOption>[
        MiniGameOption(correctEmoji, correct: true),
        for (final e in others.take((optionCount - 1).clamp(1, 5))) //
          MiniGameOption(e),
      ]..shuffle(random);
      rounds.add(MiniGameRound(
        prompt: 'شکل «$name» را پیدا کن',
        scene: target,
        sceneFontSize: 64,
        options: options,
        hint: 'به تعداد گوشه‌ها نگاه کن؛ «$name» چه شکلی دارد؟ 😉',
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
