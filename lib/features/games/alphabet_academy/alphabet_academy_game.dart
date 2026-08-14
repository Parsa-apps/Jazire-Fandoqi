import 'dart:async';
import 'dart:math' as math;
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../app/app_colors.dart';
import '../../../app/design_tokens.dart';
import 'package:jazireh_fandoghi/app/app_fonts.dart';
import '../../../core/audio_service.dart';
import '../../../core/fandoghi_coach.dart';
import '../../../core/game_data.dart';
import '../../../core/play_limit.dart';
import '../../../shared/widgets/fandoghi_v2.dart';
import '../../../shared/widgets/handwriting_score_overlay.dart';

/// A local-first Persian alphabet academy: see, hear/read, trace, receive
/// feedback, and repeat. The trace check is intentionally transparent and
/// lightweight; it evaluates coverage of the guide area rather than claiming
/// to be an opaque handwriting-AI service.
class AlphabetAcademyGame extends StatefulWidget {
  final String? stageId;
  final int? stageNumber;

  const AlphabetAcademyGame({
    super.key,
    this.stageId,
    this.stageNumber,
  });

  @override
  State<AlphabetAcademyGame> createState() => _AlphabetAcademyState();
}

class _AlphabetAcademyState extends State<AlphabetAcademyGame> {
  int _lessonIndex = 0;

  _LetterLesson get _lesson => _lessons[_lessonIndex];

