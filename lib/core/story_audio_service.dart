import 'dart:async';
import 'package:flutter/services.dart';
import 'package:just_audio/just_audio.dart';
import 'logger_service.dart';
import 'audio_service.dart';

/// ────────────────────────────────────────────────────────────
/// 🎙️ STORY AUDIO SERVICE — سرویس پخش صدای کودکانه داستان‌ها
///
/// - صدای بچگانه حرفه‌ای با فارسی روان بدون لهجه
/// - لحن کودکانه، شاد و قصه‌گو (نزدیک به صدای کودک ۸-۱۰ ساله)
/// - پخش آفلاین از فایل‌های پیش‌تولید شده (assets/audio/stories)
/// - در صورت نبود فایل، fallback به TTS سیستم
/// ────────────────────────────────────────────────────────────
class StoryAudioService {
  static final AudioPlayer _player = AudioPlayer();
  static bool _isPlayingPreRecorded = false;
  static String? _currentAsset;

  /// آیا در حال پخش فایل ضبط‌شده هستیم؟
  static bool get isPlayingPreRecorded => _isPlayingPreRecorded;
  static String? get currentAsset => _currentAsset;

  /// نگاشت storyId + pageNumber -> مسیر asset
  /// نام‌گذاری: story_{id}_page{number}.mp3
  /// مثال: story_bear_friendship_page1.mp3
  static String assetPathFor(String storyId, int pageNumber) {
    return 'assets/audio/stories/${storyId}_page$pageNumber.mp3';
  }

  /// بررسی وجود فایل در assets (برای جلوگیری از خطای just_audio)
  static Future<bool> hasPreRecordedAudio(String storyId, int pageNumber) async {
    final path = assetPathFor(storyId, pageNumber);
    try {
      await rootBundle.load(path);
      return true;
    } catch (_) {
      return false;
    }
  }

  /// پخش صدای یک صفحه داستان
  /// اگر فایل پیش‌ضبط شده وجود داشت -> پخش با just_audio (صدای بچگانه)
  /// در غیر این‌صورت -> fallback به AudioService.speak (TTS)
  static Future<void> playStoryPage({
    required String storyId,
    required int pageNumber,
    required String fallbackText,
  }) async {
    final assetPath = assetPathFor(storyId, pageNumber);
    final exists = await hasPreRecordedAudio(storyId, pageNumber);

    if (exists) {
      try {
        await _player.stop();
        AudioService.stopSpeaking(); // قطع TTS قبلی
        await _player.setAsset(assetPath);
        _currentAsset = assetPath;
        _isPlayingPreRecorded = true;
        await _player.play();
        // منتظر پایان پخش
        await _player.processingStateStream
            .firstWhere((s) => s == ProcessingState.completed)
            .timeout(const Duration(seconds: 120), onTimeout: () => ProcessingState.completed);
        _isPlayingPreRecorded = false;
        return;
      } catch (e) {
        LoggerService.e('StoryAudioService play failed for $assetPath', e);
        _isPlayingPreRecorded = false;
        // fallback به TTS
      }
    }

    // fallback: TTS کودکانه سیستم
    await AudioService.speak(fallbackText);
    // صبر تا TTS تمام شود (تقریبی)
    final wordCount = fallbackText.split(' ').length;
    final estimatedSeconds = (wordCount / 2.2).ceil() + 1;
    await Future.delayed(Duration(seconds: estimatedSeconds));
  }

  /// پخش ساده بدون انتظار (برای UI که می‌خواهد کنترل کند)
  static Future<bool> playPreRecordedOnly(String storyId, int pageNumber) async {
    final assetPath = assetPathFor(storyId, pageNumber);
    final exists = await hasPreRecordedAudio(storyId, pageNumber);
    if (!exists) return false;
    try {
      await _player.stop();
      AudioService.stopSpeaking();
      await _player.setAsset(assetPath);
      _currentAsset = assetPath;
      _isPlayingPreRecorded = true;
      unawaited(_player.play().then((_) {}));
      _player.processingStateStream.listen((state) {
        if (state == ProcessingState.completed) {
          _isPlayingPreRecorded = false;
        }
      });
      return true;
    } catch (e) {
      LoggerService.e('playPreRecordedOnly failed', e);
      _isPlayingPreRecorded = false;
      return false;
    }
  }

  static Future<void> stop() async {
    try {
      await _player.stop();
    } catch (_) {}
    AudioService.stopSpeaking();
    _isPlayingPreRecorded = false;
    _currentAsset = null;
  }

  static Future<void> pause() async {
    try {
      await _player.pause();
    } catch (_) {}
  }

  static Future<void> resume() async {
    try {
      await _player.play();
    } catch (_) {}
  }

  static Stream<Duration> get positionStream => _player.positionStream;
  static Stream<Duration?> get durationStream => _player.durationStream;
  static Stream<PlayerState> get playerStateStream => _player.playerStateStream;

  /// دریافت موقعیت فعلی پلیر (برای هماهنگی هایلایت با صدا)
  static Future<Duration> getCurrentPosition() async => _player.getCurrentPosition();

  static void dispose() {
    _player.dispose();
  }
}
