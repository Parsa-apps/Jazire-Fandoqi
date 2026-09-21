import 'package:flutter/material.dart';

/// ═══════════════════════════════════════════════════════════════
/// 🎪 دنیای بازی‌های تازه — مدل‌های مشترک (نسخه ۷.۰.۰)
///
/// ده بازی جدید همگی از یک چارچوب واحد استفاده می‌کنند:
///  - یک جریان بازی اثبات‌شده (سؤال → بازخورد مثبت → دور بعد)
///  - Hint ظریف پس از بی‌حرکتی
///  - ثبت XP، مهارت، مأموریت و مدال از مسیرهای مرکزی GameData
/// این فایل فقط مدل است و هیچ وابستگی‌ای به UI ندارد؛
/// بنابراین مولدهای سؤال هر بازی به‌راحتی تست واحد می‌شوند.
/// ═══════════════════════════════════════════════════════════════

/// یک گزینهٔ قابل لمس داخل دور بازی.
class MiniGameOption {
  /// متن گزینه: حرف، عدد فارسی، ایموجی یا واژه.
  final String label;

  /// چیپ رنگی برای بازی‌های رنگ (اختیاری — برچسب می‌پوشاند).
  final Color? swatch;

  /// آیا این گزینه پاسخ درست است؟ (دقیقاً یکی در هر دور true است)
  final bool correct;

  const MiniGameOption(
    this.label, {
    this.correct = false,
    this.swatch,
  });
}

/// یک دور (پرسش) از بازی مینی.
class MiniGameRound {
  /// سؤال بزرگ بالای صحنه، مثل «چند تا سیب است؟»
  final String prompt;

  /// صحنهٔ مرکزی: ایموجی‌ها/متن بزرگ (مثل «🍎🍎🍎» یا «تـ _ پ»).
  final String scene;

  /// اندازهٔ فونت صحنه (بازی‌های متن‌دار بزرگ‌تر نمایش می‌دهند).
  final double sceneFontSize;

  /// اگر پر باشد، صحنه با این فونت به‌صورت متن فارسی رندر می‌شود.
  /// (مثلاً واژهٔ ناقص کلمه‌ساز)
  final bool sceneIsText;

  /// گزینه‌های دور.
  final List<MiniGameOption> options;

  /// راهنمای فندقی برای Hint ظریف (بعد از ~۱۰ ثانیه بی‌حرکتی).
  final String hint;

  /// اگر true باشد کودک چند گزینه را انتخاب/برمی‌دارد و با دکمهٔ
  /// «گذاشتم!» تأیید می‌کند (طبقه‌بندی). در غیر این صورت تک‌انتخابی است.
  final bool multiSelect;

  const MiniGameRound({
    required this.prompt,
    required this.scene,
    required this.options,
    required this.hint,
    this.sceneFontSize = 44,
    this.sceneIsText = false,
    this.multiSelect = false,
  }) : assert(options.any((o) => o.correct), 'هر دور باید پاسخ درست داشته باشد');

  MiniGameRound copyWith({
    String? prompt,
    String? scene,
    double? sceneFontSize,
    bool? sceneIsText,
    List<MiniGameOption>? options,
    String? hint,
    bool? multiSelect,
  }) {
    return MiniGameRound(
      prompt: prompt ?? this.prompt,
      scene: scene ?? this.scene,
      sceneFontSize: sceneFontSize ?? this.sceneFontSize,
      sceneIsText: sceneIsText ?? this.sceneIsText,
      options: options ?? this.options,
      hint: hint ?? this.hint,
      multiSelect: multiSelect ?? this.multiSelect,
    );
  }
}

/// مشخصات هر بازی: عنوان، مهارت ثبت‌شده و لحن فندقی.
class MiniGameSpec {
  /// عنوان کامل با ایموجی — «کلمه‌ساز 🧱»
  final String title;

  /// شناسهٔ بازی برای آمار «بازی‌های انجام‌شده» و مدال‌ها.
  final String gameId;

  /// کلید مهارت در GameData.skills ('vocab', 'counting', ...)
  final String skill;

  /// شناسهٔ مأموریت روزانه ('words', 'counting', 'logic', ...)
  final String? missionId;

  /// گرادیان پس‌زمینه.
  final Gradient gradient;

  /// پیام خوش‌آمد فندقی هنگام ورود.
  final String introCoach;

  /// پیام جایزهٔ فندقی در پایان.
  final String rewardCoach;

  /// تعداد دورهای هر جلسه.
  final int rounds;

  const MiniGameSpec({
    required this.title,
    required this.gameId,
    required this.skill,
    required this.gradient,
    required this.introCoach,
    required this.rewardCoach,
    this.missionId,
    this.rounds = 6,
  });
}
