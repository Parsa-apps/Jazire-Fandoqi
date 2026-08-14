import 'dart:async';

import 'package:flutter/services.dart';
import 'package:just_audio/just_audio.dart';
import 'package:flutter_tts/flutter_tts.dart';

import 'game_data.dart';
import 'growth/parent_controls.dart';
import 'logger_service.dart';

/// ────────────────────────────────────────────────────────────
/// 🔊 سامانه صوتی آفلاین فندقی
///
/// افکت‌های بازی از `assets/audio/sfx` پخش می‌شوند (فایل‌های
/// سینثسایزشدهٔ نرم و کودک‌پسند). تلفظ حروف، اعداد، رنگ و شکل
/// هم آفلاین است.
///
/// داستان‌ها و لالایی‌ها از این کلاس رد نمی‌شوند — آن‌ها را
/// `StoryAudioService` و پخش‌کنندهٔ لالایی جداگانه مدیریت می‌کنند
/// و سشن صوتی‌شان نباید توسط افکت‌های UI قطع شود.
/// ────────────────────────────────────────────────────────────
class AudioService {
  static const String _sfxPath = 'assets/audio/sfx/';
  static const String _lettersPath = 'assets/audio/letters/';
  static const String _numbersPath = 'assets/audio/numbers/';
  static const String _learningPath = 'assets/audio/learning/';

  /// فهرست افکت‌های بسته‌بندی‌شده — برای تست و بازتولید.
  static const List<String> sfxNames = <String>[
    'tap',
    'click',
    'select',
    'back',
    'page',
    'swoosh',
    'bubble',
    'coin',
    'star',
    'correct',
    'success',
    'wrong',
    'error',
    'win',
    'lose',
    'levelup',
    'unlock',
    'tick',
    'countdown',
    'go',
    'sleep',
  ];

  /// بلندی هر دسته — UI آرام، جشن بلندتر، غلط هرگز بلند/ترسناک.
  static const Map<String, double> sfxVolumes = <String, double>{
    'tap': 0.40,
    'click': 0.36,
    'tick': 0.26,
    'back': 0.42,
    'page': 0.40,
    'swoosh': 0.46,
    'select': 0.50,
    'bubble': 0.56,
    'coin': 0.66,
    'star': 0.68,
    'correct': 0.70,
    'success': 0.68,
    'wrong': 0.44,
    'error': 0.38,
    'win': 0.78,
    'lose': 0.44,
    'levelup': 0.80,
    'unlock': 0.74,
    'countdown': 0.52,
    'go': 0.66,
    'sleep': 0.48,
  };

  static const double voiceVolume = 0.88;
  static const double defaultSfxVolume = 0.55;

  static const int _poolSize = 8;
  static final List<AudioPlayer> _sfxPool = List<AudioPlayer>.generate(
    _poolSize,
    (_) => AudioPlayer(
      handleInterruptions: false,
      handleAudioSessionActivation: false,
    ),
  );
  static int _poolIndex = 0;

  static final AudioPlayer _bgmPlayer = AudioPlayer(
    handleInterruptions: false,
    handleAudioSessionActivation: false,
  );

  /// موتور TTS — فقط برای محتوای پویا و به‌عنوان آخرین راه.
  static final FlutterTts _tts = FlutterTts();

  static final List<String> _speechQueue = <String>[];
  static bool _speaking = false;

  static bool _initialized = false;
  static bool _ttsAvailable = false;

  /// فاز H2: راه‌اندازی صدا از مسیر بحرانی اولین فریم خارج شده است.
  /// این Future یک‌بار ساخته و کش می‌شود (همان الگوی `GameData._loadFuture`)
  /// تا هر مسیری که زودتر از موعد صدا بخواهد، منتظر همان راه‌اندازی بماند
  /// و رفتار دقیقاً مثل قبل باقی بماند.
  static Future<void>? _initFuture;

  static String? _lastSfxName;
  static DateTime _lastSfxAt = DateTime.fromMillisecondsSinceEpoch(0);
  static const Duration _uiDebounce = Duration(milliseconds: 45);
  static const Set<String> _uiSfx = <String>{'tap', 'click', 'tick'};

  /// راه‌اندازی صوت. idempotent است و می‌توان بدون `await` صدایش زد؛
  /// خودِ متدهای پخش قبل از کار، منتظر پایان همین Future می‌مانند.
  static Future<void> init() {
    if (_initialized) return Future<void>.value();
    return _initFuture ??= _initInternal();
  }

  /// هر مسیر پخش صدا از این عبور می‌کند تا اگر راه‌اندازی هنوز تمام نشده
  /// باشد (چون بعد از اولین فریم شروع می‌شود) صدا از دست نرود.
  static Future<void> _ensureInitialized() {
    if (_initialized) return Future<void>.value();
    return init();
  }

