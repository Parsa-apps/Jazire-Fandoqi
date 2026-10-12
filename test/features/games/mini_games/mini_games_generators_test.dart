import 'dart:math';

import 'package:flutter_test/flutter_test.dart';

import 'package:jazireh_fandoghi/core/growth/persian_digits.dart';
import 'package:jazireh_fandoghi/features/games/mini_games/big_small_game.dart';
import 'package:jazireh_fandoghi/features/games/mini_games/color_mix_game.dart';
import 'package:jazireh_fandoghi/features/games/mini_games/counting_fun_game.dart';
import 'package:jazireh_fandoghi/features/games/mini_games/first_letter_game.dart';
import 'package:jazireh_fandoghi/features/games/mini_games/mini_game_models.dart';
import 'package:jazireh_fandoghi/features/games/mini_games/number_order_game.dart';
import 'package:jazireh_fandoghi/features/games/mini_games/odd_one_out_game.dart';
import 'package:jazireh_fandoghi/features/games/mini_games/shape_match_game.dart';
import 'package:jazireh_fandoghi/features/games/mini_games/sort_basket_game.dart';
import 'package:jazireh_fandoghi/features/games/mini_games/visual_math_game.dart';
import 'package:jazireh_fandoghi/features/games/mini_games/word_builder_game.dart';

/// 🔍 ممیزی مشترک: هر دور باید دقیقاً یک پاسخ درست، گزینه‌های تکرارنشده،
/// پرامپت/صحنه/راهنمای غیرخالی و تعداد گزینهٔ منطقی داشته باشد.
void expectValidRounds(
  List<MiniGameRound> rounds, {
  int? expectedCount,
  int? exactOptions,
}) {
  if (expectedCount != null) expect(rounds.length, expectedCount);
  for (final round in rounds) {
    expect(round.prompt.isNotEmpty, isTrue, reason: round.prompt);
    expect(round.scene.isNotEmpty, isTrue);
    expect(round.hint.isNotEmpty, isTrue);
    expect(round.options.length, greaterThanOrEqualTo(2));
    if (exactOptions != null) {
      expect(round.options.length, exactOptions);
    }
    final correctCount = round.options.where((o) => o.correct).length;
    if (round.multiSelect) {
      // چندانتخابی (مثل سبد دسته‌بندی): چند عضو درست + چند مزاحم؛
      // تعداد دقیق در تست خودِ آن بازی بررسی می‌شود.
      expect(correctCount, greaterThanOrEqualTo(2),
          reason: 'چندانتخابی باید چند پاسخ درست داشته باشد: ${round.prompt}');
    } else {
      expect(correctCount, 1,
          reason: 'دقیقاً یک پاسخ درست: ${round.prompt}');
    }
    final labels = round.options.map((o) => o.label).toSet();
    expect(labels.length, round.options.length,
        reason: 'گزینه تکراری ممنوع: ${round.prompt}');
    expect(round.sceneFontSize, greaterThan(0));
  }
}

