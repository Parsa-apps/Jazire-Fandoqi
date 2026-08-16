import 'dart:math';

import '../game_data.dart';
import 'growth_store.dart';
import 'persian_digits.dart';
import 'weekly_engine.dart';

/// ═══════════════════════════════════════════════════════════════
/// 📊 PARENT INSIGHTS ENGINE
/// تحلیل‌های معلم‌محور و آماده‌ی نمایش در «مرکز والدین».
///
/// همه‌چیز بر پایه‌ی داده‌های محلی و آفلاین محاسبه می‌شود؛ هیچ تماسی
/// با شبکه نمی‌گیرد و هیچ داده‌ای از دستگاه خارج نمی‌شود.
/// ═══════════════════════════════════════════════════════════════
class ParentInsights {
  ParentInsights._();

  // ── خلاصه امروز ────────────────────────────────────────────
  static int get todayPlayMinutes => GameData.todayPlayMinutes;

  static int get todayCartoonMinutes =>
      (GameData.cartoonWatchSeconds / 60).round();

  static int get todayLearningMinutes {
    final key = GrowthStore.dateKey();
    return GrowthStore.learningMinutes[key] ?? 0;
  }

  static int get todayEntertainmentMinutes {
    final key = GrowthStore.dateKey();
    return GrowthStore.entertainmentMinutes[key] ?? 0;
  }

  static int get sessionCorrect => GrowthStore.sessionCorrect;
  static int get sessionWrong => GrowthStore.sessionWrong;
  static int get sessionAnswers => sessionCorrect + sessionWrong;

  /// درصد دقت این دور از بازی؛ اگر دور فعلی بدون پاسخ باشد، به میانگین کلی
  /// (که پایدارتر است) برمی‌گردد تا والد عددی معنادار ببیند.
  static double get accuracyPercent {
    final total = sessionAnswers;
    if (total == 0) return GameData.averageSuccessRate;
    return sessionCorrect / total * 100;
  }

  static bool get hasEnoughSessionAnswers => sessionAnswers >= 5;

  static double get sessionAccuracy {
    final total = sessionAnswers;
    if (total == 0) return 0;
    return sessionCorrect / total;
  }

  // ── هفته ───────────────────────────────────────────────────
  static int get weekLearningMinutes => WeeklyEngine.weekLearningMinutes();
  static int get weekEntertainmentMinutes =>
      WeeklyEngine.weekEntertainmentMinutes();
  static int get weekTotalMinutes =>
      weekLearningMinutes + weekEntertainmentMinutes;

  /// نسبت یادگیری به کل زمان هفته (۰..۱).
  static double get weekLearningRatio {
    final total = weekTotalMinutes;
    return total == 0 ? 0 : weekLearningMinutes / total;
  }

  // ── اهداف ──────────────────────────────────────────────────
  static int get weeklyGoalMinutes => GrowthStore.weeklyGoalMinutes;

  static double get weeklyGoalRatio =>
      (weekLearningMinutes / weeklyGoalMinutes).clamp(0.0, 1.0);

  static bool get weeklyGoalMet => WeeklyEngine.weeklyGoalMet;

  static int get dailyGoalMinutes => (weeklyGoalMinutes / 7).round();

  // ── سلامت دیجیتال ──────────────────────────────────────────
  /// درصد باقی‌مانده از سهمیه روزانه.
  static double get dailyBudgetRatio {
    final limit = GameData.timeLimitMinutes;
    if (limit <= 0) return 1;
    return (GameData.todayPlaySeconds / (limit * 60)).clamp(0.0, 1.0);
  }

  static int get dailyBudgetRemainingMinutes {
    final limit = GameData.timeLimitMinutes;
    return max(0, limit - todayPlayMinutes);
  }

  static String get balanceLabel {
    final ratio = weekLearningRatio;
    if (weekTotalMinutes < 10) return 'هنوز فعالیت چشمگیری این هفته ثبت نشده';
    if (ratio >= 0.6) return 'تعادل عالی به سمت یادگیری 🌟';
    if (ratio >= 0.4) return 'تعادل خوب؛ کمی بیشتر یادگیری کاملش می‌کند';
    if (ratio >= 0.2) return 'بیشتر وقت به سرگرمی گذشته؛ زمان الفبا را زیاد کنید';
    return 'بیشتر وقت کارتون/بازی تند بوده؛ وقت فعالیّت یادگیری است';
  }

