import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:just_audio/just_audio.dart';

import '../../app/app_fonts.dart';
import '../../core/audio_service.dart';
import '../../core/learning_content/poems_data.dart';
import '../../core/recitation_audio.dart';

/// 🎶 خوانش شعر — اگر فایل ضبط‌شدهٔ بچگانه باندل شده باشد همان پخش
/// می‌شود؛ در غیر این صورت TTS فارسیِ دستگاه متن را می‌خواند تا شعر
/// هرگز بی‌صدا نماند.
class PoemReaderScreen extends StatefulWidget {
  final Poem poem;
  const PoemReaderScreen({super.key, required this.poem});

  @override
  State<PoemReaderScreen> createState() => _PoemReaderScreenState();
}

class _PoemReaderScreenState extends State<PoemReaderScreen> {
  final AudioPlayer _player = AudioPlayer(
    handleInterruptions: false,
    handleAudioSessionActivation: false,
  );

  bool _resolving = true;
  bool _hasRecording = false;
  bool _isPlaying = false;
  bool _ttsActive = false;
  Duration _duration = Duration.zero;
  Duration _position = Duration.zero;
  final List<StreamSubscription<dynamic>> _subs = <StreamSubscription<dynamic>>[];

  Poem get _poem => widget.poem;

  @override
  void initState() {
    super.initState();
    AudioService.poemChime();
    _resolveAndPrepare();
  }

  Future<void> _resolveAndPrepare() async {
    final exists = await RecitationAudio.exists(_poem.audioAsset);
    if (!mounted) return;
    _hasRecording = exists && AudioService.canPlayAudio;
    if (_hasRecording) {
      try {
        await _player.setAsset(_poem.audioAsset);
        await _player.setLoopMode(LoopMode.off);
        _duration = _player.duration ?? Duration.zero;
        _subs.add(_player.positionStream.listen((pos) {
          if (mounted) setState(() => _position = pos);
        }));
        _subs.add(_player.playerStateStream.listen((state) {
          if (!mounted) return;
          setState(() => _isPlaying = state.playing);
          if (state.processingState == ProcessingState.completed) {
            setState(() => _isPlaying = false);
          }
        }));
        _subs.add(_player.durationStream.listen((d) {
          if (d != null && mounted) setState(() => _duration = d);
        }));
      } catch (_) {
        _hasRecording = false;
      }
    }
    if (mounted) setState(() => _resolving = false);
  }

  @override
  void dispose() {
    for (final sub in _subs) {
      unawaited(sub.cancel());
    }
    AudioService.stopSpeaking();
    _player.dispose();
    super.dispose();
  }

  Future<void> _togglePlay() async {
    HapticFeedback.lightImpact();
    if (!AudioService.canPlayAudio) return;

    if (_hasRecording) {
      if (_player.playing) {
        await _player.pause();
      } else {
        AudioService.stopSpeaking();
        await _player.play();
      }
      return;
    }

    // حالت TTS فارسی (فایل ضبط‌شده داخل اپ نیست).
    if (_ttsActive) {
      AudioService.stopSpeaking();
      if (mounted) setState(() => _ttsActive = false);
      return;
    }
    if (mounted) setState(() => _ttsActive = true);
    await AudioService.speak(_poem.spokenText);
    if (mounted) setState(() => _ttsActive = false);
  }

