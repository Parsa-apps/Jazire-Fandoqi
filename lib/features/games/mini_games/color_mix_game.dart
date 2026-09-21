import 'dart:math';

import 'package:flutter/material.dart';

import '../../../app/app_colors.dart';
import '../../../core/ai_system.dart';
import '../mini_game_models.dart';
import '../mini_game_scaffold.dart';

/// ═══════════════════════════════════════════════════════════════
/// 🎨 ترکیب رنگ — بازی ۷ از دنیای بازی‌های تازه (نسخه ۷.۰.۰)
///
/// دو حالت واقعی و مکمل:
///  ۱) شناخت رنگ: «این چه رنگی است؟» (گزینه‌ها نام رنگ‌ها هستند)
///  ۲) ترکیب رنگ: «آبی و زرد چه رنگی می‌شوند؟» (گزینه‌ها دایرهٔ رنگی)
/// مهارت: colors | مأموریت: colors
/// ═══════════════════════════════════════════════════════════════
class ColorMixGame extends StatelessWidget {
  const ColorMixGame({super.key});

  static const MiniGameSpec spec = MiniGameSpec(
    title: 'ترکیب رنگ 🎨',
    gameId: 'ترکیب رنگ',
    skill: 'colors',
    missionId: 'colors',
    gradient: AppGradients.pink,
    introCoach: 'رنگ‌ها با هم دوست می‌شوند و رنگ تازه می‌سازند! ببین چی درست می‌شود 🌈',
    rewardCoach: 'تو یک نقاش رنگ‌شناس هستی! رنگین‌کمان به تو افتخار می‌کند 🌈',
    rounds: 6,
  );

  /// رنگ‌های پایه با نام فارسی، ایموجی و رنگ واقعی.
  static const List<(String, String, Color)> palette =
      <(String, String, Color)>[
    ('قرمز', '🔴', Color(0xFFE53935)),
    ('آبی', '🔵', Color(0xFF1E88E5)),
    ('زرد', '🟡', Color(0xFFFDD835)),
    ('سبز', '🟢', Color(0xFF43A047)),
    ('نارنجی', '🟠', Color(0xFFFB8C00)),
    ('بنفش', '🟣', Color(0xFF8E24AA)),
    ('صورتی', '🌸', Color(0xFFEC407A)),
    ('قهوه‌ای', '🟤', Color(0xFF6D4C41)),
  ];

  /// ترکیب‌های واقعاً درست از دید کودک.
  static const List<(String, String, String)> mixes =
      <(String, String, String)>[
    ('آبی', 'زرد', 'سبز'),
    ('قرمز', 'زرد', 'نارنجی'),
    ('آبی', 'قرمز', 'بنفش'),
    ('قرمز', 'سفید', 'صورتی'),
  ];

  static Color _colorOf(String name) {
    for (final (n, _, c) in palette) {
      if (n == name) return c;
    }
    return Colors.grey;
  }

  static String _emojiOf(String name) {
    for (final (n, e, _) in palette) {
      if (n == name) return e;
    }
    return '⚫';
  }

  /// ساخت دورها — خالص و قابل تست واحد.
  static List<MiniGameRound> buildRounds({
    int count = 6,
    int optionCount = 3,
    Random? rng,
  }) {
    final random = rng ?? Random();
    final rounds = <MiniGameRound>[];
    for (var i = 0; i < count; i++) {
      // نصف دورها شناخت رنگ، نصف دیگر ترکیب رنگ
      final isMix = random.nextBool() && i % 2 == 1;
      if (isMix) {
        final (a, b, result) = mixes[random.nextInt(mixes.length)];
        final distractNames = palette
            .map((p) => p.$1)
            .where((n) => n != result && n != 'سفید')
            .toList()
          ..shuffle(random);
        final options = <MiniGameOption>[
          MiniGameOption(result, correct: true, swatch: _colorOf(result)),
          for (final n in distractNames.take((optionCount - 1).clamp(1, 5)))
            MiniGameOption(n, swatch: _colorOf(n)),
        ]..shuffle(random);
        rounds.add(MiniGameRound(
          prompt: '«$a» و «$b» با هم چه رنگی می‌شوند؟',
          scene: '${_emojiOf(a)}  +  ${_emojiOf(b)}',
          sceneFontSize: 46,
          options: options,
          hint: 'اگر $a و $b را با قلم‌مو قاطی کنی، رنگ «$result» می‌سازی 😉',
        ));
      } else {
        final (name, emoji, color) = palette[random.nextInt(palette.length)];
        final distractNames = palette
            .map((p) => p.$1)
            .where((n) => n != name)
            .toList()
          ..shuffle(random);
        final options = <MiniGameOption>[
          MiniGameOption(name, correct: true),
          for (final n in distractNames.take((optionCount - 1).clamp(1, 5)))
            MiniGameOption(n),
        ]..shuffle(random);
        rounds.add(MiniGameRound(
          prompt: 'این چه رنگی است؟',
          scene: emoji,
          sceneFontSize: 64,
          options: options,
          hint: 'رنگ این یکی مثل $emoji است؛ اسمش «$name» است 😉',
        ));
      }
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
