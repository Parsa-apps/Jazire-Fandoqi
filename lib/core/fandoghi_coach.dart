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
  static final ValueNotifier<bool> persistent = ValueNotifier<bool>(false);
  /// کودک یا والد می‌تواند مربی را موقتاً جمع کند؛ وضعیت فقط در اجرای فعلی نگه داشته می‌شود.
  static final ValueNotifier<bool> minimized = ValueNotifier<bool>(false);
  static Timer? _hideTimer;
  static Timer? _hintTimer;
  static int _nextId = 0;

  // فاز ۴۳: فندقی نام کودک را به یاد می‌آورد و با همدلی حرف می‌زند
  static String _childName = '';

  static void rememberChild(String name) {
    _childName = name.trim();
  }

  static String get childName => _childName;

  static String _name() => _childName.isEmpty ? 'عزیزم' : _childName;

  /// فاز ۱۹: راهنمای هوشمند — فندقی فقط وقتی کودک ۳ ثانیه
  /// بی‌حرکت مانده راهنمایی می‌دهد (نه اسپم).
  static void armSmartHint({
    required void Function() onHint,
    Duration delay = const Duration(seconds: 3),
  }) {
    _hintTimer?.cancel();
    _hintTimer = Timer(delay, () {
      _hintTimer = null;
      onHint();
    });
  }

  /// هر فعالیت کودک (لمس/کشیدن) این را صدا بزند تا تایمر ریست شود.
  static void noteActivity() {
    _hintTimer?.cancel();
    _hintTimer = null;
  }

  static void cancelSmartHint() {
    _hintTimer?.cancel();
    _hintTimer = null;
  }

  static void enablePersistentPresence() {
    // شخصیت مربی دیگر روی صفحه نمی‌ماند؛ فقط پیام متنی نمایش داده می‌شود.
    persistent.value = false;
  }

  static void minimize() => minimized.value = true;
  static void restore() => minimized.value = false;

  static void disablePersistentPresence() {
    persistent.value = false;
    minimized.value = false;
    clear();
  }

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
        'سلام ${_name()}! من فندقی‌ام؛ مربی و داور کوچولوی تو. با هم بازی می‌کنیم و یاد می‌گیریم! 🌰',
        mood: FandoghiMood.excited,
        duration: const Duration(seconds: 5),
      );

  /// فاز ۴۳: پیام همدلی — وقتی کودک ناراحت یا خسته است.
  static void empathy(String text) => say(
        text,
        mood: FandoghiMood.shy,
        tone: FandoghiCoachTone.encouragement,
        duration: const Duration(seconds: 4),
      );

  static void celebrate(String text) => say(
        text,
        mood: FandoghiMood.celebrating,
        tone: FandoghiCoachTone.success,
        duration: const Duration(seconds: 4),
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

  static final List<String> _friendlyQuotes = [
    'من همیشه کنارتم قهرمان! 🌰✨',
    'تو خیلی باهوشی، ادامه بده! 🌟',
    'یادت نره آب بخوری دوست من! 💧',
    'تمرین بیشتر یعنی یادگیری بهتر! 📚',
    'لبخند بزن کوچولو، امروز عالی پیش میره! 😊',
    'چشم‌هات خسته نشه؛ یه نفس عمیق بکش! 🌈',
    'هر روز داری قوی‌تر و داناتر میشی! 💪',
  ];

  static void randomFriendlyTip() {
    final quote = _friendlyQuotes[DateTime.now().millisecond % _friendlyQuotes.length];
    say(
      quote,
      mood: FandoghiMood.excited,
      tone: FandoghiCoachTone.encouragement,
      duration: const Duration(seconds: 3),
    );
  }

  static void clear() {
    _hideTimer?.cancel();
    _hideTimer = null;
    current.value = null;
  }
}
