import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:just_audio/just_audio.dart';
import '../../app/app_colors.dart';
import '../../app/app_fonts.dart';
import '../../core/fandoghi_coach.dart';
import '../../core/learning_content/lullabies_data.dart';
import '../../shared/widgets/star_field.dart';

/// 🌙 LULLABY PLAYER — پخش‌کننده لالایی با تصویر، متن و صدای بچگانه
class LullabyPlayerScreen extends StatefulWidget {
  final Lullaby lullaby;
  const LullabyPlayerScreen({super.key, required this.lullaby});

  @override
  State<LullabyPlayerScreen> createState() => _LullabyPlayerScreenState();
}

class _LullabyPlayerScreenState extends State<LullabyPlayerScreen> {
  final AudioPlayer _player = AudioPlayer();
  bool _isPlaying = false;
  bool _isLooping = true;
  bool _isLoading = true;
  Duration _duration = Duration.zero;
  Duration _position = Duration.zero;
  Timer? _sleepTimer;
  int? _sleepMinutes;

  @override
  void initState() {
    super.initState();
    FandoghiCoach.enablePersistentPresence();
    _initAudio();
  }

  Future<void> _initAudio() async {
    try {
      await _player.setAsset(widget.lullaby.audioAsset);
      _duration = _player.duration ?? const Duration(seconds: 150);
      _player.setLoopMode(_isLooping ? LoopMode.one : LoopMode.off);
      _player.positionStream.listen((pos) {
        if (mounted) setState(() => _position = pos);
      });
      _player.playerStateStream.listen((state) {
        if (mounted) {
          setState(() => _isPlaying = state.playing);
          if (state.processingState == ProcessingState.completed && !_isLooping) {
            setState(() => _isPlaying = false);
          }
        }
      });
      _player.durationStream.listen((d) {
        if (d != null && mounted) setState(() => _duration = d);
      });
      setState(() => _isLoading = false);
      // شروع خودکار با تاخیر کوتاه
      Future.delayed(const Duration(milliseconds: 400), () {
        if (mounted) _togglePlay();
      });
    } catch (e) {
      setState(() => _isLoading = false);
    }
  }

  @override
  void dispose() {
    _sleepTimer?.cancel();
    _player.dispose();
    FandoghiCoach.clear();
    super.dispose();
  }

  Future<void> _togglePlay() async {
    HapticFeedback.lightImpact();
    if (_isPlaying) {
      await _player.pause();
    } else {
      await _player.play();
    }
  }

  Future<void> _toggleLoop() async {
    HapticFeedback.selectionClick();
    setState(() => _isLooping = !_isLooping);
    await _player.setLoopMode(_isLooping ? LoopMode.one : LoopMode.off);
  }

  void _setSleepTimer(int minutes) {
    HapticFeedback.lightImpact();
    _sleepTimer?.cancel();
    setState(() => _sleepMinutes = minutes);
    if (minutes == 0) {
      setState(() => _sleepMinutes = null);
      return;
    }
    _sleepTimer = Timer(Duration(minutes: minutes), () {
      _player.pause();
      if (mounted) {
        setState(() {
          _isPlaying = false;
          _sleepMinutes = null;
        });
        FandoghiCoach.say('خوابِ شیرین و آروم 🌙✨', mood: FandoghiMood.happy, duration: const Duration(seconds: 3));
      }
    });
  }

  String _format(Duration d) {
    final m = d.inMinutes.remainder(60).toString().padLeft(2, '0');
    final s = d.inSeconds.remainder(60).toString().padLeft(2, '0');
    return '$m:$s';
  }

