import 'dart:math';

import 'package:flutter/material.dart';

import '../../../app/app_colors.dart';
import '../../../core/growth/persian_digits.dart';
import 'mini_game_models.dart';
import 'mini_game_scaffold.dart';

/// ═══════════════════════════════════════════════════════════════
/// 🔢 ترتیب اعداد — بازی ۸ از دنیای بازی‌های تازه (نسخه ۷.۰.۰)
///
/// یک مجموعه عدد در هر جلسه: کودک در هر دور کوچک‌ترین عددِ
/// باقی‌مانده را انتخاب می‌کند و عملاً اعداد را مرتب می‌کند.
/// این بازی «دورهای وابسته» دارد؛ پس دورهایش از قبل به‌صورت
/// زنجیره ساخته می‌شوند (۵ دور = مرتب‌کردن ۵ عدد).
/// مهارت: counting | مأموریت: counting
/// ═══════════════════════════════════════════════════════════════
class NumberOrderGame extends StatelessWidget {
  const NumberOrderGame({super.key});

  static const MiniGameSpec spec = MiniGameSpec(
    title: 'ترتیب اعداد 🔢',
    gameId: 'ترتیب اعداد',
    skill: 'counting',
    missionId: 'counting',
    gradient: AppGradients.nightSky,
    introCoach: 'اعداد قاطی شده‌اند! از کوچک‌ترین شروع کن و به ترتیب بزن 🔢',
    rewardCoach: 'تو اعداد را مثل یک سرباز صف کشیدی! مرتب و مهربان 🎖️',
    rounds: 5,
  );

  /// ساخت دورها — خالص و قابل تست واحد.
  ///
  /// هر جلسه ۱۵ عدد یکتا از بازهٔ ۱ تا ۲۰ انتخاب و مرتب می‌شود؛
  /// هر دور یک دستهٔ سه‌تاییِ متوالی (از کوچک به بزرگ) را نشان می‌دهد
  /// و کوچک‌ترینِ آن دسته پاسخ درست است. دسته‌ها تکرار نمی‌شوند، هر
  /// دور همیشه ۳ گزینه دارد (هیچ دورِ تک‌گزینه‌ای ساخته نمی‌شود) و
  /// توالی پاسخ‌های درست صعودی است.
  static List<MiniGameRound> buildRounds({Random? rng}) {
    final random = rng ?? Random();
    final pool = List<int>.generate(20, (i) => i + 1)..shuffle(random);
    final numbers = pool.take(15).toList()..sort();
    const batchSize = 3;
    final rounds = <MiniGameRound>[];
    for (var i = 0; i + batchSize <= numbers.length; i += batchSize) {
      final batch = numbers.sublist(i, i + batchSize);
      final smallest = batch.first;
      final options = <MiniGameOption>[
        for (final n in batch)
          MiniGameOption(PersianDigits.toFa(n), correct: n == smallest),
      ]..shuffle(random);
      rounds.add(MiniGameRound(
        prompt: 'حالا کوچک‌ترین عدد کدام است؟',
        scene: '🪜 از کوچک‌ترین شروع کن!',
        sceneFontSize: 38,
        sceneIsText: true,
        options: options,
        hint: 'بین این عددها، «${PersianDigits.toFa(smallest)}» از همه کوچک‌تر است 😉',
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
