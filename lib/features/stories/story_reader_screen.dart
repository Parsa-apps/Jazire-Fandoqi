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
import '../../core/game_data.dart';
import '../../core/learning_content/children_stories_data.dart';
import '../../shared/widgets/child_touch_target.dart';
import '../../shared/widgets/fandoghi_v2.dart';
import '../../shared/widgets/particle_celebration.dart';
import '../../shared/widgets/star_field.dart';
import 'widgets/story_page_illustration.dart';
import 'widgets/story_quiz_modal.dart';

/// ═══════════════════════════════════════════════════════════════
/// 📖 STORY READER SCREEN — کتابخوان مصور و تعاملی کودکان (نسخه پیشرفته)
/// با امکان قصه شب (Bedtime Mode)، خواندن خودکار، کلمات طلایی و مسابقه درک مطلب
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

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
    FandoghiCoach.enablePersistentPresence();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      _playPageAudio(_currentPageIndex);
    });
  }

  @override
  void dispose() {
    _autoPlayTimer?.cancel();
    _pageController.dispose();
    StoryAudioService.stop();
    FandoghiCoach.clear();
    super.dispose();
  }

  ChildrenStoryPage get _currentPage => widget.story.pages[_currentPageIndex];
  bool get _isLastPage => _currentPageIndex == widget.story.pages.length - 1;

  Future<void> _playPageAudio(int pageIndex) async {
    if (pageIndex < 0 || pageIndex >= widget.story.pages.length) return;
    final page = widget.story.pages[pageIndex];
    // عنوان + متن با لحن کودکانه - صدای بچگانه حرفه‌ای
    final pageText = '${page.title}. ${page.text}';
    setState(() => _isSpeaking = true);

    // اول سعی کن فایل پیش‌ضبط شده با صدای بچگانه را پخش کنی
    final playedPreRecorded = await StoryAudioService.playPreRecordedOnly(
      widget.story.id,
      page.pageNumber,
    );

    if (playedPreRecorded) {
      // گوش دادن به پایان پخش فایل ضبط شده
      StoryAudioService.playerStateStream.listen((state) {
        if (state.processingState == ProcessingState.completed) {
          if (mounted) {
            setState(() => _isSpeaking = false);
            if (_isAutoPlaying && !_isLastPage) {
              _autoPlayTimer?.cancel();
              _autoPlayTimer = Timer(const Duration(seconds: 1), () {
                if (mounted && _isAutoPlaying) _goToNextPage();
              });
            }
          }
        }
      });
      // fallback تایمری اگر استریم نیامد (تخمین طول فایل)
      Future.delayed(Duration(seconds: (pageText.split(' ').length / 2.5).ceil() + 6), () {
        if (mounted && _isSpeaking && _isAutoPlaying && !_isLastPage) {
          // اگر هنوز speaking بود و autoPlay روشن است، برو صفحه بعد
        }
      });
      // همچنین شنونده برای تغییر isPlaying
      // اگر فایل وجود نداشت، fallback به TTS
    } else {
      // fallback: TTS سیستم با لحن کودکانه (pitch بالا)
      try {
        await AudioService.speak(pageText);
        // تخمین زمان پایان TTS
        final wordCount = pageText.split(' ').length;
        final est = Duration(seconds: (wordCount / 2.2).ceil() + 2);
        await Future.delayed(est);
      } catch (_) {}
      if (mounted) {
        setState(() => _isSpeaking = false);
        if (_isAutoPlaying && !_isLastPage) {
          _autoPlayTimer?.cancel();
          _autoPlayTimer = Timer(const Duration(seconds: 2), () {
            if (mounted && _isAutoPlaying) _goToNextPage();
          });
        }
      }
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
      _autoPlayTimer?.cancel();
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
    if (_currentPageIndex < widget.story.pages.length - 1) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 450),
        curve: Curves.easeInOutCubic,
      );
    }
  }

  void _goToPrevPage() {
    HapticFeedback.lightImpact();
    if (_currentPageIndex > 0) {
      _pageController.previousPage(
        duration: const Duration(milliseconds: 450),
        curve: Curves.easeInOutCubic,
      );
    }
  }

  void _showWordModal(StoryVocabularyWord word) {
    HapticFeedback.selectionClick();
    AudioService.speak('${word.word}. ${word.meaning}');
    GameData.addCoins(1);

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
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
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

    // ثبت تکمیل داستان برای بار اول
    GameData.markStoryCompleted(widget.story.id);
    GameData.recordAnswer(correct: true, skill: 'vocab');

    // نمایش مسابقه درک مطلب داستان
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
              // پس‌زمینه ستاره‌های خواب در حالت شب
              if (_isBedtimeMode)
                const Positioned.fill(
                  child: IgnorePointer(child: StarField()),
                ),

              Column(
                children: [
                  // ۱. نوار بالای صفحه (با دکمه‌های حالت شب، خواندن خودکار و لایک)
                  _buildTopHeader(isFav),

                  // ۲. نوار پیشرفت صفحات
                  _buildProgressBar(),

                  // ۳. بخش اصلی داستان (PageView)
                  Expanded(
                    child: PageView.builder(
                      controller: _pageController,
                      physics: const BouncingScrollPhysics(),
                      itemCount: story.pages.length,
                      onPageChanged: (index) {
                        setState(() => _currentPageIndex = index);
                        _autoPlayTimer?.cancel();
                        StoryAudioService.stop();
                        _playPageAudio(index);
                      },
                      itemBuilder: (context, index) {
                        final page = story.pages[index];
                        return _buildPageCard(page);
                      },
                    ),
                  ),

                  // ۴. نوار ناوبری پایین (صفحه قبل / بعد / چالش پایان)
                  _buildBottomNavBar(),
                ],
              ),

              if (_celebrating)
                const Positioned.fill(
                  child: ParticleCelebration(count: 60),
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
          // دکمه بازگشت
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

          // عنوان داستان و شماره صفحه
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
                  'صفحه ${_currentPageIndex + 1} از ${widget.story.pages.length} • ${_isBedtimeMode ? "حالت قصه شب 🌙" : widget.story.categoryLabel}',
                  style: TextStyle(
                    color: _isBedtimeMode ? Colors.amberAccent : Colors.white70,
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),

          // دکمه قصه شب (Bedtime)
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

          // دکمه خواندن خودکار (Auto-Play)
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
                  color: _isAutoPlaying ? Colors.greenAccent : Colors.white24,
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

          // دکمه لایک داستان
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
        child: LinearProgressIndicator(
          value: progress,
          backgroundColor: Colors.white.withOpacity(0.18),
          valueColor: AlwaysStoppedAnimation<Color>(
            _isBedtimeMode ? Colors.amberAccent : Colors.amberAccent,
          ),
          minHeight: 6,
        ),
      ),
    );
  }

  Widget _buildPageCard(ChildrenStoryPage page) {
    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // ۱. تصویر اختصاصی صفحه
          StoryPageIllustration(
            story: widget.story,
            page: page,
          ),

          const SizedBox(height: 14),

          // ۲. نوار بشنویم و زمان مطالعه
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              GestureDetector(
                onTap: () {
                  HapticFeedback.lightImpact();
                  _playPageAudio(_currentPageIndex);
                },
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
                            ? Icons.volume_up_rounded
                            : Icons.volume_up_outlined,
                        color:
                            _isSpeaking ? Colors.amberAccent : Colors.white,
                        size: 20,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        _isSpeaking
                            ? 'با صدای کودکانه... 🎙️'
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

          // ۳. کلمات طلایی این صفحه (اگر وجود داشت)
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
                        onTap: () => _showWordModal(w),
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

          // ۴. جعبه متن داستان کودکانه
          Container(
            padding: const EdgeInsets.all(22),
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
                          color: Colors.amberAccent,
                          fontSize: 17,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 14),
                Text(
                  page.text,
                  style: AppFonts.vazirmatn(
                    color: Colors.white,
                    fontSize: 17,
                    fontWeight: FontWeight.w700,
                    height: 1.9,
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 16),

          // ۵. سوال فکرکنک فندقی
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

          // ۶. اگر صفحه آخر است: نمایش پیام اخلاقی (SEL)
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
              '${_currentPageIndex + 1} / ${widget.story.pages.length}',
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