  @override
  void initState() {
    super.initState();
    FandoghiCoach.enablePersistentPresence();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      if (GameData.isDailyLimitReached) {
        FandoghiCoach.judge(
          'زمان بازی امروز تمام شده؛ فردا دوباره تمرین نوشتن را ادامه می‌دهیم ⏰',
        );
        return;
      }
      FandoghiCoach.instruction(
        'به آکادمی الفبا خوش آمدی! یک حرف انتخاب کن و بعد دکمه‌ی «تمرین نوشتن» را بزن ✍️',
      );
    });
  }

  @override
  void dispose() {
    FandoghiCoach.clear();
    super.dispose();
  }

  void _selectLesson(int index) {
    setState(() => _lessonIndex = index);
    FandoghiCoach.instruction(
      'حرف «${_lessons[index].letter}» را انتخاب کردی؛ اسمش ${_lessons[index].word} است. حالا دکمه‌ی «تمرین نوشتن» را بزن ✍️',
    );
    // فاز ۶: تلفظ حرف توسط فندقی
    unawaited(AudioService.pronounceLetter(_lessons[index].letter));
  }

  Future<void> _openTraceScreen() async {
    if (!canStartPlay(context)) return;
    await Navigator.of(context).push(
      MaterialPageRoute<void>(
        fullscreenDialog: true,
        builder: (_) => _TraceScreen(
          lessons: _lessons,
          initialIndex: _lessonIndex,
          stageId: widget.stageId,
          stageNumber: widget.stageNumber,
        ),
      ),
    );
    if (mounted) {
      FandoghiCoach.instruction(
        'خوب نوشتی! می‌توانی حرف دیگری را انتخاب کنی یا دوباره تمرین کنی 🌟',
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: DecoratedBox(
        decoration: const BoxDecoration(gradient: AppGradients.nightSky),
        child: SafeArea(
          child: Column(
            children: [
              _topBar(),
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.fromLTRB(16, 4, 16, 24),
                  child: Column(
                    children: [
                      _academyHero(),
                      const SizedBox(height: 14),
                      _lessonCard(),
                      const SizedBox(height: 14),
                      _letterPicker(),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _topBar() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        children: [
          IconButton(
            tooltip: 'برگشت',
            onPressed: () => Navigator.pop(context),
            icon: const Icon(Icons.arrow_back_rounded, color: Colors.white),
          ),
          const Spacer(),
          Text(
            'آکادمی الفبا 🔤',
            style: AppFonts.balooBhaijaan2(
              color: Colors.white,
              fontSize: 22,
              fontWeight: FontWeight.w900,
            ),
          ),
          const Spacer(),
          Text(
            '${_lessonIndex + 1}/${_lessons.length}',
            style: AppFonts.balooBhaijaan2(
              color: Colors.white70,
              fontSize: 16,
              fontWeight: FontWeight.w800,
            ),
          ),
        ],
      ),
    );
  }

  Widget _academyHero() {
    return ClipRRect(
      borderRadius: BorderRadius.circular(26),
      child: SizedBox(
        height: 155,
        width: double.infinity,
        child: Stack(
          fit: StackFit.expand,
          children: [
            Image.asset(
              'assets/illustrations/alphabet_world.webp',
              fit: BoxFit.cover,
              alignment: Alignment.center,
            ),
            DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [Colors.black.withOpacity(0.05), Colors.black.withOpacity(0.55)],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                ),
              ),
            ),
            Positioned(
              right: 18,
              bottom: 14,
              left: 18,
              child: Text(
                'ببین • بگو • بنویس • تکرار کن',
                textAlign: TextAlign.center,
                style: AppFonts.balooBhaijaan2(
                  color: Colors.white,
                  fontSize: 22,
                  fontWeight: FontWeight.w900,
                  shadows: const [Shadow(color: Colors.black54, blurRadius: 8)],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _lessonCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.1),
        borderRadius: BorderRadius.circular(26),
        border: Border.all(color: Colors.white.withOpacity(0.14)),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                width: 108,
                height: 108,
                decoration: BoxDecoration(
                  gradient: AppGradients.candy,
                  borderRadius: BorderRadius.circular(24),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.candy1.withOpacity(0.3),
                      blurRadius: 16,
                      offset: const Offset(0, 8),
                    ),
                  ],
                ),
                child: Center(
                  child: Text(
                    _lesson.letter,
                    style: AppFonts.vazirmatn(
                      color: Colors.white,
                      fontSize: 68,
                      fontWeight: FontWeight.w900,
                      height: 1,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'حرف «${_lesson.letter}»',
                      style: AppFonts.balooBhaijaan2(
                        color: Colors.white,
                        fontSize: 23,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    const SizedBox(height: 5),
                    Text(
                      '${_lesson.emoji} مثلِ «${_lesson.word}»',
                      style: AppFonts.balooBhaijaan2(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'برای تمرین نوشتن، دکمه‌ی زیر را بزن.',
                      style: AppFonts.balooBhaijaan2(
                        color: Colors.white70,
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        height: 1.5,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          SizedBox(
            width: double.infinity,
            child: FilledButton.icon(
              onPressed: _openTraceScreen,
              icon: const Icon(Icons.draw_rounded, size: 20),
              label: const Text('تمرین نوشتن ✍️'),
              style: FilledButton.styleFrom(
                backgroundColor: Colors.white,
                foregroundColor: AppColors.primaryDark,
                padding: const EdgeInsets.symmetric(vertical: 14),
                textStyle: AppFonts.balooBhaijaan2(
                  fontWeight: FontWeight.w900,
                  fontSize: 18,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(18),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _letterPicker() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.08),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.white.withOpacity(0.12)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'انتخاب حرف برای تمرین',
            style: AppFonts.balooBhaijaan2(
              color: Colors.white70,
              fontSize: 16,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 10),
          Wrap(
            spacing: 7,
            runSpacing: 7,
            children: List.generate(_lessons.length, (index) {
              final selected = index == _lessonIndex;
              return ChoiceChip(
                label: Text(_lessons[index].letter),
                selected: selected,
                onSelected: (_) => _selectLesson(index),
                selectedColor: AppColors.primary,
                backgroundColor: Colors.white.withOpacity(0.1),
                labelStyle: AppFonts.balooBhaijaan2(
                  color: selected ? Colors.white : Colors.white70,
                  fontWeight: FontWeight.w900,
                  fontSize: 16,
                ),
                side: BorderSide(color: Colors.white.withOpacity(0.1)),
              );
            }),
          ),
        ],
      ),
    );
  }
}

/// صفحه‌ی تمام‌عرض نوشتن. هیچ ScrollView و لیست عمودی‌ای ندارد، پس
/// وقتی بچه انگشتش را به هر سمتی (به‌ویژه بالا و پایین) می‌کشد،
/// صفحه بالا و پایین نمی‌رود و فقط روی حرف کشیده می‌شود.
class _TraceScreen extends StatefulWidget {
  final List<_LetterLesson> lessons;
  final int initialIndex;
  final String? stageId;
  final int? stageNumber;

  const _TraceScreen({
    required this.lessons,
    required this.initialIndex,
    this.stageId,
    this.stageNumber,
  });

  @override
  State<_TraceScreen> createState() => _TraceScreenState();
}

class _TraceScreenState extends State<_TraceScreen> {
  final GlobalKey _canvasKey = GlobalKey();
  final List<List<Offset>> _strokes = <List<Offset>>[];
  late int _lessonIndex;
  _TraceResult? _lastResult;
  bool _checking = false;

  _LetterLesson get _lesson => widget.lessons[_lessonIndex];

  @override
  void initState() {
    super.initState();
    _lessonIndex = widget.initialIndex;
  }

  void _selectLesson(int index) {
    setState(() {
      _lessonIndex = index;
      _strokes.clear();
      _lastResult = null;
    });
    FandoghiCoach.instruction(
      'حرف «${widget.lessons[index].letter}» را نگاه کن؛ اسمش ${widget.lessons[index].word} است. حالا با انگشت بنویس ✍️',
    );
  }

  void _startStroke(DragStartDetails details) {
    HapticFeedback.selectionClick();
    setState(() {
      _strokes.add(<Offset>[details.localPosition]);
      _lastResult = null;
    });
  }

  void _updateStroke(DragUpdateDetails details) {
    if (_strokes.isEmpty) return;
    setState(() => _strokes.last.add(details.localPosition));
  }

  void _clearTrace() {
    if (_strokes.isEmpty) return;
    setState(() {
      _strokes.clear();
      _lastResult = null;
    });
    FandoghiCoach.instruction(
        'اشکالی ندارد؛ صفحه را تمیز کردیم. دوباره با آرامش بنویس 🌰');
  }

  void _undoTrace() {
    if (_strokes.isEmpty) return;
    setState(() {
      _strokes.removeLast();
      _lastResult = null;
    });
  }

  Future<void> _checkTrace() async {
    if (_checking) return;
    if (GameData.isDailyLimitReached) {
      await showPlayLimitDialog(context);
      if (mounted) Navigator.pop(context);
      return;
    }
    final renderObject = _canvasKey.currentContext?.findRenderObject();
    final size =
        renderObject is RenderBox ? renderObject.size : const Size(320, 230);
    setState(() => _checking = true);
    try {
      final result = await _evaluateTrace(size);
      if (!mounted) return;

      setState(() {
        _lastResult = result;
        _checking = false;
      });
      GameData.recordAnswer(correct: result.passed, skill: 'alphabet');
      if (result.passed) {
        GameData.progressMission('alphabet');
        GameData.addCoins(8);
        GameData.addStars(1);
        AudioService.star();
        AudioService.correct();
        if (widget.stageId != null) {
          GameData.completeStage(widget.stageId!,
              stageNumber: widget.stageNumber);
        }
        FandoghiCoach.correct(
          'آفرین! فندقی دید که حرف «${_lesson.letter}» را با دقت نوشتی ✨',
        );
        // فاز ۲۱: مرحله «بگو» — فندقی تلفظ را می‌گوید و کودک تکرار می‌کند
        Future<void>.delayed(const Duration(milliseconds: 1500), () {
          if (!mounted) return;
          FandoghiCoach.say(
            'حالا اسم حرف را با من بگو: ${_lesson.letter}… حالا نوبت توست! 🗣️',
            mood: FandoghiMood.excited,
            duration: const Duration(seconds: 4),
          );
          unawaited(AudioService.pronounceLetter(_lesson.letter));
        });
      } else {
        AudioService.wrong();
        FandoghiCoach.say(
          'هنوز کمی بیرون راهنما رفتی. از نقطه‌های کم‌رنگ آرام‌تر رد شو و دوباره امتحان کن 💪',
          mood: FandoghiMood.thinking,
          tone: FandoghiCoachTone.encouragement,
          duration: const Duration(seconds: 4),
        );
      }
    } catch (_) {
      if (!mounted) return;
      setState(() => _checking = false);
      FandoghiCoach.judge('فندقی نتوانست این تمرین را بررسی کند؛ دوباره امتحان کن.');
    }
  }

  Future<_TraceResult> _evaluateTrace(Size size) async {
    final points = _strokes.expand((stroke) => stroke).toList();
    if (points.length < 8) return const _TraceResult(score: 0, passed: false);

    var totalLength = 0.0;
    for (final stroke in _strokes) {
      for (var i = 1; i < stroke.length; i++) {
        totalLength += (stroke[i] - stroke[i - 1]).distance;
      }
    }

    final guide = Rect.fromCenter(
      center: Offset(size.width / 2, size.height * 0.53),
      width: size.width * 0.58,
      height: size.height * 0.73,
    );
    final inside =
        points.where((point) => guide.inflate(28).contains(point)).length;
    final guideCoverage = inside / points.length;
    final glyphCoverage = await _glyphCoverage(size, points);
    final movement =
        (totalLength / (size.shortestSide * 1.35)).clamp(0.0, 1.0);
    final score = (glyphCoverage * 0.55 +
            guideCoverage * 0.25 +
            movement * 0.2)
        .clamp(0.0, 1.0)
        .toDouble();
    return _TraceResult(score: score, passed: score >= 0.5);
  }

  Future<double> _glyphCoverage(Size size, List<Offset> points) async {
    final recorder = ui.PictureRecorder();
    final canvas = Canvas(recorder);
    final painter = _guideTextPainter(_lesson.letter, size, Colors.white);
    painter.paint(canvas, _guideTextOffset(size, painter));
    final picture = recorder.endRecording();
    final image = await picture.toImage(size.width.ceil(), size.height.ceil());
    try {
      final data = await image.toByteData(format: ui.ImageByteFormat.rawRgba);
      if (data == null) return 0;

      var hits = 0;
      for (final point in points) {
        final x = point.dx.round();
        final y = point.dy.round();
        var hit = false;
        for (var dy = -5; dy <= 5 && !hit; dy += 2) {
          for (var dx = -5; dx <= 5; dx += 2) {
            final sampleX = x + dx;
            final sampleY = y + dy;
            if (sampleX < 0 ||
                sampleY < 0 ||
                sampleX >= image.width ||
                sampleY >= image.height) {
              continue;
            }
            final alphaIndex = (sampleY * image.width + sampleX) * 4 + 3;
            if (data.getUint8(alphaIndex) > 8) {
              hit = true;
              break;
            }
          }
        }
        if (hit) hits++;
      }
      return hits / points.length;
    } finally {
      image.dispose();
      picture.dispose();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFFFCF4),
      body: SafeArea(
        // یک لایه‌ی GestureDetector تمام‌صفحه که بچه بتواند آزادانه
        // با انگشت در همه‌ی جهت‌ها بکشد، بدون اینکه صفحه اسکرول شود.
        child: Stack(
          children: [
            Positioned.fill(
              child: Container(
                key: _canvasKey,
                color: const Color(0xFFFFFCF4),
                child: GestureDetector(
                  behavior: HitTestBehavior.opaque,
                  onPanStart: _startStroke,
                  onPanUpdate: _updateStroke,
                  child: CustomPaint(
                    painter: _TracePainter(
                      letter: _lesson.letter,
                      strokes: _strokes,
                    ),
                    child: const SizedBox.expand(),
                  ),
                ),
              ),
            ),
            // نوار بالا
            Positioned(
              top: 0,
              left: 0,
              right: 0,
              child: _traceTopBar(),
            ),
            // نوار پایین (ابزارها)
            Positioned(
              left: 0,
              right: 0,
              bottom: 0,
              child: _traceBottomBar(),
            ),
            // پیام امتیاز پریمیوم — overlay ستاره‌دار ML-like (پیشنهاد ۲۱)
            if (_lastResult != null)
              Positioned.fill(
                child: Container(
                  color: Colors.black.withOpacity(0.35),
                  alignment: Alignment.center,
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
                    child: HandwritingScoreOverlay(
                      score: _lastResult!.score,
                      letter: _lesson.letter,
                      passed: _lastResult!.passed,
                      onRetry: () => setState(() {
                        _strokes.clear();
                        _lastResult = null;
                      }),
                      onNext: () {
                        if (_lastResult!.passed) {
                          // حرف بعدی
                          final next = (_lessonIndex + 1) % widget.lessons.length;
                          setState(() {
                            _lessonIndex = next;
                            _strokes.clear();
                            _lastResult = null;
                          });
                        } else {
                          setState(() => _lastResult = null);
                        }
                      },
                    ),
                  ),
                ),
              ),
            // پیش‌نمایش کوچک حرف
            Positioned(
              top: 70,
              left: 12,
              child: _letterPreview(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _traceTopBar() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.92),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          IconButton(
            tooltip: 'برگشت',
            onPressed: () => Navigator.of(context).pop(),
            icon: const Icon(Icons.close_rounded, size: 28),
            color: AppColors.primaryDark,
          ),
          const Spacer(),
          Text(
            'بنویس: «${_lesson.letter}»',
            style: AppFonts.balooBhaijaan2(
              color: AppColors.textPrimary,
              fontSize: 20,
              fontWeight: FontWeight.w900,
            ),
          ),
          const Spacer(),
          // انتخاب‌گر سریع حرف
          PopupMenuButton<int>(
            tooltip: 'تغییر حرف',
            icon: const Icon(Icons.menu_book_rounded, size: 24),
            color: Colors.white,
            onSelected: _selectLesson,
            itemBuilder: (context) =>
                List.generate(widget.lessons.length, (i) {
              return PopupMenuItem<int>(
                value: i,
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      widget.lessons[i].letter,
                      style: AppFonts.balooBhaijaan2(
                        fontSize: 18,
                        fontWeight: FontWeight.w900,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      widget.lessons[i].word,
                      style: AppFonts.balooBhaijaan2(
                        color: AppColors.textSecondary,
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              );
            }),
          ),
        ],
      ),
    );
  }

  Widget _letterPreview() {
    return Container(
      width: 78,
      height: 78,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.primary.withOpacity(0.3), width: 2),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 6,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      alignment: Alignment.center,
      child: Text(
        _lesson.letter,
        style: AppFonts.vazirmatn(
          color: AppColors.primary,
          fontSize: 44,
          fontWeight: FontWeight.w900,
          height: 1,
        ),
      ),
    );
  }

  Widget _resultBadge(_TraceResult r) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      decoration: BoxDecoration(
        color: r.passed ? AppColors.success : AppColors.primary.withOpacity(0.9),
        borderRadius: BorderRadius.circular(22),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.18),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            r.passed ? Icons.celebration_rounded : Icons.refresh_rounded,
            color: Colors.white,
            size: 20,
          ),
          const SizedBox(width: 7),
          Text(
            r.passed
                ? 'آفرین! امتیاز: ${(r.score * 100).round()}٪'
                : 'امتیاز: ${(r.score * 100).round()}٪ — دوباره تلاش کن',
            style: AppFonts.balooBhaijaan2(
              color: Colors.white,
              fontWeight: FontWeight.w900,
              fontSize: 17,
            ),
          ),
        ],
      ),
    );
  }

  Widget _traceBottomBar() {
    return Container(
      padding: const EdgeInsets.fromLTRB(10, 8, 10, 10),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 6,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: Row(
        children: [
          IconButton.filledTonal(
            tooltip: 'برگرداندن آخرین خط',
            onPressed: _strokes.isEmpty ? null : _undoTrace,
            icon: const Icon(Icons.undo_rounded, size: 22),
          ),
          const SizedBox(width: 6),
          IconButton.filledTonal(
            tooltip: 'پاک کردن همه',
            onPressed: _strokes.isEmpty ? null : _clearTrace,
            icon: const Icon(Icons.delete_outline_rounded, size: 22),
          ),
          const Spacer(),
          FilledButton.icon(
            onPressed: _strokes.isEmpty || _checking ? null : _checkTrace,
            icon: const Icon(Icons.verified_rounded, size: 20),
            label: Text(_checking ? 'در حال بررسی…' : 'بررسی کن'),
            style: FilledButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
              padding:
                  const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
              textStyle: AppFonts.balooBhaijaan2(
                fontWeight: FontWeight.w900,
                fontSize: 17,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

const _lessons = <_LetterLesson>[
  _LetterLesson('آ', 'آهو', '🦌'),
  _LetterLesson('ا', 'ابر', '☁️'),
  _LetterLesson('ب', 'بادبادک', '🪁'),
  _LetterLesson('پ', 'پروانه', '🦋'),
  _LetterLesson('ت', 'توت', '🍓'),
  _LetterLesson('ث', 'ثانیه', '⏱️'),
  _LetterLesson('ج', 'جوجه', '🐥'),
  _LetterLesson('چ', 'چتر', '☂️'),
  _LetterLesson('ح', 'حلزون', '🐌'),
  _LetterLesson('خ', 'خروس', '🐓'),
  _LetterLesson('د', 'دلفین', '🐬'),
  _LetterLesson('ذ', 'ذرت', '🌽'),
  _LetterLesson('ر', 'رنگین‌کمان', '🌈'),
  _LetterLesson('ز', 'زرافه', '🦒'),
  _LetterLesson('ژ', 'ژله', '🍮'),
  _LetterLesson('س', 'سیب', '🍎'),
  _LetterLesson('ش', 'شیر', '🦁'),
  _LetterLesson('ص', 'صابون', '🧼'),
  _LetterLesson('ض', 'ضبط', '🎙️'),
  _LetterLesson('ط', 'طوطی', '🦜'),
  _LetterLesson('ظ', 'ظرف', '🥣'),
  _LetterLesson('ع', 'عروسک', '🪆'),
  _LetterLesson('غ', 'غاز', '🪿'),
  _LetterLesson('ف', 'فیل', '🐘'),
  _LetterLesson('ق', 'قورباغه', '🐸'),
  _LetterLesson('ک', 'کبوتر', '🕊️'),
  _LetterLesson('گ', 'گل', '🌷'),
  _LetterLesson('ل', 'لاله', '🌷'),
  _LetterLesson('م', 'ماه', '🌙'),
  _LetterLesson('ن', 'نارنگی', '🍊'),
  _LetterLesson('و', 'ورزش', '⚽'),
  _LetterLesson('ه', 'هواپیما', '✈️'),
  _LetterLesson('ی', 'یخ', '🧊'),
];

class _LetterLesson {
  final String letter;
  final String word;
  final String emoji;

  const _LetterLesson(this.letter, this.word, this.emoji);
}

class _TraceResult {
  final double score;
  final bool passed;

  const _TraceResult({required this.score, required this.passed});
}

TextPainter _guideTextPainter(String letter, Size size, Color color) {
  return TextPainter(
    text: TextSpan(
      text: letter,
      style: AppFonts.vazirmatn(
        color: color,
        fontSize: math.min(size.width * 0.58, size.height * 0.75).toDouble(),
        fontWeight: FontWeight.w900,
      ),
    ),
    textDirection: TextDirection.rtl,
  )..layout();
}

Offset _guideTextOffset(Size size, TextPainter painter) {
  return Offset(
    (size.width - painter.width) / 2,
    (size.height - painter.height) * 0.45,
  );
}

class _TracePainter extends CustomPainter {
  final String letter;
  final List<List<Offset>> strokes;

  const _TracePainter({required this.letter, required this.strokes});

  @override
  void paint(Canvas canvas, Size size) {
    // راهنمای کم‌رنگ پشت خطوط کشیده‌شده
    final guidePainter = _guideTextPainter(
      letter,
      size,
      AppColors.primary.withOpacity(0.16),
    );
    guidePainter.paint(canvas, _guideTextOffset(size, guidePainter));

    // خط پایه‌ی نقطه‌چین
    final guidePaint = Paint()
      ..color = AppColors.primary.withOpacity(0.22)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2
      ..strokeCap = StrokeCap.round;
    for (var x = size.width * 0.2; x < size.width * 0.8; x += 14) {
      canvas.drawCircle(Offset(x, size.height * 0.88), 1.2, guidePaint);
    }

    // خطوطی که بچه کشیده
    final strokePaint = Paint()
      ..color = AppColors.primaryDark
      ..style = PaintingStyle.stroke
      ..strokeWidth = 7
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;
    for (final stroke in strokes) {
      if (stroke.isEmpty) continue;
      if (stroke.length == 1) {
        canvas.drawCircle(stroke.first, 3.5, strokePaint..style = PaintingStyle.fill);
        strokePaint.style = PaintingStyle.stroke;
        continue;
      }
      final path = Path()..moveTo(stroke.first.dx, stroke.first.dy);
      for (final point in stroke.skip(1)) {
        path.lineTo(point.dx, point.dy);
      }
      canvas.drawPath(path, strokePaint);
    }
  }

  @override
  bool shouldRepaint(covariant _TracePainter oldDelegate) => true;
}
