import 'package:just_audio/just_audio.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'game_data.dart';
import 'logger_service.dart';

class AudioService {
  static final AudioPlayer _effectPlayer = AudioPlayer();
  static final AudioPlayer _bgmPlayer = AudioPlayer();
  static final FlutterTts _tts = FlutterTts();

  static Future<void> init() async {
    await _tts.setLanguage("fa-IR");
    await _tts.setPitch(1.2); // Fandoghi-like pitch
    await _tts.setSpeechRate(0.5);
  }

  static Future<void> playEffect(String assetPath) async {
    if (!GameData.soundEnabled) return;
    try {
      await _effectPlayer.setAsset(assetPath);
      await _effectPlayer.play();
    } catch (e) {
      LoggerService.e('Error playing effect', e);
    }
  }

  static Future<void> speak(String text) async {
    if (!GameData.soundEnabled) return;
    await _tts.speak(text);
  }

  static Future<void> playBgm(String assetPath) async {
    if (!GameData.soundEnabled) return;
    try {
      await _bgmPlayer.setAsset(assetPath);
      await _bgmPlayer.setLoopMode(LoopMode.one);
      await _bgmPlayer.setVolume(0.5);
      await _bgmPlayer.play();
    } catch (e) {
      LoggerService.e('Error playing BGM', e);
    }
  }

  static void stopBgm() {
    _bgmPlayer.stop();
  }

  static void dispose() {
    _effectPlayer.dispose();
    _bgmPlayer.dispose();
  }
}
