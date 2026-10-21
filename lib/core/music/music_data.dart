import 'package:flutter/material.dart';

/// 🎵 دادگانِ استودیوی موسیقی فندقی
///
/// همهٔ نت‌ها و صداهای کوبندهٔ این استودیو به‌صورت فایل WAV داخل برنامه
/// بسته‌بندی شده‌اند (`assets/audio/studio/`). بنابراین موسیقی بدون اینترنت،
/// بدون TTS و بدون وابستگی به سازِ گوشی کار می‌کند.
///
/// فایل سازنده: `tool/generate_music_assets.py`
class MusicNote {
  final String id;
  final String asset;
  final String persianName;
  final String solfege;
  final Color color;

  const MusicNote({
    required this.id,
    required this.asset,
    required this.persianName,
    required this.solfege,
    required this.color,
  });
}

class MusicNotes {
  MusicNotes._();

  static const String _base = 'assets/audio/studio/notes/';

  static const List<MusicNote> all = <MusicNote>[
    MusicNote(
      id: 'c4',
      asset: '${_base}c4.wav',
      persianName: 'دو',
      solfege: 'Do',
      color: Color(0xFFFF8A80),
    ),
    MusicNote(
      id: 'd4',
      asset: '${_base}d4.wav',
      persianName: 'رِ',
      solfege: 'Re',
      color: Color(0xFFFFB74D),
    ),
    MusicNote(
      id: 'e4',
      asset: '${_base}e4.wav',
      persianName: 'می',
      solfege: 'Mi',
      color: Color(0xFFFFD54F),
    ),
    MusicNote(
      id: 'f4',
      asset: '${_base}f4.wav',
      persianName: 'فا',
      solfege: 'Fa',
      color: Color(0xFF81C784),
    ),
    MusicNote(
      id: 'g4',
      asset: '${_base}g4.wav',
      persianName: 'سُل',
      solfege: 'Sol',
      color: Color(0xFF4FC3F7),
    ),
    MusicNote(
      id: 'a4',
      asset: '${_base}a4.wav',
      persianName: 'لا',
      solfege: 'La',
      color: Color(0xFF7986CB),
    ),
    MusicNote(
      id: 'b4',
      asset: '${_base}b4.wav',
      persianName: 'سی',
      solfege: 'Si',
      color: Color(0xFFBA68C8),
    ),
    MusicNote(
      id: 'c5',
      asset: '${_base}c5.wav',
      persianName: 'دو',
      solfege: 'Do',
      color: Color(0xFFF06292),
    ),
  ];
}

/// یک قدم از آهنگ: شمارهٔ نت + کشش (تعداد ضرب).
class SongStep {
  final int note;
  final int beats;

  const SongStep(this.note, {this.beats = 1});
}

class KidsSong {
  final String id;
  final String title;
  final String emoji;
  final String subtitle;
  final int bpm;
  final List<SongStep> steps;

  const KidsSong({
    required this.id,
    required this.title,
    required this.emoji,
    required this.subtitle,
    required this.bpm,
    required this.steps,
  });
}

class KidsSongs {
  KidsSongs._();