  @override
  Widget build(BuildContext context) {
    final l = widget.lullaby;
    return Scaffold(
      body: DecoratedBox(
        decoration: BoxDecoration(gradient: l.gradient),
        child: SafeArea(
          child: Stack(
            children: [
              const Positioned.fill(child: IgnorePointer(child: StarField())),
              Column(
                children: [
                  _buildTopBar(),
                  Expanded(
                    child: SingleChildScrollView(
                      physics: const BouncingScrollPhysics(),
                      padding: const EdgeInsets.fromLTRB(16, 8, 16, 20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          _buildCover(l),
                          const SizedBox(height: 16),
                          _buildControls(l),
                          const SizedBox(height: 16),
                          _buildLyrics(l),
                          const SizedBox(height: 16),
                          _buildMessage(l),
                          const SizedBox(height: 16),
                          _buildSleepTimer(),
                        ],
                      ),
                    ),
                  ),
                ],
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
            onTap: () => Navigator.pop(context),
            child: Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(color: Colors.white.withOpacity(0.15), borderRadius: BorderRadius.circular(16), border: Border.all(color: Colors.white24)),
              child: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white, size: 20),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('${widget.lullaby.coverEmoji} ${widget.lullaby.title}',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: AppFonts.vazirmatn(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w900)),
                Text(widget.lullaby.subtitle, style: const TextStyle(color: Colors.white70, fontSize: 11, fontWeight: FontWeight.bold)),
              ],
            ),
          ),
          GestureDetector(
            onTap: _toggleLoop,
            child: Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: _isLooping ? Colors.amber.withOpacity(0.3) : Colors.white.withOpacity(0.12),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: _isLooping ? Colors.amberAccent : Colors.white24),
              ),
              child: Icon(_isLooping ? Icons.repeat_rounded : Icons.repeat_outlined, color: _isLooping ? Colors.amberAccent : Colors.white, size: 20),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCover(Lullaby l) {
    return Container(
      height: 260,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(26),
        border: Border.all(color: Colors.white.withOpacity(0.4), width: 2),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.25), blurRadius: 16, offset: const Offset(0, 6))],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(24),
        child: Stack(
          fit: StackFit.expand,
          children: [
            Image.asset(l.coverAsset, fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => Container(color: l.themeColor, alignment: Alignment.center, child: Text(l.coverEmoji, style: const TextStyle(fontSize: 80)))),
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  gradient: LinearGradient(colors: [Colors.black.withOpacity(0.6), Colors.transparent], begin: Alignment.bottomCenter, end: Alignment.topCenter),
                ),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(color: Colors.white.withOpacity(0.2), borderRadius: BorderRadius.circular(12)),
                      child: Text('🎧 با صدای بچگانه', style: AppFonts.vazirmatn(color: Colors.white, fontSize: 11, fontWeight: FontWeight.w800)),
                    ),
                    const Spacer(),
                    Text('⏱️ ${l.duration}', style: const TextStyle(color: Colors.white70, fontSize: 11, fontWeight: FontWeight.bold)),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    ).animate().fadeIn(duration: 500.ms).scale(begin: const Offset(0.96, 0.96), end: const Offset(1, 1));
  }

  Widget _buildControls(Lullaby l) {
    final progress = _duration.inMilliseconds > 0 ? (_position.inMilliseconds / _duration.inMilliseconds).clamp(0.0, 1.0) : 0.0;
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(color: Colors.white.withOpacity(0.12), borderRadius: BorderRadius.circular(22), border: Border.all(color: Colors.white24)),
      child: Column(
        children: [
          Row(
            children: [
              GestureDetector(
                onTap: _isLoading ? null : _togglePlay,
                child: Container(
                  width: 64,
                  height: 64,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                    boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.2), blurRadius: 10)],
                  ),
                  child: Icon(_isPlaying ? Icons.pause_rounded : Icons.play_arrow_rounded, color: l.themeColor, size: 36),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(_isPlaying ? 'در حال پخش لالایی...' : 'برای پخش بزن',
                        style: AppFonts.vazirmatn(color: Colors.white, fontSize: 13, fontWeight: FontWeight.w900)),
                    const SizedBox(height: 6),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: LinearProgressIndicator(
                        value: progress,
                        backgroundColor: Colors.white.withOpacity(0.2),
                        valueColor: const AlwaysStoppedAnimation<Color>(Colors.white),
                        minHeight: 6,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(_format(_position), style: const TextStyle(color: Colors.white70, fontSize: 11, fontWeight: FontWeight.bold)),
                        Text(_format(_duration), style: const TextStyle(color: Colors.white70, fontSize: 11, fontWeight: FontWeight.bold)),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _smallBtn(Icons.replay_10_rounded, '۱۰ ثانیه عقب', () async {
                final newPos = _position - const Duration(seconds: 10);
                await _player.seek(newPos.isNegative ? Duration.zero : newPos);
              }),
              const SizedBox(width: 12),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                decoration: BoxDecoration(
                  color: _isLooping ? Colors.amber.withOpacity(0.25) : Colors.white.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: _isLooping ? Colors.amberAccent : Colors.white24),
                ),
                child: Row(
                  children: [
                    Icon(_isLooping ? Icons.repeat_rounded : Icons.repeat_outlined, color: _isLooping ? Colors.amberAccent : Colors.white70, size: 16),
                    const SizedBox(width: 6),
                    Text(_isLooping ? 'تکرار روشن' : 'تکرار خاموش',
                        style: TextStyle(color: _isLooping ? Colors.amberAccent : Colors.white70, fontSize: 11, fontWeight: FontWeight.bold)),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              _smallBtn(Icons.forward_10_rounded, '۱۰ ثانیه جلو', () async {
                final newPos = _position + const Duration(seconds: 10);
                await _player.seek(newPos > _duration ? _duration : newPos);
              }),
            ],
          ),
        ],
      ),
    );
  }

  Widget _smallBtn(IconData icon, String label, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        decoration: BoxDecoration(color: Colors.white.withOpacity(0.12), borderRadius: BorderRadius.circular(14), border: Border.all(color: Colors.white24)),
        child: Row(children: [Icon(icon, color: Colors.white, size: 16), const SizedBox(width: 4), Text(label, style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold))]),
      ),
    );
  }

  Widget _buildLyrics(Lullaby l) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(color: Colors.white.withOpacity(0.12), borderRadius: BorderRadius.circular(22), border: Border.all(color: Colors.white24)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(children: [
            const Text('🎵', style: TextStyle(fontSize: 20)),
            const SizedBox(width: 8),
            Text('متن لالایی', style: AppFonts.vazirmatn(color: Colors.amberAccent, fontSize: 14, fontWeight: FontWeight.w900)),
            const Spacer(),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(color: Colors.white.withOpacity(0.12), borderRadius: BorderRadius.circular(12)),
              child: const Text('با صدای بچگانه 🎧', style: TextStyle(color: Colors.white70, fontSize: 10, fontWeight: FontWeight.bold)),
            ),
          ]),
          const SizedBox(height: 14),
          ...l.lyrics.map((line) {
            if (line.trim().isEmpty) return const SizedBox(height: 10);
            return Padding(
              padding: const EdgeInsets.symmetric(vertical: 3),
              child: Text(line, style: AppFonts.vazirmatn(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w700, height: 1.7)),
            );
          }),
        ],
      ),
    );
  }

  Widget _buildMessage(Lullaby l) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: const LinearGradient(colors: [Color(0xFF6C5CE7), Color(0xFFA29BFE)]),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        children: [
          const Text('💜', style: TextStyle(fontSize: 28)),
          const SizedBox(width: 12),
          Expanded(child: Text(l.lullabyMessage, style: AppFonts.vazirmatn(color: Colors.white, fontSize: 13, fontWeight: FontWeight.w800, height: 1.6))),
        ],
      ),
    );
  }

  Widget _buildSleepTimer() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: Colors.black.withOpacity(0.25), borderRadius: BorderRadius.circular(20), border: Border.all(color: Colors.white12)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(children: [
            const Icon(Icons.bedtime_rounded, color: Colors.amberAccent, size: 20),
            const SizedBox(width: 8),
            Text('تایمر خواب', style: AppFonts.vazirmatn(color: Colors.white, fontSize: 13, fontWeight: FontWeight.w900)),
            const Spacer(),
            if (_sleepMinutes != null)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(color: Colors.green.withOpacity(0.3), borderRadius: BorderRadius.circular(12)),
                child: Text('⏰ $_sleepMinutes دقیقه', style: const TextStyle(color: Colors.greenAccent, fontSize: 11, fontWeight: FontWeight.bold)),
              ),
          ]),
          const SizedBox(height: 10),
          Row(
            children: [
              _timerChip('خاموش', 0, _sleepMinutes == null || _sleepMinutes == 0),
              _timerChip('۵ دقیقه', 5, _sleepMinutes == 5),
              _timerChip('۱۵ دقیقه', 15, _sleepMinutes == 15),
              _timerChip('۳۰ دقیقه', 30, _sleepMinutes == 30),
            ],
          ),
        ],
      ),
    );
  }

  Widget _timerChip(String label, int minutes, bool selected) {
    return Expanded(
      child: GestureDetector(
        onTap: () => _setSleepTimer(minutes),
        child: Container(
          margin: const EdgeInsets.only(left: 6),
          padding: const EdgeInsets.symmetric(vertical: 8),
          decoration: BoxDecoration(
            color: selected ? Colors.amber : Colors.white.withOpacity(0.12),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: selected ? Colors.amberAccent : Colors.white24),
          ),
          child: Text(label, textAlign: TextAlign.center, style: TextStyle(color: selected ? Colors.black87 : Colors.white, fontSize: 11, fontWeight: FontWeight.w800)),
        ),
      ),
    );
  }
}
