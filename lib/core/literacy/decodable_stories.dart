import 'package:flutter/material.dart';

import '../game_data.dart';
import '../learning_content/children_stories_data.dart';

/// قصهٔ کوتاه کلاس اول: فقط با نشانه‌هایی که کودک مهر زده.
class DecodableStory {
  final String id;
  final String title;
  final String emoji;
  final String requiredKey;
  final Set<String> allowedLetters;
  final List<String> pages;
  final String newWord;
  final String question;
  final List<StoryQuizQuestion> quiz;

  const DecodableStory({
    required this.id,
    required this.title,
    required this.emoji,
    required this.requiredKey,
    required this.allowedLetters,
    required this.pages,
    required this.newWord,
    required this.question,
    required this.quiz,
  });

  ChildrenStory toChildrenStory() {
    final color = _themeFor(id);
    return ChildrenStory(
      id: id,
      title: title,
      subtitle: 'با نشانه‌هایی که نوشتی',
      description: pages.join(' '),
      coverEmoji: emoji,
      category: StoryCategoryType.morals,
      categoryLabel: 'بخوان کلاس اول',
      readingTime: '۱ دقیقه',
      moralMessage: 'آفرین! خودت خواندی.',
      themeColor: color,
      gradient: LinearGradient(
        colors: [color, color.withOpacity(0.65)],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ),
      pages: [
        for (var i = 0; i < pages.length; i++)
          ChildrenStoryPage(
            pageNumber: i + 1,
            title: title,
            text: pages[i],
            fallbackEmoji: emoji,
            interactiveQuestion: question,
            goldenWords: i == 0
                ? [
                    StoryVocabularyWord(
                      word: newWord,
                      emoji: emoji,
                      meaning: 'این کلمه را خودت بخوان.',
                    ),
                  ]
                : const [],
          ),
      ],
      quizQuestions: quiz,
    );
  }
}

/// متن قابل‌خواندن کتاب اول — نه قصهٔ چهار دقیقه‌ای برای مادر.
class DecodableStories {
  DecodableStories._();

  static const String idPrefix = 'decodable-';

  static bool isDecodableId(String id) => id.startsWith(idPrefix);

  static const List<DecodableStory> all = _stories;

  static DecodableStory? byId(String id) {
    for (final story in _stories) {
      if (story.id == id) return story;
    }
    return null;
  }

  /// پیشرفته‌ترین قصهٔ بازِ نخوانده؛ اگر همه را خوانده، همان آخری را مرور می‌کند.
  static DecodableStory forToday({Iterable<String>? masteredKeys}) {
    final unlocked = unlockedStories(masteredKeys: masteredKeys);
    if (unlocked.isEmpty) return _stories.first;
    for (var i = unlocked.length - 1; i >= 0; i--) {
      if (!GameData.hasCompletedStory(unlocked[i].id)) return unlocked[i];
    }
    return unlocked.last;
  }

  static List<DecodableStory> unlockedStories({Iterable<String>? masteredKeys}) {
    return [
      for (final story in _stories)
        if (isUnlocked(story, masteredKeys: masteredKeys)) story,
    ];
  }

  static bool isUnlocked(
    DecodableStory story, {
    Iterable<String>? masteredKeys,
  }) {
    final keys = (masteredKeys ?? GameData.masteredAlphabetKeys).toSet();
    if (keys.contains(story.requiredKey)) return true;
    final known = lettersFromKeys(keys);
    if (known.isEmpty) return false;
    return story.allowedLetters.every(known.contains);
  }

  /// نویسه‌های فارسی متن — بدون حرکت، کشیده، فاصله و ایموجی.
  static Set<String> lettersIn(String raw) {
    final out = <String>{};
    for (final rune in raw.runes) {
      final ch = String.fromCharCode(rune);
      if (_ignore.hasMatch(ch)) continue;
      final mapped = _normalize[ch] ?? ch;
      if (mapped.isEmpty) continue;
      if (_persianLetter.hasMatch(mapped)) out.add(mapped);
    }
    return out;
  }