  static Future<void> _initInternal() async {
    // بلندی هر هشت پلیر مستقل است؛ موازی انجام می‌شود تا هشت رفت‌وبرگشت
    // platform channel پشت‌سرهم صف نکشند.
    // این راه‌اندازی هرگز throw نمی‌کند: چون دیگر در main منتظرش نمی‌مانیم،
    // یک خطای صوتی نباید بعداً از داخل یک متد پخش بیرون بزند.
    try {
      await Future.wait<void>(<Future<void>>[
        for (final AudioPlayer player in _sfxPool)
          player.setVolume(defaultSfxVolume),
      ]);
    } catch (error) {
      LoggerService.e('Audio pool volume init failed', error);
    }

    // لحن گرم و شمرده — نه صدای بچگانهٔ مصنوعی با pitch بالا.
    try {
      await _tts.setLanguage('fa-IR');
      await _tts.setPitch(1.06);
      await _tts.setSpeechRate(0.40);
      await _tts.setVolume(1.0);
      _ttsAvailable = true;
    } catch (error) {
      _ttsAvailable = false;
      LoggerService.e('TTS unavailable on this device', error);
    }

    _initialized = true;
  }

  static bool get _muted =>
      !GameData.soundEnabled || ParentControls.shouldMuteSound;

  static AudioPlayer _acquirePlayer() {
    for (final AudioPlayer player in _sfxPool) {
      if (!player.playing) return player;
    }
    final AudioPlayer player = _sfxPool[_poolIndex];
    _poolIndex = (_poolIndex + 1) % _poolSize;
    return player;
  }

  static bool _shouldSkipDuplicate(String name) {
    if (!_uiSfx.contains(name)) return false;
    if (_lastSfxName != name) return false;
    return DateTime.now().difference(_lastSfxAt) < _uiDebounce;
  }

  /// پخش یک افکت از استخر (بدون قطع جشن در حال پخش).
  static Future<void> _playFromPool(
    String assetPath, {
    double volume = defaultSfxVolume,
  }) async {
    if (_muted) return;
    // اگر راه‌اندازی (که بعد از اولین فریم شروع می‌شود) هنوز تمام نشده،
    // اینجا کامل می‌شود تا هیچ افکتی از دست نرود.
    await _ensureInitialized();
    if (_muted) return;
    try {
      final AudioPlayer player = _acquirePlayer();
      await player.setVolume(volume.clamp(0.0, 1.0));
      await player.stop();
      await player.setAsset(assetPath);
      unawaited(player.play());
    } catch (error) {
      LoggerService.e('SFX missing: $assetPath', error);
    }
  }

  static Future<void> playSfx(String name) async {
    if (_shouldSkipDuplicate(name)) return;
    _lastSfxName = name;
    _lastSfxAt = DateTime.now();
    final double volume = sfxVolumes[name] ?? defaultSfxVolume;
    await _playFromPool('$_sfxPath$name.wav', volume: volume);
  }

  static Future<void> tap() => playSfx('tap');
  static Future<void> click() => playSfx('click');
  static Future<void> select() => playSfx('select');
  static Future<void> back() => playSfx('back');
  static Future<void> page() => playSfx('page');
  static Future<void> swoosh() => playSfx('swoosh');
  static Future<void> bubble() => playSfx('bubble');
  static Future<void> coin() => playSfx('coin');
  static Future<void> star() => playSfx('star');
  static Future<void> correct() => playSfx('correct');
  static Future<void> success() => playSfx('success');
  static Future<void> wrong() => playSfx('wrong');
  static Future<void> error() => playSfx('error');
  static Future<void> win() => playSfx('win');
  static Future<void> lose() => playSfx('lose');
  static Future<void> levelUp() => playSfx('levelup');
  static Future<void> unlock() => playSfx('unlock');
  static Future<void> tick() => playSfx('tick');
  static Future<void> countdown() => playSfx('countdown');
  static Future<void> go() => playSfx('go');
  static Future<void> sleepChime() => playSfx('sleep');

  /// بازخورد لمسی + صوتی برای دکمه‌ها.
  static Future<void> buttonTap() async {
    HapticFeedback.lightImpact();
    await tap();
  }

  // ─────────────────────────── حروف الفبا (آفلاین) ───────────────────────────

  /// نگاشت حرف فارسی به شماره فایل صوتی (l01..l32).
  static const Map<String, int> letterIndex = {
    'آ': 1,
    'ا': 1,
    'ب': 2,
    'پ': 3,
    'ت': 4,
    'ث': 5,
    'ج': 6,
    'چ': 7,
    'ح': 8,
    'خ': 9,
    'د': 10,
    'ذ': 11,
    'ر': 12,
    'ز': 13,
    'ژ': 14,
    'س': 15,
    'ش': 16,
    'ص': 17,
    'ض': 18,
    'ط': 19,
    'ظ': 20,
    'ع': 21,
    'غ': 22,
    'ف': 23,
    'ق': 24,
    'ک': 25,
    'گ': 26,
    'ل': 27,
    'م': 28,
    'ن': 29,
    'و': 30,
    'ه': 31,
    'ی': 32,
  };

  static String? letterAssetFor(String letter) {
    final int? idx = letterIndex[letter];
    if (idx == null) return null;
    return '$_lettersPath${'l${idx.toString().padLeft(2, '0')}'}.mp3';
  }

