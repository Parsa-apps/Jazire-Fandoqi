import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:jazireh_fandoghi/app/app_colors.dart';
import 'package:jazireh_fandoghi/core/fandoghi_coach.dart';
import 'package:jazireh_fandoghi/core/game_data.dart';
import 'package:jazireh_fandoghi/features/games/mini_games/mini_game_models.dart';
import 'package:jazireh_fandoghi/features/games/mini_games/mini_game_scaffold.dart';

const _spec = MiniGameSpec(
  title: 'بازی آزمایشی 🧪',
  gameId: 'بازی آزمایشی',
  skill: 'logic',
  missionId: 'logic',
  gradient: AppGradients.primary,
  introCoach: 'سلام! شروع کنیم',
  rewardCoach: 'تمام شد!',
  rounds: 3,
);

List<MiniGameRound> _fixedRounds() => <MiniGameRound>[
      MiniGameRound(
        prompt: '۱ + ۱ چند می‌شود؟',
        scene: '🧪',
        options: [
          MiniGameOption('۲', correct: true),
          MiniGameOption('۳'),
        ],
        hint: 'دوتا یکی دیگه اضافه کن',
      ),
      MiniGameRound(
        prompt: 'کدام میوه است؟',
        scene: '🍽️',
        options: [
          MiniGameOption('🍌', correct: true),
          MiniGameOption('🐱'),
        ],
        hint: 'زرد و خوشمزه!',
      ),
      MiniGameRound(
        prompt: 'همهٔ میوه‌ها را بگذار داخل سبد',
        scene: '🧺',
        options: [
          MiniGameOption('🍎', correct: true),
          MiniGameOption('🍌', correct: true),
          MiniGameOption('🐶'),
        ],
        hint: 'سیب و موز میوه‌اند',
        multiSelect: true,
      ),
    ];

Future<void> _pump(WidgetTester tester) async {
  _mark('pump: pumpWidget begin');
  await tester.pumpWidget(
    MaterialApp(
      locale: const Locale('fa'),
      supportedLocales: const [Locale('fa')],
      // همان نماینده‌های فارسیِ خودِ برنامه (main.dart)؛ بدون آن‌ها MaterialApp
      // برای زبان «fa» هشدار می‌دهد و همهٔ تست‌های این فایل شکست می‌خورند.
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      home: MiniGameScaffold(
        spec: _spec,
        roundFactory: _fixedRounds,
      ),
    ),
  );
  _mark('pump: pumpWidget done');
  await tester.pump(const Duration(milliseconds: 100));
  _mark('pump: first pump done');
}

/// TEMPORARY diagnostic marks — deleted together with the diagnostic workflow.
/// Each step is appended to diag-logs/mini_game_scaffold-progress.log so a hang
/// still shows which action never returned (stdout of a hung test never lands
/// in the CI log, but this file does).
final List<String> _marks = <String>[];

void _mark(String step) {
  _marks.add(step);
  try {
    final file = File('diag-logs/mini_game_scaffold-progress.log');
    if (!file.parent.existsSync()) file.parent.createSync(recursive: true);
    file.writeAsStringSync('${_marks.join('\n')}\n');
  } catch (_) {}
}

/// پایانِ تمیز هر تست: `flutter_animate` هنگام سوارشدن هر `Animate` یک تایمر
/// تأخیری صفر می‌سازد؛ اگر تست پیش از سوختن آن تمام شود، چارچوب «تایمر معلق»
/// را خطا می‌شمارد. یک تیک کوتاه همه را می‌سوزاند (و چون درخت ثابت است، تایمر
/// تازه‌ای هم ساخته نمی‌شود).
Future<void> _drainTimers(WidgetTester tester) async {
  await tester.pump(const Duration(milliseconds: 20));
}

/// لمس ایمن: گزینه‌ها داخل ویوپورتِ اسکرول‌شدنی‌اند و در قابِ کوتاهِ تست،
/// کارت پایینی بیرون دید می‌افتد (لمس روی دکمهٔ «گذاشتم» می‌نشیند). پیش از
/// هر لمس، ویجت را کامل داخل قاب می‌آوریم تا لمس واقعاً روی هدف بنشیند.
Future<void> _tap(WidgetTester tester, Finder finder) async {
  _mark('tap: ${finder.description}');
  await tester.ensureVisible(finder);
  await tester.pump();
  await tester.tap(finder);
  _mark('tap done');
}

