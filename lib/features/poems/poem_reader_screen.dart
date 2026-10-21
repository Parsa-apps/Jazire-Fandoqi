import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../app/app_fonts.dart';
import '../../app/island_world_style.dart';
import '../../core/audio_service.dart';
import '../../core/fandoghi_coach.dart';
import '../../core/game_data.dart';
import '../../core/growth/persian_digits.dart';
import '../../core/learning_content/poems_data.dart';
import '../../shared/widgets/kids_world_scaffold.dart';

/// 📖 صفحهٔ خواندنِ یک شعر
///
/// سه تجربهٔ کوچک روی هم:
///   • خواندنِ خط‌به‌خط با روشن‌شدنِ خطِ جاری (با TTS فارسی)
///   • «با ریتم بزن»: کودک تعداد ضربه‌های شعر را می‌شمارد و دست می‌زند
///   • «بازیِ قافیه/معنا»: یک پرسشِ سه‌گزینه‌ای با بازخوردِ مهربان
class PoemReaderScreen extends StatefulWidget {
  const PoemReaderScreen({super.key, required this.poem});

  final KidsPoem poem;

  @override
  State<PoemReaderScreen> createState() => _PoemReaderScreenState();
}

class _PoemReaderScreenState extends State<PoemReaderScreen> {
  bool _reading = false;
  int _activeLine = -1;
  int _token = 0;

  int _beatCount = 0;
  bool _beatDone = false;
  bool _beatRewarded = false;

  String? _selectedOption;
  bool _readDone = false;
  bool _markingRead = false;

  /// پاداشِ درست‌پاسخ فقط یک‌بار برای هر شعر داده می‌شود؛ وگرنه کودک با
  /// تکرارِ «یک بار دیگر» می‌توانست بی‌نهایت ستاره بگیرد.
  bool _quizSolved = false;
  bool _quizRewarding = false;

  KidsPoem get _poem => widget.poem;

  String get _doneKey => 'poem_done_${_poem.id}';

  String get _quizKey => 'poem_quiz_${_poem.id}';

