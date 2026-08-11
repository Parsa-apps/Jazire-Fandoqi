import 'growth_store.dart';

/// رویدادهای محلی و بدون شبکه — فقط برای گزارش والد و دیباگ سازنده.
class OfflineAnalytics {
  OfflineAnalytics._();

  static void touch() {}

  static void event(String name, [Map<String, Object?> props = const {}]) {
    final row = <String, Object?>{
      'name': name,
      'at': DateTime.now().toIso8601String(),
      ...props,
    };
    final list = List<Map<String, Object?>>.from(GrowthStore.localEvents);
    list.insert(0, row);
    if (list.length > 200) list.removeRange(200, list.length);
    GrowthStore.localEvents = list;
  }

  static int count(String name) =>
      GrowthStore.localEvents.where((e) => e['name'] == name).length;

  static Map<String, int> summary() {
    final map = <String, int>{};
    for (final e in GrowthStore.localEvents) {
      final name = e['name']?.toString() ?? 'other';
      map[name] = (map[name] ?? 0) + 1;
    }
    return map;
  }
}
