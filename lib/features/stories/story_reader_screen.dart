import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:just_audio/just_audio.dart';

import '../../app/app_colors.dart';
import '../../app/app_fonts.dart';
import '../../core/audio_service.dart';
import '../../core/story_audio_service.dart';
import '../../core/fandoghi_coach.dart';
import '../../core/fandoghi_models.dart';
import '../../core/game_data.dart';
import '../../core/growth/persian_digits.dart';
import '../../core/learning_content/children_stories_data.dart';
import '../../core/literacy/story_read_along.dart';
import '../../core/logger_service.dart';
import '../../shared/widgets/child_touch_target.dart';
import '../../shared/widgets/particle_celebration.dart';
import '../../shared/widgets/star_field.dart';
import 'widgets/story_page_illustration.dart';
import 'widgets/story_quiz_modal.dart';

/// ═══════════════════════════════════════════════════════════════
/// 📖 STORY READER SCREEN — کتابخوان مصور و تعاملی کودکان (نسخه پیشرفته)
/// با هایلایت هماهنگ خط‌به‌خط با صدای گوینده، حالت قصه شب، پخش خودکار و مسابقه
/// ═══════════════════════════════════════════════════════════════
class StoryReaderScreen extends StatefulWidget {
  final ChildrenStory story;

  const StoryReaderScreen({super.key, required this.story});

  @override
  State<StoryReaderScreen> createState() => _StoryReaderScreenState();
}

class _StoryReaderScreenState extends State<StoryReaderScreen> {
  late final PageController _pageController;
  int _currentPageIndex = 0;
  bool _isSpeaking = false;
  bool _isAutoPlaying = false;
  bool _isBedtimeMode = false;
  bool _celebrating = false;

  Timer? _autoPlayTimer;
  StreamSubscription<Duration>? _positionSub;
  StreamSubscription<PlayerState>? _playerStateSub;

  int _highlightedLineIndex = 0;
  int _highlightedWordIndex = 0;
  double _audioProgress = 0.0;
  Duration _pageDuration = Duration.zero;
  final Set<String> _awardedWords = <String>{};

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
    FandoghiCoach.enablePersistentPresence();