  @override
  void initState() {
    super.initState();
    _readDone = GameData.getBool(_doneKey) == true;
    _quizSolved = GameData.getBool(_quizKey) == true;
    FandoghiCoach.enablePersistentPresence();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      FandoghiCoach.say(
        'این شعر دربارهٔ «${_poem.theme}» است. با هم بخوانیمش؟ 📖',
        duration: const Duration(seconds: 4),
      );
    });
  }

  @override
  void dispose() {
    _token++;
    AudioService.stopSpeaking();
    FandoghiCoach.clear();
    super.dispose();
  }

  Future<void> _toggleReading() async {
    if (_reading) {
      _stopReading();
      return;
    }
    HapticFeedback.lightImpact();
    final token = ++_token;
    setState(() {
      _reading = true;
      _activeLine = 0;
    });
    for (var i = 0; i < _poem.lines.length; i++) {
      if (!mounted || token != _token) return;
      setState(() => _activeLine = i);
      unawaited(AudioService.speak(_poem.lines[i].text));
      final length = _poem.lines[i].text.runes.length;
      final ms = (1700 + length * 78).clamp(1900, 5200).toInt();
      await Future<void>.delayed(Duration(milliseconds: ms));
    }
    if (!mounted || token != _token) return;
    setState(() {
      _reading = false;
      _activeLine = -1;
    });
  }

  void _stopReading() {
    _token++;
    AudioService.stopSpeaking();
    if (mounted) {
      setState(() {
        _reading = false;
        _activeLine = -1;
      });
    }
  }

  void _tapBeat() {
    if (_beatDone) return;
    HapticFeedback.selectionClick();
    unawaited(AudioService.tick());
    final next = _beatCount + 1;
    setState(() {
      _beatCount = next;
      if (next >= _poem.totalBeats) _beatDone = true;
    });
    if (next >= _poem.totalBeats) {
      AudioService.success();
      if (!_beatRewarded) {
        _beatRewarded = true;
        GameData.addStars(1);
        GameData.addXp(3);
        FandoghiCoach.celebrate(
          'ریتمِ شعر را کامل زدی و یک ستاره گرفتی! '
          '${PersianDigits.toFa(_poem.totalBeats)} ضربه 🎉',
        );
      } else {
        FandoghiCoach.celebrate(
          'دوباره ریتم را کامل زدی! '
          '${PersianDigits.toFa(_poem.totalBeats)} ضربه 🎉',
        );
      }
    }
  }

  void _resetBeats() {
    HapticFeedback.lightImpact();
    AudioService.tap();
    setState(() {
      _beatCount = 0;
      _beatDone = false;
    });
  }

  void _answerQuiz(String option) {
    if (_selectedOption != null) return;
    final correct = option == _poem.answer;
    setState(() => _selectedOption = option);
    if (correct) {
      AudioService.correct();
      GameData.recordAnswer(correct: true, skill: 'poems');
      if (!_quizSolved && !_quizRewarding) {
        _quizRewarding = true;
        unawaited(_awardQuizOnce());
      }
      FandoghiCoach.correct('آفرین! جواب درست «${_poem.answer}» بود 🌟');
    } else {
      AudioService.wrong();
      GameData.recordAnswer(correct: false, skill: 'poems');
      FandoghiCoach.instruction(
        'نزدیک بود! جوابِ درست «${_poem.answer}» است؛ یک بار دیگر بخوان و امتحان کن.',
      );
    }
  }

  Future<void> _awardQuizOnce() async {
    await GameData.setBool(_quizKey, true);
    _quizSolved = true;
    GameData.addStars(1);
    GameData.addXp(4);
    _quizRewarding = false;
    if (!mounted) return;
    setState(() {});
  }

  void _retryQuiz() {
    HapticFeedback.selectionClick();
    AudioService.tap();
    setState(() => _selectedOption = null);
  }

  Future<void> _markRead() async {
    if (_readDone || _markingRead) return;
    _markingRead = true;
    await GameData.setBool(_doneKey, true);
    GameData.addStars(3);
    GameData.addXp(8);
    GameData.recordAnswer(correct: true, skill: 'poems');
    if (!mounted) return;
    setState(() => _readDone = true);
    _markingRead = false;
    AudioService.win();
    FandoghiCoach.celebrate(
      'آفرین! شعرِ «${_poem.title}» را کامل خواندی 🌟',
    );
  }

  @override
  Widget build(BuildContext context) {
    final gradient = <Color>[
      Color.lerp(_poem.themeColor, Colors.black, 0.38)!,
      _poem.themeColor,
      _poem.accentColor,
    ];
    final quizCorrect = _selectedOption != null &&
        _selectedOption == _poem.answer;

    return KidsWorldScaffold(
      title: _poem.title,
      subtitle: '${_poem.theme} • ${PersianDigits.toFa(_poem.lines.length)} خط',
      emoji: _poem.emoji,
      gradient: gradient,
      headerActions: <Widget>[
        KidsWorldBadge(
          label: _readDone ? 'خوانده‌شده' : 'شعرِ کودکانه',
          background: _readDone
              ? const Color(0xE67BE495)
              : const Color(0x33FFFFFF),
          foreground: _readDone ? const Color(0xFF0B3D1E) : Colors.white,
        ),
      ],
      body: ListView(
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.fromLTRB(12, 6, 12, 0),
        children: <Widget>[
          _PoemPaper(
            poem: _poem,
            activeLine: _activeLine,
          ),
          const SizedBox(height: 10),
          KidsWorldCard(
            padding: const EdgeInsets.fromLTRB(12, 10, 12, 12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: <Widget>[
                Row(
                  children: <Widget>[
                    const Text('🔊', style: TextStyle(fontSize: 20)),
                    const SizedBox(width: 6),
                    Expanded(
                      child: Text(
                        _reading ? 'دارم می‌خوانم...' : 'با هم بخوانیم',
                        style: AppFonts.kids(
                          fontSize: 15.5,
                          fontWeight: FontWeight.w800,
                          color: IslandWorldPalette.ink,
                        ),
                      ),
                    ),
                    if (_reading)
                      Text(
                        'خطِ ${PersianDigits.toFa(_activeLine + 1)} از '
                        '${PersianDigits.toFa(_poem.lines.length)}',
                        style: AppFonts.vazirmatn(
                          fontSize: 10,
                          fontWeight: FontWeight.w700,
                          color: IslandWorldPalette.mutedInk,
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 8),
                KidsWorldButton(
                  label: _reading ? 'توقفِ خواندن' : 'بخوان برایم',
                  emoji: _reading ? '⏹️' : '🎧',
                  color: _reading
                      ? const Color(0xFFFFE0E0)
                      : const Color(0xFFFFD166),
                  textColor: _reading
                      ? const Color(0xFF8E0000)
                      : const Color(0xFF3B2A00),
                  onPressed: _toggleReading,
                ),
                const SizedBox(height: 5),
                Text(
                  'اگر دستگاه صدا نداشت، با صدای بلند خودت بخوان؛ شعر برای '
                  'خواندن با هم ساخته شده است.',
                  style: AppFonts.vazirmatn(
                    fontSize: 10,
                    fontWeight: FontWeight.w600,
                    height: 1.5,
                    color: IslandWorldPalette.mutedInk,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 10),
          KidsWorldCard(
            padding: const EdgeInsets.fromLTRB(12, 12, 12, 12),
            color: const Color(0xFFFFF8EC),
            borderColor: const Color(0xFFFFD166),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: <Widget>[
                Row(
                  children: <Widget>[
                    const Text('👏', style: TextStyle(fontSize: 22)),
                    const SizedBox(width: 6),
                    Expanded(
                      child: Text(
                        'با ریتم بزن',
                        style: AppFonts.kids(
                          fontSize: 16,
                          fontWeight: FontWeight.w800,
                          color: IslandWorldPalette.ink,
                        ),
                      ),
                    ),
                    Text(
                      '${PersianDigits.toFa(_beatCount)} از '
                      '${PersianDigits.toFa(_poem.totalBeats)}',
                      style: AppFonts.vazirmatn(
                        fontSize: 10.5,
                        fontWeight: FontWeight.w800,
                        color: IslandWorldPalette.mutedInk,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                ClipRRect(
                  borderRadius: BorderRadius.circular(99),
                  child: LinearProgressIndicator(
                    value: _poem.totalBeats == 0
                        ? 0.0
                        : _beatCount / _poem.totalBeats,
                    minHeight: 9,
                    backgroundColor: const Color(0xFFEDE0C8),
                    valueColor: AlwaysStoppedAnimation<Color>(
                      _beatDone
                          ? const Color(0xFF43A047)
                          : const Color(0xFFD97706),
                    ),
                  ),
                ),
                const SizedBox(height: 10),
                Row(
                  children: <Widget>[
                    Expanded(
                      child: KidsWorldButton(
                        label: _beatDone ? 'آفرین! ریتم کامل شد' : 'ضربه بزن',
                        emoji: _beatDone ? '🎉' : '👏',
                        color: _beatDone
                            ? const Color(0xFFC8E6C9)
                            : const Color(0xFFFFD166),
                        textColor: const Color(0xFF3B2A00),
                        onPressed: _beatDone ? _resetBeats : _tapBeat,
                      ),
                    ),
                    if (_beatCount > 0) ...<Widget>[
                      const SizedBox(width: 8),
                      Semantics(
                        button: true,
                        label: 'شروعِ دوبارهٔ ریتم',
                        child: IconButton(
                          tooltip: 'شروع دوباره',
                          onPressed: _resetBeats,
                          icon: const Icon(Icons.restart_alt_rounded),
                          color: IslandWorldPalette.mutedInk,
                        ),
                      ),
                    ],
                  ],
                ),
                Text(
                  'هر خط را با دست بشمار؛ ضربه‌ها با «👏» شماره می‌شوند.',
                  style: AppFonts.vazirmatn(
                    fontSize: 10,
                    fontWeight: FontWeight.w600,
                    color: IslandWorldPalette.mutedInk,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 10),
          KidsWorldCard(
            padding: const EdgeInsets.fromLTRB(12, 12, 12, 12),
            color: const Color(0xFFF3F8FF),
            borderColor: const Color(0xFF90CAF9),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: <Widget>[
                Row(
                  children: <Widget>[
                    const Text('🧩', style: TextStyle(fontSize: 22)),
                    const SizedBox(width: 6),
                    Expanded(
                      child: Text(
                        'بازیِ قافیه',
                        style: AppFonts.kids(
                          fontSize: 16,
                          fontWeight: FontWeight.w800,
                          color: IslandWorldPalette.ink,
                        ),
                      ),
                    ),
                    if (_selectedOption != null)
                      Icon(
                        quizCorrect
                            ? Icons.check_circle_rounded
                            : Icons.cancel_rounded,
                        color: quizCorrect
                            ? const Color(0xFF2E7D32)
                            : const Color(0xFFC62828),
                        size: 22,
                      ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  _poem.question,
                  style: AppFonts.vazirmatn(
                    fontSize: 12.5,
                    fontWeight: FontWeight.w700,
                    height: 1.6,
                    color: IslandWorldPalette.ink,
                  ),
                ),
                const SizedBox(height: 8),
                for (final option in _poem.options)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 6),
                    child: _QuizOption(
                      label: option,
                      state: _selectedOption == null
                          ? _QuizState.idle
                          : option == _poem.answer
                              ? _QuizState.correct
                              : option == _selectedOption
                                  ? _QuizState.wrong
                                  : _QuizState.dimmed,
                      onTap: _selectedOption == null
                          ? () => _answerQuiz(option)
                          : null,
                    ),
                  ),
                if (_selectedOption != null && !quizCorrect)
                  TextButton.icon(
                    onPressed: _retryQuiz,
                    icon: const Icon(Icons.refresh_rounded, size: 18),
                    label: const Text('یک بار دیگر امتحان کن'),
                    style: TextButton.styleFrom(
                      foregroundColor: const Color(0xFF1565C0),
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(height: 10),
          KidsWorldCard(
            padding: const EdgeInsets.fromLTRB(12, 12, 12, 12),
            color: const Color(0xFFF1F8E9),
            borderColor: const Color(0xFFA5D6A7),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: <Widget>[
                Row(
                  children: <Widget>[
                    const Text('💡', style: TextStyle(fontSize: 22)),
                    const SizedBox(width: 6),
                    Expanded(
                      child: Text(
                        'پیامِ شعر',
                        style: AppFonts.kids(
                          fontSize: 16,
                          fontWeight: FontWeight.w800,
                          color: IslandWorldPalette.ink,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 5),
                Text(
                  _poem.message,
                  style: AppFonts.vazirmatn(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    height: 1.7,
                    color: IslandWorldPalette.ink,
                  ),
                ),
                const SizedBox(height: 10),
                KidsWorldButton(
                  label: _readDone ? 'خواندم ✓' : 'خواندم و یاد گرفتم',
                  emoji: _readDone ? '🌟' : '✅',
                  color: _readDone
                      ? const Color(0xFFC8E6C9)
                      : const Color(0xFFFFD166),
                  textColor: const Color(0xFF3B2A00),
                  onPressed: _readDone ? null : _markRead,
                ),
              ],
            ),
          ),
          const KidsWorldOfflineNote(
            text: 'این شعر داخل برنامه است؛ برای گوش‌دادن نیازی به اینترنت نیست.',
          ),
          const KidsWorldBottomSpacer(),
        ],
      ),
    );
  }
}

class _PoemPaper extends StatelessWidget {
  const _PoemPaper({required this.poem, required this.activeLine});

  final KidsPoem poem;
  final int activeLine;

  @override
  Widget build(BuildContext context) {
    return KidsWorldCard(
      padding: const EdgeInsets.fromLTRB(14, 16, 14, 14),
      color: const Color(0xFFFFFCF3),
      borderColor: poem.accentColor,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          Row(
            children: <Widget>[
              Text(poem.emoji, style: const TextStyle(fontSize: 26)),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  poem.title,
                  style: AppFonts.kids(
                    fontSize: 20,
                    fontWeight: FontWeight.w800,
                    color: IslandWorldPalette.ink,
                  ),
                ),
              ),
              KidsWorldBadge(
                label: poem.theme,
                background: poem.themeColor.withOpacity(0.12),
                foreground: poem.themeColor,
              ),
            ],
          ),
          const SizedBox(height: 10),
          for (var i = 0; i < poem.lines.length; i++) ...<Widget>[
            AnimatedContainer(
              duration: const Duration(milliseconds: 180),
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
              decoration: BoxDecoration(
                color: activeLine == i
                    ? poem.accentColor.withOpacity(0.24)
                    : Colors.transparent,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: activeLine == i
                      ? poem.themeColor.withOpacity(0.35)
                      : Colors.transparent,
                ),
              ),
              child: Row(
                children: <Widget>[
                  Container(
                    width: 20,
                    height: 20,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: activeLine == i
                          ? poem.themeColor
                          : poem.themeColor.withOpacity(0.12),
                    ),
                    child: Center(
                      child: Text(
                        PersianDigits.toFa(i + 1),
                        style: AppFonts.vazirmatn(
                          fontSize: 9,
                          fontWeight: FontWeight.w800,
                          color: activeLine == i
                              ? Colors.white
                              : poem.themeColor,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      poem.lines[i].text,
                      style: AppFonts.vazirmatn(
                        fontSize: 16.5,
                        fontWeight: FontWeight.w700,
                        height: 1.9,
                        color: IslandWorldPalette.ink,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            if (i.isOdd) const SizedBox(height: 5),
          ],
        ],
      ),
    );
  }
}

enum _QuizState { idle, correct, wrong, dimmed }

class _QuizOption extends StatelessWidget {
  const _QuizOption({
    required this.label,
    required this.state,
    required this.onTap,
  });

  final String label;
  final _QuizState state;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final Color background;
    final Color border;
    final Color textColor;
    switch (state) {
      case _QuizState.correct:
        background = const Color(0xFFE8F5E9);
        border = const Color(0xFF43A047);
        textColor = const Color(0xFF1B5E20);
        break;
      case _QuizState.wrong:
        background = const Color(0xFFFFEBEE);
        border = const Color(0xFFE53935);
        textColor = const Color(0xFF8E0000);
        break;
      case _QuizState.dimmed:
        background = const Color(0xFFF5F5F5);
        border = const Color(0xFFE0E0E0);
        textColor = const Color(0xFF9E9E9E);
        break;
      case _QuizState.idle:
        background = Colors.white;
        border = const Color(0xFFBBDEFB);
        textColor = IslandWorldPalette.ink;
        break;
    }
    return Semantics(
      button: onTap != null,
      label: label,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 160),
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 11),
          decoration: BoxDecoration(
            color: background,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: border, width: 1.6),
          ),
          child: Row(
            children: <Widget>[
              Icon(
                state == _QuizState.correct
                    ? Icons.check_rounded
                    : state == _QuizState.wrong
                        ? Icons.close_rounded
                        : Icons.radio_button_unchecked_rounded,
                size: 18,
                color: textColor,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  label,
                  style: AppFonts.vazirmatn(
                    fontSize: 12.5,
                    fontWeight: FontWeight.w700,
                    color: textColor,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