void main() {
  group('🔤 حرف اول', () {
    test('برای هر واژه، گزینهٔ درست همان حرف اول است', () {
      final rounds = FirstLetterGame.buildRounds(
        count: 6,
        optionCount: 4,
        rng: Random(7),
      );
      expectValidRounds(rounds, expectedCount: 6, exactOptions: 4);
      for (final round in rounds) {
        final correct = round.options.firstWhere((o) => o.correct).label;
        // پرامپت شامل واژه است: «“توپ” با کدام حرف شروع می‌شود؟»
        final word = round.prompt
            .split('«')
            .last
            .split('»')
            .first;
        expect(word.isNotEmpty, isTrue);
        expect(word.startsWith(correct), isTrue,
            reason: '$word باید با $correct شروع شود');
      }
    });

    test('با seed ثابت نتیجه تکرارپذیر است (تست QA پایدار)', () {
      final a = FirstLetterGame.buildRounds(count: 3, rng: Random(42));
      final b = FirstLetterGame.buildRounds(count: 3, rng: Random(42));
      expect(a.length, b.length);
      for (var i = 0; i < a.length; i++) {
        expect(a[i].prompt, b[i].prompt);
        expect(a[i].options.map((o) => o.label),
            b[i].options.map((o) => o.label));
      }
    });
  });

  group('🧱 کلمه‌ساز', () {
    test('جای خالی دقیقاً یک حرف است و با گزینهٔ درست کامل می‌شود', () {
      final rounds = WordBuilderGame.buildRounds(
        count: 8,
        optionCount: 3,
        rng: Random(3),
      );
      expectValidRounds(rounds, expectedCount: 8, exactOptions: 3);
      for (final round in rounds) {
        final correct = round.options.firstWhere((o) => o.correct).label;
        expect(correct.length, 1);
        // صحنه: «emoji\n□ جای‌دارده» — دقیقاً یک □
        expect('□'.allMatches(round.scene).length, 1,
            reason: round.scene);
        // با گذاشتن حرف درست، واژهٔ حقیقی ساخته می‌شود
        final rebuilt = round.scene
            .split('\n')
            .last
            .replaceAll('□', correct);
        expect(WordBuilderGame.words.map((w) => w.$1).contains(rebuilt),
            isTrue,
            reason: '$rebuilt باید یکی از واژه‌های معتبر باشد');
      }
    });
  });

  group('🔢 شمارش خوش', () {
    test('عدد درست برابر تعداد ایموجی‌های صحنه است', () {
      final rounds = CountingFunGame.buildRounds(
        count: 10,
        optionCount: 4,
        rng: Random(11),
      );
      expectValidRounds(rounds, expectedCount: 10);
      for (final round in rounds) {
        final correct =
            round.options.firstWhere((o) => o.correct).label;
        final emojiCount =
            round.scene.split(' ').where((s) => s.isNotEmpty).length;
        expect(PersianDigits.toFa(emojiCount), correct,
            reason: round.scene);
      }
    });
  });

  group('➕ جمع تصویری', () {
    test('نتیجهٔ درست = تعداد کل ایموجی‌های دو دسته', () {
      final rounds = VisualMathGame.buildRounds(
        count: 10,
        optionCount: 3,
        rng: Random(5),
      );
      expectValidRounds(rounds, expectedCount: 10);
      for (final round in rounds) {
        final correct =
            round.options.firstWhere((o) => o.correct).label;
        final parts = round.scene.split('+');
        expect(parts.length, 2, reason: round.scene);
        // شمارش ایموجی با rune: هر ایموجی این بازی یک code point است ولی
        // در UTF-16 دو code unit دارد؛ «length» تعداد را دوبرابر می‌کرد.
        final left = parts[0].trim().runes.length;
        final right = parts[1].trim().runes.length;
        expect(PersianDigits.toFa(left + right), correct,
            reason: round.scene);
      }
    });
  });

  group('🐘 بزرگ و کوچک', () {
    test('همیشه دو گزینه مکمل و یک پاسخ درست', () {
      final rounds = BigSmallGame.buildRounds(count: 6, rng: Random(9));
      expectValidRounds(rounds, expectedCount: 6, exactOptions: 2);
    });
  });

  group('🔷 جورچین شکل‌ها', () {
    test('گزینهٔ درست هم‌شکلِ هدف است (رنگ متفاوت مجاز)', () {
      final rounds = ShapeMatchGame.buildRounds(
        count: 6,
        optionCount: 4,
        rng: Random(2),
      );
      expectValidRounds(rounds, expectedCount: 6, exactOptions: 4);
      for (final round in rounds) {
        final target = round.scene;
        final correctEmoji =
            round.options.firstWhere((o) => o.correct).label;
        // هر دو باید در یک خانوادهٔ شکل باشند
        String family(String emoji) {
          for (final (name, emojis) in ShapeMatchGame.shapes) {
            if (emojis.contains(emoji)) return name;
          }
          return '?';
        }
        expect(family(target), isNot('?'));
        expect(family(correctEmoji), family(target),
            reason: '$target و $correctEmoji هم‌شکل نیستند');
        // گزینهٔ درست خودِ هدف نباشد (کپی نکردن!)
        expect(correctEmoji, isNot(target));
      }
    });
  });

  group('🎨 ترکیب رنگ', () {
    test('ترکیب‌ها فقط از فرمول‌های واقعی می‌آیند', () {
      final rounds = ColorMixGame.buildRounds(
        count: 12,
        optionCount: 4,
        rng: Random(17),
      );
      expectValidRounds(rounds, expectedCount: 12);
      for (final round in rounds) {
        final correct =
            round.options.firstWhere((o) => o.correct).label;
        expect(ColorMixGame.palette.map((p) => p.$1).contains(correct),
            isTrue);
      }
    });

    test('دورهای ترکیب صحنهٔ «+» دارند و دورهای شناخت ندارند', () {
      final rounds = ColorMixGame.buildRounds(count: 12, rng: Random(4));
      for (final round in rounds) {
        final isMix = round.prompt.contains('با هم چه رنگی');
        expect(round.scene.contains('+'), isMix,
            reason: round.prompt);
      }
    });
  });

  group('🪜 ترتیب اعداد', () {
    test('زنجیرهٔ دورها یک مرتب‌سازی کامل است (کوچک → بزرگ)', () {
      final rounds = NumberOrderGame.buildRounds(rng: Random(8));
      expectValidRounds(rounds, expectedCount: 5);
      final answers = <int>[];
      for (final round in rounds) {
        final correct =
            round.options.firstWhere((o) => o.correct).label;
        answers.add(int.parse(PersianDigits.toEn(correct)));
      }
      // توالی پاسخ‌ها باید صعودی و هر عدد یک‌بار باشد
      expect(answers.toSet().length, answers.length);
      for (var i = 1; i < answers.length; i++) {
        expect(answers[i], greaterThan(answers[i - 1]),
            reason: '$answers باید صعودی باشد');
      }
    });

    test('هر دور فقط اعدادِ باقی‌مانده را نشان می‌دهد', () {
      final rounds = NumberOrderGame.buildRounds(rng: Random(21));
      final seen = <int>{};
      for (final round in rounds) {
        final shown = round.options
            .map((o) => int.parse(PersianDigits.toEn(o.label)))
            .toSet();
        // هیچ عددِ یافته‌شده دوباره ظاهر نمی‌شود
        for (final s in shown) {
          expect(seen.contains(s), isFalse, reason: '$s نباید دوباره بیاید');
        }
        seen.addAll(shown);
      }
    });
  });

  group('🕵️ متفاوت را پیدا کن', () {
    test('دستهٔ اصلی هم‌گروه و مورد متفاوت از دستهٔ دیگر است', () {
      final rounds = OddOneOutGame.buildRounds(
        count: 8,
        optionCount: 4,
        rng: Random(13),
      );
      expectValidRounds(rounds, expectedCount: 8, exactOptions: 4);
      String categoryOf(String emoji) {
        for (final e in OddOneOutGame.categories.entries) {
          if (e.value.contains(emoji)) return e.key;
        }
        return '?';
      }
      for (final round in rounds) {
        final odd = round.options.firstWhere((o) => o.correct).label;
        final others =
            round.options.where((o) => !o.correct).map((o) => o.label);
        final oddCat = categoryOf(odd);
        expect(oddCat, isNot('?'));
        for (final other in others) {
          expect(categoryOf(other), isNot(oddCat),
              reason: '$other نباید هم‌دستهٔ $odd باشد');
          expect(categoryOf(other), isNot('?'));
        }
      }
    });
  });

  group('🧺 سبد دسته‌بندی', () {
    test('هر دور چندانتخابی با ۳ عضو درست و ۳ مزاحم است', () {
      final rounds = SortBasketGame.buildRounds(rng: Random(6));
      expectValidRounds(rounds, expectedCount: 4, exactOptions: 6);
      for (final round in rounds) {
        expect(round.multiSelect, isTrue);
        expect(
          round.options.where((o) => o.correct).length,
          3,
          reason: round.prompt,
        );
        expect(
          round.options.where((o) => !o.correct).length,
          3,
          reason: round.prompt,
        );
      }
    });

    test('پرامپت نام دستهٔ هدف را دارد و اعضای درست واقعاً همان دسته‌اند', () {
      final rounds = SortBasketGame.buildRounds(rng: Random(31));
      for (final round in rounds) {
        final target = round.prompt
            .split('«')
            .last
            .split('»')
            .first;
        expect(SortBasketGame.categories.containsKey(target), isTrue,
            reason: round.prompt);
        for (final o in round.options.where((o) => o.correct)) {
          expect(SortBasketGame.categories[target]!.contains(o.label),
              isTrue,
              reason: '${o.label} عضو $target نیست');
        }
      }
    });
  });

  group('🎪 مشخصات مشترک بازی‌ها (ثبت در آمار و مأموریت)', () {
    test('شناسهٔ بازی‌ها یکتاست', () {
      final ids = <String>{
        FirstLetterGame.spec.gameId,
        WordBuilderGame.spec.gameId,
        CountingFunGame.spec.gameId,
        VisualMathGame.spec.gameId,
        BigSmallGame.spec.gameId,
        ShapeMatchGame.spec.gameId,
        ColorMixGame.spec.gameId,
        NumberOrderGame.spec.gameId,
        OddOneOutGame.spec.gameId,
        SortBasketGame.spec.gameId,
      };
      expect(ids.length, 10);
    });

    test('همهٔ مشخصات متن فندقی و مهارت معتبر دارند', () {
      const specs = <MiniGameSpec>[
        FirstLetterGame.spec,
        WordBuilderGame.spec,
        CountingFunGame.spec,
        VisualMathGame.spec,
        BigSmallGame.spec,
        ShapeMatchGame.spec,
        ColorMixGame.spec,
        NumberOrderGame.spec,
        OddOneOutGame.spec,
        SortBasketGame.spec,
      ];
      const validSkills = <String>{
        'math', 'alphabet', 'memory', 'colors', 'shapes', 'animals',
        'counting', 'pattern', 'fruits', 'concepts', 'vocab', 'body',
        'vehicles', 'time', 'weather', 'emotions', 'jobs', 'stories',
        'lullaby', 'logic',
      };
      const validMissions = <String>{
        'questions', 'alphabet', 'drawing', 'colors', 'math', 'memory',
        'words', 'counting', 'logic',
      };
      for (final spec in specs) {
        expect(spec.title.isNotEmpty, isTrue);
        expect(spec.introCoach.isNotEmpty, isTrue);
        expect(spec.rewardCoach.isNotEmpty, isTrue);
        expect(spec.rounds, greaterThanOrEqualTo(4));
        expect(validSkills.contains(spec.skill), isTrue,
            reason: spec.title);
        if (spec.missionId != null) {
          expect(validMissions.contains(spec.missionId!), isTrue,
              reason: spec.title);
        }
      }
    });
  });
}
