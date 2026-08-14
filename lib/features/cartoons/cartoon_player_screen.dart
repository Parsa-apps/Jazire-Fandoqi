import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:jazireh_fandoghi/app/app_colors.dart';
import 'package:jazireh_fandoghi/app/app_fonts.dart';
import 'package:jazireh_fandoghi/core/audio_service.dart';
import 'package:jazireh_fandoghi/core/cartoons/aparat_service.dart';
import 'package:jazireh_fandoghi/core/cartoons/cartoon_data.dart';
import 'package:video_player/video_player.dart';
import 'package:jazireh_fandoghi/core/fandoghi_coach.dart';
import 'package:jazireh_fandoghi/core/game_data.dart';
import 'package:jazireh_fandoghi/features/cartoons/widgets/cartoon_cover.dart';
import 'package:jazireh_fandoghi/features/cartoons/widgets/cartoon_rating_dialog.dart';
import 'package:jazireh_fandoghi/features/cartoons/widgets/cartoon_trivia_dialog.dart';
import 'package:jazireh_fandoghi/shared/widgets/fandoghi_v2.dart';
import 'package:jazireh_fandoghi/shared/widgets/star_field.dart';

/// ═══════════════════════════════════════════════════════════════
/// 🍿 CARTOON PLAYER SCREEN — سینما کارتون فوق حرفه‌ای کودک
/// ═══════════════════════════════════════════════════════════════
class CartoonPlayerScreen extends StatefulWidget {
  final Cartoon cartoon;
  final int initialEpisodeIndex;

  const CartoonPlayerScreen({
    super.key,
    required this.cartoon,
    this.initialEpisodeIndex = 0,
  });

  @override
  State<CartoonPlayerScreen> createState() => _CartoonPlayerScreenState();
}

