import 'package:flutter/foundation.dart';
import 'package:just_audio/just_audio.dart';
import 'package:flutter_tts/flutter_tts.dart';

import 'game_data.dart';
import 'logger_service.dart';

/// ────────────────────────────────────────────────────────────
/// 🔊 فاز ۶: طراحی سیستم صوتی حرفه‌ای
///
/// - دو پخش‌کننده جدا: افکت و موسیقی پس‌زمینه (بدون تداخل)
/// - صف TTS: جملات پشت سر هم قطع نمی‌شوند و overlap ندارند
/// - افکت‌های تشویقی/درست/غلط از طریق TTS کودکانه (بدون نیاز به
///   فایل صوتی سنگین؛ صدای فندقی) + امکان جایگزینی با asset بعداً
/// - تلفظ فارسی حروف الفبا برای آکادمی الفبا
/// - خاموش/روشن کردن با یک پرچم سراسری
/// ────────────────────────────────────────────────────────────
class AudioService {
  static final AudioPlayer _effectPlayer = AudioPlayer();
  static final AudioPlayer _bgmPlayer = AudioPlayer();

  /// صدای مربی فندقی (TTS)
  static final FlutterTts _tts = FlutterTts();

  /// صف جملات: تا جمله قبلی تمام نشود، جمله بعدی شروع نمی‌شود.
  static final List<String> _speechQueue = <String>[];
  static bool _speaking = false;

  static bool _initialized = false;

  static Future<void> init() async {
    if (_initialized) return;
    try {
      await _tts.setLanguage('fa-IR');
      await _tts.setPitch(1.2); // صدای بامزه فندقی
      await _tts.setSpeechRate(0.5);
      await _tts.setVolume(1.0);
      _initialized = true;
    } catch (error) {
      LoggerService.e('AudioService.init failed', error);
    }
  }

  // ─────────────────────────── افکت ───────────────────────────

  /// پخش افکت صوتی از asset. اگر فایل نبود، خطا فقط لاگ می‌شود.
  static Future<void> playEffect(String assetPath) async {
    if (!GameData.soundEnabled) return;
    try {
      await _effectPlayer.setAsset(assetPath);
      await _effectPlayer.play();
    } catch (error) {
      LoggerService.e('Error playing effect: $assetPath', error);
    }
  }

  static Future<void> playBgm(String assetPath) async {
    if (!GameData.soundEnabled) return;
    try {
      await _bgmPlayer.setAsset(assetPath);
      await _bgmPlayer.setLoopMode(LoopMode.one);
      await _bgmPlayer.setVolume(0.5);
      await _bgmPlayer.play();
    } catch (error) {
      LoggerService.e('Error playing BGM: $assetPath', error);
    }
  }

  static void stopBgm() {
    _bgmPlayer.stop();
  }

  static void setBgmVolume(double volume) {
    _bgmPlayer.setVolume(volume.clamp(0.0, 1.0).toDouble());
  }

  // ─────────────────────────── TTS ───────────────────────────

  /// سخن گفتن فندقی — جمله در صف قرار می‌گیرد.
  static Future<void> speak(String text) async {
    final clean = text.trim();
    if (clean.isEmpty) return;
    if (!GameData.soundEnabled) return;

    _speechQueue.add(clean);
    if (!_speaking) {
      unawaited(_drainQueue());
    }
  }

  /// آیا هم‌اکنون فندقی در حال حرف زدن است؟
  static bool get isSpeaking => _speaking;

  /// متوقف کردن همه جمله‌های در صف (مثلاً موقع ناوبری).
  static void stopSpeaking() {
    _speechQueue.clear();
    _tts.stop();
    _speaking = false;
  }

  static Future<void> _drainQueue() async {
    _speaking = true;
    while (_speechQueue.isNotEmpty && GameData.soundEnabled) {
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

  // ─────────────── افکت‌های آماده (بدون فایل) ───────────────

  /// تشویق کوتاه بعد از جواب درست.
  static Future<void> playCorrect() =>
      speak(_randomChoice(<String>['آفرین! 🎉', 'عالی بود! 🌟', 'همین‌طور ادامه بده! 💪']));

  /// بازخورد ملایم بعد از جواب نادرست (بدون سرزنش — روانشناسی کودک).
  static Future<void> playWrong() =>
      speak(_randomChoice(<String>['اشکالی نداره، دوباره تلاش کن 🌱', 'نزدیک بود! دوباره 🎯']));

  /// صدای سکه/ستاره.
  static Future<void> playCoin() =>
      speak(_randomChoice(<String>['یک سکه گرفتی! 🪙', 'ستاره گرفتی! ✨']));

  /// جشن برد بازی.
  static Future<void> playWin() =>
      speak(_randomChoice(<String>['بردی! آفرین قهرمان! 🏆', 'چه بازی قشنگی! تو برنده‌ای! 🎊']));

  /// تلفظ یک حرف فارسی برای آکادمی الفبا.
  static Future<void> pronounceLetter(String letter) async {
    const Map<String, String> letters = <String, String>{
      'آ': 'الف',
      'ا': 'الف',
      'ب': 'ب',
      'پ': 'پ',
      'ت': 'ت',
      'ث': 'ث',
      'ج': 'ج',
      'چ': 'چ',
      'ح': 'ح',
      'خ': 'خ',
      'د': 'د',
      'ذ': 'ذ',
      'ر': 'ر',
      'ز': 'ز',
      'ژ': 'ژ',
      'س': 'س',
      'ش': 'ش',
      'ص': 'ص',
      'ض': 'ض',
      'ط': 'ط',
      'ظ': 'ظ',
      'ع': 'ع',
      'غ': 'غ',
      'ف': 'ف',
      'ق': 'ق',
      'ک': 'ک',
      'گ': 'گ',
      'ل': 'ل',
      'م': 'م',
      'ن': 'ن',
      'و': 'و',
      'ه': 'ه',
      'ی': 'ی',
    };
    await speak(letters[letter] ?? letter);
  }

  static String _randomChoice(List<String> options) {
    return options[DateTime.now().microsecondsSinceEpoch % options.length];
  }

  static void dispose() {
    _effectPlayer.dispose();
    _bgmPlayer.dispose();
  }
}
