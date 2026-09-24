import 'dart:math';

import 'package:flutter/material.dart';

import '../../../app/app_colors.dart';
import 'mini_game_models.dart';
import 'mini_game_scaffold.dart';

/// ═══════════════════════════════════════════════════════════════
/// 🐘 بزرگ و کوچک — بازی ۵ از دنیای بازی‌های تازه (نسخه ۷.۰.۰)
///
/// مقایسهٔ اندازه با جفت‌های آشنا: «کدام بزرگ‌تر است؟»
/// گاهی برعکس می‌پرسد تا مفهوم مقایسه واقعاً ساخته شود.
/// مهارت: concepts
/// ═══════════════════════════════════════════════════════════════
class BigSmallGame extends StatelessWidget {
  const BigSmallGame({super.key});

  static const MiniGameSpec spec = MiniGameSpec(
    title: 'بزرگ و کوچک 🐘',
    gameId: 'بزرگ و کوچک',
    skill: 'concepts',
    gradient: AppGradients.aurora,
    introCoach: 'کدام بزرگ‌تر است و کدام کوچک‌تر؟ با دقت نگاه کن 👀',
    rewardCoach: 'تو مفهوم بزرگ و کوچک را کامل می‌دانی! 👏',
    rounds: 6,
  );

  /// جفت‌هایی که تفاوت اندازه‌شان برای کودک بدیهی است.
  static const List<(String, String)> pairs = <(String, String)>[
    ('🐘', '🐜'),
    ('🐋', '🐠'),
    ('🏠', '🔑'),
    ('✈️', '🐝'),
    ('🌳', '🌸'),
    ('🦁', '🐞'),
    ('🐴', '🐔'),
    ('🍉', '🍇'),
    ('🚂', '🚗'),
    ('🏔️', '🪨'),
    ('🌕', '⭐'),
    ('🦒', '🐢'),
  ];

  /// ساخت دورها — خالص و قابل تست واحد.
  static List<MiniGameRound> buildRounds({
    int count = 6,
    int optionCount = 2,
    Random? rng,
  }) {
    final random = rng ?? Random();
    final picked = <(String, String)>[...pairs]..shuffle(random);
    final n = count < picked.length ? count : picked.length;
    final rounds = <MiniGameRound>[];
    for (var i = 0; i < n; i++) {
      final (big, small) = picked[i];
      final askBig = random.nextBool();
      rounds.add(MiniGameRound(
        prompt: askBig ? 'کدام بزرگ‌تر است؟' : 'کدام کوچک‌تر است؟',
        scene: '⚖️',
        options: <MiniGameOption>[
          MiniGameOption(askBig ? big : small, correct: true),
          MiniGameOption(askBig ? small : big),
        ]..shuffle(random),
        hint: askBig
            ? 'به اندازه‌ها نگاه کن؛ یکی خیلی بزرگ‌تر دیده می‌شود 😉'
            : 'کدام توی یک دست جا می‌شود؟ کوچک‌تر را پیدا کن 😉',
      ));
    }
    return rounds;
  }

  @override
  Widget build(BuildContext context) {
    return MiniGameScaffold(
      spec: spec,
      roundFactory: () => buildRounds(),
    );
  }
}
