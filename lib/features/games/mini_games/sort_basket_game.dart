import 'dart:math';

import 'package:flutter/material.dart';

import '../../../app/app_colors.dart';
import '../mini_game_models.dart';
import '../mini_game_scaffold.dart';

/// ═══════════════════════════════════════════════════════════════
/// 🧺 سبد دسته‌بندی — بازی ۱۰ از دنیای بازی‌های تازه (نسخه ۷.۰.۰)
///
/// کودک همهٔ اعضای دستهٔ خواسته‌شده را انتخاب می‌کند و در سبد
/// می‌گذارد (چندانتخابی با دکمهٔ تأیید). بازی واقعی طبقه‌بندی.
/// مهارت: logic | مأموریت: logic
/// ═══════════════════════════════════════════════════════════════
class SortBasketGame extends StatelessWidget {
  const SortBasketGame({super.key});

  static const MiniGameSpec spec = MiniGameSpec(
    title: 'سبد دسته‌بندی 🧺',
    gameId: 'سبد دسته‌بندی',
    skill: 'logic',
    missionId: 'logic',
    gradient: AppGradients.sunset,
    introCoach: 'سبد آماده است! فقط چیزهایی که فندقی می‌گوید داخلش بگذار 🧺',
    rewardCoach: 'تو عالی دسته‌بندی می‌کنی! یک فروشندهٔ کوچک حرفه‌ای 🧺✨',
    rounds: 4,
  );

  /// دسته‌ها: کلید = چیزی که روی سبد نوشته می‌شود.
  static const Map<String, List<String>> categories =
      <String, List<String>>{
    'میوه': ['🍎', '🍌', '🍇', '🍉', '🍓', '🍐'],
    'حیوان': ['🐱', '🐶', '🐰', '🐼', '🦁', '🐸'],
    'وسیلهٔ نقلیه': ['🚗', '🚌', '🚲', '✈️', '🚂', '🚁'],
    'گل و گیاه': ['🌳', '🌸', '🌴', '🌲', '🌺', '🌻'],
  };

  /// ساخت دورها — خالص و قابل تست واحد.
  /// هر دور: ۳ عضو دستهٔ هدف + ۳ عضو مزاحم از دسته‌های دیگر.
  static List<MiniGameRound> buildRounds({Random? rng}) {
    final random = rng ?? Random();
    final categoryNames = categories.keys.toList()..shuffle(random);
    final rounds = <MiniGameRound>[];
    for (var i = 0; i < 4 && i < categoryNames.length; i++) {
      final target = categoryNames[i];
      final targetMembers = [...categories[target]!]..shuffle(random);
      final others = <String>[];
      final otherCats =
          categories.keys.where((c) => c != target).toList()..shuffle(random);
      for (final c in otherCats) {
        others.addAll(categories[c]!);
      }
      others.shuffle(random);
      final options = <MiniGameOption>[
        for (var j = 0; j < 3; j++)
          MiniGameOption(targetMembers[j], correct: true),
        for (var j = 0; j < 3; j++) MiniGameOption(others[j]),
      ]..shuffle(random);
      rounds.add(MiniGameRound(
        prompt: 'همهٔ «$target»ها را در سبد بگذار',
        scene: '🧺 $target',
        sceneFontSize: 42,
        sceneIsText: true,
        options: options,
        hint: 'فقط $target‌ها داخل سبد می‌روند؛ بقیه را جا بگذار 😉',
        multiSelect: true,
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