    final savedPage = GameData.lastStoryPage;
    final savedStory = GameData.lastStoryId;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      if (savedStory == widget.story.id &&
          savedPage > 0 &&
          savedPage < widget.story.pages.length) {
        _currentPageIndex = savedPage;
        _pageController.jumpToPage(savedPage);
      }
      _playPageAudio(_currentPageIndex);
    });
  }

  @override
  void dispose() {
    _cleanupAudio();
    _pageController.dispose();
    StoryAudioService.stop();
    FandoghiCoach.clear();
    super.dispose();
  }

  void _cleanupAudio() {
    _autoPlayTimer?.cancel();
    _autoPlayTimer = null;
    _positionSub?.cancel();
    _positionSub = null;
    _playerStateSub?.cancel();
    _playerStateSub = null;
  }

  ChildrenStoryPage get _currentPage => widget.story.pages[_currentPageIndex];
  bool get _isLastPage => _currentPageIndex == widget.story.pages.length - 1;

  Future<void> _playPageAudio(int pageIndex) async {
    _cleanupAudio();
    if (pageIndex < 0 || pageIndex >= widget.story.pages.length) return;

    final page = widget.story.pages[pageIndex];
    final lines = StoryReadAlong.sentences(page.text);

    setState(() {
      _highlightedLineIndex = 0;
      _highlightedWordIndex = 0;
      _audioProgress = 0.0;
      _isSpeaking = true;
    });

    // ۱. پخش فایل صوتی اختصاصی و باکیفیت داستان
    final loadedDuration = await StoryAudioService.playPreRecordedOnly(
      widget.story.id,
      page.pageNumber,
    );

    if (loadedDuration != null && loadedDuration > Duration.zero) {
      _pageDuration = loadedDuration;

      // دریافت موقعیت زنده پخش و تغییر خط فعال بر اساس پیشرفت صدا
      _positionSub = StoryAudioService.positionStream.listen((pos) {
        if (!mounted) return;
        final totalMs = _pageDuration.inMilliseconds;
        if (totalMs > 0) {
          final progress =
              (pos.inMilliseconds / totalMs).clamp(0.0, 1.0);
          final activeIndex = StoryReadAlong.activeIndex(lines, progress);
          final local = StoryReadAlong.localProgress(lines, progress, activeIndex);
          final words = activeIndex < lines.length
              ? StoryReadAlong.words(lines[activeIndex])
              : const <String>[];
          final wordIndex = StoryReadAlong.activeIndex(words, local);
          if (activeIndex != _highlightedLineIndex ||
              wordIndex != _highlightedWordIndex ||
              (progress - _audioProgress).abs() > 0.02) {
            setState(() {
              _audioProgress = progress;
              _highlightedLineIndex = activeIndex;
              _highlightedWordIndex = wordIndex;
            });
          }
        }
      });

      // گوش دادن به اتمام پخش فایل
      _playerStateSub = StoryAudioService.playerStateStream.listen((state) {
        if (!mounted) return;
        if (state.processingState == ProcessingState.completed) {
          setState(() {
            _isSpeaking = false;
            _audioProgress = 1.0;
            _highlightedLineIndex = lines.isEmpty ? 0 : lines.length - 1;
          });
          if (_isAutoPlaying && !_isLastPage) {
            _autoPlayTimer?.cancel();
            _autoPlayTimer = Timer(const Duration(milliseconds: 1400), () {
              if (mounted && _isAutoPlaying) _goToNextPage();
            });
          }
        }
      });
    } else {
      // ۲. در صورت عدم وجود فایل صوتی -> پخش با موتور صوتی TTS به‌صورت خط به خط
      try {
        for (int i = 0; i < lines.length; i++) {
          if (!mounted || !_isSpeaking) break;
          final words = StoryReadAlong.words(lines[i]);
          setState(() {
            _highlightedLineIndex = i;
            _highlightedWordIndex = 0;
            _audioProgress = lines.isEmpty ? 1.0 : (i / lines.length);
          });
          unawaited(AudioService.speak(lines[i]));
          for (var w = 0; w < words.length; w++) {
            if (!mounted || !_isSpeaking) break;
            setState(() => _highlightedWordIndex = w);
            await Future<void>.delayed(
              Duration(milliseconds: (320 + words[w].length * 80).clamp(280, 900)),
            );
          }
        }
      } catch (_) {}

      if (mounted) {
        setState(() {
          _isSpeaking = false;
          _audioProgress = 1.0;
          _highlightedLineIndex = lines.isEmpty ? 0 : lines.length - 1;
        });
        if (_isAutoPlaying && !_isLastPage) {
          _autoPlayTimer?.cancel();
          _autoPlayTimer = Timer(const Duration(seconds: 2), () {
            if (mounted && _isAutoPlaying) _goToNextPage();
          });
        }
      }
    }
  }

  void _toggleAudioPlayback() {
    HapticFeedback.lightImpact();
    if (_isSpeaking) {
      StoryAudioService.stop();
      _cleanupAudio();
      setState(() => _isSpeaking = false);
    } else {
      _playPageAudio(_currentPageIndex);
    }
  }

  void _toggleAutoPlay() {
    HapticFeedback.lightImpact();
    setState(() {
      _isAutoPlaying = !_isAutoPlaying;
    });
    if (_isAutoPlaying) {
      _playPageAudio(_currentPageIndex);
    } else {
      _cleanupAudio();
      StoryAudioService.stop();
      setState(() => _isSpeaking = false);
    }
  }

  void _toggleBedtimeMode() {
    HapticFeedback.lightImpact();
    setState(() {
      _isBedtimeMode = !_isBedtimeMode;
    });
    if (_isBedtimeMode) {
      FandoghiCoach.say(
        'حالت قصه شب فعال شد 🌙 آرام باش و با خیال راحت قصه رو گوش کن...',
        mood: FandoghiMood.happy,
        duration: const Duration(seconds: 4),
      );
    }
  }

  void _goToNextPage() {
    HapticFeedback.lightImpact();
    AudioService.page();
    if (_currentPageIndex < widget.story.pages.length - 1) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 450),
        curve: Curves.easeInOutCubic,
      );
    }
  }

  void _goToPrevPage() {
    HapticFeedback.lightImpact();
    AudioService.page();
    if (_currentPageIndex > 0) {
      _pageController.previousPage(
        duration: const Duration(milliseconds: 450),
        curve: Curves.easeInOutCubic,
      );
    }
  }

  void _awardGoldenWord(StoryVocabularyWord word) {
    HapticFeedback.selectionClick();
    AudioService.speak('${word.word}. ${word.meaning}');
    final key = '${widget.story.id}:${word.word}';
    if (_awardedWords.add(key)) {
      GameData.addCoins(1);
      AudioService.coin();
    }
    _showWordModal(word);
  }

  void _showWordModal(StoryVocabularyWord word) {
    HapticFeedback.selectionClick();

    showDialog(
      context: context,
      builder: (ctx) => Dialog(
        backgroundColor: Colors.transparent,
        child: Container(
          padding: const EdgeInsets.all(22),
          decoration: BoxDecoration(
            color: const Color(0xFF28234E),
            borderRadius: BorderRadius.circular(26),
            border: Border.all(color: Colors.amberAccent, width: 2),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.5),
                blurRadius: 20,
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(word.emoji, style: const TextStyle(fontSize: 54))
                  .animate(onPlay: (c) => c.repeat(reverse: true))
                  .scale(
                    begin: const Offset(0.95, 0.95),
                    end: const Offset(1.1, 1.1),
                    duration: 900.ms,
                  ),
              const SizedBox(height: 12),
              Text(
                'کلمه طلایی: ${word.word}',
                style: AppFonts.vazirmatn(
                  color: Colors.amberAccent,
                  fontSize: 20,
                  fontWeight: FontWeight.w900,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                word.meaning,
                textAlign: TextAlign.center,
                style: AppFonts.vazirmatn(
                  color: Colors.white,
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                  height: 1.6,
                ),
              ),
              const SizedBox(height: 14),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                decoration: BoxDecoration(
                  color: Colors.amber.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.monetization_on_rounded,
                        color: Colors.amber, size: 18),
                    SizedBox(width: 6),
                    Text(
                      '+۱ سکه جایزه یادگیری کلمه!',
                      style: TextStyle(
                        color: Colors.amberAccent,
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 18),
              ElevatedButton(
                onPressed: () => Navigator.pop(ctx),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.amber,
                  foregroundColor: Colors.black87,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
                child: Text(
                  'یاد گرفتم ✨',
                  style: AppFonts.vazirmatn(fontWeight: FontWeight.w900),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _completeStoryAndStartQuiz() {
    HapticFeedback.mediumImpact();
    StoryAudioService.stop();
    _cleanupAudio();

    final isNew = GameData.markStoryCompleted(widget.story.id);
    GameData.recordAnswer(correct: true, skill: 'vocab');

    LoggerService.event(
      event: 'story_completed',
      properties: {
        'story_id': widget.story.id,
        'story_title': widget.story.title,
        'is_first_time': isNew,
        'page_index': _currentPageIndex,
        'reading_time': widget.story.readingTime,
      },
    );

    if (isNew) {
      AudioService.win();
      setState(() => _celebrating = true);
      Future.delayed(const Duration(seconds: 2), () {
        if (mounted) setState(() => _celebrating = false);
      });
    }

    StoryQuizModal.show(context, widget.story);
  }

  @override
  Widget build(BuildContext context) {
    final story = widget.story;
    final isFav = GameData.isStoryFavorite(story.id);

    return Scaffold(
      body: DecoratedBox(
        decoration: BoxDecoration(
          gradient: _isBedtimeMode ? AppGradients.nightSky : story.gradient,
        ),
        child: SafeArea(
          child: Stack(
            children: [
              if (_isBedtimeMode)
                const Positioned.fill(
                  child: IgnorePointer(child: StarFieldBackground()),
                ),

              Column(
                children: [
                  _buildTopHeader(isFav),
                  _buildProgressBar(),
                  Expanded(
                    child: PageView.builder(
                      controller: _pageController,
                      physics: const BouncingScrollPhysics(),
                      itemCount: story.pages.length,
                      onPageChanged: (index) {
                        setState(() => _currentPageIndex = index);
                        GameData.saveStoryProgress(widget.story.id, index);
                        _cleanupAudio();
                        StoryAudioService.stop();
                        _playPageAudio(index);
                      },
                      itemBuilder: (context, index) {
                        final page = story.pages[index];
                        return _buildPageCard(page);
                      },
                    ),
                  ),
                  _buildBottomNavBar(),
                ],
              ),

              if (_celebrating)
                const Positioned.fill(
                  child:
                      ParticleCelebration(trigger: true, particleCount: 60),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTopHeader(bool isFav) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 10, 16, 8),
      child: Row(
        children: [
          ChildTouchTarget(
            onTap: () => Navigator.pop(context),
            child: Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.15),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.white24),
              ),
              child: const Icon(Icons.arrow_back_ios_new_rounded,
                  color: Colors.white, size: 20),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '${widget.story.coverEmoji} ${widget.story.title}',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: AppFonts.vazirmatn(
                    color: Colors.white,
                    fontSize: 15,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                Text(
                  'صفحه ${PersianDigits.toFa(_currentPageIndex + 1)} از ${PersianDigits.toFa(widget.story.pages.length)} • ${_isBedtimeMode ? "حالت قصه شب 🌙" : widget.story.categoryLabel}',
                  style: TextStyle(
                    color:
                        _isBedtimeMode ? Colors.amberAccent : Colors.white70,
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
          GestureDetector(
            onTap: _toggleBedtimeMode,
            child: Container(
              margin: const EdgeInsets.only(left: 6),
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: _isBedtimeMode
                    ? Colors.amber.withOpacity(0.3)
                    : Colors.white.withOpacity(0.12),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(
                  color: _isBedtimeMode ? Colors.amberAccent : Colors.white24,
                ),
              ),
              child: Icon(
                _isBedtimeMode
                    ? Icons.nightlight_round
                    : Icons.nightlight_outlined,
                color: _isBedtimeMode ? Colors.amberAccent : Colors.white,
                size: 20,
              ),
            ),
          ),
          GestureDetector(
            onTap: _toggleAutoPlay,
            child: Container(
              margin: const EdgeInsets.only(left: 6),
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: _isAutoPlaying
                    ? Colors.greenAccent.withOpacity(0.3)
                    : Colors.white.withOpacity(0.12),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(
                  color:
                      _isAutoPlaying ? Colors.greenAccent : Colors.white24,
                ),
              ),
              child: Icon(
                _isAutoPlaying
                    ? Icons.play_circle_fill_rounded
                    : Icons.play_circle_outline_rounded,
                color: _isAutoPlaying ? Colors.greenAccent : Colors.white,
                size: 20,
              ),
            ),
          ),
          GestureDetector(
            onTap: () {
              HapticFeedback.lightImpact();
              GameData.toggleStoryFavorite(widget.story.id);
              setState(() {});
            },
            child: Container(
              margin: const EdgeInsets.only(left: 6),
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: isFav
                    ? Colors.redAccent.withOpacity(0.3)
                    : Colors.white.withOpacity(0.12),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(
                  color: isFav ? Colors.redAccent : Colors.white24,
                ),
              ),
              child: Icon(
                isFav
                    ? Icons.favorite_rounded
                    : Icons.favorite_border_rounded,
                color: isFav ? Colors.redAccent : Colors.white,
                size: 20,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProgressBar() {
    final progress = (_currentPageIndex + 1) / widget.story.pages.length;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(8),
        child: Container(
          height: 8,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(8),
            color: Colors.white.withOpacity(0.1),
          ),
          child: Stack(
            children: [
              AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                width: MediaQuery.of(context).size.width * 0.82 * progress,
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [
                      Colors.amberAccent,
                      Colors.orangeAccent,
                      Colors.pinkAccent,
                    ],
                    begin: Alignment.centerLeft,
                    end: Alignment.centerRight,
                  ),
                  borderRadius: BorderRadius.circular(8),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.amberAccent.withOpacity(0.4),
                      blurRadius: 12,
                      spreadRadius: 2,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPageCard(ChildrenStoryPage page) {
    final lines = StoryReadAlong.sentences(page.text);

    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(
        parent: AlwaysScrollableScrollPhysics(),
        decelerationRate: ScrollDecelerationRate.fast,
      ),
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // تصویر اختصاصی صفحه
          StoryPageIllustration(
            story: widget.story,
            page: page,
          ),

          const SizedBox(height: 14),

          // نوار پخش صدا و زمان مطالعه
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              GestureDetector(
                onTap: _toggleAudioPlayback,
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  decoration: BoxDecoration(
                    color: _isSpeaking
                        ? Colors.amberAccent.withOpacity(0.3)
                        : Colors.white.withOpacity(0.16),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color:
                          _isSpeaking ? Colors.amberAccent : Colors.white24,
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        _isSpeaking
                            ? Icons.pause_circle_filled_rounded
                            : Icons.volume_up_rounded,
                        color:
                            _isSpeaking ? Colors.amberAccent : Colors.white,
                        size: 20,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        _isSpeaking
                            ? 'در حال خواندن قصه... 🎙️'
                            : 'بشنویم با صدای بچگانه 🎧',
                        style: AppFonts.vazirmatn(
                          color:
                              _isSpeaking ? Colors.amberAccent : Colors.white,
                          fontSize: 12,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Text(
                  '⏱️ ${widget.story.readingTime}',
                  style: const TextStyle(color: Colors.white70, fontSize: 11),
                ),
              ),
            ],
          ),

          const SizedBox(height: 14),

          // کلمات طلایی صفحه
          if (page.goldenWords.isNotEmpty) ...[
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.08),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: Colors.white12),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Text('🌟', style: TextStyle(fontSize: 16)),
                      const SizedBox(width: 6),
                      Text(
                        'کلمات طلایی این صفحه (برای شنیدن معنی ضربه بزن):',
                        style: AppFonts.vazirmatn(
                          color: Colors.amberAccent,
                          fontSize: 12,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: page.goldenWords.map((w) {
                      return GestureDetector(
                        onTap: () => _awardGoldenWord(w),
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 12, vertical: 6),
                          decoration: BoxDecoration(
                            color: Colors.amber.withOpacity(0.22),
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(
                              color: Colors.amberAccent.withOpacity(0.5),
                            ),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(w.emoji,
                                  style: const TextStyle(fontSize: 16)),
                              const SizedBox(width: 6),
                              Text(
                                w.word,
                                style: AppFonts.vazirmatn(
                                  color: Colors.white,
                                  fontSize: 13,
                                  fontWeight: FontWeight.w800,
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 14),
          ],

          // جعبه متن داستان با هایلایت هماهنگ خط‌به‌خط
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: _isBedtimeMode
                  ? Colors.black.withOpacity(0.35)
                  : Colors.white.withOpacity(0.12),
              borderRadius: BorderRadius.circular(26),
              border: Border.all(color: Colors.white.withOpacity(0.22)),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.15),
                  blurRadius: 16,
                  offset: const Offset(0, 6),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      page.fallbackEmoji,
                      style: const TextStyle(fontSize: 28),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        page.title,
                        style: AppFonts.vazirmatn(
                          color: _isBedtimeMode
                              ? const Color(0xFFFFF3E0)
                              : Colors.amberAccent,
                          fontSize: 17,
                          fontWeight: FontWeight.w900,
                          shadows: const [
                            Shadow(
                                color: Color(0xFFFFA726),
                                blurRadius: 10,
                                offset: Offset(0, 2)),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 14),
                _ReadingTextHighlight(
                  lines: lines,
                  activeIndex: _highlightedLineIndex,
                  activeWordIndex: _highlightedWordIndex,
                  isSpeaking: _isSpeaking,
                ),
              ],
            ),
          ),

          const SizedBox(height: 16),

          // سوال فکرکنک فندقی
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.amber.withOpacity(0.18),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: Colors.amber.withOpacity(0.4)),
            ),
            child: Row(
              children: [
                const Text('💡', style: TextStyle(fontSize: 26)),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'سوال فکرکنک فندقی:',
                        style: AppFonts.vazirmatn(
                          color: Colors.amberAccent,
                          fontSize: 12,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        page.interactiveQuestion,
                        style: AppFonts.vazirmatn(
                          color: Colors.white,
                          fontSize: 13,
                          fontWeight: FontWeight.w800,
                          height: 1.5,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // پیام اخلاقی در پایان داستان
          if (_isLastPage) ...[
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF43A047), Color(0xFF66BB6A)],
                ),
                borderRadius: BorderRadius.circular(22),
                boxShadow: [
                  BoxShadow(
                    color: Colors.green.withOpacity(0.3),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Row(
                children: [
                  const Text('🌟', style: TextStyle(fontSize: 32)),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'پند این داستان:',
                          style: AppFonts.vazirmatn(
                            color: Colors.white,
                            fontSize: 13,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          widget.story.moralMessage,
                          style: AppFonts.vazirmatn(
                            color: Colors.white,
                            fontSize: 14,
                            fontWeight: FontWeight.w800,
                            height: 1.5,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildBottomNavBar() {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 10, 16, 16),
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.25),
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          if (_currentPageIndex > 0)
            ElevatedButton.icon(
              onPressed: _goToPrevPage,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.white.withOpacity(0.18),
                foregroundColor: Colors.white,
                padding:
                    const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(18),
                ),
                elevation: 0,
              ),
              icon: const Icon(Icons.arrow_forward_rounded, size: 20),
              label: Text(
                'صفحه قبل',
                style: AppFonts.vazirmatn(fontWeight: FontWeight.w800),
              ),
            )
          else
            const SizedBox(width: 100),

          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.12),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Text(
              '${PersianDigits.toFa(_currentPageIndex + 1)} / ${PersianDigits.toFa(widget.story.pages.length)}',
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 14,
              ),
            ),
          ),

          if (!_isLastPage)
            ElevatedButton.icon(
              onPressed: _goToNextPage,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.amber,
                foregroundColor: Colors.black87,
                padding:
                    const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(18),
                ),
                elevation: 4,
              ),
              icon: const Icon(Icons.arrow_back_rounded, size: 20),
              label: Text(
                'صفحه بعد',
                style: AppFonts.vazirmatn(
                  fontWeight: FontWeight.w900,
                  color: Colors.black87,
                ),
              ),
            )
          else
            ElevatedButton.icon(
              onPressed: _completeStoryAndStartQuiz,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF43A047),
                foregroundColor: Colors.white,
                padding:
                    const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(18),
                ),
                elevation: 6,
              ),
              icon: const Icon(Icons.military_tech_rounded, size: 22),
              label: Text(
                'چالش درک مطلب 🏆',
                style: AppFonts.vazirmatn(fontWeight: FontWeight.w900),
              ),
            ),
        ],
      ),
    );
  }
}

/// ════════════════════════════════════════════════════════════
/// 🌈 متن داستان با هایلایت خط‌به‌خط هماهنگ با صدای گوینده
/// ════════════════════════════════════════════════════════════
class _ReadingTextHighlight extends StatelessWidget {
  final List<String> lines;
  final int activeIndex;
  final int activeWordIndex;
  final bool isSpeaking;

  const _ReadingTextHighlight({
    required this.lines,
    required this.activeIndex,
    this.activeWordIndex = 0,
    required this.isSpeaking,
  });

  @override
  Widget build(BuildContext context) {
    if (lines.isEmpty) return const SizedBox.shrink();

    final textScale = GameData.textScale.clamp(0.9, 1.4);
    final fontSize = 17.0 * textScale;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: List.generate(lines.length, (index) {
        final line = lines[index];
        final isCurrent = isSpeaking && index == activeIndex;
        final isPast = isSpeaking && index < activeIndex;

        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 3),
          child: GestureDetector(
            onTap: () {
              HapticFeedback.selectionClick();
              AudioService.speak(line);
            },
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 280),
              curve: Curves.easeOutCubic,
              padding:
                  const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(14),
                color: isCurrent
                    ? const Color(0xFFFFB300).withOpacity(0.28)
                    : isPast
                        ? Colors.white.withOpacity(0.05)
                        : Colors.transparent,
                border: Border.all(
                  color: isCurrent
                      ? const Color(0xFFFFD54F)
                      : isPast
                          ? Colors.white.withOpacity(0.1)
                          : Colors.transparent,
                  width: isCurrent ? 1.8 : 1.0,
                ),
                boxShadow: isCurrent
                    ? [
                        BoxShadow(
                          color: const Color(0xFFFFB300).withOpacity(0.35),
                          blurRadius: 12,
                          offset: const Offset(0, 2),
                        ),
                      ]
                    : [],
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (isCurrent)
                    Padding(
                      padding: const EdgeInsets.only(left: 6, top: 4),
                      child: const Icon(
                        Icons.play_arrow_rounded,
                        color: Color(0xFFFFD54F),
                        size: 18,
                      )
                          .animate(onPlay: (c) => c.repeat(reverse: true))
                          .scale(
                            begin: const Offset(0.85, 0.85),
                            end: const Offset(1.15, 1.15),
                            duration: 500.ms,
                          ),
                    ),
                  Expanded(
                    child: isCurrent
                        ? Wrap(
                            spacing: 6,
                            runSpacing: 4,
                            children: [
                              for (final entry
                                  in StoryReadAlong.words(line).asMap().entries)
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 4,
                                    vertical: 1,
                                  ),
                                  decoration: BoxDecoration(
                                    color: entry.key == activeWordIndex
                                        ? const Color(0xFFFF8F00)
                                        : Colors.transparent,
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Text(
                                    entry.value,
                                    style: AppFonts.vazirmatn(
                                      color: entry.key == activeWordIndex
                                          ? const Color(0xFFFFFDE7)
                                          : const Color(0xFFFFF9C4),
                                      fontSize: fontSize,
                                      fontWeight: entry.key == activeWordIndex
                                          ? FontWeight.w900
                                          : FontWeight.w700,
                                      height: 1.85,
                                    ),
                                  ),
                                ),
                            ],
                          )
                        : Text(
                            line,
                            style: AppFonts.vazirmatn(
                              color: isPast
                                  ? Colors.white.withOpacity(0.85)
                                  : Colors.white,
                              fontSize: fontSize,
                              fontWeight: FontWeight.w700,
                              height: 1.85,
                            ),
                          ),
                  ),
                ],
              ),
            ),
          ),
        );
      }),
    );
  }
}