  String _format(Duration d) {
    final m = d.inMinutes.remainder(60).toString().padLeft(2, '0');
    final s = d.inSeconds.remainder(60).toString().padLeft(2, '0');
    return '$m:$s';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: DecoratedBox(
        decoration: BoxDecoration(gradient: _poem.gradient),
        child: SafeArea(
          child: Column(
            children: [
              _buildTopBar(),
              Expanded(
                child: SingleChildScrollView(
                  physics: const BouncingScrollPhysics(),
                  padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      _buildCover(),
                      const SizedBox(height: 16),
                      _buildPlayerCard(),
                      const SizedBox(height: 16),
                      _buildPoemText(),
                      const SizedBox(height: 16),
                      _buildMessage(),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTopBar() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 10, 16, 8),
      child: Row(
        children: [
          GestureDetector(
            onTap: () {
              HapticFeedback.selectionClick();
              AudioService.tap();
              Navigator.of(context).maybePop();
            },
            child: Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.15),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.white24),
              ),
              child: const Icon(Icons.arrow_back_ios_new_rounded,
                  color: Colors.white, size: 20),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              '${_poem.coverEmoji} ${_poem.title}',
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: AppFonts.kids(
                color: Colors.white,
                fontSize: 19,
                fontWeight: FontWeight.w900,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCover() {
    return Container(
      height: 170,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(26),
        border: Border.all(color: Colors.white.withOpacity(0.4), width: 2),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.22),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
        color: Colors.white.withOpacity(0.12),
      ),
      child: Center(
        child: Container(
          padding: const EdgeInsets.all(26),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.18),
            shape: BoxShape.circle,
          ),
          child: Text(_poem.coverEmoji, style: const TextStyle(fontSize: 72)),
        ),
      ),
    );
  }

  Widget _buildPlayerCard() {
    final active = _isPlaying || _ttsActive;
    final progress = _duration.inMilliseconds > 0
        ? (_position.inMilliseconds / _duration.inMilliseconds).clamp(0.0, 1.0)
        : 0.0;

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.13),
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: Colors.white24),
      ),
      child: Column(
        children: [
          Row(
            children: [
              GestureDetector(
                onTap: _resolving ? null : _togglePlay,
                child: Container(
                  width: 62,
                  height: 62,
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                  ),
                  child: _resolving
                      ? const Padding(
                          padding: EdgeInsets.all(18),
                          child: CircularProgressIndicator(strokeWidth: 3),
                        )
                      : Icon(
                          active
                              ? Icons.pause_rounded
                              : Icons.play_arrow_rounded,
                          color: _poem.themeColor,
                          size: 34,
                        ),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _resolving
                          ? 'در حال آماده‌سازی صدا...'
                          : active
                              ? 'در حال خوانش شعر...'
                              : 'برای شنیدن شعر بزن',
                      style: AppFonts.vazirmatn(
                        color: Colors.white,
                        fontSize: 13,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    const SizedBox(height: 6),
                    if (_hasRecording) ...[
                      ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: LinearProgressIndicator(
                          value: progress,
                          backgroundColor: Colors.white.withOpacity(0.2),
                          valueColor:
                              const AlwaysStoppedAnimation<Color>(Colors.white),
                          minHeight: 6,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(_format(_position),
                              style: const TextStyle(
                                  color: Colors.white70,
                                  fontSize: 11,
                                  fontWeight: FontWeight.bold)),
                          Text(_format(_duration),
                              style: const TextStyle(
                                  color: Colors.white70,
                                  fontSize: 11,
                                  fontWeight: FontWeight.bold)),
                        ],
                      ),
                    ] else
                      Text(
                        'خوانش با صدای دستگاه (TTS فارسی)',
                        style: AppFonts.vazirmatn(
                          color: Colors.white70,
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildPoemText() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.13),
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: Colors.white24),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Text('🎵', style: TextStyle(fontSize: 20)),
              const SizedBox(width: 8),
              Text(
                'متن شعر',
                style: AppFonts.kids(
                  color: Colors.amberAccent,
                  fontSize: 15,
                  fontWeight: FontWeight.w900,
                ),
              ),
              const Spacer(),
              Text(
                _poem.ageLabel,
                style: AppFonts.vazirmatn(
                  color: Colors.white70,
                  fontSize: 10.5,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          ..._poem.lines.map(
            (line) => Padding(
              padding: const EdgeInsets.symmetric(vertical: 4),
              child: Text(
                line,
                textAlign: TextAlign.center,
                style: AppFonts.kids(
                  color: Colors.white,
                  fontSize: 18,
                  height: 1.9,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMessage() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF6C5CE7), Color(0xFFA29BFE)],
        ),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        children: [
          const Text('💜', style: TextStyle(fontSize: 26)),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              _poem.message,
              style: AppFonts.vazirmatn(
                color: Colors.white,
                fontSize: 13,
                fontWeight: FontWeight.w800,
                height: 1.6,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