  /// ملودی‌های کوتاه و اورجینال برای این استودیو؛ هیچ آهنگِ دارای
  /// حقِ نشر استفاده نشده است.
  static const List<KidsSong> all = <KidsSong>[
    KidsSong(
      id: 'sunny_day',
      title: 'خورشید خانم',
      emoji: '☀️',
      subtitle: 'صبح بخیر، خورشید!',
      bpm: 104,
      steps: <SongStep>[
        SongStep(0), SongStep(1), SongStep(2), SongStep(1),
        SongStep(0), SongStep(1), SongStep(2), SongStep(1),
        SongStep(2), SongStep(3), SongStep(4, beats: 2),
        SongStep(2), SongStep(3), SongStep(4, beats: 2),
        SongStep(4), SongStep(5), SongStep(4), SongStep(3),
        SongStep(2), SongStep(1), SongStep(0, beats: 2),
      ],
    ),
    KidsSong(
      id: 'spring_rain',
      title: 'بارانِ بهاری',
      emoji: '🌧️',
      subtitle: 'تیک‌تیک، قطره‌قطره',
      bpm: 92,
      steps: <SongStep>[
        SongStep(4), SongStep(4), SongStep(3), SongStep(2),
        SongStep(1), SongStep(1), SongStep(2), SongStep(3),
        SongStep(2), SongStep(1), SongStep(0, beats: 2),
      ],
    ),
    KidsSong(
      id: 'golden_chick',
      title: 'جوجه‌ی طلایی',
      emoji: '🐥',
      subtitle: 'جیک‌جیک، کوچولوی زرد',
      bpm: 112,
      steps: <SongStep>[
        SongStep(2), SongStep(2), SongStep(1), SongStep(0),
        SongStep(1), SongStep(2), SongStep(2), SongStep(0),
        SongStep(1), SongStep(2), SongStep(3), SongStep(2),
        SongStep(1), SongStep(0, beats: 2),
      ],
    ),
    KidsSong(
      id: 'night_star',
      title: 'ستاره‌ی شب',
      emoji: '🌟',
      subtitle: 'چشمک بزن، ستاره',
      bpm: 76,
      steps: <SongStep>[
        SongStep(7, beats: 2), SongStep(5), SongStep(4),
        SongStep(2, beats: 2), SongStep(0),
        SongStep(2), SongStep(4), SongStep(5),
        SongStep(7, beats: 2),
      ],
    ),
    KidsSong(
      id: 'fandoghi_party',
      title: 'جشن فندقی',
      emoji: '🎉',
      subtitle: 'همه با هم بپریم!',
      bpm: 120,
      steps: <SongStep>[
        SongStep(0), SongStep(0), SongStep(1), SongStep(2),
        SongStep(1), SongStep(0), SongStep(2), SongStep(2),
        SongStep(3), SongStep(4), SongStep(3), SongStep(2),
        SongStep(1), SongStep(0, beats: 2),
      ],
    ),
  ];
}

class PercussionPad {
  final String id;
  final String label;
  final String emoji;
  final String asset;
  final Color color;
  final double volume;

  const PercussionPad({
    required this.id,
    required this.label,
    required this.emoji,
    required this.asset,
    required this.color,
    required this.volume,
  });
}

class PercussionPads {
  PercussionPads._();

  static const String _base = 'assets/audio/studio/perc/';

  static const List<PercussionPad> all = <PercussionPad>[
    PercussionPad(
      id: 'kick',
      label: 'طبل بزرگ',
      emoji: '🥁',
      asset: '${_base}kick.wav',
      color: Color(0xFFEF5350),
      volume: 0.85,
    ),
    PercussionPad(
      id: 'snare',
      label: 'طبل کوچک',
      emoji: '🪘',
      asset: '${_base}snare.wav',
      color: Color(0xFFFFB74D),
      volume: 0.70,
    ),
    PercussionPad(
      id: 'hat',
      label: 'سنج',
      emoji: '✨',
      asset: '${_base}hat.wav',
      color: Color(0xFF4DB6AC),
      volume: 0.62,
    ),
    PercussionPad(
      id: 'clap',
      label: 'دست',
      emoji: '👏',
      asset: '${_base}clap.wav',
      color: Color(0xFF9575CD),
      volume: 0.66,
    ),
    PercussionPad(
      id: 'tom',
      label: 'تام',
      emoji: '🪇',
      asset: '${_base}tom.wav',
      color: Color(0xFF4FC3F7),
      volume: 0.72,
    ),
  ];
}

class RhythmPattern {
  final String id;
  final String title;
  final String emoji;
  final List<int> pads;
  final int bpm;

  const RhythmPattern({
    required this.id,
    required this.title,
    required this.emoji,
    required this.pads,
    required this.bpm,
  });
}

class RhythmPatterns {
  RhythmPatterns._();

  static const List<RhythmPattern> all = <RhythmPattern>[
    RhythmPattern(
      id: 'walk',
      title: 'قدم‌قدم',
      emoji: '🚶',
      pads: <int>[0, 2, 1, 2],
      bpm: 96,
    ),
    RhythmPattern(
      id: 'jump',
      title: 'بپر بپر',
      emoji: '🐰',
      pads: <int>[0, 0, 1, 2],
      bpm: 112,
    ),
    RhythmPattern(
      id: 'clap',
      title: 'دست‌دست',
      emoji: '👏',
      pads: <int>[3, 1, 3, 1],
      bpm: 104,
    ),
    RhythmPattern(
      id: 'rain',
      title: 'باران',
      emoji: '🌧️',
      pads: <int>[2, 2, 3, 2, 1],
      bpm: 118,
    ),
    RhythmPattern(
      id: 'party',
      title: 'جشن',
      emoji: '🎉',
      pads: <int>[0, 2, 1, 3, 0, 0, 1, 3],
      bpm: 124,
    ),
  ];
}

