import 'dart:async';

import 'package:flutter/foundation.dart';

import 'fandoghi_models.dart';

/// The kind of feedback shown in فندقی's speech bubble.
enum FandoghiCoachTone { neutral, success, encouragement, warning }

class FandoghiCoachMessage {
  final int id;
  final String text;
  final FandoghiMood mood;
  final FandoghiCoachTone tone;

  const FandoghiCoachMessage({
    required this.id,
    required this.text,
    required this.mood,
    required this.tone,
  });
}

/// App-wide coach/host channel.
///
/// Games do not know anything about overlays or navigation. They only publish
/// feedback here; [FandoghiCoachOverlay] renders it consistently above every
/// route. This keeps the judge/teacher character present in every activity and
/// makes correct, incorrect and instructional feedback accessible to the child.
class FandoghiCoach {
  FandoghiCoach._();

  static final ValueNotifier<FandoghiCoachMessage?> current =
      ValueNotifier<FandoghiCoachMessage?>(null);
  static Timer? _hideTimer;
  static int _nextId = 0;

  static void say(
    String text, {
    FandoghiMood mood = FandoghiMood.happy,
    FandoghiCoachTone tone = FandoghiCoachTone.neutral,
    Duration duration = const Duration(seconds: 3),
  }) {
    final cleanText = text.trim();
    if (cleanText.isEmpty) return;

    _hideTimer?.cancel();
    final id = ++_nextId;
    current.value = FandoghiCoachMessage(
      id: id,
      text: cleanText,
      mood: mood,
      tone: tone,
    );
    _hideTimer = Timer(duration, () {
      if (current.value?.id == id) current.value = null;
    });
  }

  static void welcome() => say(
        'سلام! من فندقی‌ام؛ مربی و داور کوچولوی تو. با هم بازی می‌کنیم و یاد می‌گیریم! 🌰',
        mood: FandoghiMood.excited,
        duration: const Duration(seconds: 5),
      );

  static void instruction(String text) => say(
        text,
        mood: FandoghiMood.thinking,
        tone: FandoghiCoachTone.neutral,
      );

  static void correct([String text = 'آفرین قهرمان! جواب درست بود؛ همین‌طور ادامه بده! 🌟']) => say(
        text,
        mood: FandoghiMood.excited,
        tone: FandoghiCoachTone.success,
        duration: const Duration(seconds: 2),
      );

  static void incorrect(String answer) => say(
        'اشکالی نداره عزیزم! جواب درست «$answer» بود. دوباره با هم تمرین می‌کنیم 💪',
        mood: FandoghiMood.thinking,
        tone: FandoghiCoachTone.encouragement,
        duration: const Duration(seconds: 3),
      );

  static void judge(String text) => say(
        text,
        mood: FandoghiMood.wink,
        tone: FandoghiCoachTone.warning,
      );

  static void reward(String text) => say(
        text,
        mood: FandoghiMood.excited,
        tone: FandoghiCoachTone.success,
        duration: const Duration(seconds: 4),
      );

  static void clear() {
    _hideTimer?.cancel();
    _hideTimer = null;
    current.value = null;
  }
}
