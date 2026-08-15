import 'dart:async';
import 'dart:math' as math;
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';

import '../../../app/app_colors.dart';
import '../../../app/design_tokens.dart';
import 'package:jazireh_fandoghi/app/app_fonts.dart';
import '../../../core/audio_service.dart';
import '../../../core/content_access_policy.dart';
import '../../../core/fandoghi_coach.dart';
import '../../../core/game_data.dart';
import '../../../core/monetization.dart';
import '../../../core/play_limit.dart';
import '../../../shared/widgets/child_touch_target.dart';
import '../../../shared/widgets/fandoghi_v2.dart';
import '../../../shared/widgets/handwriting_score_overlay.dart';
import '../../../shared/widgets/particle_celebration.dart';
import '../../shop/full_version_paywall.dart';

/// ────────────────────────────────────────────────────────────
/// 🔤 آکادمی الفبا و فارسی اول دبستان (Grade 1 Curriculum)
///
/// دو حالت جامع:
/// ۱. حالت اول: مطابق کتاب بخوانیم اول دبستان (زنجیره بسته‌های نشانه‌های ۱ و ۲ + کارگاه واژه‌سازی)
/// ۲. حالت دوم: جستجوی الفبایی آزاد (الف تا ی + جستجوی زنده)
/// ۳. رفتار معلم واقعی: قفل بودن حرف بعدی تا تایید رسمی خط کودک
/// ────────────────────────────────────────────────────────────
enum _AlphabetMode { grade1, alphabetical }

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
  _AlphabetMode _mode = _AlphabetMode.grade1;
  int _selectedBundleIndex = 0;
  int _lessonIndex = 0;
  bool _hasFullVersion = false;
  String _searchQuery = '';
  final TextEditingController _searchController = TextEditingController();

  _Grade1Bundle get _currentBundle => _grade1Bundles[_selectedBundleIndex];

  List<_LetterLesson> get _currentLessons {
    if (_mode == _AlphabetMode.grade1) {
      return _currentBundle.lessons;
    }
    if (_searchQuery.trim().isEmpty) {
      return _alphabeticalLessons;
    }
    final q = _searchQuery.trim().toLowerCase();
    return _alphabeticalLessons.where((l) {
      return l.letter.contains(q) || l.word.contains(q);
    }).toList();
  }

  _LetterLesson get _lesson {
    final list = _currentLessons;
    if (_lessonIndex >= list.length) {
      _lessonIndex = 0;
    }
    return list.isEmpty ? _alphabeticalLessons.first : list[_lessonIndex];
  }

  @override
  void initState() {
    super.initState();
    FandoghiCoach.enablePersistentPresence();
    _refreshEntitlement();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      if (GameData.isDailyLimitReached) {
        FandoghiCoach.judge(
          'زمان بازی امروز تمام شده؛ فردا دوباره تمرین نوشتن را ادامه می‌دهیم ⏰',
        );
        return;
      }
      FandoghiCoach.instruction(
        'به آکادمی الفبای اول دبستان خوش آمدی! نشانه را انتخاب کن و کلمه‌های آن را بساز ✍️',
      );
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    FandoghiCoach.clear();
    super.dispose();
  }

  bool _isLocked(int index) =>
      !_hasFullVersion && !ContentAccessPolicy.isAlphabetLessonFree(index);

  Future<bool> _refreshEntitlement() async {
    final hasFullVersion = await Monetization.hasFullVersion();
    if (mounted && hasFullVersion != _hasFullVersion) {
      setState(() => _hasFullVersion = hasFullVersion);
    }
    return hasFullVersion;
  }

  Future<void> _selectLesson(int index) async {
    if (_isLocked(index) && !await Monetization.hasFullVersion()) {
      if (!mounted) return;
      await showFullVersionPaywall(
        context,
        featureName: 'نشانه «${_currentLessons[index].letter}»',
      );
      if (!await _refreshEntitlement()) return;
    }
    if (!mounted) return;
    setState(() => _lessonIndex = index.clamp(0, _currentLessons.length - 1));
    final lesson = _lesson;
    FandoghiCoach.instruction(
      'نشانه «${lesson.letter}» را انتخاب کردی؛ مثل «${lesson.word}». دکمه «تمرین نوشتن» را بزن ✍️',
    );
    unawaited(AudioService.pronounceLetter(lesson.letter));
  }

  void _selectBundle(int idx) {
    HapticFeedback.selectionClick();
    setState(() {
      _selectedBundleIndex = idx;
      _lessonIndex = 0;
    });
    FandoghiCoach.say(
      '${_grade1Bundles[idx].title} انتخاب شد! نشانه‌ها را یاد بگیر و کلمه‌های جدید بساز ✨',
      mood: FandoghiMood.excited,
    );
  }

  void _switchMode(_AlphabetMode newMode) {
    if (_mode == newMode) return;
    HapticFeedback.selectionClick();
    setState(() {
      _mode = newMode;
      _lessonIndex = 0;
      _searchQuery = '';
      _searchController.clear();
    });
  }

  Future<void> _openTraceScreen() async {
    if (_isLocked(_lessonIndex) || !canStartPlay(context)) return;
    await Navigator.of(context).push(
      MaterialPageRoute<void>(
        fullscreenDialog: true,
        builder: (_) => _TraceScreen(
          lessons: _currentLessons,
          initialIndex: _lessonIndex,
          hasFullVersion: _hasFullVersion,
          stageId: widget.stageId,
          stageNumber: widget.stageNumber,
        ),
      ),
    );
    if (mounted) {
      FandoghiCoach.instruction(
        'خوب نوشتی! می‌توانی نشانه دیگری را انتخاب کنی یا دوباره تمرین کنی 🌟',
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
              _modeSwitchBar(),
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.fromLTRB(16, 4, 16, 24),
                  child: Column(
                    children: [
                      _academyHero(),
                      const SizedBox(height: 12),
                      if (_mode == _AlphabetMode.grade1) ...[
                        _bundleSelectorRow(),
                        const SizedBox(height: 12),
                        _wordMakingWorkshopCard(),
                        const SizedBox(height: 12),
                      ] else ...[
                        _searchBar(),
                        const SizedBox(height: 12),
                      ],
                      _lessonCard(),
                      const SizedBox(height: 14),
                      _allographsCard(),
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
            'آکادمی الفبا و اول دبستان 🔤',
            style: AppFonts.balooBhaijaan2(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.w900,
            ),
          ),
          const Spacer(),
          Text(
            '${_lessonIndex + 1}/${_currentLessons.length}',
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

  Widget _modeSwitchBar() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.12),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        children: [
          Expanded(
            child: GestureDetector(
              onTap: () => _switchMode(_AlphabetMode.grade1),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding: const EdgeInsets.symmetric(vertical: 8),
                decoration: BoxDecoration(
                  color: _mode == _AlphabetMode.grade1
                      ? AppColors.primary
                      : Colors.transparent,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Text(
                  'کتاب اول دبستان 📚',
                  textAlign: TextAlign.center,
                  style: AppFonts.balooBhaijaan2(
                    color: Colors.white,
                    fontWeight: FontWeight.w900,
                    fontSize: 14,
                  ),
                ),
              ),
            ),
          ),
          Expanded(
            child: GestureDetector(
              onTap: () => _switchMode(_AlphabetMode.alphabetical),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding: const EdgeInsets.symmetric(vertical: 8),
                decoration: BoxDecoration(
                  color: _mode == _AlphabetMode.alphabetical
                      ? AppColors.primary
                      : Colors.transparent,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Text(
                  'الفبایی سنتی 🔤',
                  textAlign: TextAlign.center,
                  style: AppFonts.balooBhaijaan2(
                    color: Colors.white,
                    fontWeight: FontWeight.w900,
                    fontSize: 14,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _academyHero() {
    return ClipRRect(
      borderRadius: BorderRadius.circular(24),
      child: SizedBox(
        height: 130,
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
                  colors: [
                    Colors.black.withOpacity(0.05),
                    Colors.black.withOpacity(0.60)
                  ],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                ),
              ),
            ),
            Positioned(
              right: 16,
              bottom: 12,
              left: 16,
              child: Text(
                _mode == _AlphabetMode.grade1
                    ? 'زنجیره نشانه‌های ۱ و ۲ • کتاب بخوانیم اول دبستان'
                    : 'جستجوی آزاد و تمرین ۳۳ نشانه الفبا',
                textAlign: TextAlign.center,
                style: AppFonts.balooBhaijaan2(
                  color: Colors.white,
                  fontSize: 18,
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

  Widget _bundleSelectorRow() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
          child: Row(
            children: [
              const Text('📦', style: TextStyle(fontSize: 16)),
              const SizedBox(width: 6),
              Text(
                'بسته‌های آموزشی کتاب فارسی اول دبستان:',
                style: AppFonts.balooBhaijaan2(
                  color: Colors.white,
                  fontSize: 14,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 6),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: List.generate(_grade1Bundles.length, (i) {
              final b = _grade1Bundles[i];
              final isSelected = i == _selectedBundleIndex;

              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: 4),
                child: GestureDetector(
                  onTap: () => _selectBundle(i),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    decoration: BoxDecoration(
                      color: isSelected ? b.color : Colors.white.withOpacity(0.12),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: isSelected ? Colors.white : Colors.white24,
                        width: isSelected ? 2 : 1,
                      ),
                      boxShadow: isSelected
                          ? [
                              BoxShadow(
                                color: b.color.withOpacity(0.4),
                                blurRadius: 10,
                                offset: const Offset(0, 4),
                              ),
                            ]
                          : null,
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          b.shortTitle,
                          style: AppFonts.balooBhaijaan2(
                            color: Colors.white,
                            fontSize: 13,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                        Text(
                          b.lettersPreview,
                          style: const TextStyle(
                            color: Colors.white70,
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            }),
          ),
        ),
      ],
    );
  }

  Widget _wordMakingWorkshopCard() {
    final b = _currentBundle;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: b.color.withOpacity(0.18),
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: b.color.withOpacity(0.4), width: 1.5),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Text('🏗️', style: TextStyle(fontSize: 20)),
              const SizedBox(width: 8),
              Text(
                'کارگاه واژه‌سازی ${b.shortTitle}:',
                style: AppFonts.balooBhaijaan2(
                  color: Colors.white,
                  fontSize: 15,
                  fontWeight: FontWeight.w900,
                ),
              ),
              const Spacer(),
              Text(
                'لمس کن تا بشنوی',
                style: AppFonts.balooBhaijaan2(
                  color: Colors.white60,
                  fontSize: 11,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            'با یادگیری نشانه‌های این بسته (${b.lettersPreview})، می‌توانی این کلمه‌ها را بسازی و بخوانی:',
            style: const TextStyle(
              color: Colors.white70,
              fontSize: 12,
              height: 1.5,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 10),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: b.createdWords.map((word) {
              return GestureDetector(
                onTap: () {
                  HapticFeedback.lightImpact();
                  final clean = word.replaceAll(RegExp(r'[\p{Extended_Pictographic}]', unicode: true), '').trim();
                  AudioService.speak(clean);
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(14),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.12),
                        blurRadius: 6,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        word,
                        style: AppFonts.vazirmatn(
                          fontSize: 14,
                          fontWeight: FontWeight.w900,
                          color: const Color(0xFF2C3E50),
                        ),
                      ),
                      const SizedBox(width: 4),
                      const Icon(Icons.volume_up_rounded, size: 14, color: Color(0xFF3498DB)),
                    ],
                  ),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    ).animate().fadeIn(duration: 300.ms);
  }

  Widget _searchBar() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.12),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: Colors.white24),
      ),
      child: TextField(
        controller: _searchController,
        style: const TextStyle(color: Colors.white),
        onChanged: (val) {
          setState(() {
            _searchQuery = val;
            _lessonIndex = 0;
          });
        },
        decoration: InputDecoration(
          hintText: 'جستجوی نشانه یا کلمه (مثال: ب، سیب)...',
          hintStyle: const TextStyle(color: Colors.white54, fontSize: 13),
          prefixIcon: const Icon(Icons.search_rounded, color: Colors.white70),
          suffixIcon: _searchQuery.isNotEmpty
              ? IconButton(
                  icon: const Icon(Icons.clear_rounded, color: Colors.white70),
                  onPressed: () {
                    setState(() {
                      _searchController.clear();
                      _searchQuery = '';
                      _lessonIndex = 0;
                    });
                  },
                )
              : null,
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        ),
      ),
    );
  }

  Widget _lessonCard() {
    final locked = _isLocked(_lessonIndex);
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
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
                width: 96,
                height: 96,
                decoration: BoxDecoration(
                  gradient: AppGradients.candy,
                  borderRadius: BorderRadius.circular(22),
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
                      fontSize: 48,
                      fontWeight: FontWeight.w900,
                      height: 1,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'نشانه «${_lesson.letter}»',
                      style: AppFonts.balooBhaijaan2(
                        color: Colors.white,
                        fontSize: 22,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${_lesson.emoji} مثلِ «${_lesson.word}»',
                      style: AppFonts.balooBhaijaan2(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        IconButton.filledTonal(
                          tooltip: 'تلفظ نشانه',
                          onPressed: () {
                            HapticFeedback.lightImpact();
                            AudioService.pronounceLetter(_lesson.letter);
                          },
                          icon: const Icon(Icons.volume_up_rounded, size: 18),
                        ),
                        const SizedBox(width: 6),
                        Text(
                          'تلفظ صوتی',
                          style: AppFonts.balooBhaijaan2(
                            color: Colors.white70,
                            fontSize: 13,
                          ),
                        ),
                      ],
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
              onPressed: locked
                  ? () => showFullVersionPaywall(context, featureName: 'حرف «${_lesson.letter}»')
                  : _openTraceScreen,
              icon: Icon(locked ? Icons.lock_rounded : Icons.draw_rounded, size: 20),
              label: Text(locked ? 'بازگشایی نسخه کامل 🔒' : 'تمرین نوشتن روی خط کرسی ✍️'),
              style: FilledButton.styleFrom(
                backgroundColor: Colors.white,
                foregroundColor: AppColors.primaryDark,
                padding: const EdgeInsets.symmetric(vertical: 14),
                textStyle: AppFonts.balooBhaijaan2(
                  fontWeight: FontWeight.w900,
                  fontSize: 17,
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

  Widget _allographsCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.08),
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: Colors.white.withOpacity(0.12)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Text('📝', style: TextStyle(fontSize: 18)),
              const SizedBox(width: 8),
              Text(
                'شکل‌های مختلف نشانه در کلمه (اشکال چهارگانه):',
                style: AppFonts.balooBhaijaan2(
                  color: Colors.white,
                  fontSize: 14,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            children: List.generate(_lesson.allographs.length, (idx) {
              final shape = _lesson.allographs[idx];
              final label = _lesson.allographNames[idx];
              final sample = _lesson.allographWords[idx];

              return Expanded(
                child: GestureDetector(
                  onTap: () {
                    HapticFeedback.lightImpact();
                    AudioService.speak('$shape $label مثل $sample');
                  },
                  child: Container(
                    margin: const EdgeInsets.symmetric(horizontal: 3),
                    padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.15),
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: Colors.white30),
                    ),
                    child: Column(
                      children: [
                        Text(
                          shape,
                          style: AppFonts.vazirmatn(
                            color: Colors.amberAccent,
                            fontSize: 22,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                        Text(
                          label,
                          style: const TextStyle(
                            color: Colors.white70,
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          sample,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 11,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            }),
          ),
        ],
      ),
    );
  }

  Widget _letterPicker() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.08),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.white.withOpacity(0.12)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            _mode == _AlphabetMode.grade1
                ? 'نشانه‌های این بسته (${_currentBundle.shortTitle})'
                : 'فهرست نشانه‌های الفبا',
            style: AppFonts.balooBhaijaan2(
              color: Colors.white70,
              fontSize: 15,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 12),
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: _currentLessons.length,
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 6,
              mainAxisSpacing: 8,
              crossAxisSpacing: 8,
              childAspectRatio: 0.95,
            ),
            itemBuilder: (context, index) {
              final item = _currentLessons[index];
              final locked = _isLocked(index);
              final isSelected = index == _lessonIndex && !locked;

              return ChildTouchTarget(
                onTap: () => _selectLesson(index),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 180),
                  decoration: BoxDecoration(
                    color: isSelected
                        ? Colors.white
                        : locked
                            ? Colors.black.withOpacity(0.25)
                            : Colors.white.withOpacity(0.14),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: isSelected
                          ? AppColors.candy1
                          : locked
                              ? Colors.white24
                              : Colors.white.withOpacity(0.2),
                      width: isSelected ? 2.5 : 1,
                    ),
                    boxShadow: isSelected
                        ? [
                            BoxShadow(
                              color: AppColors.candy1.withOpacity(0.4),
                              blurRadius: 10,
                              offset: const Offset(0, 4),
                            ),
                          ]
                        : null,
                  ),
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      Text(
                        item.letter,
                        style: AppFonts.vazirmatn(
                          color: isSelected
                              ? AppColors.primaryDark
                              : locked
                                  ? Colors.white54
                                  : Colors.white,
                          fontSize: 19,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                      if (locked)
                        const Positioned(
                          top: 4,
                          right: 4,
                          child: Icon(
                            Icons.lock_rounded,
                            color: Colors.amberAccent,
                            size: 12,
                          ),
                        ),
                    ],
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────── صفحه تمرین ردیابی و نوشتن ───────────────────────────

class _TraceScreen extends StatefulWidget {
  final List<_LetterLesson> lessons;
  final int initialIndex;
  final bool hasFullVersion;
  final String? stageId;
  final int? stageNumber;

  const _TraceScreen({
    required this.lessons,
    required this.initialIndex,
    this.hasFullVersion = false,
    this.stageId,
    this.stageNumber,
  });

  @override
  State<_TraceScreen> createState() => _TraceScreenState();
}

class _TraceScreenState extends State<_TraceScreen>
    with SingleTickerProviderStateMixin {
  final GlobalKey _canvasKey = GlobalKey();
  final List<List<Offset>> _strokes = <List<Offset>>[];
  late int _lessonIndex;
  _TraceResult? _lastResult;
  bool _checking = false;
  bool _showMagicDemo = false;
  late AnimationController _demoController;

  _LetterLesson get _lesson => widget.lessons[_lessonIndex];

  @override
  void initState() {
    super.initState();
    _lessonIndex = widget.initialIndex;
    _demoController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2200),
    )..addStatusListener((status) {
        if (status == AnimationStatus.completed) {
          setState(() => _showMagicDemo = false);
        }
      });

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      _speakVoiceGuidance();
    });
  }

  @override
  void dispose() {
    _demoController.dispose();
    super.dispose();
  }

  void _speakVoiceGuidance() {
    final text =
        'نشانه «${_lesson.letter}» را ببین! از نقطه سبز شروع کن و با انگشتت روی خط کرسی بکش ✍️';
    FandoghiCoach.instruction(text);
    unawaited(AudioService.speak('از نقطه سبز شروع کن و نشانه ${_lesson.letter} را بنویس'));
  }

  void _playMagicPenDemo() {
    HapticFeedback.mediumImpact();
    setState(() => _showMagicDemo = true);
    _demoController.forward(from: 0);
    AudioService.swoosh();
    unawaited(AudioService.speak('حرکت قلم جادویی را ببین و یاد بگیر!'));
  }

  void _selectLesson(int index) {
    if (!widget.hasFullVersion &&
        !ContentAccessPolicy.isAlphabetLessonFree(index)) {
      showFullVersionPaywall(
        context,
        featureName: 'نشانه «${widget.lessons[index].letter}»',
      );
      return;
    }
    setState(() {
      _lessonIndex = index;
      _strokes.clear();
      _lastResult = null;
    });
    _speakVoiceGuidance();
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
      'صفحه تمیز شد! دوباره با آرامش از نقطه سبز شروع کن 🌰',
    );
  }

  void _undoTrace() {
    if (_strokes.isEmpty) return;
    setState(() {
      _strokes.removeLast();
      _lastResult = null;
    });
  }

  /// ═══════════════════════════════════════════════════════════
  /// 👩‍🏫 ارزیابی واقعی و سخت‌گیرانه معلم کلاس اول (Teacher Evaluation)
  /// ═══════════════════════════════════════════════════════════
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
        // تأیید رسمی معلم + مهر صدآفرین
        GameData.progressMission('alphabet');
        GameData.addCoins(8);
        GameData.addStars(1);
        AudioService.star();
        AudioService.correct();
        AudioService.win();
        if (widget.stageId != null) {
          GameData.completeStage(
            widget.stageId!,
            stageNumber: widget.stageNumber,
          );
        }
        FandoghiCoach.correct(
          'آفرین صدآفرین! خط نشانه «${_lesson.letter}» تایید شد و مهر قبولی گرفتی 🌟',
        );
        unawaited(AudioService.speak('آفرین صدآفرین! خیلی تمیز نوشتی. مهر قبولی رو گرفتی'));
      } else {
        // عدم تایید معلم — باید دوباره تمرین کند
        AudioService.wrong();
        FandoghiCoach.instruction(
          'هنوز کامل نشد! باید از نقطه سبز شروع کنی و دقیقاً روی خطوط کم‌رنگ بکشی ✍️',
        );
        unawaited(AudioService.speak('هنوز کامل نشد! دوباره از نقطه سبز شروع کن'));
      }
    } catch (_) {
      if (mounted) setState(() => _checking = false);
    }
  }

  Future<_TraceResult> _evaluateTrace(Size size) async {
    if (_strokes.isEmpty) {
      return const _TraceResult(score: 0.0, passed: false);
    }
    final points = <Offset>[];
    for (final stroke in _strokes) {
      for (final p in stroke) {
        points.add(p);
      }
    }
    // حداقل ۱۲ نقطه کشیده شده برای جلوگیری از تپ‌های تصادفی
    if (points.length < 12) {
      return const _TraceResult(score: 0.2, passed: false);
    }

    final coverage = await _computeGuideCoverage(size, points);
    // شرط قبولی سخت‌گیرانه معلم: پوشش حداقل ۵۲٪ خطوط نشانه
    final passed = coverage >= 0.52;
    return _TraceResult(score: coverage, passed: passed);
  }

  Future<double> _computeGuideCoverage(Size size, List<Offset> points) async {
    final recorder = ui.PictureRecorder();
    final canvas = Canvas(recorder);
    final painter = _guideTextPainter(
      _lesson.letter,
      size,
      const Color(0xFF000000),
    );
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
                  child: AnimatedBuilder(
                    animation: _demoController,
                    builder: (context, _) {
                      return CustomPaint(
                        painter: _TracePainter(
                          letter: _lesson.letter,
                          strokes: _strokes,
                          demoProgress: _showMagicDemo ? _demoController.value : 0.0,
                        ),
                        child: const SizedBox.expand(),
                      );
                    },
                  ),
                ),
              ),
            ),
            Positioned(
              top: 0,
              left: 0,
              right: 0,
              child: _traceTopBar(),
            ),
            Positioned(
              left: 0,
              right: 0,
              bottom: 0,
              child: _traceBottomBar(),
            ),
            // اورلی ارزیابی دقیق معلم با قفل حرف بعدی
            if (_lastResult != null)
              Positioned.fill(
                child: Container(
                  color: Colors.black.withOpacity(0.4),
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
                      onShowGuide: () {
                        setState(() {
                          _strokes.clear();
                          _lastResult = null;
                        });
                        _playMagicPenDemo();
                      },
                      onNext: _lastResult!.passed
                          ? () {
                              final next = (_lessonIndex + 1) % widget.lessons.length;
                              setState(() {
                                _lessonIndex = next;
                                _strokes.clear();
                                _lastResult = null;
                              });
                              _speakVoiceGuidance();
                            }
                          : null,
                    ),
                  ),
                ),
              ),
            Positioned(
              top: 65,
              left: 12,
              child: _letterPreview(),
            ),
            if (_lastResult != null && _lastResult!.passed)
              const Positioned.fill(
                child: IgnorePointer(
                  child: ParticleCelebration(trigger: true, particleCount: 45),
                ),
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
        color: Colors.white.withOpacity(0.95),
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
          // دکمه قلم جادویی
          IconButton(
            tooltip: 'نشانم بده (قلم جادویی)',
            onPressed: _playMagicPenDemo,
            icon: const Icon(Icons.auto_awesome_rounded, color: Colors.orange, size: 24),
          ),
        ],
      ),
    );
  }

  Widget _letterPreview() {
    return Container(
      width: 76,
      height: 76,
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
          fontSize: 40,
          fontWeight: FontWeight.w900,
          height: 1,
        ),
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
            label: Text(_checking ? 'در حال بررسی معلم…' : 'تأیید معلم ✍️'),
            style: FilledButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
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

// ─────────────────────────── مدل‌های داده الفبایی ───────────────────────────

class _Grade1Bundle {
  final String shortTitle;
  final String title;
  final String lettersPreview;
  final Color color;
  final List<_LetterLesson> lessons;
  final List<String> createdWords;

  const _Grade1Bundle({
    required this.shortTitle,
    required this.title,
    required this.lettersPreview,
    required this.color,
    required this.lessons,
    required this.createdWords,
  });
}

class _LetterLesson {
  final String letter;
  final String word;
  final String emoji;
  final List<String> allographs;
  final List<String> allographNames;
  final List<String> allographWords;

  const _LetterLesson(
    this.letter,
    this.word,
    this.emoji, {
    this.allographs = const ['اول', 'وسط', 'آخر'],
    this.allographNames = const ['اول', 'وسط', 'آخر'],
    this.allographWords = const ['', '', ''],
  });
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
    (size.height - painter.height) * 0.42,
  );
}

class _TracePainter extends CustomPainter {
  final String letter;
  final List<List<Offset>> strokes;
  final double demoProgress;

  const _TracePainter({
    required this.letter,
    required this.strokes,
    this.demoProgress = 0.0,
  });

  @override
  void paint(Canvas canvas, Size size) {
    // رسم خط زمینه اصلی (خط کرسی آبی اول دبستان)
    final baselineY = size.height * 0.74;
    final baselinePaint = Paint()
      ..color = Colors.blue.withOpacity(0.40)
      ..strokeWidth = 2.5
      ..style = PaintingStyle.stroke;

    canvas.drawLine(
      Offset(size.width * 0.08, baselineY),
      Offset(size.width * 0.92, baselineY),
      baselinePaint,
    );

    // نوشتن برچسب «خط کرسی»
    final labelPainter = TextPainter(
      text: TextSpan(
        text: 'خط کرسی (خط زمینه)',
        style: TextStyle(
          color: Colors.blue.shade700,
          fontSize: 11,
          fontWeight: FontWeight.bold,
        ),
      ),
      textDirection: TextDirection.rtl,
    )..layout();
    labelPainter.paint(canvas, Offset(size.width * 0.1, baselineY + 4));

    // خط کمکی بالایی (نقطه‌چین)
    final topGuidePaint = Paint()
      ..color = Colors.red.withOpacity(0.25)
      ..strokeWidth = 1.5
      ..style = PaintingStyle.stroke;
    for (var x = size.width * 0.15; x < size.width * 0.85; x += 12) {
      canvas.drawCircle(Offset(x, size.height * 0.28), 1.0, topGuidePaint);
    }

    // راهنمای کم‌رنگ نشانه
    final guidePainter = _guideTextPainter(
      letter,
      size,
      AppColors.primary.withOpacity(0.16),
    );
    final offset = _guideTextOffset(size, guidePainter);
    guidePainter.paint(canvas, offset);

    // نقطه شروع سبز تپنده (Start Dot)
    final startDotPos = Offset(offset.dx + guidePainter.width * 0.76, offset.dy + 22);

    // امواج نورانی رادار نقطه سبز
    final wavePaint = Paint()
      ..color = const Color(0xFF2ECC71).withOpacity(0.30)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;
    canvas.drawCircle(startDotPos, 12, wavePaint);

    final startDotPaint = Paint()
      ..color = const Color(0xFF2ECC71)
      ..style = PaintingStyle.fill;
    canvas.drawCircle(startDotPos, 6.5, startDotPaint);

    // رسم انیمیشن قلم جادویی (Demo Pen)
    if (demoProgress > 0.0) {
      final demoPos = Offset.lerp(
        startDotPos,
        Offset(offset.dx + guidePainter.width * 0.25, baselineY - 10),
        demoProgress,
      )!;

      final penPaint = Paint()
        ..color = Colors.amber
        ..style = PaintingStyle.fill;
      canvas.drawCircle(demoPos, 10, penPaint);

      final sparkPaint = Paint()
        ..color = Colors.orange
        ..style = PaintingStyle.stroke
        ..strokeWidth = 3;
      canvas.drawCircle(demoPos, 16, sparkPaint);
    }

    // خطوطی که کودک کشیده
    final strokePaint = Paint()
      ..color = AppColors.primaryDark
      ..style = PaintingStyle.stroke
      ..strokeWidth = 8
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;
    for (final stroke in strokes) {
      if (stroke.isEmpty) continue;
      if (stroke.length == 1) {
        canvas.drawCircle(stroke.first, 4.0, strokePaint..style = PaintingStyle.fill);
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

// ─────────────────────────── بسته‌های کتاب فارسی اول دبستان ───────────────────────────

const List<_Grade1Bundle> _grade1Bundles = [
  // بسته ۱
  _Grade1Bundle(
    shortTitle: 'بسته ۱ (درس ۱ و ۲)',
    title: 'بسته ۱: نشانه‌های پایه',
    lettersPreview: 'آ ا • بـ ب • اَ َ • د',
    color: Color(0xFFE74C3C),
    lessons: [
      _LetterLesson('آ ا', 'آب', '💧', allographs: ['آ', 'ا'], allographNames: ['اول', 'غیر اول'], allographWords: ['آب', 'بابا']),
      _LetterLesson('ب', 'بابا', '👨', allographs: ['بـ', 'ـبـ', 'ـب', 'ب'], allographNames: ['اول', 'وسط', 'آخر چسبان', 'تنها'], allographWords: ['باران', 'ابر', 'سیب', 'آب']),
      _LetterLesson('اَ َ', 'انار', '🍎', allographs: ['اَ', 'ـَ'], allographNames: ['اول', 'غیر اول'], allographWords: ['انار', 'دست']),
      _LetterLesson('د', 'دست', '✋', allographs: ['د', 'ـد'], allographNames: ['تنها', 'چسبان'], allographWords: ['داس', 'باد']),
    ],
    createdWords: ['آب 💧', 'بابا 👨', 'باد 💨', 'داد', 'آباد'],
  ),
  // بسته ۲
  _Grade1Bundle(
    shortTitle: 'بسته ۲ (درس ۳ و ۴)',
    title: 'بسته ۲: واژه‌های مهر و خانه',
    lettersPreview: 'مـ م • سـ س • او و • تـ ت',
    color: Color(0xFFE67E22),
    lessons: [
      _LetterLesson('م', 'مادر', '👩', allographs: ['مـ', 'ـمـ', 'ـم', 'م'], allographNames: ['اول', 'وسط', 'آخر چسبان', 'تنها'], allographWords: ['مادر', 'نمد', 'پرچم', 'بادام']),
      _LetterLesson('س', 'سیب', '🍏', allographs: ['سـ', 'ـسـ', 'ـس', 'س'], allographNames: ['اول', 'وسط', 'آخر چسبان', 'تنها'], allographWords: ['سیب', 'پسته', 'نرگس', 'داس']),
      _LetterLesson('او و', 'توت', '🍓', allographs: ['او', 'و'], allographNames: ['اول', 'غیر اول'], allographWords: ['او', 'توت']),
      _LetterLesson('ت', 'تاب', '🪑', allographs: ['تـ', 'ـتـ', 'ـت', 'ت'], allographNames: ['اول', 'وسط', 'آخر چسبان', 'تنها'], allographWords: ['تاب', 'دفتر', 'دست', 'سوت']),
    ],
    createdWords: ['مادر 👩', 'توت 🍓', 'دوست 🤝', 'دست ✋', 'سوت 📢'],
  ),
  // بسته ۳
  _Grade1Bundle(
    shortTitle: 'بسته ۳ (درس ۵ و ۶)',
    title: 'بسته ۳: ایران و طبیعت',
    lettersPreview: 'ر • نـ ن • ایـ یـ ی ای • ز',
    color: Color(0xFF27AE60),
    lessons: [
      _LetterLesson('ر', 'رنگ', '🎨', allographs: ['ر', 'ـر'], allographNames: ['تنها', 'چسبان'], allographWords: ['رنگ', 'ابر']),
      _LetterLesson('ن', 'نان', '🍞', allographs: ['نـ', 'ـنـ', 'ـن', 'ن'], allographNames: ['اول', 'وسط', 'آخر چسبان', 'تنها'], allographWords: ['نان', 'قند', 'دامن', 'باران']),
      _LetterLesson('ایـ ی', 'ایران', '🇮🇷', allographs: ['ایـ', 'ـیـ', 'ـی', 'ای'], allographNames: ['اول', 'وسط', 'آخر چسبان', 'تنها'], allographWords: ['ایران', 'سیب', 'آبی', 'سینی']),
      _LetterLesson('ز', 'زرد', '💛', allographs: ['ز', 'ـز'], allographNames: ['تنها', 'چسبان'], allographWords: ['زرد', 'سبز']),
    ],
    createdWords: ['باران 🌧️', 'ایران 🇮🇷', 'سبز 🟢', 'نان 🍞', 'زرد 💛'],
  ),
  // بسته ۴
  _Grade1Bundle(
    shortTitle: 'بسته ۴ (درس ۷ و ۸)',
    title: 'بسته ۴: آسمان و زیبایی',
    lettersPreview: 'اِ ِ ـه ه • شـ ش • یـ ی • اُ ُ',
    color: Color(0xFF2980B9),
    lessons: [
      _LetterLesson('اِ ِ ـه ه', 'استخر', '🏊', allographs: ['اِ', 'ـِ', 'ـه', 'ه'], allographNames: ['اول', 'وسط', 'آخر چسبان', 'تنها'], allographWords: ['امروز', 'نرده', 'نامه', 'کوه']),
      _LetterLesson('ش', 'شیر', '🦁', allographs: ['شـ', 'ـشـ', 'ـش', 'ش'], allographNames: ['اول', 'وسط', 'آخر چسبان', 'تنها'], allographWords: ['شیر', 'گوشت', 'آتش', 'کفش']),
      _LetterLesson('ی', 'یاس', '🌸', allographs: ['یـ', 'ـیـ', 'ـی', 'ی'], allographNames: ['اول', 'وسط', 'آخر چسبان', 'تنها'], allographWords: ['یاس', 'سایه', 'چای', 'موی']),
      _LetterLesson('اُ ُ', 'اردک', '🦆', allographs: ['اُ', 'ـُ'], allographNames: ['اول', 'غیر اول'], allographWords: ['اردک', 'بلبل']),
    ],
    createdWords: ['شیر 🦁', 'یاس 🌸', 'اردک 🦆', 'ستاره ⭐', 'دریا 🌊'],
  ),
  // بسته ۵
  _Grade1Bundle(
    shortTitle: 'بسته ۵ (درس ۹ و ۱۰)',
    title: 'بسته ۵: بازی و پویا بودن',
    lettersPreview: 'کـ ک • و • پـ پ • گـ گ',
    color: Color(0xFF8E44AD),
    lessons: [
      _LetterLesson('ک', 'کفش', '👟', allographs: ['کـ', 'ـکـ', 'ـک', 'ک'], allographNames: ['اول', 'وسط', 'آخر چسبان', 'تنها'], allographWords: ['کفش', 'شکلات', 'نمک', 'پاک']),
      _LetterLesson('و', 'ورزش', '⚽', allographs: ['و', 'ـو'], allographNames: ['تنها', 'چسبان'], allographWords: ['ورزش', 'گاو']),
      _LetterLesson('پ', 'پا', '🦶', allographs: ['پـ', 'ـپـ', 'ـپ', 'پ'], allographNames: ['اول', 'وسط', 'آخر چسبان', 'تنها'], allographWords: ['پا', 'سوپ', 'توپ', 'چپ']),
      _LetterLesson('گ', 'گل', '🌷', allographs: ['گـ', 'ـگـ', 'ـگ', 'گ'], allographNames: ['اول', 'وسط', 'آخر چسبان', 'تنها'], allographWords: ['گل', 'نرگس', 'سگ', 'برگ']),
    ],
    createdWords: ['کفش 👟', 'ورزش ⚽', 'پا 🦶', 'گل 🌷', 'کودک 👶'],
  ),
  // بسته ۶
  _Grade1Bundle(
    shortTitle: 'بسته ۶ (درس ۱۱ و ۱۲)',
    title: 'بسته ۶: جنگل و حیوانات',
    lettersPreview: 'فـ ف • خـ خ • قـ ق • لـ ل',
    color: Color(0xFF16A085),
    lessons: [
      _LetterLesson('ف', 'فیل', '🐘', allographs: ['فـ', 'ـفـ', 'ـف', 'ف'], allographNames: ['اول', 'وسط', 'آخر چسبان', 'تنها'], allographWords: ['فیل', 'دفتر', 'برف', 'سفید']),
      _LetterLesson('خ', 'خرس', '🐻', allographs: ['خـ', 'ـخـ', 'ـخ', 'خ'], allographNames: ['اول', 'وسط', 'آخر چسبان', 'تنها'], allographWords: ['خرس', 'درخت', 'میخ', 'کاخ']),
      _LetterLesson('ق', 'قاشق', '🥄', allographs: ['قـ', 'ـقـ', 'ـق', 'ق'], allographNames: ['اول', 'وسط', 'آخر چسبان', 'تنها'], allographWords: ['قاشق', 'سقف', 'بوق', 'اتاق']),
      _LetterLesson('ل', 'لب', '👄', allographs: ['لـ', 'ـلـ', 'ـل', 'ل'], allographNames: ['اول', 'وسط', 'آخر چسبان', 'تنها'], allographWords: ['لب', 'بلبل', 'فیل', 'گل']),
    ],
    createdWords: ['فیل 🐘', 'خرس 🐻', 'قاشق 🥄', 'بلبل 🐦', 'برف ❄️'],
  ),
  // بسته ۷
  _Grade1Bundle(
    shortTitle: 'بسته ۷ (درس ۱۳ و ۱۴)',
    title: 'بسته ۷: پایان نشانه‌های ۱',
    lettersPreview: 'جـ ج • خوا • چـ چ • هـ • ژ',
    color: Color(0xFFD35400),
    lessons: [
      _LetterLesson('ج', 'جوجه', '🐥', allographs: ['جـ', 'ـجـ', 'ـج', 'ج'], allographNames: ['اول', 'وسط', 'آخر چسبان', 'تنها'], allographWords: ['جوجه', 'مسجد', 'پنج', 'کاج']),
      _LetterLesson('خوا', 'خورشید', '☀️', allographs: ['خوا', 'ـخوا'], allographNames: ['اول', 'غیر اول'], allographWords: ['خواب', 'خواهر']),
      _LetterLesson('چ', 'چتر', '☂️', allographs: ['چـ', 'ـچـ', 'ـچ', 'چ'], allographNames: ['اول', 'وسط', 'آخر چسبان', 'تنها'], allographWords: ['چتر', 'قیچی', 'هیچ', 'کوچ']),
      _LetterLesson('هـ', 'هواپیما', '✈️', allographs: ['هـ', 'ـهـ', 'ـه', 'ه'], allographNames: ['اول', 'وسط', 'آخر چسبان', 'تنها'], allographWords: ['هوا', 'بهار', 'نامه', 'ماه']),
      _LetterLesson('ژ', 'ژاله', '🍮', allographs: ['ژ', 'ـژ'], allographNames: ['تنها', 'چسبان'], allographWords: ['ژاله', 'مژده']),
    ],
    createdWords: ['جوجه 🐥', 'خورشید ☀️', 'چتر ☂️', 'هواپیما ✈️', 'ژاله 🍮'],
  ),
  // بسته ۸ (نشانه‌های ۲)
  _Grade1Bundle(
    shortTitle: 'بسته ۸ (نشانه‌های ۲)',
    title: 'بسته ۸: نشانه‌های تکمیلی ۲',
    lettersPreview: 'ص • ذ • ع • ث • ح • ض • ط • غ • ظ',
    color: Color(0xFF2C3E50),
    lessons: [
      _LetterLesson('ص', 'صابون', '🧼', allographs: ['صـ', 'ـصـ', 'ـص', 'ص'], allographNames: ['اول', 'وسط', 'آخر چسبان', 'تنها'], allographWords: ['صابون', 'تصویر', 'شخص', 'قرص']),
      _LetterLesson('ذ', 'ذرت', '🌽', allographs: ['ذ', 'ـذ'], allographNames: ['تنها', 'چسبان'], allographWords: ['ذرت', 'کاغذ']),
      _LetterLesson('ع', 'عسل', '🍯', allographs: ['عـ', 'ـعـ', 'ـع', 'ع'], allographNames: ['اول', 'وسط', 'آخر چسبان', 'تنها'], allographWords: ['عسل', 'جعبه', 'مربع', 'شروع']),
      _LetterLesson('ث', 'ثانیه', '⏱️', allographs: ['ثـ', 'ـثـ', 'ـث', 'ث'], allographNames: ['اول', 'وسط', 'آخر چسبان', 'تنها'], allographWords: ['ثانیه', 'مثلث', 'کثیف', 'ارث']),
      _LetterLesson('ح', 'حباب', '🫧', allographs: ['حـ', 'ـحـ', 'ـح', 'ح'], allographNames: ['اول', 'وسط', 'آخر چسبان', 'تنها'], allographWords: ['حباب', 'صحرا', 'صبح', 'نوح']),
      _LetterLesson('ض', 'ضبط', '🎙️', allographs: ['ضـ', 'ـضـ', 'ـض', 'ض'], allographNames: ['اول', 'وسط', 'آخر چسبان', 'تنها'], allographWords: ['ضربه', 'حاضر', 'مریض', 'حوض']),
      _LetterLesson('ط', 'طبل', '🥁', allographs: ['ط', 'ـط'], allographNames: ['تنها', 'چسبان'], allographWords: ['طبل', 'طوطی']),
      _LetterLesson('غ', 'غاز', '🪿', allographs: ['غـ', 'ـغـ', 'ـغ', 'غ'], allographNames: ['اول', 'وسط', 'آخر چسبان', 'تنها'], allographWords: ['غاز', 'چراغ', 'جیغ', 'مرغ']),
      _LetterLesson('ظ', 'ظرف', '🥣', allographs: ['ظ', 'ـظ'], allographNames: ['تنها', 'چسبان'], allographWords: ['ظرف', 'ناظم']),
    ],
    createdWords: ['صابون 🧼', 'عسل 🍯', 'حباب 🫧', 'طبل 🥁', 'غاز 🪿', 'ظرف 🥣'],
  ),
];

/// چیدمان سنتی الفبایی
const _alphabeticalLessons = <_LetterLesson>[
  _LetterLesson('آ', 'آب', '💧', allographs: ['آ', 'ا'], allographNames: ['اول', 'غیر اول'], allographWords: ['آب', 'بابا']),
  _LetterLesson('ا', 'ابر', '☁️', allographs: ['اَ', 'ـَ'], allographNames: ['اول', 'غیر اول'], allographWords: ['ابر', 'سبز']),
  _LetterLesson('ب', 'بابا', '👨', allographs: ['بـ', 'ـبـ', 'ـب', 'ب'], allographNames: ['اول', 'وسط', 'آخر چسبان', 'تنها'], allographWords: ['باران', 'ابر', 'سیب', 'آب']),
  _LetterLesson('پ', 'پا', '🦶', allographs: ['پـ', 'ـپـ', 'ـپ', 'پ'], allographNames: ['اول', 'وسط', 'آخر چسبان', 'تنها'], allographWords: ['پا', 'سوپ', 'توپ', 'چپ']),
  _LetterLesson('ت', 'توت', '🍓', allographs: ['تـ', 'ـتـ', 'ـت', 'ت'], allographNames: ['اول', 'وسط', 'آخر چسبان', 'تنها'], allographWords: ['توت', 'دفتر', 'دست', 'سوت']),
  _LetterLesson('ث', 'ثانیه', '⏱️', allographs: ['ثـ', 'ـثـ', 'ـث', 'ث'], allographNames: ['اول', 'وسط', 'آخر چسبان', 'تنها'], allographWords: ['ثانیه', 'مثلث', 'کثیف', 'ارث']),
  _LetterLesson('ج', 'جوجه', '🐥', allographs: ['جـ', 'ـجـ', 'ـج', 'ج'], allographNames: ['اول', 'وسط', 'آخر چسبان', 'تنها'], allographWords: ['جوجه', 'مسجد', 'پنج', 'کاج']),
  _LetterLesson('چ', 'چتر', '☂️', allographs: ['چـ', 'ـچـ', 'ـچ', 'چ'], allographNames: ['اول', 'وسط', 'آخر چسبان', 'تنها'], allographWords: ['چتر', 'قیچی', 'هیچ', 'کوچ']),
  _LetterLesson('ح', 'حباب', '🫧', allographs: ['حـ', 'ـحـ', 'ـح', 'ح'], allographNames: ['اول', 'وسط', 'آخر چسبان', 'تنها'], allographWords: ['حباب', 'صحرا', 'صبح', 'نوح']),
  _LetterLesson('خ', 'خرس', '🐻', allographs: ['خـ', 'ـخـ', 'ـخ', 'خ'], allographNames: ['اول', 'وسط', 'آخر چسبان', 'تنها'], allographWords: ['خرس', 'درخت', 'میخ', 'کاخ']),
  _LetterLesson('د', 'دست', '✋', allographs: ['د', 'ـد'], allographNames: ['تنها', 'چسبان'], allographWords: ['داس', 'باد']),
  _LetterLesson('ذ', 'ذرت', '🌽', allographs: ['ذ', 'ـذ'], allographNames: ['تنها', 'چسبان'], allographWords: ['ذرت', 'کاغذ']),
  _LetterLesson('ر', 'رنگ', '🎨', allographs: ['ر', 'ـر'], allographNames: ['تنها', 'چسبان'], allographWords: ['رنگ', 'ابر']),
  _LetterLesson('ز', 'زرد', '💛', allographs: ['ز', 'ـز'], allographNames: ['تنها', 'چسبان'], allographWords: ['زرد', 'سبز']),
  _LetterLesson('ژ', 'ژله', '🍮', allographs: ['ژ', 'ـژ'], allographNames: ['تنها', 'چسبان'], allographWords: ['ژاله', 'مژده']),
  _LetterLesson('س', 'سیب', '🍎', allographs: ['سـ', 'ـسـ', 'ـس', 'س'], allographNames: ['اول', 'وسط', 'آخر چسبان', 'تنها'], allographWords: ['سیب', 'پسته', 'نرگس', 'داس']),
  _LetterLesson('ش', 'شیر', '🦁', allographs: ['شـ', 'ـشـ', 'ـش', 'ش'], allographNames: ['اول', 'وسط', 'آخر چسبان', 'تنها'], allographWords: ['شیر', 'گوشت', 'آتش', 'کفش']),
  _LetterLesson('ص', 'صابون', '🧼', allographs: ['صـ', 'ـصـ', 'ـص', 'ص'], allographNames: ['اول', 'وسط', 'آخر چسبان', 'تنها'], allographWords: ['صابون', 'تصویر', 'شخص', 'قرص']),
  _LetterLesson('ض', 'ضبط', '🎙️', allographs: ['ضـ', 'ـضـ', 'ـض', 'ض'], allographNames: ['اول', 'وسط', 'آخر چسبان', 'تنها'], allographWords: ['ضربه', 'حاضر', 'مریض', 'حوض']),
  _LetterLesson('ط', 'طبل', '🥁', allographs: ['ط', 'ـط'], allographNames: ['تنها', 'چسبان'], allographWords: ['طبل', 'طوطی']),
  _LetterLesson('ظ', 'ظرف', '🥣', allographs: ['ظ', 'ـظ'], allographNames: ['تنها', 'چسبان'], allographWords: ['ظرف', 'ناظم']),
  _LetterLesson('ع', 'عسل', '🍯', allographs: ['عـ', 'ـعـ', 'ـع', 'ع'], allographNames: ['اول', 'وسط', 'آخر چسبان', 'تنها'], allographWords: ['عسل', 'جعبه', 'مربع', 'شروع']),
  _LetterLesson('غ', 'غاز', '🪿', allographs: ['غـ', 'ـغـ', 'ـغ', 'غ'], allographNames: ['اول', 'وسط', 'آخر چسبان', 'تنها'], allographWords: ['غاز', 'چراغ', 'جیغ', 'مرغ']),
  _LetterLesson('ف', 'فیل', '🐘', allographs: ['فـ', 'ـفـ', 'ـف', 'ف'], allographNames: ['اول', 'وسط', 'آخر چسبان', 'تنها'], allographWords: ['فیل', 'دفتر', 'برف', 'سفید']),
  _LetterLesson('ق', 'قاشق', '🥄', allographs: ['قـ', 'ـقـ', 'ـق', 'ق'], allographNames: ['اول', 'وسط', 'آخر چسبان', 'تنها'], allographWords: ['قاشق', 'سقف', 'بوق', 'اتاق']),
  _LetterLesson('ک', 'کفش', '👟', allographs: ['کـ', 'ـکـ', 'ـک', 'ک'], allographNames: ['اول', 'وسط', 'آخر چسبان', 'تنها'], allographWords: ['کفش', 'شکلات', 'نمک', 'پاک']),
  _LetterLesson('گ', 'گل', '🌷', allographs: ['گـ', 'ـگـ', 'ـگ', 'گ'], allographNames: ['اول', 'وسط', 'آخر چسبان', 'تنها'], allographWords: ['گل', 'نرگس', 'سگ', 'برگ']),
  _LetterLesson('ل', 'لب', '👄', allographs: ['لـ', 'ـلـ', 'ـل', 'ل'], allographNames: ['اول', 'وسط', 'آخر چسبان', 'تنها'], allographWords: ['لب', 'بلبل', 'فیل', 'گل']),
  _LetterLesson('م', 'ماه', '🌙', allographs: ['مـ', 'ـمـ', 'ـم', 'م'], allographNames: ['اول', 'وسط', 'آخر چسبان', 'تنها'], allographWords: ['مادر', 'نمد', 'پرچم', 'بادام']),
  _LetterLesson('ن', 'نان', '🍞', allographs: ['نـ', 'ـنـ', 'ـن', 'ن'], allographNames: ['اول', 'وسط', 'آخر چسبان', 'تنها'], allographWords: ['نان', 'قند', 'دامن', 'باران']),
  _LetterLesson('و', 'وان', '🛁', allographs: ['و', 'ـو'], allographNames: ['تنها', 'چسبان'], allographWords: ['ورزش', 'گاو']),
  _LetterLesson('ه', 'هلو', '🍑', allographs: ['هـ', 'ـهـ', 'ـه', 'ه'], allographNames: ['اول', 'وسط', 'آخر چسبان', 'تنها'], allographWords: ['هوا', 'بهار', 'نامه', 'ماه']),
  _LetterLesson('ی', 'یخ', '🧊', allographs: ['یـ', 'ـیـ', 'ـی', 'ی'], allographNames: ['اول', 'وسط', 'آخر چسبان', 'تنها'], allographWords: ['یاس', 'سایه', 'چای', 'موی']),
];