void main() {
  setUp(() {
    // مثل بقیهٔ تست‌های اپ: در تست منبع فونت آنلاین وجود ندارد، پس تلاش برای
    // دانلود فونت باید خاموش باشد وگرنه GoogleFonts در فریم‌های بعدی خطای
    // بی‌ربط (و در تایم‌لاین فِیک، تعلیق) می‌سازد.
    GoogleFonts.config.allowRuntimeFetching = false;
    GameData.resetForTesting();
  });

  tearDown(() {
    FandoghiCoach.clear();
    FandoghiCoach.disablePersistentPresence();
  });

  testWidgets('جریان کامل: پاسخ درست → دور بعد؛ اشتباه بدون شکست', (tester) async {
    _mark('test1 start');
    await _pump(tester);
    _mark('test1 mounted');

    // دور ۱ — اول یک اشتباه (گزینهٔ ۳) سپس درست (۲)
    expect(find.text('۱ + ۱ چند می‌شود؟'), findsOneWidget);
    await _tap(tester, find.text('۳'));
    await tester.pump(const Duration(milliseconds: 300));
    // دور عوض نشده؛ کودک می‌تواند دوباره امتحان کند
    expect(find.text('۱ + ۱ چند می‌شود؟'), findsOneWidget);

    await _tap(tester, find.text('۲'));
    await tester.pump(const Duration(milliseconds: 300));
    // XP: تلاش ۱ + درست ۲ = ۳ — تلاش هم پاداش دارد
    expect(GameData.xp, 3);

    // دور ۲
    await tester.pump(const Duration(milliseconds: 1200));
    expect(find.text('کدام میوه است؟'), findsOneWidget);
    await _tap(tester, find.text('🍌'));
    await tester.pump(const Duration(milliseconds: 300));

    // دور ۳ — چندانتخابی
    await tester.pump(const Duration(milliseconds: 1200));
    expect(find.text('همهٔ میوه‌ها را بگذار داخل سبد'), findsOneWidget);
    await _tap(tester, find.text('🍎'));
    await tester.pump(const Duration(milliseconds: 200));
    await _tap(tester, find.text('🐶')); // مزاحم
    await tester.pump(const Duration(milliseconds: 200));
    await _tap(tester, find.text('گذاشتم! ۲ تا 🧺'));
    await tester.pump(const Duration(milliseconds: 400));
    // هنوز در همان دور — بازخورد مثبتِ «تقریباً»
    expect(find.text('همهٔ میوه‌ها را بگذار داخل سبد'), findsOneWidget);

    // انتخاب درست: میوه‌ها
    await _tap(tester, find.text('🐶')); // برداشتن مزاحم
    await tester.pump(const Duration(milliseconds: 200));
    await _tap(tester, find.text('🍌'));
    await tester.pump(const Duration(milliseconds: 200));
    await _tap(tester, find.text('گذاشتم! ۲ تا 🧺'));
    await tester.pump(const Duration(milliseconds: 400));

    // صفحهٔ نتیجه
    _mark('test1: pump 1500 result');
    await tester.pump(const Duration(milliseconds: 1500));
    _mark('test1: result pumped');
    expect(find.text('بازی آزمایشی 🧪'), findsOneWidget);
    expect(find.text('دور جدید 🔄'), findsOneWidget);

    await _drainTimers(tester);
  });

  testWidgets('مأموریت، مهارت و آمار بازی ثبت می‌شود', (tester) async {
    _mark('test2 start');
    await _pump(tester);
    _mark('test2 mounted');

    await _tap(tester, find.text('۲'));
    await tester.pump(const Duration(milliseconds: 400));
    await tester.pump(const Duration(milliseconds: 1200));
    await _tap(tester, find.text('🍌'));
    await tester.pump(const Duration(milliseconds: 400));
    await tester.pump(const Duration(milliseconds: 1200));

    // سبد: هر دو میوه
    await _tap(tester, find.text('🍎'));
    await tester.pump();
    await _tap(tester, find.text('🍌'));
    await tester.pump();
    await _tap(tester, find.text('گذاشتم! ۲ تا 🧺'));
    await tester.pump(const Duration(milliseconds: 1200));

    expect(GameData.playedGames, contains('بازی آزمایشی'));
    // سه پاسخ درست داده شد ولی سقف مأموریت logic برابر ۲ است
    expect(GameData.missionValue('logic'), 2);
    expect(GameData.skills['logic'], greaterThanOrEqualTo(3));
    // XP: ۲+۲+۲ (پاسخ‌های درست) + ۵ (پایان بازی)
    expect(GameData.xp, 11);

    await _drainTimers(tester);
  });

  testWidgets('Hint ظریف بعد از ۱۰ ثانیه بی‌حرکتی فعال می‌شود (بدون کرش)',
      (tester) async {
    _mark('test3 start');
    await _pump(tester);
    _mark('test3 mounted');
    // تایمر Hint از postFrame شروع می‌شود. زمان را در گام‌های یک‌ثانیه‌ای
    // جلو می‌بریم (به‌جای یک elapse یازده‌ثانیه‌ای) تا هم تایمر Hint و هم
    // تایمرِ پنهان‌شدنِ پیام در قاب‌های جداگانه پردازش شوند.
    for (var i = 0; i < 11; i++) {
      _mark('test3 hint pump ${i + 1} begin');
      await tester.pump(const Duration(seconds: 1));
      _mark('test3 hint pump ${i + 1} done');
    }
    expect(find.text('۱ + ۱ چند می‌شود؟'), findsOneWidget);
    // فندقی راهنما را گفته و بازی پایدار مانده
    expect(tester.takeException(), isNull);

    // پیام را جمع می‌کنیم تا کاراکترِ سخنگو (و تایمر پلک‌زدنش) پیاده شود؛
    // وگرنه «تایمر معلق» در پایان تست خطا می‌شود.
    FandoghiCoach.clear();
    await _drainTimers(tester);
  });

  testWidgets('دور جدید دوباره از اول شروع می‌شود', (tester) async {
    _mark('test4 start');
    await _pump(tester);
    _mark('test4 mounted');
    // سه دور را کامل کن
    await _tap(tester, find.text('۲'));
    await tester.pump(const Duration(milliseconds: 1200));
    await tester.pump(const Duration(milliseconds: 1200));
    await _tap(tester, find.text('🍌'));
    await tester.pump(const Duration(milliseconds: 1200));
    await tester.pump(const Duration(milliseconds: 1200));
    await _tap(tester, find.text('🍎'));
    await tester.pump(const Duration(milliseconds: 200));
    await _tap(tester, find.text('🍌'));
    await tester.pump(const Duration(milliseconds: 200));
    await _tap(tester, find.text('گذاشتم! ۲ تا 🧺'));
    await tester.pump(const Duration(milliseconds: 1200));
    await tester.pump(const Duration(milliseconds: 1200));

    await _tap(tester, find.text('دور جدید 🔄'));
    await tester.pump(const Duration(milliseconds: 300));
    expect(find.text('۱ + ۱ چند می‌شود؟'), findsOneWidget);

    await _drainTimers(tester);
  });
}
