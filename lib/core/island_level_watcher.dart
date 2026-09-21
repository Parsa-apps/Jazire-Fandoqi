import 'game_data.dart';

/// ═══════════════════════════════════════════════════════════════
/// 🎉 نگهبان سطح جزیره — نسخه ۷.۰.۰
///
/// «سطح جزیره» حالا در تمام برنامه زنده است: هر بازی قدیمی یا جدیدی
/// که XP بیاورد و کودک را به سطح برساند، یک بار جشن گرفته می‌شود
/// (صدای levelup + پیام فندقی) — بدون اینکه صفحهٔ بازی خودش چیزی بداند.
///
/// منطق محافظ:
///  - تا arm نشود جشنی نمی‌گیرد (بارگذاری/مهاجرت اولیه بی‌صدا است)
///  - تعویض کامل پروفایل (profileGeneration) بی‌صدا re-baseline می‌شود
///  - فاصلهٔ حداقلی بین جشن‌ها از فرسودگی شادی جلوگیری می‌کند
///
/// این کلاس خالص و بدون وابستگی به UI است؛ اتصال صدا/فندقی بر عهدهٔ
/// لایهٔ برنامه (main) است تا تست واحد ساده بماند.
/// ═══════════════════════════════════════════════════════════════
class IslandLevelWatcher {
  /// با هر ارتقای واقعی (از سطح، به سطح) صدا زده می‌شود.
  final void Function(int fromLevel, int toLevel) onLevelUp;

  /// حداقل فاصلهٔ بین دو جشن — حتی اگر دو ارتقا پشت هم بیاید.
  final Duration minInterval;

  /// ساعت تزریقی برای تست‌پذیری.
  final DateTime Function() clock;

  int _lastKnownLevel;
  int _lastGeneration;
  bool _armed = false;
  DateTime? _lastCelebratedAt;

  IslandLevelWatcher({
    required this.onLevelUp,
    this.minInterval = const Duration(seconds: 90),
    DateTime Function()? clock,
  })  : clock = clock ?? DateTime.now,
        _lastKnownLevel = GameData.islandLevel,
        _lastGeneration = GameData.profileGeneration;

  /// بعد از اولین فریم برنامه صدا زده شود؛ تغییر سطحِ حین بارگذاری
  /// اولیه و مهاجرت ۶.x هرگز جشن نمی‌گیرد.
  void arm() {
    _lastKnownLevel = GameData.islandLevel;
    _lastGeneration = GameData.profileGeneration;
    _armed = true;
  }

  /// این متد باید به `GameData.changes` وصل شود.
  void handleChange() {
    if (!_armed) {
      arm();
      return;
    }
    // تعویض کامل پروفایل (خواهر/برادر یا بازیابی بکاپ): بی‌صدا
    if (GameData.profileGeneration != _lastGeneration) {
      arm();
      return;
    }
    final current = GameData.islandLevel;
    if (current > _lastKnownLevel) {
      final from = _lastKnownLevel;
      _lastKnownLevel = current;
      final now = clock();
      final celebratedRecently = _lastCelebratedAt != null &&
          now.difference(_lastCelebratedAt!) < minInterval;
      if (!celebratedRecently) {
        _lastCelebratedAt = now;
        onLevelUp(from, current);
      }
      return;
    }
    if (current < _lastKnownLevel) {
      // نباید رخ دهد (XP کم نمی‌شود)؛ محافظ در برابر دادهٔ دستکاری‌شده.
      _lastKnownLevel = current;
    }
  }
}