  static bool usesOnly(String raw, Set<String> allowed) {
    return lettersIn(raw).every(allowed.contains);
  }

  static Set<String> lettersFromKeys(Iterable<String> keys) {
    final out = <String>{};
    for (final key in keys) {
      final mapped = _lettersByKey[key];
      if (mapped != null) {
        out.addAll(mapped);
        continue;
      }
      if (key.startsWith('alpha-')) {
        final index = int.tryParse(key.substring(6));
        if (index != null && index >= 0 && index < _alphaLetters.length) {
          out.add(_alphaLetters[index]);
        }
      }
    }
    return out;
  }
}

final _ignore = RegExp(
  r'[\s\u200c\u200d\u0640\u064b-\u0652\u0670\u06C0.,!؟?،؛:«»"\u2018\u2019()\[\]0-9۰-۹\-…]+',
);

final _persianLetter = RegExp(
  r'^[آابپتثجچحخدذرزژسشصضطظعغفقکگلمنوهی]$',
);

const _normalize = <String, String>{
  'ي': 'ی',
  'ى': 'ی',
  'ك': 'ک',
  'ة': 'ه',
  'ۀ': 'ه',
  'ؤ': 'و',
  'ئ': 'ی',
  'أ': 'ا',
  'إ': 'ا',
  'ء': '',
};

/// کلید درس کتاب اول → نشانه‌هایی که بعد از مهر آن درس خواندنی‌اند.
const _lettersByKey = <String, Set<String>>{
  'g1-0-0': {'آ', 'ا'},
  'g1-0-1': {'ب'},
  'g1-0-2': {'ا'},
  'g1-0-3': {'د'},
  'g1-1-0': {'م'},
  'g1-1-1': {'س'},
  'g1-1-2': {'و'},
  'g1-1-3': {'ت'},
  'g1-2-0': {'ر'},
  'g1-2-1': {'ن'},
  'g1-2-2': {'ی'},
  'g1-2-3': {'ز'},
  'g1-3-0': {'ه'},
  'g1-3-1': {'ش'},
  'g1-3-2': {'ی'},
  'g1-3-3': {'ا'},
  'g1-4-0': {'ک'},
  'g1-4-1': {'و'},
  'g1-4-2': {'پ'},
  'g1-4-3': {'گ'},
  'g1-5-0': {'ف'},
  'g1-5-1': {'خ'},
  'g1-5-2': {'ق'},
  'g1-5-3': {'ل'},
  'g1-6-0': {'ج'},
  'g1-6-1': {'خ', 'و', 'ا'},
  'g1-6-2': {'چ'},
  'g1-6-3': {'ه'},
  'g1-6-4': {'ژ'},
  'g1-7-0': {'ص'},
  'g1-7-1': {'ذ'},
  'g1-7-2': {'ع'},
  'g1-7-3': {'ث'},
  'g1-7-4': {'ح'},
  'g1-7-5': {'ض'},
  'g1-7-6': {'ط'},
  'g1-7-7': {'غ'},
  'g1-7-8': {'ظ'},
};

const _alphaLetters = <String>[
  'آ', 'ا', 'ب', 'پ', 'ت', 'ث', 'ج', 'چ', 'ح', 'خ',
  'د', 'ذ', 'ر', 'ز', 'ژ', 'س', 'ش', 'ص', 'ض', 'ط',
  'ظ', 'ع', 'غ', 'ف', 'ق', 'ک', 'گ', 'ل', 'م', 'ن',
  'و', 'ه', 'ی',
];

