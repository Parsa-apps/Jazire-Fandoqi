import '../game_data.dart';
import '../jalali_calendar.dart';
import 'growth_store.dart';
import 'persian_digits.dart';

class ChildCertificate {
  final String id;
  final String title;
  final String emoji;
  final String requirement;
  final bool earned;

  const ChildCertificate({
    required this.id,
    required this.title,
    required this.emoji,
    required this.requirement,
    required this.earned,
  });

  String shareText(String childName) {
    final name = childName.isEmpty ? 'قهرمان کوچولو' : childName;
    return '''
📜 گواهی جزیره فندقی
$name موفق شد «$title» را بگیرد $emoji
تاریخ: ${JalaliDate.today().format()}
ساخته‌شده توسط فندقی و Parsa Apps
''';
  }
}

/// گواهی‌های قابل اشتراک برای لحظهٔ افتخار کودک و استوری والد.
class CertificateBuilder {
  CertificateBuilder._();

  static List<ChildCertificate> all() {
    final alphabet = (GameData.skills['alphabet'] ?? 0) >= 20;
    final numbers = (GameData.skills['counting'] ?? 0) >= 15;
    final stories = GameData.completedStories.length >= 5;
    final life = GrowthStore.completedLifeTopics.length >= 5;
    final streak = GameData.streak >= 7;
    final explorer = GameData.playedGames.length >= 8;
    return [
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
