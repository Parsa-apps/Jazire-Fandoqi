/// جدا کردن قصه برای «بخوان و بشنو» — جمله، بعد کلمه، هماهنگ با صدا.
class StoryReadAlong {
  StoryReadAlong._();

  static List<String> sentences(String text) {
    final clean = text.replaceAll('\r\n', '\n').replaceAll('\r', '\n').trim();
    if (clean.isEmpty) return const <String>[];
    if (clean.contains('\n')) {
      final explicit = clean
          .split('\n')
          .map((line) => line.trim())
          .where((line) => line.isNotEmpty)
          .toList();
      if (explicit.length > 1) return explicit;
    }

    final chunks = <String>[];
    final buffer = StringBuffer();
    for (final rune in clean.runes) {
      final ch = String.fromCharCode(rune);
      buffer.write(ch);
      if (ch == '.' || ch == '!' || ch == '?' || ch == '؟' || ch == '!') {
        final piece = buffer.toString().trim();
        if (piece.isNotEmpty) chunks.add(piece);
        buffer.clear();
      }
    }
    final tail = buffer.toString().trim();
    if (tail.isNotEmpty) chunks.add(tail);

    final merged = <String>[];
    for (final chunk in chunks) {
      if (merged.isNotEmpty && chunk.length < 12) {
        merged[merged.length - 1] = '${merged.last} $chunk';
      } else {
        merged.add(chunk);
      }
    }
    return merged.isEmpty ? <String>[clean] : merged;
  }

  static List<String> words(String sentence) {
    return sentence
        .split(RegExp(r'\s+'))
        .map((w) => w.trim())
        .where((w) => w.isNotEmpty)
        .toList();
  }

  static int activeIndex(List<String> parts, double progress) {
    if (parts.isEmpty) return 0;
    if (progress <= 0) return 0;
    if (progress >= 0.98) return parts.length - 1;
    final weights = parts.map((p) => p.length + 8).toList();
    final total = weights.fold<int>(0, (a, b) => a + b);
    if (total == 0) return 0;
    var seen = 0;
    for (var i = 0; i < parts.length; i++) {
      seen += weights[i];
      if (progress < seen / total) return i;
    }
    return parts.length - 1;
  }

  static double localProgress(List<String> parts, double progress, int index) {
    if (parts.isEmpty || index < 0 || index >= parts.length) return 0;
    final weights = parts.map((p) => p.length + 8).toList();
    final total = weights.fold<int>(0, (a, b) => a + b);
    if (total == 0) return 0;
    var before = 0;
    for (var i = 0; i < index; i++) {
      before += weights[i];
    }
    final start = before / total;
    final end = (before + weights[index]) / total;
    if (end <= start) return 0;
    return ((progress - start) / (end - start)).clamp(0.0, 1.0);
  }
}