class MusicInstrument {
  final String id;
  final String name;
  final String emoji;
  final String family;
  final String fact;
  final String playHint;
  final bool percussion;
  final List<int> demoNotes;
  final List<int> demoPads;

  const MusicInstrument({
    required this.id,
    required this.name,
    required this.emoji,
    required this.family,
    required this.fact,
    required this.playHint,
    this.percussion = false,
    this.demoNotes = const <int>[],
    this.demoPads = const <int>[],
  });
}

class MusicInstruments {
  MusicInstruments._();

  /// سازهای ایرانی اول فهرست می‌آیند تا کودک اول با موسیقی سرزمینش آشنا شود.
  static const List<MusicInstrument> all = <MusicInstrument>[
    MusicInstrument(
      id: 'tonbak',
      name: 'تنبک',
      emoji: '🪘',
      family: 'ساز کوبه‌ای',
      fact: 'تنبک با ضربه‌های انگشت روی پوستش صدا می‌سازد؛ صدایش مثل قلبِ موسیقی است.',
      playHint: 'با کفِ دست یک ضربِ آرام بزن.',
      percussion: true,
      demoPads: <int>[0, 1, 0, 3, 1],
    ),
    MusicInstrument(
      id: 'ney',
      name: 'نی',
      emoji: '🎋',
      family: 'ساز بادی',
      fact: 'نی از یک ساقهٔ توخالی ساخته می‌شود و صدایش بوی چوپان و دشت می‌دهد.',
      playHint: 'آرام بدم و گوش کن؛ صدای باد می‌آید.',
      demoNotes: <int>[2, 3, 4, 5, 4, 3, 2],
    ),
    MusicInstrument(
      id: 'setar',
      name: 'سه‌تار',
      emoji: '🪕',
      family: 'ساز زهی',
      fact: 'سه‌تار صدای نرم و دنج دارد و با ناخن نواخته می‌شود.',
      playHint: 'یک سیم را آرام به صدا دربیاور.',
      demoNotes: <int>[5, 4, 3, 4, 5, 5, 5],
    ),
    MusicInstrument(
      id: 'kamancheh',
      name: 'کمانچه',
      emoji: '🎻',
      family: 'ساز زهی آرشه‌ای',
      fact: 'کمانچه با آرشه نواخته می‌شود؛ صدایش می‌تواند بخندد یا گریه کند.',
      playHint: 'آرشه را آرام روی سیم بکش.',
      demoNotes: <int>[2, 4, 5, 4, 2, 1, 0],
    ),
    MusicInstrument(
      id: 'piano',
      name: 'پیانو',
      emoji: '🎹',
      family: 'ساز شستی‌دار',
      fact: 'پیانو کلیدهای سفید و سیاه دارد و با فشار دادن هر کلید یک نت می‌شنوی.',
      playHint: 'کلیدها را یکی‌یکی فشار بده.',
      demoNotes: <int>[0, 2, 4, 7, 4, 2, 0],
    ),
    MusicInstrument(
      id: 'guitar',
      name: 'گیتار',
      emoji: '🎸',
      family: 'ساز زهی',
      fact: 'گیتار شش سیم دارد و با انگشت یا مضراب نواخته می‌شود.',
      playHint: 'سیم‌ها را آرام و پشت سر هم لمس کن.',
      demoNotes: <int>[4, 5, 4, 2, 4, 2, 0],
    ),
    MusicInstrument(
      id: 'flute',
      name: 'فلوت',
      emoji: '🪈',
      family: 'ساز بادی',
      fact: 'فلوت صدایی نازک و روشن دارد؛ با دمیدن در آن صدا تولید می‌شود.',
      playHint: 'نفس آرام، صدای بلند؛ نفس تند، صدای کوتاه.',
      demoNotes: <int>[7, 5, 4, 5, 7, 7],
    ),
    MusicInstrument(
      id: 'dohol',
      name: 'دهل',
      emoji: '🥁',
      family: 'ساز کوبه‌ای',
      fact: 'دهل صدای بلند و شادِ جشن‌هاست و معمولاً دو نفره نواخته می‌شود.',
      playHint: 'با دو دست، دو ضربهٔ پشت سر هم بزن.',
      percussion: true,
      demoPads: <int>[0, 0, 1, 0, 2, 1],
    ),
  ];
}
