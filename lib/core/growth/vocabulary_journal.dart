import 'growth_store.dart';

/// دفترچه واژه‌های طلایی که کودک در قصه و مهارت زندگی یاد گرفته.
class VocabularyJournal {
  VocabularyJournal._();

  static List<String> get words => List<String>.unmodifiable(GrowthStore.vocabWords);

  static bool add(String word) {
    final clean = word.trim();
    if (clean.isEmpty || clean.length > 32) return false;
    if (GrowthStore.vocabWords.contains(clean)) return false;
    GrowthStore.vocabWords = [...GrowthStore.vocabWords, clean];
    GrowthStore.save();
    GrowthStore.changes.bump();
    return true;
  }

  static void addAll(Iterable<String> items) {
    var changed = false;
    final next = List<String>.from(GrowthStore.vocabWords);
    for (final item in items) {
      final clean = item.trim();
      if (clean.isEmpty || clean.length > 32 || next.contains(clean)) continue;
      next.add(clean);
      changed = true;
    }
    if (!changed) return;
    GrowthStore.vocabWords = next;
    GrowthStore.save();
    GrowthStore.changes.bump();
  }

  static int get count => GrowthStore.vocabWords.length;
}
