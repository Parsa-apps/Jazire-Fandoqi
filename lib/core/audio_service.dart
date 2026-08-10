import 'dart:async';
import 'dart:math';

import 'package:flutter/services.dart';
import 'package:just_audio/just_audio.dart';
import 'package:flutter_tts/flutter_tts.dart';

import 'game_data.dart';
import 'logger_service.dart';

/// ────────────────────────────────────────────────────────────
/// 🔊 سامانه صوتی آفلاین فندقی
///
/// همهٔ افکت‌های بازی (کلیک، درست، غلط، برد، باخت، سکه، ستاره،
/// ترکیدن حباب و...) و تلفظ حروف الفبا به‌صورت فایل‌های صوتی
/// داخل اپ (assets/audio) پخش می‌شوند تا روی هیچ دستگاهی به
/// موتور TTS وابسته نباشند.
///
/// یک استخر از پخش‌کننده‌ها برای همپوشانی افکت‌ها استفاده می‌شود
/// (مثلاً ترکیدن پشت سر هم حباب‌ها).
///
/// TTS فقط برای محتوای کاملاً پویا (مثل پاسخ‌های هوش مصنوعی
/// دوست فندقی) باقی مانده و در صورت عدم پشتیبانی، بی‌صدا رد می‌شود.
/// ────────────────────────────────────────────────────────────
class AudioService {
  static const String _sfxPath = 'assets/audio/sfx/';
  static const String _lettersPath = 'assets/audio/letters/';
  static const String _numbersPath = 'assets/audio/numbers/';

  // استخر افکت برای پخش همزمان چند صدا
  static const int _poolSize = 5;
  static final List<AudioPlayer> _sfxPool =
      List.generate(_poolSize, (_) => AudioPlayer());
  static int _poolIndex = 0;

  static final AudioPlayer _bgmPlayer = AudioPlayer();

  /// موتور TTS — فقط برای محتوای پویا و به‌عنوان آخرین راه.
  static final FlutterTts _tts = FlutterTts();

  static final List<String> _speechQueue = <String>[];
  static bool _speaking = false;

  static bool _initialized = false;
  static bool _ttsAvailable = false;

  static Future<void> init() async {
    if (_initialized) return;

    // صدای همه پخش‌کننده‌ها
    for (final p in _sfxPool) {
      p.setVolume(1.0);
    }

    // TTS را اختیاری راه‌اندازی کن؛ روی دستگاه‌هایی که ندارند،
    // خطا را بی‌صدا می‌بلعیم و بدونش ادامه می‌دهیم.
    try {
      await _tts.setLanguage('fa-IR');
      await _tts.setPitch(1.35);
      await _tts.setSpeechRate(0.46);
      await _tts.setVolume(1.0);
      _ttsAvailable = true;
    } catch (error) {
      _ttsAvailable = false;
      LoggerService.e('TTS unavailable on this device', error);
    }

    _initialized = true;
  }

  // ─────────────────────────── افکت‌های آفلاین ───────────────────────────

  /// پخش یک افکت از استخر (بدون قطع صدای قبلی).
  static Future<void> _playFromPool(String assetPath) async {
    if (!GameData.soundEnabled) return;
    try {
      final player = _sfxPool[_poolIndex];
      _poolIndex = (_poolIndex + 1) % _poolSize;
      await player.stop();
      await player.setAsset(assetPath);
      await player.play();
    } catch (error) {
      // فایل صوتی ممکن است هنوز تولید نشده باشد؛ بی‌صدا رد شو.
      LoggerService.e('SFX missing: $assetPath', error);
    }
  }

  static Future<void> playSfx(String name) =>
      _playFromPool('$_sfxPath$name.wav');

  // ── افکت‌های آماده ──
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
  static Future<void> wrong() => playSfx('wrong');
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
  static const Map<String, int> _letterIndex = {
    'آ': 1, 'ا': 1,
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

  /// تلفظ رسای حرف فارسی از فایل آفلاین.
  static Future<void> pronounceLetter(String letter) async {
    if (!GameData.soundEnabled) return;
    final idx = _letterIndex[letter];
    if (idx == null) {
      // حرف ناشناخته — بی‌صدا
      return;
    }
    final fileName = 'l${idx.toString().padLeft(2, '0')}.mp3';
    await _playFromPool('$_lettersPath$fileName');
  }

  // ─────────────────────────── اعداد (آفلاین) ───────────────────────────

  static const Map<int, int> _numberIndex = {
    0: 0, 1: 1, 2: 2, 3: 3, 4: 4, 5: 5,
    6: 6, 7: 7, 8: 8, 9: 9, 10: 10,
    11: 11, 12: 12, 13: 13, 14: 14, 15: 15,
    16: 16, 17: 17, 18: 18, 19: 19, 20: 20,
  };

  /// تلفظ عدد فارسی از فایل آفلاین (در صورت موجود بودن).
  static Future<void> speakNumber(int number) async {
    if (!GameData.soundEnabled) return;
    final idx = _numberIndex[number];
    if (idx == null) return;
    final fileName = 'n${idx.toString().padLeft(2, '0')}.mp3';
    await _playFromPool('$_numbersPath$fileName');
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
    if (clean.isEmpty || !GameData.soundEnabled || !_ttsAvailable) return;

    // پاکسازی اموجی‌ها برای گفتار روان‌تر
    final spoken = clean.replaceAll(RegExp(r'[\p{Extended_Pictographic}]', unicode: true), ' ').trim();
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
    while (_speechQueue.isNotEmpty && GameData.soundEnabled && _ttsAvailable) {
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

  static final Random _rng = Random();

  /// تشویق کوتاه بعد از جواب درست (صدای آفلاین).
  static Future<void> playCorrect() => correct();

  /// بازخورد ملایم بعد از جواب نادرست (صدای آفلاین).
  static Future<void> playWrong() => wrong();

  /// جشن برد (صدای آفلاین).
  static Future<void> playWin() => win();

  /// دریافت سکه.
  static Future<void> playCoin() => coin();

  /// ارجاعات قدیمی به playEffect — به استخر هدایت می‌شود.
  static Future<void> playEffect(String assetPath) =>
      _playFromPool(assetPath);

  static String _randomChoice(List<String> options) =>
      options[_rng.nextInt(options.length)];

  static void dispose() {
    for (final p in _sfxPool) {
      p.dispose();
    }
    _bgmPlayer.dispose();
  }
}
