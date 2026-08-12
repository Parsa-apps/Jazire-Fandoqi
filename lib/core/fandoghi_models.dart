/// Visual moods shared by the coach service and the mascot widget.
/// Kept in core so the feedback channel does not depend on a UI widget.
///
/// فاز ۱۲: ۱۰ حالت احساسی فندقی V3
enum FandoghiMood {
  happy, // خوشحال
  excited, // ذوق‌زده
  thinking, // متفکر
  sleeping, // خواب‌آلود
  wink, // چشمک
  proud, // مغرور (بعد از برد)
  shy, // خجالتی
  surprised, // متعجب
  sad, // ناراحت مهربان
  celebrating, // جشن‌گیران
}

/// نگاشت حالت احساسی به ایموجی صورت فندقی (بدون هاله سفید — ایموجی
/// پس‌زمینه شفاف دارد و با هر تم هماهنگ است).
extension FandoghiMoodVisuals on FandoghiMood {
  String get emoji => switch (this) {
        FandoghiMood.happy => '😊',
        FandoghiMood.excited => '🤩',
        FandoghiMood.thinking => '🤔',
        FandoghiMood.sleeping => '😴',
        FandoghiMood.wink => '😉',
        FandoghiMood.proud => '😎',
        FandoghiMood.shy => '☺️',
        FandoghiMood.surprised => '😮',
        FandoghiMood.sad => '🥺',
        FandoghiMood.celebrating => '🎉',
      };

  /// مدت پیشنهادی نمایش پیام برای هر حالت.
  Duration get suggestedDuration => switch (this) {
        FandoghiMood.celebrating || FandoghiMood.sad => const Duration(seconds: 4),
        FandoghiMood.excited || FandoghiMood.surprised => const Duration(seconds: 3),
        _ => const Duration(seconds: 2),
      };

  /// تصویر اختصاصی این حالت از مسکات «فندقی کوچولو».
  ///
  /// هر ۱۰ حالت احساسی تصویر مخصوص خودش را دارد. مقدار `null` فقط
  /// به‌عنوان شبکهٔ اطمینان برای حالت‌های آیندهٔ بدون تصویر باقی مانده
  /// تا رابط کاربری به تصویر پیش‌فرض + ایموجی احساس برگردد.
  String? get portraitAsset => switch (this) {
        FandoghiMood.happy => 'assets/mascot/fandoghi_baby.webp',
        FandoghiMood.excited => 'assets/mascot/fandoghi_baby_cheer.webp',
        FandoghiMood.celebrating => 'assets/mascot/fandoghi_baby_party.webp',
        FandoghiMood.proud => 'assets/mascot/fandoghi_baby_proud.webp',
        FandoghiMood.thinking => 'assets/mascot/fandoghi_baby_think.webp',
        FandoghiMood.surprised => 'assets/mascot/fandoghi_baby_wow.webp',
        FandoghiMood.wink => 'assets/mascot/fandoghi_baby_wink.webp',
        FandoghiMood.sleeping => 'assets/mascot/fandoghi_baby_sleep.webp',
        FandoghiMood.shy => 'assets/mascot/fandoghi_baby_shy.webp',
        FandoghiMood.sad => 'assets/mascot/fandoghi_baby_sad.webp',
      };
}