  /// تلفظ رسای حرف فارسی از فایل آفلاین.
  static Future<void> pronounceLetter(String letter) async {
    if (_muted) return;
    final String? asset = letterAssetFor(letter);
    if (asset == null) return;
    await _playFromPool(asset, volume: voiceVolume);
  }

  // ─────────────────────────── اعداد (آفلاین) ───────────────────────────

  static String? numberAssetFor(int number) {
    if (number < 0 || number > 20) return null;
    return '$_numbersPath${'n${number.toString().padLeft(2, '0')}'}.mp3';
  }

  /// تلفظ عدد فارسی از فایل آفلاین (در صورت موجود بودن).
  static Future<void> speakNumber(int number) async {
    if (_muted) return;
    final String? asset = numberAssetFor(number);
    if (asset == null) return;
    await _playFromPool(asset, volume: voiceVolume);
  }

  // ─────────────────────── واژه‌های آموزشی آفلاین ───────────────────────

  /// مسیر فایل ضبط‌شدهٔ کارت‌های رنگ و شکل را برمی‌گرداند.
  /// این دو بازی نباید به نصب‌بودن موتور فارسی TTS روی گوشی وابسته باشند.
  static String? learningVoiceAsset({
    required String topicId,
    required String cardId,
  }) {
    final match = RegExp(r'^[a-zA-Z](\d+)$').firstMatch(cardId);
    final index = int.tryParse(match?.group(1) ?? '');
    if (index == null) return null;
    final padded = index.toString().padLeft(2, '0');

    return switch (topicId) {
      'colors' when index >= 1 && index <= 12 =>
        '${_learningPath}colors/c$padded.wav',
      'shapes' when index >= 1 && index <= 10 =>
        '${_learningPath}shapes/s$padded.wav',
      _ => null,
    };
  }

  /// نام کارت را می‌خواند؛ برای رنگ‌ها و شکل‌ها همیشه از صدای بسته‌بندی‌شده
  /// داخل اپ استفاده می‌کند و برای موضوع‌های دیگر به TTS فارسی برمی‌گردد.
  static Future<void> speakLearningCard({
    required String topicId,
    required String cardId,
    required String fallbackText,
  }) async {
    if (_muted) return;
    final asset = learningVoiceAsset(topicId: topicId, cardId: cardId);
    if (asset != null) {
      await _playFromPool(asset, volume: voiceVolume);
      return;
    }
    await speak(fallbackText);
  }

  // ─────────────────────────── موسیقی پس‌زمینه ───────────────────────────
  // به‌درخواست کاربر: هیچ موسیقی پس‌زمینه‌ای پخش نمی‌شود.
  // متدها برای سازگاری با کدهای قدیمی نگه داشته شده ولی بی‌اثرند.

  static Future<void> playBgm(String assetPath) async {
    // عمداً خالی — موسیقی پس‌زمینه خاموش است.
  }

  static void stopBgm() {
    _bgmPlayer.stop();
  }

  static void setBgmVolume(double volume) {
    // بدون تغییر — BGM خاموش است.
  }

  // ─────────────────────────── TTS پویا (فقط محتوای زنده) ───────────────────────────

  /// سخن گفتن برای محتوای کاملاً پویا که نمی‌توان از قبل ضبط کرد
  /// (مثل پاسخ‌های هوش مصنوعی دوست فندقی). روی دستگاه‌های بدون
  /// TTS بی‌صدا رد می‌شود.
  static Future<void> speak(String text) async {
    final clean = text.trim();
    if (clean.isEmpty || _muted) return;
    // `_ttsAvailable` تا پایان راه‌اندازی معلوم نیست؛ پس اول منتظر می‌مانیم
    // وگرنه اولین درخواست گفتار بی‌صدا رد می‌شد.
    await _ensureInitialized();
    if (_muted || !_ttsAvailable) return;

    final spoken = clean
        .replaceAll(RegExp(r'[\p{Extended_Pictographic}]', unicode: true), ' ')
        .trim();
    if (spoken.isEmpty) return;

    _speechQueue.add(spoken);
    if (!_speaking) {
      unawaited(_drainQueue());
    }
  }

  static bool get isSpeaking => _speaking;

  static void stopSpeaking() {
    _speechQueue.clear();
    try {
      _tts.stop();
    } catch (_) {}
    _speaking = false;
  }

  static Future<void> _drainQueue() async {
    _speaking = true;
    while (_speechQueue.isNotEmpty && !_muted && _ttsAvailable) {
      final text = _speechQueue.removeAt(0);
      try {
        await _tts.speak(text);
      } catch (error) {
        LoggerService.e('TTS speak failed', error);
        break;
      }
    }
    _speaking = false;
  }

  // ─────────────────────────── سازگاری با نسخه قدیم ───────────────────────────

  static Future<void> playCorrect() => correct();
  static Future<void> playWrong() => wrong();
  static Future<void> playWin() => win();
  static Future<void> playCoin() => coin();

  static Future<void> playEffect(String assetPath) =>
      _playFromPool(assetPath, volume: defaultSfxVolume);

  static void dispose() {
    for (final AudioPlayer player in _sfxPool) {
      player.dispose();
    }
    _bgmPlayer.dispose();
  }
}