const _ab = {'آ', 'ا', 'ب'};
const _abd = {'آ', 'ا', 'ب', 'د'};
const _abdm = {'آ', 'ا', 'ب', 'د', 'م'};
const _abdms = {'آ', 'ا', 'ب', 'د', 'م', 'س'};
const _abdmso = {'آ', 'ا', 'ب', 'د', 'م', 'س', 'و'};
const _abdmsot = {'آ', 'ا', 'ب', 'د', 'م', 'س', 'و', 'ت'};
const _toR = {'آ', 'ا', 'ب', 'د', 'م', 'س', 'و', 'ت', 'ر'};
const _toN = {'آ', 'ا', 'ب', 'د', 'م', 'س', 'و', 'ت', 'ر', 'ن'};
const _toY = {'آ', 'ا', 'ب', 'د', 'م', 'س', 'و', 'ت', 'ر', 'ن', 'ی'};
const _toZ = {'آ', 'ا', 'ب', 'د', 'م', 'س', 'و', 'ت', 'ر', 'ن', 'ی', 'ز'};
const _toSh = {'آ', 'ا', 'ب', 'د', 'م', 'س', 'و', 'ت', 'ر', 'ن', 'ی', 'ز', 'ش'};
const _toG = {
  'آ', 'ا', 'ب', 'د', 'م', 'س', 'و', 'ت', 'ر', 'ن', 'ی', 'ز', 'ش', 'ک', 'پ', 'گ',
};

