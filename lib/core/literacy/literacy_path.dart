/// مسیر سواد اول دبستان: صدا → هجا → کلمه → جمله + مرور فاصله‌دار.
class LiteracyUnit {
  final String letter;
  final String soundHint;
  final String syllable;
  final String word;
  final String sentence;

  const LiteracyUnit({
    required this.letter,
    required this.soundHint,
    required this.syllable,
    required this.word,
    required this.sentence,
  });

  /// واحد درس از روی نشانه و کلمهٔ نمونهٔ همان درس.
  static LiteracyUnit forLesson(String letter, String word) {
    final key = firstLetter(letter);
    return _units[key] ??
        LiteracyUnit(
          letter: letter,
          soundHint: 'صدای «$key»',
          syllable: key,
          word: word,
          sentence: '$word را بخوان.',
        );
  }

  /// واژه‌های املا از خودِ مسیر سواد — نه میوه و نه ایموجی.
  static List<String> dictationWords() {
    final seen = <String>{};
    final words = <String>[];
    for (final unit in _units.values) {
      final word = unit.word.trim();
      if (word.length >= 2 && seen.add(word)) words.add(word);
    }
    return words;
  }

  /// کلید پایدار نشانه — «او و» باید «او» شود نه «ا».
  static String firstLetter(String raw) {
    final clean = raw.replaceAll('ـ', '').trim();
    if (clean.isEmpty) return 'ا';
    if (clean.startsWith('آ')) return 'آ';
    if (clean.startsWith('اَ') || clean.startsWith('اِ') || clean.startsWith('اُ')) {
      return clean.substring(0, 2);
    }
    if (clean.startsWith('او')) return 'او';
    if (clean.startsWith('ای')) return 'ای';
    if (clean.startsWith('خوا')) return 'خوا';
    return clean.substring(0, 1);
  }
}

const Map<String, LiteracyUnit> _units = <String, LiteracyUnit>{
  'آ': LiteracyUnit(letter: 'آ', soundHint: 'آ مثل آب', syllable: 'آ', word: 'آب', sentence: 'بابا آب داد.'),
  'ا': LiteracyUnit(letter: 'ا', soundHint: 'ا مثل ابر', syllable: 'اَ', word: 'ابر', sentence: 'ابر آمد.'),
  'اَ': LiteracyUnit(letter: 'اَ', soundHint: 'اَ مثل انار', syllable: 'اَن', word: 'انار', sentence: 'انار سرخ است.'),
  'ب': LiteracyUnit(letter: 'ب', soundHint: 'ب مثل بابا', syllable: 'با', word: 'بابا', sentence: 'بابا آب داد.'),
  'د': LiteracyUnit(letter: 'د', soundHint: 'د مثل دست', syllable: 'دَ', word: 'دست', sentence: 'بابا دست داد.'),
  'م': LiteracyUnit(letter: 'م', soundHint: 'م مثل مادر', syllable: 'ما', word: 'مادر', sentence: 'مادر آمد.'),
  'س': LiteracyUnit(letter: 'س', soundHint: 'س مثل سیب', syllable: 'سی', word: 'سیب', sentence: 'سیب سرخ است.'),
  'او': LiteracyUnit(letter: 'او', soundHint: 'او مثل توت', syllable: 'تو', word: 'توت', sentence: 'بابا توت داد.'),
  'و': LiteracyUnit(letter: 'و', soundHint: 'و مثل ورزش', syllable: 'وَ', word: 'ورزش', sentence: 'او آمد.'),
  'ت': LiteracyUnit(letter: 'ت', soundHint: 'ت مثل تاب', syllable: 'تا', word: 'تاب', sentence: 'بابا توت داد.'),
  'ر': LiteracyUnit(letter: 'ر', soundHint: 'ر مثل رنگ', syllable: 'رَ', word: 'رنگ', sentence: 'ابر آمد.'),
  'ن': LiteracyUnit(letter: 'ن', soundHint: 'ن مثل نان', syllable: 'نا', word: 'نان', sentence: 'نان ایران سبز است.'),
  'ای': LiteracyUnit(letter: 'ای', soundHint: 'ای مثل ایران', syllable: 'ای', word: 'ایران', sentence: 'نان ایران سبز است.'),
  'ی': LiteracyUnit(letter: 'ی', soundHint: 'ی مثل یاس', syllable: 'یا', word: 'یاس', sentence: 'یاس زیباست.'),
  'ز': LiteracyUnit(letter: 'ز', soundHint: 'ز مثل زرد', syllable: 'زَ', word: 'زرد', sentence: 'نان ایران سبز است.'),
  'اِ': LiteracyUnit(letter: 'اِ', soundHint: 'اِ مثل امروز', syllable: 'اِم', word: 'امروز', sentence: 'شیر در دریا است.'),
  'ش': LiteracyUnit(letter: 'ش', soundHint: 'ش مثل شیر', syllable: 'شی', word: 'شیر', sentence: 'شیر در دریا است.'),
  'اُ': LiteracyUnit(letter: 'اُ', soundHint: 'اُ مثل اردک', syllable: 'اُر', word: 'اردک', sentence: 'اردک آمد.'),
  'ک': LiteracyUnit(letter: 'ک', soundHint: 'ک مثل کفش', syllable: 'کَ', word: 'کفش', sentence: 'پا پاک است.'),
  'پ': LiteracyUnit(letter: 'پ', soundHint: 'پ مثل پا', syllable: 'پا', word: 'پا', sentence: 'پا پاک است.'),
  'گ': LiteracyUnit(letter: 'گ', soundHint: 'گ مثل گل', syllable: 'گُ', word: 'گل', sentence: 'گل پاک است.'),
  'ف': LiteracyUnit(letter: 'ف', soundHint: 'ف مثل فیل', syllable: 'فی', word: 'فیل', sentence: 'فیل در برف است.'),
  'خ': LiteracyUnit(letter: 'خ', soundHint: 'خ مثل خرس', syllable: 'خِ', word: 'خرس', sentence: 'خرس آمد.'),
  'ق': LiteracyUnit(letter: 'ق', soundHint: 'ق مثل قاشق', syllable: 'قا', word: 'قاشق', sentence: 'قاشق اینجاست.'),
  'ل': LiteracyUnit(letter: 'ل', soundHint: 'ل مثل لب', syllable: 'لَ', word: 'لب', sentence: 'فیل در برف است.'),
  'ج': LiteracyUnit(letter: 'ج', soundHint: 'ج مثل جوجه', syllable: 'جو', word: 'جوجه', sentence: 'جوجه در هوا است.'),
  'خوا': LiteracyUnit(letter: 'خوا', soundHint: 'خوا مثل خواب', syllable: 'خوا', word: 'خواب', sentence: 'خواهر آمد.'),
  'چ': LiteracyUnit(letter: 'چ', soundHint: 'چ مثل چتر', syllable: 'چَ', word: 'چتر', sentence: 'چتر اینجاست.'),
  'ه': LiteracyUnit(letter: 'ه', soundHint: 'ه مثل هوا', syllable: 'هَ', word: 'هوا', sentence: 'جوجه در هوا است.'),
  'هـ': LiteracyUnit(letter: 'هـ', soundHint: 'ه مثل هوا', syllable: 'هَ', word: 'هوا', sentence: 'جوجه در هوا است.'),
  'ژ': LiteracyUnit(letter: 'ژ', soundHint: 'ژ مثل ژاله', syllable: 'ژا', word: 'ژاله', sentence: 'ژاله آمد.'),
  'ص': LiteracyUnit(letter: 'ص', soundHint: 'ص مثل صابون', syllable: 'صا', word: 'صابون', sentence: 'صابون اینجاست.'),
  'ذ': LiteracyUnit(letter: 'ذ', soundHint: 'ذ مثل ذرت', syllable: 'ذُ', word: 'ذرت', sentence: 'ذرت زرد است.'),
  'ع': LiteracyUnit(letter: 'ع', soundHint: 'ع مثل عسل', syllable: 'عَ', word: 'عسل', sentence: 'عسل در ظرف است.'),
  'ث': LiteracyUnit(letter: 'ث', soundHint: 'ث مثل ثانیه', syllable: 'ثا', word: 'ثانیه', sentence: 'یک ثانیه صبر کن.'),
  'ح': LiteracyUnit(letter: 'ح', soundHint: 'ح مثل حباب', syllable: 'حُ', word: 'حباب', sentence: 'حباب آمد.'),
  'ض': LiteracyUnit(letter: 'ض', soundHint: 'ض مثل ضربه', syllable: 'ضَ', word: 'ضربه', sentence: 'یک ضربه بزن.'),
  'ط': LiteracyUnit(letter: 'ط', soundHint: 'ط مثل طبل', syllable: 'طَ', word: 'طبل', sentence: 'طبل را بزن.'),
  'غ': LiteracyUnit(letter: 'غ', soundHint: 'غ مثل غاز', syllable: 'غا', word: 'غاز', sentence: 'غاز آمد.'),
  'ظ': LiteracyUnit(letter: 'ظ', soundHint: 'ظ مثل ظرف', syllable: 'ظَ', word: 'ظرف', sentence: 'عسل در ظرف است.'),
};