  static ColorTone get balanceTone {
    final ratio = weekLearningRatio;
    if (weekTotalMinutes < 10) return ColorTone.neutral;
    if (ratio >= 0.6) return ColorTone.good;
    if (ratio >= 0.4) return ColorTone.ok;
    return ColorTone.warn;
  }

  // ── مهارت‌ها ───────────────────────────────────────────────
  /// نگاشت تمیز ۸ مهارت رادار به ۰..۱۰۰.
  static Map<String, int> radarSkills() {
    final raw = GameData.topSkills;
    int pick(List<String> keys) {
      for (final k in keys) {
        final v = raw[k];
        if (v is int && v > 0) return v.clamp(0, 100);
      }
      return 0;
    }

    return <String, int>{
      'الفبا': pick(['alphabet', 'الفبا']),
      'اعداد': pick(['counting', 'math', 'اعداد', 'ریاضی']),
      'رنگ‌ها': pick(['colors', 'رنگ‌ها']),
      'شکل‌ها': pick(['shapes', 'شکل‌ها']),
      'حیوانات': pick(['animals', 'حیوانات']),
      'حافظه': pick(['memory', 'حافظه']),
      'ریاضی': pick(['math', 'ریاضی']),
      'هنر': pick(['drawing', 'هنر']),
    };
  }