class _CartoonPlayerScreenState extends State<CartoonPlayerScreen>
    with TickerProviderStateMixin {
  late int _currentEpIndex;
  bool _isPlaying = true;
  double _progress = 0.15;
  int _secondsWatched = 0;
  Timer? _playbackTimer;

  // پخش‌کننده واقعی (لینک مستقیم از سرور آپارات / CDN ایران)
  VideoPlayerController? _controller;
  bool _videoReady = false;
  bool _videoLoading = false;
  bool _videoError = false;
  String? _videoErrorMsg;
  String? _posterUrl;
  int _positionMs = 0;
  int _durationMs = 0;

  // Pro cinema features
  bool _cinemaDimMode = false;
  bool _childLock = false;
  bool _eyeProtectMode = false;
  String _selectedQuality = '720p';
  double _playbackSpeed = 1.0;

  // Popcorn minigame
  int _popcornTaps = 0;
  final List<_PopcornParticle> _popcornParticles = [];

  // Controllers for cinema atmosphere
  late AnimationController _beamCtrl;
  late AnimationController _pulseCtrl;

  @override
  void initState() {
    super.initState();
    _currentEpIndex = widget.initialEpisodeIndex.clamp(0, widget.cartoon.episodes.length - 1);

    _beamCtrl = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 4),
    )..repeat(reverse: true);

    _pulseCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..repeat(reverse: true);

    // بارگذاری ویدیوی واقعی (لینک مستقیم از سرورهای ایران)
    _loadCurrentEpisode();

    // پایش موقعیت پخش واقعی + ثبت زمان تماشا
    _playbackTimer = Timer.periodic(const Duration(milliseconds: 500), (timer) {
      if (!mounted) return;
      if (_controller != null && _videoReady) {
        final pos = _controller!.value.position;
        final dur = _controller!.value.duration;
        setState(() {
          _positionMs = pos.inMilliseconds;
          _durationMs = dur.inMilliseconds;
        });
        if (_controller!.value.isPlaying && !_childLock) {
          _secondsWatched++;
          GameData.recordCartoonWatched(widget.cartoon.id, durationSeconds: 1);
        }
      }
    });

    // Fandoghi welcome message
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        FandoghiCoach.say(
          'به سینمای فندقی خوش اومدی! پاپ‌کورن بخور و از کارتون «${widget.cartoon.title}» لذت ببر 🍿🎬',
          mood: FandoghiMood.excited,
          duration: const Duration(seconds: 4),
        );
      }
    });
  }

  @override
  void dispose() {
    _playbackTimer?.cancel();
    _controller?.removeListener(_videoListener);
    _controller?.dispose();
    _beamCtrl.dispose();
    _pulseCtrl.dispose();
    super.dispose();
  }

  CartoonEpisode get _currentEpisode => widget.cartoon.episodes[_currentEpIndex];

  void _videoListener() {
    if (!mounted || _controller == null) return;
    if (_controller!.value.isInitialized) {
      final dur = _controller!.value.duration.inMilliseconds;
      final pos = _controller!.value.position.inMilliseconds;
      if (dur > 1000 && pos >= dur - 600) {
        _onEpisodeFinished();
      }
    }
  }

  void _onEpisodeFinished() {
    _progress = 0.0;
    if (_currentEpIndex + 1 < widget.cartoon.episodes.length) {
      _selectEpisode(_currentEpIndex + 1);
    } else {
      _isPlaying = false;
      if (_controller != null && _videoReady) {
        _controller!.pause();
      }
      // Auto open trivia after finishing all
      _openTrivia();
    }
  }

  String? _pickUrl(AparatResolved resolved) {
    if (!resolved.hasSource) return null;
    final wanted = _selectedQuality;
    VideoStream? exact;
    VideoStream? fallback;
    for (final s in resolved.streams) {
      final q = s.quality.toLowerCase();
      if (q.contains(wanted.toLowerCase()) || wanted.toLowerCase().contains(q)) {
        exact ??= s;
      } else if (q.contains('480') || q.contains('360')) {
        fallback ??= s;
      } else if (fallback == null) {
        fallback = s;
      }
    }
    return (exact ?? fallback ?? resolved.streams.first).url;
  }

  Future<void> _loadCurrentEpisode() async {
    if (_childLock) return;
    _controller?.removeListener(_videoListener);
    await _controller?.dispose();
    _controller = null;

    if (!mounted) return;
    setState(() {
      _videoReady = false;
      _videoError = false;
      _videoErrorMsg = null;
      _videoLoading = true;
      _positionMs = 0;
      _durationMs = 0;
    });

    final ep = _currentEpisode;

    // 🛡️ ایمنی کودک (C2): فقط قسمت‌های تأییدشدهٔ کاتالوگ پخش می‌شوند.
    // اگر لینک CDN ثابتی در بانک اطلاعاتی تعریف شده باشد، باید از دامنه‌های
    // مجاز آپارات و روی HTTPS باشد؛ در غیر این صورت نادیده گرفته می‌شود.
    // هیچ جستجوی متنی و هیچ ویدیوی جایگزینی در کار نیست.
    AparatResolved resolved;
    final directUrl = ep.streamUrl?.trim() ?? '';
    if (directUrl.isNotEmpty && AparatService.isPlayableStreamUrl(directUrl)) {
      resolved = AparatResolved(
        streams: [VideoStream(url: directUrl, quality: 'auto')],
      );
    } else {
      resolved = await AparatService.resolve(videoHash: ep.aparatHash);
    }

    if (!mounted) return;

    final url = _pickUrl(resolved);
    // آخرین خط دفاعی قبل از تحویل آدرس به پلیر.
    if (url != null && !AparatService.isPlayableStreamUrl(url)) {
      setState(() {
        _videoLoading = false;
        _videoError = true;
        _videoErrorMsg = 'این قسمت الان قابل پخش نیست. بعداً دوباره امتحان کن.';
      });
      return;
    }
    if (url == null) {
      setState(() {
        _videoLoading = false;
        _videoError = true;
        _videoErrorMsg = 'لینک پخش در دسترس نیست. اینترنت را بررسی کن یا بعداً امتحان کن.';
      });
      return;
    }

    try {
      final controller = VideoPlayerController.networkUrl(Uri.parse(url));
      _controller = controller;
      controller.addListener(_videoListener);
      await controller.initialize();
      if (!mounted) {
        controller.dispose();
        return;
      }
      await controller.setLooping(false);
      await controller.setVolume(AudioService.canPlayAudio ? 1.0 : 0.0);
      await controller.setPlaybackSpeed(_playbackSpeed.clamp(0.5, 2.0));
      if (_isPlaying) {
        await controller.play();
      }
      setState(() {
        _videoReady = true;
        _videoLoading = false;
        _posterUrl = resolved.posterUrl;
      });
    } catch (e) {
      if (mounted) {
        setState(() {
          _videoLoading = false;
          _videoError = true;
          _videoErrorMsg = 'خطا در بارگذاری ویدیو. دوباره تلاش کن.';
        });
      }
    }
  }

  Future<void> _retryLoad() => _loadCurrentEpisode();

  Future<void> _changeQuality(String quality) async {
    if (_childLock) return;
    if (_selectedQuality == quality && _videoReady) return;
    HapticFeedback.selectionClick();
    if (!mounted) return;
    setState(() => _selectedQuality = quality);
    await _loadCurrentEpisode();
    FandoghiCoach.say('کیفیت به $quality تغییر یافت! ✨', mood: FandoghiMood.happy);
  }

  void _enterFullscreen() {
    if (_childLock) return;
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => _FullscreenVideo(controller: _controller, color: widget.cartoon.themeColor),
      ),
    );
  }

  void _togglePlayPause() {
    if (_childLock) return;
    HapticFeedback.lightImpact();
    if (_controller != null && _videoReady) {
      if (_controller!.value.isPlaying) {
        _controller!.pause();
        setState(() => _isPlaying = false);
        FandoghiCoach.say('کارتون متوقف شد ⏸', mood: FandoghiMood.thinking);
      } else {
        _controller!.play();
        setState(() => _isPlaying = true);
        FandoghiCoach.say('کارتون ادامه پیدا کرد! ▶', mood: FandoghiMood.happy);
      }
      return;
    }
    setState(() => _isPlaying = !_isPlaying);
  }

  void _seekRelative(double delta) {
    if (_childLock) return;
    HapticFeedback.selectionClick();
    if (_controller != null && _videoReady) {
      final cur = _controller!.value.position.inMilliseconds;
      final dur = _controller!.value.duration.inMilliseconds;
      final target = (cur + (delta * 10 * 1000).round()).clamp(0, dur);
      _controller!.seekTo(Duration(milliseconds: target));
      return;
    }
    setState(() {
      _progress = (_progress + delta).clamp(0.0, 1.0);
    });
  }

  void _cycleSpeed() {
    if (_childLock) return;
    HapticFeedback.selectionClick();
    setState(() {
      if (_playbackSpeed == 0.75) {
        _playbackSpeed = 1.0;
      } else if (_playbackSpeed == 1.0) {
        _playbackSpeed = 1.25;
      } else {
        _playbackSpeed = 0.75;
      }
    });
    FandoghiCoach.say('سرعت پخش: ${_playbackSpeed}x ⚡', mood: FandoghiMood.wink);
  }

  void _showQualityDialog() {
    if (_childLock) return;
    HapticFeedback.selectionClick();
    showDialog<void>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        title: const Row(
          children: [
            Icon(Icons.high_quality_rounded, color: Colors.blueAccent),
            SizedBox(width: 8),
            Text('کیفیت پخش ویدیو', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _qualityTile('1080p HD (بالاترین کیفیت) 🌟', '1080p', ctx),
            _qualityTile('720p استاندارد (مصرف متناسب) ⚡', '720p', ctx),
            _qualityTile('480p اقتصادی (صرفه‌جویی در اینترنت) 📱', '480p', ctx),
            _qualityTile('360p سبک (اینترنت کند) 🐢', '360p', ctx),
          ],
        ),
      ),
    );
  }

  Widget _qualityTile(String label, String value, BuildContext dialogCtx) {
    final selected = _selectedQuality == value;
    return ListTile(
      title: Text(label, style: TextStyle(fontWeight: selected ? FontWeight.bold : FontWeight.normal, fontSize: 13)),
      trailing: selected ? const Icon(Icons.check_circle_rounded, color: Colors.green) : null,
      onTap: () {
        Navigator.pop(dialogCtx);
        _changeQuality(value);
      },
    );
  }

  void _playCatchphrase() {
    if (_childLock) return;
    HapticFeedback.mediumImpact();
    final phrase = _currentEpisode.catchphrase.isNotEmpty
        ? _currentEpisode.catchphrase
        : widget.cartoon.catchphrase;
    if (phrase.isNotEmpty) {
      AudioService.speak(phrase);
      FandoghiCoach.say(phrase, mood: FandoghiMood.excited, duration: const Duration(seconds: 4));
    }
  }

  void _openTrivia() {
    if (_childLock) return;
    HapticFeedback.mediumImpact();
    CartoonTriviaDialog.show(
      context,
      cartoon: widget.cartoon,
      episode: _currentEpisode,
    );
  }

  void _onPopcornTap() {
    if (_childLock) return;
    HapticFeedback.mediumImpact();
    setState(() {
      _popcornTaps++;
      final random = Random();
      for (int i = 0; i < 4; i++) {
        _popcornParticles.add(_PopcornParticle(
          x: 40.0 + random.nextDouble() * 30,
          y: 40.0 + random.nextDouble() * 30,
          vx: (random.nextDouble() - 0.5) * 60,
          vy: -40.0 - random.nextDouble() * 50,
          emoji: ['🍿', '✨', '⭐', '🌽'][random.nextInt(4)],
        ));
      }
      if (_popcornParticles.length > 20) {
        _popcornParticles.removeRange(0, 10);
      }
    });

    if (_popcornTaps % 5 == 0) {
      GameData.addCoins(1);
      FandoghiCoach.say('به‌به! یک سکه پاپ‌کورنی گرفتی! 🪙🍿', mood: FandoghiMood.excited);
    }
  }

  void _selectEpisode(int index) {
    if (_childLock) return;
    if (index == _currentEpIndex) return;
    HapticFeedback.mediumImpact();
    setState(() {
      _currentEpIndex = index;
      _progress = 0.0;
      _isPlaying = true;
    });
    FandoghiCoach.say(
      'قسمت ${_currentEpisode.episodeNumber}: ${_currentEpisode.title} شروع شد! 🎬',
      mood: FandoghiMood.happy,
    );
    _loadCurrentEpisode();
  }

  void _toggleFavorite() {
    if (_childLock) return;
    HapticFeedback.lightImpact();
    GameData.toggleCartoonFavorite(widget.cartoon.id);
    setState(() {});
  }

  void _toggleChildLock() {
    HapticFeedback.heavyImpact();
    setState(() => _childLock = !_childLock);
    if (_childLock) {
      FandoghiCoach.say('🔒 قفل کودک فعال شد! برای باز کردن، روی علامت قفل ۲ ثانیه نگه دارید.', mood: FandoghiMood.wink);
    } else {
      FandoghiCoach.say('🔓 قفل کودک باز شد!', mood: FandoghiMood.happy);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isFav = GameData.isCartoonFavorite(widget.cartoon.id);

    return Scaffold(
      backgroundColor: _cinemaDimMode ? Colors.black : const Color(0xFF0F0C20),
      body: Stack(
        children: [
          // Cinema Starfield
          if (!_cinemaDimMode) const StarFieldBackground(starCount: 45),

          // Projector Beam
          _buildProjectorBeam(),

          // Eye Protection Warm Filter
          if (_eyeProtectMode)
            Positioned.fill(
              child: IgnorePointer(
                child: Container(color: Colors.amber.withOpacity(0.09)),
              ),
            ),

          // Main Content
          SafeArea(
            child: Column(
              children: [
                // Top App Bar
                _buildTopBar(isFav),

                // Cinema Screen & Video Player Area
                Expanded(
                  child: SingleChildScrollView(
                    physics: _childLock ? const NeverScrollableScrollPhysics() : const BouncingScrollPhysics(),
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 8),

                        // Cinema Theater Box
                        _buildCinemaScreen(),

                        const SizedBox(height: 14),

                        // Cinema Quick Toolbar (Trivia, Voice, Dim, Speed, Quality, Lock)
                        if (!_childLock) _buildCinemaToolbar(),

                        const SizedBox(height: 16),

                        // Cartoon Details & Quick Actions
                        if (!_childLock) _buildCartoonInfo(),

                        const SizedBox(height: 20),

                        // Interactive Popcorn Minigame & Rating Prompt
                        if (!_childLock) _buildPopcornAndRatingRow(),

                        const SizedBox(height: 24),

                        // Episodes Playlist
                        if (!_childLock) _buildEpisodesPlaylist(),

                        const SizedBox(height: 30),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Child Lock Floating Indicator
          if (_childLock) _buildChildLockFloatingPill(),
        ],
      ),
    );
  }

  Widget _buildChildLockFloatingPill() {
    return Positioned(
      bottom: 30,
      left: 0,
      right: 0,
      child: Center(
        child: GestureDetector(
          onLongPress: _toggleChildLock,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            decoration: BoxDecoration(
              color: Colors.redAccent.withOpacity(0.9),
              borderRadius: BorderRadius.circular(30),
              boxShadow: [
                BoxShadow(
                  color: Colors.redAccent.withOpacity(0.4),
                  blurRadius: 15,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: const Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.lock_rounded, color: Colors.white, size: 22),
                SizedBox(width: 8),
                Text(
                  'قفل لمس کودک فعال است (نگه دارید تا باز شود)',
                  style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 12),
                ),
              ],
            ),
          ).animate(onPlay: (c) => c.repeat(reverse: true)).scale(begin: const Offset(0.98, 0.98), end: const Offset(1.02, 1.02), duration: 1000.ms),
        ),
      ),
    );
  }

  Widget _buildProjectorBeam() {
    return AnimatedBuilder(
      animation: _beamCtrl,
      builder: (context, _) {
        return Positioned(
          top: 0,
          left: 0,
          right: 0,
          height: 300,
          child: Opacity(
            opacity: _cinemaDimMode ? 0.04 : (0.12 + _beamCtrl.value * 0.08),
            child: Container(
              decoration: BoxDecoration(
                gradient: RadialGradient(
                  center: const Alignment(0, -0.6),
                  radius: 1.2,
                  colors: [
                    widget.cartoon.themeColor.withOpacity(0.4),
                    Colors.purple.withOpacity(0.15),
                    Colors.transparent,
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildTopBar(bool isFav) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        children: [
          // Back Button
          GestureDetector(
            onTap: () {
              if (!_childLock) Navigator.of(context).pop();
            },
            child: Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.12),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.white24),
              ),
              child: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white, size: 20),
            ),
          ),
          const SizedBox(width: 12),

          // Title
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      widget.cartoon.title,
                      style: AppFonts.vazirmatn(
                        fontSize: 18,
                        fontWeight: FontWeight.w900,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                      decoration: BoxDecoration(
                        color: widget.cartoon.themeColor.withOpacity(0.3),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: widget.cartoon.themeColor.withOpacity(0.6)),
                      ),
                      child: Text(
                        widget.cartoon.ageRating,
                        style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ],
                ),
                Text(
                  _currentEpisode.title,
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.white.withOpacity(0.7),
                    fontWeight: FontWeight.w500,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),

          // Eye Protection Mode
          GestureDetector(
            onTap: () {
              if (_childLock) return;
              HapticFeedback.lightImpact();
              setState(() => _eyeProtectMode = !_eyeProtectMode);
              FandoghiCoach.say(_eyeProtectMode ? 'حالت محافظت از چشم فعال شد 👁️' : 'حالت عادی ☀️', mood: FandoghiMood.happy);
            },
            child: Container(
              margin: const EdgeInsets.only(left: 6),
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: _eyeProtectMode ? Colors.orangeAccent.withOpacity(0.3) : Colors.white.withOpacity(0.12),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: _eyeProtectMode ? Colors.orangeAccent : Colors.white24),
              ),
              child: Icon(
                Icons.remove_red_eye_rounded,
                color: _eyeProtectMode ? Colors.orangeAccent : Colors.white70,
                size: 20,
              ),
            ),
          ),

          // Cinema Light Dimmer
          GestureDetector(
            onTap: () {
              if (_childLock) return;
              HapticFeedback.lightImpact();
              setState(() => _cinemaDimMode = !_cinemaDimMode);
            },
            child: Container(
              margin: const EdgeInsets.only(left: 6),
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: _cinemaDimMode ? Colors.amber.withOpacity(0.2) : Colors.white.withOpacity(0.12),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: _cinemaDimMode ? Colors.amber : Colors.white24),
              ),
              child: Icon(
                _cinemaDimMode ? Icons.lightbulb_rounded : Icons.lightbulb_outline_rounded,
                color: _cinemaDimMode ? Colors.amber : Colors.white70,
                size: 20,
              ),
            ),
          ),

          // Child Lock Toggle Button
          GestureDetector(
            onTap: _toggleChildLock,
            child: Container(
              margin: const EdgeInsets.only(left: 6),
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: _childLock ? Colors.redAccent.withOpacity(0.3) : Colors.white.withOpacity(0.12),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: _childLock ? Colors.redAccent : Colors.white24),
              ),
              child: Icon(
                _childLock ? Icons.lock_rounded : Icons.lock_open_rounded,
                color: _childLock ? Colors.redAccent : Colors.white70,
                size: 20,
              ),
            ),
          ),

          // Favorite Button
          GestureDetector(
            onTap: _toggleFavorite,
            child: Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: isFav ? Colors.redAccent.withOpacity(0.2) : Colors.white.withOpacity(0.12),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: isFav ? Colors.redAccent : Colors.white24),
              ),
              child: Icon(
                isFav ? Icons.favorite_rounded : Icons.favorite_border_rounded,
                color: isFav ? Colors.redAccent : Colors.white,
                size: 20,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCinemaScreen() {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF1E1B38),
        borderRadius: BorderRadius.circular(28),
        boxShadow: [
          BoxShadow(
            color: widget.cartoon.themeColor.withOpacity(0.35),
            blurRadius: 25,
            spreadRadius: 2,
            offset: const Offset(0, 8),
          ),
        ],
        border: Border.all(
          color: widget.cartoon.themeColor.withOpacity(0.5),
          width: 2,
        ),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(26),
        child: Column(
          children: [
            // Video Display Frame
            AspectRatio(
              aspectRatio: 16 / 9,
              child: Stack(
                fit: StackFit.expand,
                children: [
                  // لایه پس‌زمینه (پوستر / نماد کارتون)
                  if (widget.cartoon.coverAsset != null && widget.cartoon.coverAsset!.isNotEmpty)
                    Positioned.fill(
                      child: Image.asset(
                        widget.cartoon.coverAsset!,
                        fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) => Container(
                          decoration: BoxDecoration(gradient: widget.cartoon.gradient),
                          child: Center(
                            child: Text(_currentEpisode.coverEmoji, style: const TextStyle(fontSize: 64)),
                          ),
                        ),
                      ),
                    )
                  else if (_posterUrl != null)
                    Positioned.fill(
                      child: Image.network(
                        _posterUrl!,
                        fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) => Container(
                          decoration: BoxDecoration(gradient: widget.cartoon.gradient),
                          child: Center(
                            child: Text(_currentEpisode.coverEmoji, style: const TextStyle(fontSize: 64)),
                          ),
                        ),
                      ),
                    )
                  else
                    Positioned.fill(
                      child: Container(
                        decoration: BoxDecoration(gradient: widget.cartoon.gradient),
                        child: Center(
                          child: Text(_currentEpisode.coverEmoji, style: const TextStyle(fontSize: 64))
                              .animate(onPlay: (c) => c.repeat(reverse: true))
                              .scale(begin: const Offset(0.9, 0.9), end: const Offset(1.1, 1.1), duration: 1500.ms),
                        ),
                      ),
                    ),

                  // پخش‌کننده واقعی ویدیو
                  if (_controller != null && _videoReady)
                    Positioned.fill(
                      child: GestureDetector(
                        onTap: _togglePlayPause,
                        child: VideoPlayer(_controller!),
                      ),
                    ),

                  // نوار بارگذاری
                  if (_videoLoading)
                    const Positioned.fill(
                      child: Center(
                        child: CircularProgressIndicator(color: Colors.white, strokeWidth: 3),
                      ),
                    ),

                  // پیام خطا + تلاش دوباره
                  if (_videoError)
                    Positioned.fill(
                      child: Container(
                        color: Colors.black.withOpacity(0.65),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(Icons.cloud_off_rounded, color: Colors.white, size: 44),
                            const SizedBox(height: 10),
                            Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 20),
                              child: Text(
                                _videoErrorMsg ?? 'خطا در پخش ویدیو.',
                                textAlign: TextAlign.center,
                                style: const TextStyle(color: Colors.white, fontSize: 13),
                              ),
                            ),
                            const SizedBox(height: 12),
                            GestureDetector(
                              onTap: _childLock ? null : _retryLoad,
                              child: Container(
                                padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 8),
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                child: const Text('تلاش دوباره', style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold, fontSize: 13)),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),

                  // دکمه مرکزی پخش/توقف
                  if (!_videoLoading && !_videoError)
                    Center(
                      child: GestureDetector(
                        onTap: _togglePlayPause,
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 300),
                          width: 64,
                          height: 64,
                          decoration: BoxDecoration(
                            color: Colors.black.withOpacity(0.55),
                            shape: BoxShape.circle,
                            border: Border.all(color: Colors.white, width: 2.5),
                          ),
                          child: Icon(
                            (_controller != null && _videoReady && _controller!.value.isPlaying)
                                ? Icons.pause_rounded
                                : Icons.play_arrow_rounded,
                            color: Colors.white,
                            size: 38,
                          ),
                        ),
                      ),
                    ),

                  // دکمه تمام‌صفحه
                  Positioned(
                    top: 10,
                    right: 70,
                    child: GestureDetector(
                      onTap: _childLock ? null : _enterFullscreen,
                      child: Container(
                        padding: const EdgeInsets.all(6),
                        decoration: BoxDecoration(
                          color: Colors.black.withOpacity(0.6),
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(color: Colors.white54),
                        ),
                        child: const Icon(Icons.fullscreen_rounded, color: Colors.white, size: 18),
                      ),
                    ),
                  ),

                  // Quality Badge (Tap to change quality)
                  Positioned(
                    top: 10,
                    right: 12,
                    child: GestureDetector(
                      onTap: _showQualityDialog,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                        decoration: BoxDecoration(
                          color: Colors.black.withOpacity(0.6),
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(color: Colors.amber.withOpacity(0.7)),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(Icons.hd_rounded, color: Colors.amber, size: 16),
                            const SizedBox(width: 4),
                            Text(_selectedQuality, style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold)),
                          ],
                        ),
                      ),
                    ),
                  ),

                  // Episode Number Badge
                  Positioned(
                    top: 10,
                    left: 12,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
                      decoration: BoxDecoration(
                        color: AppColors.primaryDark.withOpacity(0.8),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Text(
                        'قسمت ${_currentEpisode.episodeNumber}',
                        style: const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // Controls Bar
            Container(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 14),
              color: const Color(0xFF16142A),
              child: Column(
                children: [
                  Row(
                    children: [
                      Text(
                        _formatTime(_durationMs > 0 ? _positionMs : (_progress * _estimatedDurationMs()).round()),
                        style: const TextStyle(color: Colors.white70, fontSize: 11, fontWeight: FontWeight.bold),
                      ),
                      Expanded(
                        child: SliderTheme(
                          data: SliderTheme.of(context).copyWith(
                            trackHeight: 4,
                            thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 7),
                            overlayShape: const RoundSliderOverlayShape(overlayRadius: 14),
                            activeTrackColor: widget.cartoon.themeColor,
                            inactiveTrackColor: Colors.white24,
                            thumbColor: Colors.white,
                          ),
                          child: Slider(
                            value: (_durationMs > 1000 ? _positionMs : (_progress * _estimatedDurationMs()).round())
                                .toDouble()
                                .clamp(0, _maxSliderMs().toDouble()),
                            max: _maxSliderMs().toDouble(),
                            onChanged: _childLock
                                ? null
                                : (val) {
                                    if (_controller != null && _videoReady && _durationMs > 1000) {
                                      _controller!.seekTo(Duration(milliseconds: val.round()));
                                    } else {
                                      setState(() => _progress = (val / _estimatedDurationMs()).clamp(0.0, 1.0));
                                    }
                                  },
                          ),
                        ),
                      ),
                      Text(
                        _formatTime(_durationMs > 0 ? _durationMs : _estimatedDurationMs()),
                        style: const TextStyle(color: Colors.white70, fontSize: 11, fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      IconButton(
                        onPressed: _childLock ? null : () => _seekRelative(-1.0),
                        icon: const Icon(Icons.replay_10_rounded, color: Colors.white, size: 28),
                        tooltip: '۱۰ ثانیه عقب',
                      ),
                      GestureDetector(
                        onTap: _togglePlayPause,
                        child: Container(
                          width: 52,
                          height: 52,
                          decoration: BoxDecoration(
                            gradient: widget.cartoon.gradient,
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                color: widget.cartoon.themeColor.withOpacity(0.5),
                                blurRadius: 12,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: Icon(
                            _isPlaying ? Icons.pause_rounded : Icons.play_arrow_rounded,
                            color: Colors.white,
                            size: 32,
                          ),
                        ),
                      ),
                      IconButton(
                        onPressed: _childLock ? null : () => _seekRelative(1.0),
                        icon: const Icon(Icons.forward_10_rounded, color: Colors.white, size: 28),
                        tooltip: '۱۰ ثانیه جلو',
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCinemaToolbar() {
    return Row(
      children: [
        // 1. Trivia Riddle Button
        Expanded(
          flex: 2,
          child: GestureDetector(
            onTap: _openTrivia,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
              decoration: BoxDecoration(
                color: Colors.amber.withOpacity(0.18),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.amber.withOpacity(0.5)),
              ),
              child: const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text('💡', style: TextStyle(fontSize: 16)),
                  SizedBox(width: 6),
                  Text(
                    'معمای فندقی (+۱۰ سکه)',
                    style: TextStyle(color: Colors.amber, fontWeight: FontWeight.bold, fontSize: 12),
                  ),
                ],
              ),
            ),
          ),
        ),

        const SizedBox(width: 8),

        // 2. Character Catchphrase Voice Button
        Expanded(
          flex: 2,
          child: GestureDetector(
            onTap: _playCatchphrase,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
              decoration: BoxDecoration(
                color: AppColors.primary.withOpacity(0.2),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppColors.primary.withOpacity(0.5)),
              ),
              child: const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text('🎙️', style: TextStyle(fontSize: 16)),
                  SizedBox(width: 6),
                  Text(
                    'صدای شخصیت',
                    style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 12),
                  ),
                ],
              ),
            ),
          ),
        ),

        const SizedBox(width: 8),

        // 3. Playback Speed Selector
        GestureDetector(
          onTap: _cycleSpeed,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.1),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: Colors.white24),
            ),
            child: Text(
              '${_playbackSpeed}x',
              style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 12),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildCartoonInfo() {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.07),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.white12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(14),
                child: SizedBox(
                  width: 52,
                  height: 52,
                  child: CartoonCoverImage(
                    videoHash: _currentEpisode.aparatHash,
                    coverAsset: _currentEpisode.coverAsset ?? widget.cartoon.coverAsset,
                    fallbackEmoji: widget.cartoon.coverEmoji,
                    fallbackGradient: widget.cartoon.gradient,
                    emojiSize: 24,
                    cacheWidth: 160,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.cartoon.title,
                      style: AppFonts.vazirmatn(
                        fontSize: 17,
                        fontWeight: FontWeight.w900,
                        color: Colors.white,
                      ),
                    ),
                    Text(
                      'شخصیت‌ها: ${widget.cartoon.characterName}',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.white.withOpacity(0.7),
                      ),
                    ),
                  ],
                ),
              ),
              Row(
                children: [
                  const Icon(Icons.star_rounded, color: Colors.amber, size: 20),
                  const SizedBox(width: 4),
                  Text(
                    '${widget.cartoon.rating}',
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            widget.cartoon.description,
            style: TextStyle(
              fontSize: 13,
              color: Colors.white.withOpacity(0.85),
              height: 1.5,
            ),
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: AppColors.success.withOpacity(0.15),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: AppColors.success.withOpacity(0.4)),
            ),
            child: Row(
              children: [
                const Icon(Icons.lightbulb_rounded, color: AppColors.successLight, size: 18),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'هدف آموزشی: ${widget.cartoon.learningGoal}',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPopcornAndRatingRow() {
    return Row(
      children: [
        // Popcorn Interactive Button
        Expanded(
          child: GestureDetector(
            onTap: _onPopcornTap,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFFFF9F43), Color(0xFFFF6B6B)],
                ),
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: Colors.orange.withOpacity(0.3),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Row(
                children: [
                  const Text('🍿', style: TextStyle(fontSize: 28)),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'پاپ‌کورن فندقی',
                          style: AppFonts.vazirmatn(
                            color: Colors.white,
                            fontSize: 13,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                        Text(
                          'تپ کن سکه بگیر! ($_popcornTaps)',
                          style: const TextStyle(color: Colors.white70, fontSize: 10),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),

        const SizedBox(width: 12),

        // 5-Star Rating Button
        Expanded(
          child: GestureDetector(
            onTap: () => CartoonRatingDialog.show(context),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF6C5CE7), Color(0xFFA29BFE)],
                ),
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.primary.withOpacity(0.3),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Row(
                children: [
                  const Text('⭐', style: TextStyle(fontSize: 28)),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'ثبت ۵ ستاره',
                          style: AppFonts.vazirmatn(
                            color: Colors.white,
                            fontSize: 13,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                        const Text(
                          '+۵۰ سکه هدیه! 🎁',
                          style: TextStyle(color: Colors.amberAccent, fontSize: 10, fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildEpisodesPlaylist() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Icon(Icons.playlist_play_rounded, color: Colors.amber, size: 24),
            const SizedBox(width: 8),
            Text(
              'قسمت‌های دیگر این کارتون (${widget.cartoon.episodes.length} قسمت)',
              style: AppFonts.vazirmatn(
                fontSize: 16,
                fontWeight: FontWeight.w800,
                color: Colors.white,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        ...List.generate(widget.cartoon.episodes.length, (index) {
          final ep = widget.cartoon.episodes[index];
          final isCurrent = index == _currentEpIndex;

          return Container(
            margin: const EdgeInsets.only(bottom: 10),
            decoration: BoxDecoration(
              color: isCurrent ? widget.cartoon.themeColor.withOpacity(0.2) : Colors.white.withOpacity(0.06),
              borderRadius: BorderRadius.circular(18),
              border: Border.all(
                color: isCurrent ? widget.cartoon.themeColor : Colors.white12,
                width: isCurrent ? 2 : 1,
              ),
            ),
            child: ListTile(
              onTap: () => _selectEpisode(index),
              contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
              leading: ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: SizedBox(
                  width: 58,
                  height: 44,
                  child: isCurrent
                      ? Container(
                          color: widget.cartoon.themeColor,
                          child: const Center(
                            child: Icon(Icons.equalizer_rounded, color: Colors.white, size: 24),
                          ),
                        )
                      : CartoonCoverImage(
                          videoHash: ep.aparatHash,
                          coverAsset: ep.coverAsset ?? widget.cartoon.coverAsset,
                          fallbackEmoji: ep.coverEmoji,
                          fallbackGradient: widget.cartoon.gradient,
                          emojiSize: 22,
                          cacheWidth: 160,
                        ),
                ),
              ),
              title: Text(
                ep.title,
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: isCurrent ? FontWeight.bold : FontWeight.w600,
                  fontSize: 14,
                ),
              ),
              subtitle: Text(
                ep.description,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  color: Colors.white.withOpacity(0.6),
                  fontSize: 11,
                ),
              ),
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.access_time_rounded,
                    color: Colors.white.withOpacity(0.5),
                    size: 14,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    ep.duration,
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.7),
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          );
        }),
      ],
    );
  }

  String _formatTime(int milliseconds) {
    final totalSeconds = (milliseconds / 1000).round();
    final m = (totalSeconds ~/ 60).toString().padLeft(2, '0');
    final s = (totalSeconds % 60).toString().padLeft(2, '0');
    return '$m:$s';
  }

  int _estimatedDurationMs() {
    // تبدیل رشتهٔ «MM:SS» به میلی‌ثانیه برای زمان تقریبی قبل از بارگذاری ویدیو
    final parts = _currentEpisode.duration.split(':');
    if (parts.length == 2) {
      final m = int.tryParse(parts[0].replaceAll(RegExp(r'[^0-9]'), '')) ?? 0;
      final s = int.tryParse(parts[1].replaceAll(RegExp(r'[^0-9]'), '')) ?? 0;
      return (m * 60 + s) * 1000;
    }
    return 15 * 60 * 1000;
  }

  int _maxSliderMs() {
    if (_durationMs > 1000) return _durationMs;
    return _estimatedDurationMs();
  }
}

/// صفحهٔ تمام‌صفحه برای پخش راحت‌تر کارتون (بدون نیاز به بستن پخش‌کننده اصلی).
class _FullscreenVideo extends StatefulWidget {
  final VideoPlayerController? controller;
  final Color color;

  const _FullscreenVideo({required this.controller, required this.color});

  @override
  State<_FullscreenVideo> createState() => _FullscreenVideoState();
}

class _FullscreenVideoState extends State<_FullscreenVideo> {
  @override
  void initState() {
    super.initState();
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.landscapeRight,
    ]);
    widget.controller?.play();
  }

  @override
  void dispose() {
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: Stack(
          children: [
            Center(
              child: widget.controller != null && widget.controller!.value.isInitialized
                  ? AspectRatio(
                      aspectRatio: widget.controller!.value.aspectRatio,
                      child: VideoPlayer(widget.controller!),
                    )
                  : const CircularProgressIndicator(color: Colors.white),
            ),
            Positioned(
              top: 16,
              right: 16,
              child: GestureDetector(
                onTap: () => Navigator.of(context).pop(),
                child: Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.6),
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.white54),
                  ),
                  child: const Icon(Icons.fullscreen_exit_rounded, color: Colors.white, size: 24),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _PopcornParticle {
  double x;
  double y;
  double vx;
  double vy;
  String emoji;

  _PopcornParticle({
    required this.x,
    required this.y,
    required this.vx,
    required this.vy,
    required this.emoji,
  });
}
