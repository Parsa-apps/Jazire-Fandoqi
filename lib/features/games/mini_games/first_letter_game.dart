import 'dart:math';

import 'package:flutter/material.dart';

import '../../../app/app_colors.dart';
import '../../../core/ai_system.dart';
import '../mini_game_models.dart';
import '../mini_game_scaffold.dart';

/// ═══════════════════════════════════════════════════════════════
/// 🔤 حرف اول — بازی ۱ از دنیای بازی‌های تازه (نسخه ۷.۰.۰)
///
/// تصویر واژه نمایش داده می‌شود و کودک حرف اول را از بین
/// گزینه‌ها پیدا می‌کند؛ تقویت آواشناسی و شروع خواندن.
/// مهارت: alphabet | مأموریت: words
/// ═══════════════════════════════════════════════════════════════
class FirstLetterGame extends StatelessWidget {
  const FirstLetterGame({super.key});

  static const MiniGameSpec spec = MiniGameSpec(
    title: 'حرف اول 🔤',
    gameId: 'حرف اول',
    skill: 'alphabet',
    missionId: 'words',
    gradient: AppGradients.ocean,
    introCoach: 'به سرزمین کلمه‌ها خوش آمدی! حرف اول هر کلمه را پیدا کن ✨',
    rewardCoach: 'چه خوب حرف‌ها را می‌شناسی! تو یک قهرمان کلمه‌ای 📚',
    rounds: 6,
  );

  /// واژه‌های ملموس و آشنای کودک ۳ تا ۸ سال — همه با تصویر روشن.
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
    ('پرنده', '🐦'),
    ('هندوانه', '🍉'),
    ('موز', '🍌'),
    ('گوجه', '🍅'),
    ('هواپیما', '✈️'),
    ('قطار', '🚂'),
    ('ماشین', '🚗'),
    ('اسب', '🐴'),
    ('مرغ', '🐔'),
    ('بستنی', '🍦'),
    ('کلاه', '👒'),
    ('جوراب', '🧦'),
    ('دوچرخه', '🚲'),
    ('ساعت', '⏰'),
    ('کلید', '🔑'),
    ('قلم', '🖊️'),
    ('کتاب', '📕'),
    ('صندلی', '🪑'),
  ];

  /// حروف پرکاربرد برای گزینه‌های انحرافی.
  static const List<String> letterPool = <String>[
    'ا', 'ب', 'پ', 'ت', 'ث', 'ج', 'چ', 'ح', 'خ', 'د', 'ر', 'ز', 'س',
    'ش', 'ف', 'ق', 'ک', 'گ', 'ل', 'م', 'ن', 'و', 'ه', 'ی',
  ];

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
      final correct = word.substring(0, 1);
      final distract = letterPool.where((l) => l != correct).toList()
        ..shuffle(random);
      final options = <MiniGameOption>[
        MiniGameOption(correct, correct: true),
        for (final l in distract.take((optionCount - 1).clamp(1, 5))) //
          MiniGameOption(l),
      ]..shuffle(random);
      rounds.add(MiniGameRound(
        prompt: '«$word» با کدام حرف شروع می‌شود؟',
        scene: '$emoji\n$word',
        sceneFontSize: 46,
        sceneIsText: true,
        options: options,
        hint: 'به اول «$word» نگاه کن؛ حرف «$correct» آنجاست 😉',
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
