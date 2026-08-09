import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../app/app_colors.dart';
import '../../../core/audio_service.dart';
import '../../../core/fandoghi_coach.dart';
import '../../../core/game_data.dart';
import '../../../core/learning_content/stories.dart';
import '../../../shared/widgets/child_touch_target.dart';
import '../../../shared/widgets/fandoghi_v2.dart';
import '../../../shared/widgets/premium_button.dart';

/// ────────────────────────────────────────────────────────────
/// 📖 فاز ۲۹: پخش‌کننده داستان تعاملی
///
/// فندقی راوی است (TTS)، کودک انتخاب می‌کند و داستان شاخه می‌زند.
/// در پایان هر داستان، ستاره + سکه پاداش و ثبت مهارت «vocab».
/// ────────────────────────────────────────────────────────────
class StoryScreen extends StatefulWidget {
  final String storyId;

  const StoryScreen({super.key, required this.storyId});

  @override
  State<StoryScreen> createState() => _StoryScreenState();
}

class _StoryScreenState extends State<StoryScreen> {
  late final Story _story;
  late String _currentNodeId;
  int _choicesMade = 0;
  bool _finished = false;

  @override
  void initState() {
    super.initState();
    _story = storyById(widget.storyId);
    _currentNodeId = _story.startNode;
    FandoghiCoach.enablePersistentPresence();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      Future<void>.delayed(const Duration(milliseconds: 600), _narrate);
    });
  }

  @override
  void dispose() {
    FandoghiCoach.clear();
    AudioService.stopSpeaking();
    super.dispose();
  }

  StoryNode get _current => _story.node(_currentNodeId);

  void _narrate() {
    unawaited(AudioService.speak(_current.text));
  }

  void _choose(String nextId) {
    FandoghiCoach.cancelSmartHint();
    HapticFeedback.lightImpact();
    setState(() {
      _currentNodeId = nextId;
      _choicesMade++;
      _finished = _story.node(nextId).choices.isEmpty;
    });
    Future<void>.delayed(const Duration(milliseconds: 400), _narrate);

    if (_finished) {
      // پاداش پایان داستان — فقط یک‌بار برای هر داستان (ضد farming)
      if (GameData.markStoryCompleted(_story.id)) {
        GameData.addStars(2);
        GameData.addCoins(10);
      }
      GameData.recordAnswer(correct: true, skill: 'vocab');
      FandoghiCoach.reward('داستان «${_story.title}» تمام شد! تو قهرمان داستان‌ها هستی 📚');
    }
  }

  @override
  Widget build(BuildContext context) {
    final node = _current;
    return Scaffold(
      body: DecoratedBox(
        decoration: const BoxDecoration(gradient: AppGradients.nightSky),
        child: SafeArea(
          child: Column(
            children: [
              // Header
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
                child: Row(
                  children: [
                    ChildTouchTarget(
                      onTap: () => Navigator.pop(context),
                      child: const Icon(Icons.arrow_back_rounded,
                          color: Colors.white, size: 28),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        '${_story.emoji} ${_story.title}',
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                    ),
                    const SizedBox(width: 36),
                  ],
                ),
              ),
              const SizedBox(height: 8),
              // Narrator
              FandoghiV2(size: 84, mood: FandoghiMood.happy),
              const SizedBox(height: 12),
              // Story text
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(horizontal: 26),
                  child: Column(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(22),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.12),
                          borderRadius: BorderRadius.circular(24),
                          border: Border.all(
                            color: Colors.white.withOpacity(0.2),
                          ),
                        ),
                        child: Column(
                          children: [
                            Text(
                              node.emoji,
                              style: const TextStyle(fontSize: 56),
                            ),
                            const SizedBox(height: 14),
                            Text(
                              node.text,
                              textAlign: TextAlign.center,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 19,
                                fontWeight: FontWeight.w700,
                                height: 1.7,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 16),
                      // بازپخش صدا
                      ChildTouchTarget(
                        onTap: _narrate,
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 20, vertical: 10),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(30),
                          ),
                          child: const Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(Icons.volume_up_rounded,
                                  color: Colors.white, size: 20),
                              SizedBox(width: 8),
                              Text('دوباره بشنو',
                                  style: TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.w700)),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 24),
                      // Choices
                      for (final choice in node.choices) ...[
                        SizedBox(
                          width: double.infinity,
                          child: Material(
                            color: Colors.transparent,
                            child: InkWell(
                              borderRadius: BorderRadius.circular(22),
                              onTap: () => _choose(choice.nextId),
                              child: Container(
                                constraints: const BoxConstraints(minHeight: 64),
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 18, vertical: 14),
                                decoration: BoxDecoration(
                                  gradient: AppGradients.purple,
                                  borderRadius: BorderRadius.circular(22),
                                  boxShadow: [
                                    BoxShadow(
                                      color: AppColors.primary.withOpacity(0.3),
                                      blurRadius: 12,
                                      offset: const Offset(0, 4),
                                    ),
                                  ],
                                ),
                                child: Text(
                                  choice.label,
                                  textAlign: TextAlign.center,
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 17,
                                    fontWeight: FontWeight.w800,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 12),
                      ],
                      if (_finished) ...[
                        const SizedBox(height: 6),
                        PremiumButton(
                          text: 'داستان دیگر 📚',
                          icon: Icons.menu_book_rounded,
                          color: const Color(0xFF5C6BC0),
                          onPressed: () => Navigator.pop(context),
                        ),
                      ],
                      const SizedBox(height: 30),
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
}