  /// سه مهارت برتر (نام فارسی، امتیاز).
  static List<MapEntry<String, int>> strongestSkills() {
    final skills = radarSkills().entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));
    return skills.take(3).toList();
  }

  /// سه مهارتِ نیازمند تمرین (صفرها نادیده گرفته می‌شوند).
  static List<MapEntry<String, int>> focusSkills() {
    final skills = radarSkills().entries.where((e) => e.value > 0).toList()
      ..sort((a, b) => a.value.compareTo(b.value));
    return skills.take(3).toList();
  }

  static String get weakestSkillName {
    final focus = focusSkills();
    if (focus.isEmpty) return 'هنوز تمرینی ثبت نشده';
    return focus.first.key;
  }

  // ── روند (۷ روز) ───────────────────────────────────────────
  static List<({String label, int total, int learning})> trend() =>
      WeeklyEngine.last7Days()
          .map((d) =>
              (label: d.$1, total: d.$2, learning: d.$3))
          .toList(growable: false);

  static int get streakDays => GameData.streak;

  // ── توصیه‌های معلم ─────────────────────────────────────────
  static String teacherHeadline() {
    final name = GameData.childName.trim().isEmpty
        ? 'قهرمان کوچولو'
        : GameData.childName.trim();
    final weak = weakestSkillName;
    if (weekLearningMinutes >= weeklyGoalMinutes) {
      return '$name این هفته هدف یادگیری را تمام کرده. آفرین! وقت بازی آزاد و تشویق کلامی بدهید 🌈';
    }
    if (hasEnoughSessionAnswers && sessionAccuracy < 0.5) {
      return 'امروز چند پاسخ پشت‌سرهم اشتباه بوده. به‌جای اصرار، یک استراحت کوتاه یا فعالیت آفلاین پیشنهاد بدهید.';
    }
    if (dailyBudgetRatio > 0.85) {
      return 'سهمیه‌ی صفحه‌ی امروز رو به پایان است. وقت یک فعالیت بدنی یا کتاب کاغذی است 🌳';
    }
    return 'پیشنهاد معلم: ۱۰ دقیقه‌ی امروز را روی «$weak» بگذارید؛ کوچک و پیوسته بهتر از طولانی و خسته است.';
  }

  static List<TeacherTip> teacherTips() {
    final tips = <TeacherTip>[];
    final ratio = weekLearningRatio;

    if (weekTotalMinutes >= 10 && ratio < 0.4) {
      tips.add(const TeacherTip(
        emoji: '⚖️',
        title: 'تعادل یادگیری و سرگرمی',
        body: 'این هفته نسبت یادگیری کم است. می‌توانید کارتون را بعد از ۱۰ دقیقه تمرین الفبا/اعداد «جایزه» بدهید.',
        tone: ColorTone.warn,
      ));
    }
    if (dailyBudgetRatio > 0.8 && todayPlayMinutes > 0) {
      tips.add(const TeacherTip(
        emoji: '👀',
        title: 'استراحت چشم ۲۰-۲۰-۲۰',
        body: 'هر ۲۰ دقیقه، ۲۰ ثانیه به فاصله‌ی ۶ متری نگاه کند. قانون ۲۰-۲۰-۲۰ برای سلامت چشم خردسالان حیاتی است.',
        tone: ColorTone.warn,
      ));
    }
    if (hasEnoughSessionAnswers && sessionAccuracy >= 0.8) {
      tips.add(const TeacherTip(
        emoji: '⭐',
        title: 'دقت بالا',
        body: 'دقت امروز عالی است! این بهترین فرصت برای دادن یک چالش کمی سخت‌تر و تقویت اعتمادبه‌نفس است.',
        tone: ColorTone.good,
      ));
    }
    final focus = focusSkills();
    if (focus.isNotEmpty && focus.first.value < 60) {
      tips.add(TeacherTip(
        emoji: '🎯',
        title: 'نقطه تمرین: ${focus.first.key}',
        body: 'به‌جای کار سخت‌تر، کوتاه‌تر و بازی‌گونه تمرین کنید. ۵ دقیقه‌ی خوشحال، از ۲۰ دقیقه‌ی بی‌حوصله بهتر است.',
        tone: ColorTone.ok,
      ));
    }
    tips.add(const TeacherTip(
      emoji: '🤸',
      title: 'فعالیت آفلاین',
      body: 'برای هر ۲۰ دقیقه صفحه، یک حرکت بدنی بگذارید: لی‌لی، طناب‌بازی یا حتی چیدن میز. یادگیری با بدن تثبیت می‌شود.',
      tone: ColorTone.neutral,
    ));
    return tips;
  }

  // ── اعلان‌های هوشمند (تب خانه) ─────────────────────────────
  static List<ParentAlert> alerts() {
    final list = <ParentAlert>[];

    if (GameData.timeLimitMinutes > 0 &&
        todayPlayMinutes >= GameData.timeLimitMinutes) {
      list.add(const ParentAlert(
        emoji: '⏰',
        title: 'سهمیه‌ی امروز کامل شد',
        body: 'کودک به سقف زمانی روزانه رسید. اپ به‌صورت خودکار محدود می‌کند.',
        tone: ColorTone.warn,
      ));
    } else if (dailyBudgetRatio >= 0.75) {
      list.add(ParentAlert(
        emoji: '⏳',
        title: 'نزدیک شدن به سقف روزانه',
        body: 'حدود ${PersianDigits.toFa(dailyBudgetRemainingMinutes)} دقیقه از سهمیه باقی مانده.',
        tone: ColorTone.ok,
      ));
    }

    if (weekLearningMinutes >= weeklyGoalMinutes) {
      list.add(const ParentAlert(
        emoji: '🏆',
        title: 'هدف هفتگی محقق شد',
        body: 'هدف یادگیری هفته انجام شد. یک تشویق گرم و شاید یک گواهی جدید!',
        tone: ColorTone.good,
      ));
    }

    final cartMin = todayCartoonMinutes;
    final learnMin = todayLearningMinutes;
    if (cartMin > 20 && cartMin > learnMin * 2) {
      list.add(const ParentAlert(
        emoji: '📺',
        title: 'کارتون بیشتر از یادگیری',
        body: 'برای تعادل، پیشنهاد می‌شود بعد از کارتون یک فعالیت آموزشی کوتاه انجام شود.',
        tone: ColorTone.warn,
      ));
    }

    if (GameData.totalWrong > GameData.totalCorrect &&
        GameData.totalWrong >= 5) {
      list.add(const ParentAlert(
        emoji: '💛',
        title: 'نیاز به راهنمایی بیشتر',
        body: 'تعداد پاسخ‌های نادرست بیشتر است. شاید بهتر است یک درجه سختی را کمتر کنید یا همراهی کنید.',
        tone: ColorTone.ok,
      ));
    }

    if (list.isEmpty) {
      list.add(const ParentAlert(
        emoji: '✅',
        title: 'همه‌چیز آرام و متعادل است',
        body: 'هشدار خاصی نیست. همین الگوی کوچک و پیوسته را حفظ کنید.',
        tone: ColorTone.good,
      ));
    }
    return list;
  }
}

/// لحن رنگی کارت‌ها برای هماهنگی بصری.
enum ColorTone { good, ok, warn, neutral }

class TeacherTip {
  final String emoji;
  final String title;
  final String body;
  final ColorTone tone;
  const TeacherTip({
    required this.emoji,
    required this.title,
    required this.body,
    required this.tone,
  });
}

class ParentAlert {
  final String emoji;
  final String title;
  final String body;
  final ColorTone tone;
  const ParentAlert({
    required this.emoji,
    required this.title,
    required this.body,
    required this.tone,
  });
}
