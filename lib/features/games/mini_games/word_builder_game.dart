import 'dart:math';

import 'package:flutter/material.dart';

import '../../../app/app_colors.dart';
import '../../../core/ai_system.dart';
import '../mini_game_models.dart';
import '../mini_game_scaffold.dart';

/// ═══════════════════════════════════════════════════════════════
/// 🧱 کلمه‌ساز — بازی ۲ از دنیای بازی‌های تازه (نسخه ۷.۰.۰)
///
/// واژه با یک حرف گم‌شده نمایش داده می‌شود (در هر جای کلمه)
/// و کودک حرف درست را می‌گذارد تا کلمه کامل شود.
/// مهارت: vocab | مأموریت: words
/// ═══════════════════════════════════════════════════════════════
class WordBuilderGame extends StatelessWidget {
  const WordBuilderGame({super.key});

  static const MiniGameSpec spec = MiniGameSpec(
    title: 'کلمه‌ساز 🧱',
    gameId: 'کلمه‌ساز',
    skill: 'vocab',
    missionId: 'words',
    gradient: AppGradients.forest,
    introCoach: 'یک حرف از کلمه‌ها گم شده! مثل یک معمار، حرف درست را جا بگذار 🧱',
    rewardCoach: 'تو کلمه‌های زیادی ساختی! یک معمار کلمه‌های واقعی 🏗️',
    rounds: 6,
  );

  /// واژه‌های کوتاه (۳ تا ۴ حرف) با تصویر — مناسب ساخت کلمه.
  static const List<(String, String)> words = <(String, String)>[
    ('توپ', '⚽'),
    ('سیب', '🍎'),
    ('ماه', '🌙'),
    ('خانه', '🏠'),
    ('ماهی', '🐟'),
    ('نان', '🍞'),
    ('دست', '✋'),
    ('شیر', '🦁'),
    ('گربه', '🐱'),
    ('درخت', '🌳'),
    ('موز', '🍌'),
    ('قطار', '🚂'),
    ('ماشین', '🚗'),
    ('اسب', '🐴'),
    ('مرغ', '🐔'),
    ('باد', '🍃'),
    ('گل', '🌼'),
    ('برف', '❄️'),
    ('کوه', '⛰️'),
    ('چشم', '👁️'),
  ];

  static const List<String> letterPool = <String>[
    'ا', 'ب', 'پ', 'ت', 'ج', 'چ', 'ح', 'د', 'ر', 'ز', 'س',
    'ش', 'ف', 'ق', 'ک', 'گ', 'ل', 'م', 'ن', 'و', 'ه', 'ی',
  ];

  /// نشانگر خانهٔ خالی — خوانا و کودک‌پسند (مربع خالی).
  static const String blank = '□';

  /// ساخت دورها — خالص و قابل تست واحد.
  static List<MiniGameRound> buildRounds({
    int count = 6,
    int optionCount = 3,
    Random? rng,
  }) {
    final random = rng ?? Random();
    final picks = <(String, String)>[...words]..shuffle(random);
    final n = count < picks.length ? count : picks.length;
    final rounds = <MiniGameRound>[];
    for (var i = 0; i < n; i++) {
      final (word, emoji) = picks[i];
      final missingAt = random.nextInt(word.length);
      final correct = word[missingAt];
      final broken = word.substring(0, missingAt) +
          blank +
          word.substring(missingAt + 1);
      final distract = letterPool.where((l) => l != correct).toList()
        ..shuffle(random);
      final options = <MiniGameOption>[
        MiniGameOption(correct, correct: true),
        for (final l in distract.take((optionCount - 1).clamp(1, 5))) //
          MiniGameOption(l),
      ]..shuffle(random);
      rounds.add(MiniGameRound(
        prompt: 'کدام حرف جا مانده است؟',
        scene: '$emoji\n$broken',
        sceneFontSize: 46,
        sceneIsText: true,
        options: options,
        hint: 'کلمهٔ «$word» را در سرت بخوان؛ حرف «$correct» جایش خالی است 😉',
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
