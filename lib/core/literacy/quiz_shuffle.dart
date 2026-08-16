import 'dart:math';

/// گزینه‌ها را قاطی می‌کند تا کودک یاد نگیرد «همیشه اولی درست است».
class ShuffledChoices {
  final List<String> options;
  final int correctIndex;

  const ShuffledChoices({required this.options, required this.correctIndex});

  static ShuffledChoices of(
    List<String> options,
    int correctIndex, {
    Random? random,
  }) {
    if (options.isEmpty) {
      return const ShuffledChoices(options: [], correctIndex: 0);
    }
    final safe = correctIndex.clamp(0, options.length - 1);
    final pairs = <(String, bool)>[
      for (var i = 0; i < options.length; i++) (options[i], i == safe),
    ]..shuffle(random ?? Random());
    return ShuffledChoices(
      options: pairs.map((p) => p.$1).toList(),
      correctIndex: pairs.indexWhere((p) => p.$2),
    );
  }
}
