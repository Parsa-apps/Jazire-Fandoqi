import 'dart:math';

import 'package:flutter/material.dart';

import '../../../app/app_colors.dart';
import 'mini_game_models.dart';
import 'mini_game_scaffold.dart';

/// ═══════════════════════════════════════════════════════════════
/// 🕵️ متفاوت را پیدا کن — بازی ۹ از دنیای بازی‌های تازه (نسخه ۷.۰.۰)
///
/// سه عضو از یک دسته + یک عضو از دستهٔ دیگر؛ کودک مورد
/// متفاوت را پیدا می‌کند. پایهٔ مهارت طبقه‌بندی ذهنی.
/// مهارت: logic | مأموریت: logic
/// ═══════════════════════════════════════════════════════════════
class OddOneOutGame extends StatelessWidget {
  const OddOneOutGame({super.key});

  static const MiniGameSpec spec = MiniGameSpec(
    title: 'متفاوت را پیدا کن 🕵️',
    gameId: 'متفاوت را پیدا کن',
    skill: 'logic',
    missionId: 'logic',
    gradient: AppGradients.primary,
    introCoach: 'یکی از این‌ها با بقیه فرق دارد! مثل کارآگاه پیدا کن 🕵️',
    rewardCoach: 'چشم تیز کارآگاه داری! هیچ متفاوتی از تو پنهان نمی‌ماند 🔍',
    rounds: 6,
  );

  /// دسته‌های آشنا برای کودک — هر کدام حداقل ۴ عضو.
  static const Map<String, List<String>> categories =
      <String, List<String>>{
    'میوه': ['🍎', '🍌', '🍇', '🍉', '🍓', '🍐'],
    'حیوان': ['🐱', '🐶', '🐰', '🐼', '🦁', '🐸'],
    'وسیلهٔ نقلیه': ['🚗', '🚌', '🚲', '✈️', '🚂', '🚁'],
    'گل و گیاه': ['🌳', '🌸', '🌴', '🌲', '🌺', '🌻'],
  };

  /// ساخت دورها — خالص و قابل تست واحد.
  /// تعداد گزینه‌ها = اعضای دستهٔ اصلی + یک مورد متفاوت.
  static List<MiniGameRound> buildRounds({
    int count = 6,
    int optionCount = 4,
    Random? rng,
  }) {
    final random = rng ?? Random();
    final categoryNames = categories.keys.toList()..shuffle(random);
    final rounds = <MiniGameRound>[];
    for (var i = 0; i < count; i++) {
      final mainCat = categoryNames[i % categoryNames.length];
      final otherCats =
          categories.keys.where((c) => c != mainCat).toList()..shuffle(random);
      final oddCat = otherCats.first;
      final mainMembers = [...categories[mainCat]!]..shuffle(random);
      final oddMember =
          categories[oddCat]![random.nextInt(categories[oddCat]!.length)];
      final mainCount = (optionCount - 1).clamp(2, 5);
      final options = <MiniGameOption>[
        for (var j = 0; j < mainCount; j++) MiniGameOption(mainMembers[j]),
        MiniGameOption(oddMember, correct: true),
      ]..shuffle(random);
      rounds.add(MiniGameRound(
        prompt: 'کدام با بقیه فرق دارد؟',
        scene: '🧐',
        sceneFontSize: 56,
        options: options,
        hint: 'سه‌تای این‌ها «$mainCat» هستند؛ یکی از آن‌ها نیست! 😉',
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
