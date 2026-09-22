import '../game_data.dart';
import '../jalali_calendar.dart';
import '../xp_system.dart';
import 'growth_store.dart';
import 'persian_digits.dart';

class ChildCertificate {
  final String id;
  final String title;
  final String emoji;
  final String requirement;
  final bool earned;

  /// جملهٔ سفارشی برای اشتراک‌گذاری (اختیاری) — مثلاً برای گواهی‌های
  /// «سطح جزیره» که رسیدن به لقب را توصیف می‌کنند.
  final String? shareDetail;

  const ChildCertificate({
    required this.id,
    required this.title,
    required this.emoji,
    required this.requirement,
    required this.earned,
    this.shareDetail,
  });

  String shareText(String childName) {
    final name = childName.isEmpty ? 'قهرمان کوچولو' : childName;
    final achievement = shareDetail ?? 'موفق شد «$title» را بگیرد $emoji';
    return '''
📜 گواهی جزیره فندقی
$name $achievement
تاریخ: ${JalaliDate.today().format()}
ساخته‌شده توسط فندقی و Parsa Apps
''';
  }
}

/// گواهی‌های قابل اشتراک برای لحظهٔ افتخار کودک و استوری والد.
class CertificateBuilder {
  CertificateBuilder._();

  /// ⭐ نسخهٔ ۷.۱ — نقاط عطف «سطح جزیره»: رسیدن به لقب‌های بزرگ
  /// (دوست جزیره، سیاح جزیره، قهرمان جزیره، افسانه جزیره) هرکدام یک
  /// گواهی افتخار باز می‌کند؛ لحظهٔ رسیدن هم با جشن گواهی گرفته
  /// می‌شود (IslandMilestoneCelebration).
  static const List<({int level, String title, String emoji})>
      islandMilestones = [
    (level: 3, title: 'دوست جزیره', emoji: '🤝'),
    (level: 5, title: 'سیاح جزیره', emoji: '🧭'),
    (level: 7, title: 'قهرمان جزیره', emoji: '🏆'),
    (level: 9, title: 'افسانه جزیره', emoji: '👑'),
  ];

  /// آیا این سطح یک نقطهٔ عطف گواهی‌دار است؟
  static bool isIslandMilestone(int level) =>
      islandMilestones.any((milestone) => milestone.level == level);

  /// گواهی نقطهٔ عطف مربوط به سطح داده‌شده (اگر نقطهٔ عطف نباشد null).
  static ChildCertificate? islandCertificateFor(int level) {
    if (!isIslandMilestone(level)) return null;
    final id = 'cert_island_$level';
    for (final certificate in all()) {
      if (certificate.id == id) return certificate;
    }
    return null;
  }

  static List<ChildCertificate> all() {
    final islandLevel = GameData.islandLevel;
    final alphabet = (GameData.skills['alphabet'] ?? 0) >= 20;
    final numbers = (GameData.skills['counting'] ?? 0) >= 15;
    final stories = GameData.completedStories.length >= 5;
    final life = GrowthStore.completedLifeTopics.length >= 5;
    final streak = GameData.streak >= 7;
    final explorer = GameData.playedGames.length >= 8;
    return [
      // ⭐ نقاط عطف سطح جزیره — سرِ فهرست: پیشرفت واقعی و سراسری کودک
      for (final milestone in islandMilestones)
        ChildCertificate(
          id: 'cert_island_${milestone.level}',
          title: milestone.title,
          emoji: milestone.emoji,
          requirement:
              'رسیدن به سطح ${PersianDigits.toFa(milestone.level)} جزیره',
          earned: islandLevel >= milestone.level,
          shareDetail:
              'با تلاش و یادگیری به سطح ${PersianDigits.toFa(milestone.level)} جزیره رسید و لقب «${milestone.title}» را گرفت ${milestone.emoji}',
        ),
      ChildCertificate(
        id: 'cert_alpha',
        title: 'خوشنویس جزیره',
        emoji: '✍️',
        requirement: '۲۰ تمرین الفبا',
        earned: alphabet,
      ),
      ChildCertificate(
        id: 'cert_math',
        title: 'شمارش‌گر طلایی',
        emoji: '🔢',
        requirement: '۱۵ تمرین عدد',
        earned: numbers,
      ),
      ChildCertificate(
        id: 'cert_story',
        title: 'قصه‌گوی مهربان',
        emoji: '📖',
        requirement: '۵ داستان کامل',
        earned: stories,
      ),
      ChildCertificate(
        id: 'cert_life',
        title: 'کاوشگر زندگی',
        emoji: '🧭',
        requirement: '۵ دنیای مهارت زندگی',
        earned: life,
      ),
      ChildCertificate(
        id: 'cert_streak',
        title: 'هفتهٔ پیوسته',
        emoji: '🔥',
        requirement: '۷ روز استریک',
        earned: streak,
      ),
      ChildCertificate(
        id: 'cert_explore',
        title: 'جهانگرد بازی‌ها',
        emoji: '🌍',
        requirement: '۸ بازی مختلف',
        earned: explorer,
      ),
    ];
  }

  static int get earnedCount => all().where((c) => c.earned).length;

  static String achievementCardText(String title) {
    final name =
        GameData.childName.isNotEmpty ? GameData.childName : 'قهرمان کوچولو';
    return '$name مدال «$title» را در جزیره فندقی گرفت! ${PersianDigits.toFa(GameData.stars)} ستاره ⭐';
  }
}
