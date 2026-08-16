import '../game_data.dart';
import 'growth_store.dart';

/// تا ۳ پروفایل کودک روی یک گوشی — تعویض با ذخیرهٔ پیشرفت جدا.
class SiblingProfiles {
  SiblingProfiles._();

  static const int maxSiblings = 3;

  static List<Map<String, Object?>> get all => GrowthStore.siblings;

  static String get activeId => GrowthStore.activeSiblingId;

  static Map<String, Object?> get active {
    for (final s in GrowthStore.siblings) {
      if (s['id'] == activeId) return s;
    }
    return GrowthStore.siblings.first;
  }

  static bool add({
    required String name,
    required int age,
    String avatar = '🧒',
  }) {
    if (GrowthStore.siblings.length >= maxSiblings) return false;
    final trimmed = name.trim();
    if (trimmed.isEmpty) return false;
    final id = 'sib_${DateTime.now().millisecondsSinceEpoch}';
    GrowthStore.siblings = [
      ...GrowthStore.siblings,
      <String, Object?>{
        'id': id,
        'name': trimmed.substring(0, trimmed.length.clamp(0, 24)),
        'age': age.clamp(3, 12),
        'avatar': avatar,
      },
    ];
    GrowthStore.save();
    GrowthStore.changes.bump();
    return true;
  }

  static bool switchTo(String id) {
    if (id == GrowthStore.activeSiblingId) return true;
    final exists = GrowthStore.siblings.any((s) => s['id'] == id);
    if (!exists) return false;

    // ذخیره پیشرفت کودک فعلی
    GrowthStore.siblingSnapshots[GrowthStore.activeSiblingId] =
        GameData.exportChildProgress();

    final incoming = GrowthStore.siblingSnapshots[id];
    GrowthStore.activeSiblingId = id;
    if (incoming != null && incoming.isNotEmpty) {
      GameData.importChildProgress(incoming);
    } else {
      GameData.resetChildProgressKeepingParent();
      final meta = GrowthStore.siblings.firstWhere((s) => s['id'] == id);
      GameData.updateProfile(
        name: meta['name']?.toString() ?? '',
        avatarIcon: meta['avatar']?.toString(),
      );
      GameData.childAge = (meta['age'] is num)
          ? (meta['age'] as num).toInt().clamp(3, 12)
          : 5;
    }
    _syncMetaFromGame();
    GrowthStore.save();
    GrowthStore.changes.bump();
    return true;
  }

  static void _syncMetaFromGame() => syncActiveMeta();

  /// به‌روزرسانی فراداده‌ی کودک فعال (نام، سن، آواتار) از GameData.
  /// وقتی والد مستقیماً پروفایل را ویرایش می‌کند صدا زده می‌شود.
  static void syncActiveMeta() {
    GrowthStore.siblings = GrowthStore.siblings.map((s) {
      if (s['id'] != GrowthStore.activeSiblingId) return s;
      return <String, Object?>{
        ...s,
        'name': GameData.childName,
        'age': GameData.childAge,
        'avatar': GameData.avatar,
      };
    }).toList();
    GrowthStore.save();
    GrowthStore.changes.bump();
  }
}