const List<DecodableStory> _stories = [
  DecodableStory(
    id: 'decodable-baba-ab',
    title: 'بابا آب',
    emoji: '💧',
    requiredKey: 'g1-0-1',
    allowedLetters: _ab,
    pages: ['بابا آب.', 'آب بابا.'],
    newWord: 'آب',
    question: 'بابا آب؟',
    quiz: [
      StoryQuizQuestion(
        question: 'بابا چه داشت؟',
        options: ['آب 💧', 'توت 🍓', 'نان 🍞'],
        correctIndex: 0,
        explanation: 'آفرین! بابا آب.',
      ),
      StoryQuizQuestion(
        question: 'کی آب داشت؟',
        options: ['مادر 👩', 'بابا 👨', 'سگ 🐕'],
        correctIndex: 1,
        explanation: 'بله، بابا آب داشت.',
      ),
    ],
  ),
  DecodableStory(
    id: 'decodable-baba-dad',
    title: 'بابا آب داد',
    emoji: '✋',
    requiredKey: 'g1-0-3',
    allowedLetters: _abd,
    pages: ['بابا آب داد.', 'بابا باد داد.'],
    newWord: 'داد',
    question: 'بابا آب داد؟',
    quiz: [
      StoryQuizQuestion(
        question: 'بابا چه داد؟',
        options: ['سیب 🍏', 'آب 💧', 'نان 🍞'],
        correctIndex: 1,
        explanation: 'آفرین! بابا آب داد.',
      ),
      StoryQuizQuestion(
        question: 'بابا باد داد؟',
        options: ['بله ✅', 'نه ❌', 'نمی‌دانم'],
        correctIndex: 0,
        explanation: 'بله، بابا باد داد.',
      ),
    ],
  ),
  DecodableStory(
    id: 'decodable-amad',
    title: 'بابا آمد',
    emoji: '🚪',
    requiredKey: 'g1-1-0',
    allowedLetters: _abdm,
    pages: ['بابا آمد.', 'آب آمد.'],
    newWord: 'آمد',
    question: 'بابا آمد؟',
    quiz: [
      StoryQuizQuestion(
        question: 'کی آمد؟',
        options: ['سگ 🐕', 'بابا 👨', 'فیل 🐘'],
        correctIndex: 1,
        explanation: 'بابا آمد.',
      ),
      StoryQuizQuestion(
        question: 'آب آمد؟',
        options: ['بله ✅', 'نه ❌', 'نمی‌دانم'],
        correctIndex: 0,
        explanation: 'بله، آب آمد.',
      ),
    ],
  ),
  DecodableStory(
    id: 'decodable-sabad',
    title: 'بابا سبد داد',
    emoji: '🧺',
    requiredKey: 'g1-1-1',
    allowedLetters: _abdms,
    pages: ['بابا سبد داد.', 'سبد آمد.'],
    newWord: 'سبد',
    question: 'بابا سبد داد؟',
    quiz: [
      StoryQuizQuestion(
        question: 'بابا چه داد؟',
        options: ['توت 🍓', 'سبد 🧺', 'شیر 🥛'],
        correctIndex: 1,
        explanation: 'بابا سبد داد.',
      ),
      StoryQuizQuestion(
        question: 'سبد آمد؟',
        options: ['نه ❌', 'بله ✅', 'شاید'],
        correctIndex: 1,
        explanation: 'بله، سبد آمد.',
      ),
    ],
  ),
  DecodableStory(
    id: 'decodable-oo-amad',
    title: 'او آمد',
    emoji: '👋',
    requiredKey: 'g1-1-2',
    allowedLetters: _abdmso,
    pages: ['او آمد.', 'بابا آب داد.'],
    newWord: 'او',
    question: 'او آمد؟',
    quiz: [
      StoryQuizQuestion(
        question: 'کی آمد؟',
        options: ['او 👋', 'فیل 🐘', 'ماه 🌙'],
        correctIndex: 0,
        explanation: 'او آمد.',
      ),
      StoryQuizQuestion(
        question: 'بابا چه داد؟',
        options: ['نان 🍞', 'آب 💧', 'گل 🌷'],
        correctIndex: 1,
        explanation: 'بابا آب داد.',
      ),
    ],
  ),
  DecodableStory(
    id: 'decodable-tut',
    title: 'بابا توت داد',
    emoji: '🍓',
    requiredKey: 'g1-1-3',
    allowedLetters: _abdmsot,
    pages: ['بابا توت داد.', 'دوست آمد.'],
    newWord: 'توت',
    question: 'بابا توت داد؟',
    quiz: [
      StoryQuizQuestion(
        question: 'بابا چه داد؟',
        options: ['نان 🍞', 'شیر 🥛', 'توت 🍓'],
        correctIndex: 2,
        explanation: 'بابا توت داد.',
      ),
      StoryQuizQuestion(
        question: 'کی آمد؟',
        options: ['دوست 🤝', 'خرس 🐻', 'فیل 🐘'],
        correctIndex: 0,
        explanation: 'دوست آمد.',
      ),
    ],
  ),
  DecodableStory(
    id: 'decodable-abr',
    title: 'مادر آمد',
    emoji: '👩',
    requiredKey: 'g1-2-0',
    allowedLetters: _toR,
    pages: ['مادر آمد.', 'ابر آمد.'],
    newWord: 'مادر',
    question: 'مادر آمد؟',
    quiz: [
      StoryQuizQuestion(
        question: 'کی آمد؟',
        options: ['مادر 👩', 'شیر 🦁', 'فیل 🐘'],
        correctIndex: 0,
        explanation: 'مادر آمد.',
      ),
      StoryQuizQuestion(
        question: 'ابر آمد؟',
        options: ['نه ❌', 'بله ✅', 'نمی‌دانم'],
        correctIndex: 1,
        explanation: 'بله، ابر آمد.',
      ),
    ],
  ),
  DecodableStory(
    id: 'decodable-baran',
    title: 'باران آمد',
    emoji: '🌧️',
    requiredKey: 'g1-2-1',
    allowedLetters: _toN,
    pages: ['نان آمد.', 'باران آمد.'],
    newWord: 'باران',
    question: 'باران آمد؟',
    quiz: [
      StoryQuizQuestion(
        question: 'چه آمد؟',
        options: ['شیر 🦁', 'باران 🌧️', 'ماه 🌙'],
        correctIndex: 1,
        explanation: 'باران آمد.',
      ),
      StoryQuizQuestion(
        question: 'نان آمد؟',
        options: ['بله ✅', 'نه ❌', 'شاید'],
        correctIndex: 0,
        explanation: 'بله، نان آمد.',
      ),
    ],
  ),
  DecodableStory(
    id: 'decodable-iran',
    title: 'نان ایران',
    emoji: '🇮🇷',
    requiredKey: 'g1-2-2',
    allowedLetters: _toY,
    pages: ['سیب آمد.', 'نان ایران آمد.'],
    newWord: 'ایران',
    question: 'نان ایران آمد؟',
    quiz: [
      StoryQuizQuestion(
        question: 'چه میوه‌ای آمد؟',
        options: ['سیب 🍏', 'موز 🍌', 'انگور 🍇'],
        correctIndex: 0,
        explanation: 'سیب آمد.',
      ),
      StoryQuizQuestion(
        question: 'نان کجا آمد؟',
        options: ['ماه 🌙', 'ایران 🇮🇷', 'دریا 🌊'],
        correctIndex: 1,
        explanation: 'نان ایران آمد.',
      ),
    ],
  ),
  DecodableStory(
    id: 'decodable-sabz',
    title: 'نان سبز است',
    emoji: '🟢',
    requiredKey: 'g1-2-3',
    allowedLetters: _toZ,
    pages: ['نان ایران سبز است.', 'نان زرد است.'],
    newWord: 'سبز',
    question: 'نان سبز است؟',
    quiz: [
      StoryQuizQuestion(
        question: 'نان ایران چه رنگی است؟',
        options: ['آبی 💙', 'سبز 🟢', 'سیاه ⚫'],
        correctIndex: 1,
        explanation: 'نان ایران سبز است.',
      ),
      StoryQuizQuestion(
        question: 'نان زرد است؟',
        options: ['بله ✅', 'نه ❌', 'نمی‌دانم'],
        correctIndex: 0,
        explanation: 'بله، نان زرد است.',
      ),
    ],
  ),
  DecodableStory(
    id: 'decodable-shir',
    title: 'شیر آمد',
    emoji: '🦁',
    requiredKey: 'g1-3-1',
    allowedLetters: _toSh,
    pages: ['شیر آمد.', 'شیر در آب است.'],
    newWord: 'شیر',
    question: 'شیر آمد؟',
    quiz: [
      StoryQuizQuestion(
        question: 'کی آمد؟',
        options: ['فیل 🐘', 'شیر 🦁', 'ماه 🌙'],
        correctIndex: 1,
        explanation: 'شیر آمد.',
      ),
      StoryQuizQuestion(
        question: 'شیر کجاست؟',
        options: ['در آب 💧', 'در ماه 🌙', 'در آتش 🔥'],
        correctIndex: 0,
        explanation: 'شیر در آب است.',
      ),
    ],
  ),
  DecodableStory(
    id: 'decodable-pa-pak',
    title: 'پا پاک است',
    emoji: '🦶',
    requiredKey: 'g1-4-3',
    allowedLetters: _toG,
    pages: ['پا پاک است.', 'سگ آمد.'],
    newWord: 'پاک',
    question: 'پا پاک است؟',
    quiz: [
      StoryQuizQuestion(
        question: 'پا چگونه است؟',
        options: ['پاک ✨', 'زرد 💛', 'سرد ❄️'],
        correctIndex: 0,
        explanation: 'پا پاک است.',
      ),
      StoryQuizQuestion(
        question: 'کی آمد؟',
        options: ['فیل 🐘', 'سگ 🐕', 'ماه 🌙'],
        correctIndex: 1,
        explanation: 'سگ آمد.',
      ),
    ],
  ),
];

Color _themeFor(String id) {
  const colors = <Color>[
    Color(0xFF1E88E5),
    Color(0xFF43A047),
    Color(0xFF8E24AA),
    Color(0xFFFB8C00),
    Color(0xFF00897B),
    Color(0xFFE53935),
    Color(0xFF5E35B1),
    Color(0xFF039BE5),
    Color(0xFF7CB342),
    Color(0xFFD81B60),
    Color(0xFF6D4C41),
    Color(0xFF3949AB),
  ];
  var hash = 0;
  for (final unit in id.codeUnits) {
    hash = (hash + unit) & 0x7fffffff;
  }
  return colors[hash % colors.length];
}
