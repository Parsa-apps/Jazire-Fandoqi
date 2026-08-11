import '../cartoons/cartoon_data.dart';
import '../learning_content/children_stories_data.dart';
import 'life_skills_data.dart';

class CatalogItem {
  final String title;
  final String subtitle;
  final String route;
  final String emoji;
  final String category;
  final List<String> tags;

  const CatalogItem({
    required this.title,
    required this.subtitle,
    required this.route,
    required this.emoji,
    required this.category,
    this.tags = const [],
  });
}

/// فهرست واحد جستجو روی بازی، قصه، کارتون و مهارت زندگی.
class CatalogSearch {
  CatalogSearch._();

  static List<CatalogItem> allItems() {
    final items = <CatalogItem>[
      const CatalogItem(title: 'الفبا', subtitle: 'نوشتن حروف فارسی', route: '/game/الفبا', emoji: '🔤', category: 'بازی', tags: ['حرف', 'نوشتن']),
      const CatalogItem(title: 'اعداد', subtitle: 'شمارش ۱ تا ۲۰', route: '/numbers', emoji: '🔢', category: 'آموزش', tags: ['ریاضی']),
      const CatalogItem(title: 'رنگ‌ها', subtitle: 'آزمایشگاه رنگ', route: '/game/رنگ‌ها', emoji: '🎨', category: 'بازی', tags: ['رنگ']),
      const CatalogItem(title: 'حافظه', subtitle: 'کارت‌های حافظه', route: '/memory_match', emoji: '🧠', category: 'بازی', tags: ['فکر']),
      const CatalogItem(title: 'حباب‌ترکان', subtitle: 'بازی سرعت', route: '/bubble_pop', emoji: '🫧', category: 'بازی', tags: ['سرگرمی']),
      const CatalogItem(title: 'ستاره‌گیری', subtitle: 'گرفتن ستاره', route: '/star_catch', emoji: '⭐', category: 'بازی', tags: ['سرگرمی']),
      const CatalogItem(title: 'نقاشی', subtitle: 'دفتر رنگ‌آمیزی', route: '/game/نقاشی', emoji: '🖌️', category: 'هنر', tags: ['رنگ']),
      const CatalogItem(title: 'حیوانات ایران', subtitle: 'دانشنامه ۳۰ حیوان', route: '/animals', emoji: '🦁', category: 'آموزش', tags: ['ایران']),
      const CatalogItem(title: 'شغل‌ها', subtitle: '۲۰ شغل آشنا', route: '/jobs', emoji: '👷', category: 'آموزش'),
      const CatalogItem(title: 'احساسات', subtitle: 'هوش هیجانی', route: '/sel', emoji: '💛', category: 'آموزش', tags: ['sel']),
      const CatalogItem(title: 'قصه‌خانه', subtitle: 'داستان تعاملی', route: '/stories', emoji: '📖', category: 'قصه'),
      const CatalogItem(title: 'لالایی', subtitle: 'خواب آرام', route: '/lullabies', emoji: '🌙', category: 'آرامش'),
      const CatalogItem(title: 'سینما کارتون', subtitle: 'کارتون دوبله', route: '/cartoons', emoji: '🎬', category: 'کارتون'),
      const CatalogItem(title: 'مهارت زندگی', subtitle: '۱۰ دنیای روزمره', route: '/life-skills', emoji: '🧭', category: 'آموزش', tags: ['ترافیک', 'بهداشت', 'پول']),
      const CatalogItem(title: 'گزارش هفتگی', subtitle: 'برای والدین', route: '/weekly-report', emoji: '📊', category: 'والدین'),
      const CatalogItem(title: 'گواهی‌ها', subtitle: 'افتخارهای کودک', route: '/certificates', emoji: '📜', category: 'پروفایل'),
      const CatalogItem(title: 'واژه‌نامه', subtitle: 'کلمات طلایی', route: '/vocabulary', emoji: '📝', category: 'آموزش'),
    ];

    for (final story in ChildrenStoriesData.allStories) {
      items.add(CatalogItem(
        title: story.title,
        subtitle: story.subtitle,
        route: '/story/${story.id}',
        emoji: story.coverEmoji,
        category: 'قصه',
        tags: [story.categoryLabel],
      ));
    }
    for (final cartoon in CartoonData.allCartoons) {
      items.add(CatalogItem(
        title: cartoon.title,
        subtitle: cartoon.learningGoal,
        route: '/cartoon/${cartoon.id}',
        emoji: cartoon.coverEmoji,
        category: 'کارتون',
        tags: [cartoon.categoryLabel, cartoon.englishTitle],
      ));
    }
    for (final topic in LifeSkillsData.topics) {
      items.add(CatalogItem(
        title: topic.title,
        subtitle: topic.subtitle,
        route: '/life-skills/${topic.id}',
        emoji: topic.emoji,
        category: 'مهارت زندگی',
        tags: topic.tags,
      ));
    }
    return items;
  }

  static List<CatalogItem> query(String raw) {
    final q = raw.trim().toLowerCase();
    if (q.isEmpty) return allItems().take(12).toList();
    return allItems().where((item) {
      final hay = [
        item.title,
        item.subtitle,
        item.category,
        ...item.tags,
      ].join(' ').toLowerCase();
      return hay.contains(q);
    }).toList();
  }
}
