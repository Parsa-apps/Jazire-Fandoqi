import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:just_audio/just_audio.dart';

import '../../app/app_fonts.dart';
import '../../core/audio_service.dart';
import '../../core/learning_content/quran_data.dart';
import '../../core/recitation_audio.dart';

/// 🕌 صفحهٔ سوره — متن عربی اعراب‌دار + معنی سادهٔ فارسی.
///
/// خط‌مشی صوتی: تلاوت فقط وقتی پخش می‌شود که فایل رسمیِ ضبط‌شده
/// داخل اپ باندل شده باشد. نبودِ فایل هرگز با TTS عربی پر نمی‌شود؛
/// به‌جایش یک اعلان آرام «به‌زودی» نشان داده می‌شود تا تلفظ نادرست
/// از دستگاه کودک پخش نشود.
class QuranReaderScreen extends StatefulWidget {
  final Surah surah;
  const QuranReaderScreen({super.key, required this.surah});

  @override
  State<QuranReaderScreen> createState() => _QuranReaderScreenState();
}

class _QuranReaderScreenState extends State<QuranReaderScreen> {
  final AudioPlayer _player = AudioPlayer(
    handleInterruptions: false,
    handleAudioSessionActivation: false,
  );

  bool _resolving = true;
  bool _hasRecitation = false;
  bool _isPlaying = false;
  Duration _duration = Duration.zero;
  Duration _position = Duration.zero;
  final List<StreamSubscription<dynamic>> _subs = <StreamSubscription<dynamic>>[];

  Surah get _surah => widget.surah;

  @override
  void initState() {
    super.initState();
    AudioService.quranChime();
    _resolveAndPrepare();
  }

  Future<void> _resolveAndPrepare() async {
    final exists = await RecitationAudio.exists(_surah.audioAsset);
    if (!mounted) return;
    _hasRecitation = exists && AudioService.canPlayAudio;
    if (_hasRecitation) {
      try {
        await _player.setAsset(_surah.audioAsset);
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
        _hasRecitation = false;
      }
    }
    if (mounted) setState(() => _resolving = false);
  }

  @override
  void dispose() {
    for (final sub in _subs) {
      unawaited(sub.cancel());
    }
    _player.dispose();
    super.dispose();
  }