/// مرور فاصله‌دار معلم کلاس اول: ۱ روز، ۳ روز، سپس ۷ روز.
class AlphabetReview {
  AlphabetReview._();

  static const int fluentPassCount = 3;

  static int gapDaysFor(int passCount) {
    if (passCount <= 0) return 0;
    if (passCount == 1) return 1;
    if (passCount == 2) return 3;
    return 7;
  }

  static bool isDue({
    required int passCount,
    required String lastDay,
    required String today,
  }) {
    if (passCount <= 0 || lastDay.isEmpty) return false;
    final last = DateTime.tryParse(lastDay);
    final now = DateTime.tryParse(today);
    if (last == null || now == null) return false;
    final elapsed = DateTime(now.year, now.month, now.day)
        .difference(DateTime(last.year, last.month, last.day))
        .inDays;
    return elapsed >= gapDaysFor(passCount);
  }
}

/// چهار پلهٔ اجباری روی کارت درس: صدا → هجا → کلمه، بعد نوشتن؛ جمله بعد از قبولی.
class LiteracyLadder {
  static const int sound = 0;
  static const int syllable = 1;
  static const int word = 2;
  static const int sentence = 3;
  static const int stepCount = 4;
  static const int stepsBeforeWrite = 3;

  static const List<String> labels = <String>['صدا', 'هجا', 'کلمه', 'جمله'];

  int heardCount = 0;

  bool isHeard(int step) => step >= 0 && step < heardCount;

  /// فقط پلهٔ جاری باز است؛ پریدن ممنوع.
  bool canHear(int step) => step == heardCount && step < stepCount;

  bool get canWrite => heardCount >= stepsBeforeWrite;

  bool get finished => heardCount >= stepCount;

  bool hear(int step) {
    if (!canHear(step)) return false;
    heardCount++;
    return true;
  }

  void reset() => heardCount = 0;
}