  Future<void> _togglePlay() async {
    HapticFeedback.lightImpact();
    if (!_hasRecitation || !AudioService.canPlayAudio) return;
    if (_player.playing) {
      await _player.pause();
    } else {
      await _player.play();
    }
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
        decoration: BoxDecoration(gradient: _surah.gradient),
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
                      _buildTitleCard(),
                      const SizedBox(height: 14),
                      _buildPlayerCard(),
                      const SizedBox(height: 14),
                      if (_surah.showBasmalaHeader) ...[
                        _buildBasmala(),
                        const SizedBox(height: 14),
                      ],
                      ..._buildVerses(),
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
              '${_surah.coverEmoji} ${_surah.persianName}',
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: AppFonts.kids(
                color: Colors.white,
                fontSize: 19,
                fontWeight: FontWeight.w900,
              ),
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.16),
              borderRadius: BorderRadius.circular(999),
            ),
            child: Text(
              _surah.subtitle,
              style: AppFonts.vazirmatn(
                color: Colors.white70,
                fontSize: 10.5,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTitleCard() {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 22, horizontal: 16),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.13),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.white24),
      ),
      child: Column(
        children: [
          Text(
            _surah.arabicName,
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 26,
              fontWeight: FontWeight.bold,
              height: 1.6,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            _surah.persianName,
            style: AppFonts.kids(
              color: Colors.amberAccent,
              fontSize: 17,
              fontWeight: FontWeight.w900,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPlayerCard() {
    final progress = _duration.inMilliseconds > 0
        ? (_position.inMilliseconds / _duration.inMilliseconds).clamp(0.0, 1.0)
        : 0.0;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.13),
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: Colors.white24),
      ),
      child: _resolving
          ? const Padding(
              padding: EdgeInsets.symmetric(vertical: 14),
              child: Center(
                child: CircularProgressIndicator(color: Colors.white),
              ),
            )
          : _hasRecitation
              ? Column(
                  children: [
                    Row(
                      children: [
                        GestureDetector(
                          onTap: _togglePlay,
                          child: Container(
                            width: 60,
                            height: 60,
                            decoration: const BoxDecoration(
                              color: Colors.white,
                              shape: BoxShape.circle,
                            ),
                            child: Icon(
                              _isPlaying
                                  ? Icons.pause_rounded
                                  : Icons.play_arrow_rounded,
                              color: _surah.themeColor,
                              size: 32,
                            ),
                          ),
                        ),
                        const SizedBox(width: 14),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                _isPlaying
                                    ? 'در حال پخش تلاوت...'
                                    : 'برای شنیدن تلاوت بزن',
                                style: AppFonts.vazirmatn(
                                  color: Colors.white,
                                  fontSize: 13,
                                  fontWeight: FontWeight.w900,
                                ),
                              ),
                              const SizedBox(height: 6),
                              ClipRRect(
                                borderRadius: BorderRadius.circular(8),
                                child: LinearProgressIndicator(
                                  value: progress,
                                  backgroundColor:
                                      Colors.white.withOpacity(0.2),
                                  valueColor:
                                      const AlwaysStoppedAnimation<Color>(
                                          Colors.white),
                                  minHeight: 6,
                                ),
                              ),
                              const SizedBox(height: 6),
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
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
                            ],
                          ),
                        ),
                      ],
                    ),
                  ],
                )
              : _buildRecitationPending(),
    );
  }

  /// حالت نبودِ فایل تلاوت: متن و معنی کامل در دسترس است ولی صدا فعلاً
  /// وجود ندارد؛ با لحن نرم اطلاع‌رسانی می‌شود، نه دکمهٔ خطا.
  Widget _buildRecitationPending() {
    return Row(
      children: [
        Container(
          width: 60,
          height: 60,
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.18),
            shape: BoxShape.circle,
          ),
          child: const Icon(Icons.headphones_rounded,
              color: Colors.white60, size: 28),
        ),
        const SizedBox(width: 14),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'تلاوت این سوره به‌زودی اضافه می‌شود',
                style: AppFonts.vazirmatn(
                  color: Colors.white,
                  fontSize: 13,
                  fontWeight: FontWeight.w900,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                'فعلاً می‌توانی متن عربی و معنی فارسی را بخوانی.',
                style: AppFonts.vazirmatn(
                  color: Colors.white70,
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  height: 1.5,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildBasmala() {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.16),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: Colors.white24),
      ),
      child: const Directionality(
        textDirection: TextDirection.rtl,
        child: Text(
          Surah.basmala,
          textAlign: TextAlign.center,
          style: TextStyle(
            color: Colors.white,
            fontSize: 22,
            fontWeight: FontWeight.bold,
            height: 1.8,
          ),
        ),
      ),
    );
  }

  List<Widget> _buildVerses() {
    final widgets = <Widget>[];
    for (var i = 0; i < _surah.verses.length; i++) {
      final verse = _surah.verses[i];
      widgets.add(
        Container(
          margin: const EdgeInsets.only(bottom: 12),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.12),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: Colors.white24),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                children: [
                  Container(
                    width: 34,
                    height: 34,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: Colors.amberAccent.withOpacity(0.85),
                      shape: BoxShape.circle,
                    ),
                    child: Text(
                      '${i + 1}',
                      style: const TextStyle(
                        color: Color(0xFF4A3200),
                        fontWeight: FontWeight.w900,
                        fontSize: 14,
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Text(
                    'آیه ${i + 1}',
                    style: AppFonts.vazirmatn(
                      color: Colors.amberAccent,
                      fontSize: 12,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Directionality(
                textDirection: TextDirection.rtl,
                child: Text(
                  verse.arabic,
                  textAlign: TextAlign.right,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 21,
                    height: 2.0,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              const SizedBox(height: 10),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.18),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Text(
                  verse.meaning,
                  style: AppFonts.vazirmatn(
                    color: Colors.white.withOpacity(0.92),
                    fontSize: 13,
                    height: 1.8,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    }
    return widgets;
  }
}
