import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:amoozesh_fandoghi/app/app_colors.dart';
import 'package:amoozesh_fandoghi/app/app_fonts.dart';
import 'package:amoozesh_fandoghi/core/cartoons/cartoon_data.dart';
import 'package:amoozesh_fandoghi/core/fandoghi_coach.dart';
import 'package:amoozesh_fandoghi/core/game_data.dart';
import 'package:amoozesh_fandoghi/shared/widgets/fandoghi_v2.dart';
import 'package:amoozesh_fandoghi/shared/widgets/star_field.dart';
import 'widgets/cartoon_rating_dialog.dart';

/// ═══════════════════════════════════════════════════════════════
/// 🍿 CARTOON PLAYER SCREEN — سینما کارتون تعاملی کودک
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
  Timer? _restReminderTimer;

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

    // Track watching progress
    _playbackTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!mounted) return;
      if (_isPlaying) {
        setState(() {
          _secondsWatched++;
          _progress = (_progress + 0.005).clamp(0.0, 1.0);
          if (_progress >= 1.0) {
            _progress = 0.0; // loop episode
          }
        });
        GameData.recordCartoonWatched(widget.cartoon.id, durationSeconds: 1);
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
    _restReminderTimer?.cancel();
    _beamCtrl.dispose();
    _pulseCtrl.dispose();
    super.dispose();
  }

  CartoonEpisode get _currentEpisode => widget.cartoon.episodes[_currentEpIndex];

  void _togglePlayPause() {
    HapticFeedback.lightImpact();
    setState(() => _isPlaying = !_isPlaying);
    if (_isPlaying) {
      FandoghiCoach.say('کارتون ادامه پیدا کرد! ▶', mood: FandoghiMood.happy);
    } else {
      FandoghiCoach.say('کارتون متوقف شد ⏸', mood: FandoghiMood.thinking);
    }
  }

  void _seekRelative(double delta) {
    HapticFeedback.selectionClick();
    setState(() {
      _progress = (_progress + delta).clamp(0.0, 1.0);
    });
  }

  void _onPopcornTap() {
    HapticFeedback.mediumImpact();
    setState(() {
      _popcornTaps++;
      // Spawn 4 popcorn particles
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

    // Reward 1 coin every 5 taps
    if (_popcornTaps % 5 == 0) {
      GameData.addCoins(1);
      FandoghiCoach.say('به‌به! یک سکه پاپ‌کورنی گرفتی! 🪙🍿', mood: FandoghiMood.excited);
    }
  }

  void _selectEpisode(int index) {
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
  }

  void _toggleFavorite() {
    HapticFeedback.lightImpact();
    GameData.toggleCartoonFavorite(widget.cartoon.id);
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final isFav = GameData.isCartoonFavorite(widget.cartoon.id);

    return Scaffold(
      backgroundColor: const Color(0xFF0F0C20),
      body: Stack(
        children: [
          // Cinema Starfield
          const StarFieldBackground(starCount: 45),

          // Projector Beam
          _buildProjectorBeam(),

          // Main Content
          SafeArea(
            child: Column(
              children: [
                // Top App Bar
                _buildTopBar(isFav),

                // Cinema Screen & Video Player Area
                Expanded(
                  child: SingleChildScrollView(
                    physics: const BouncingScrollPhysics(),
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 8),

                        // Cinema Theater Box
                        _buildCinemaScreen(),

                        const SizedBox(height: 16),

                        // Cartoon Details & Quick Actions
                        _buildCartoonInfo(),

                        const SizedBox(height: 20),

                        // Interactive Popcorn Minigame & Rating Prompt
                        _buildPopcornAndRatingRow(),

                        const SizedBox(height: 24),

                        // Episodes Playlist
                        _buildEpisodesPlaylist(),

                        const SizedBox(height: 30),
                      ],
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
            opacity: 0.12 + _beamCtrl.value * 0.08,
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
            onTap: () => Navigator.of(context).pop(),
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

          // Favorite Button
          GestureDetector(
            onTap: _toggleFavorite,
            child: Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: isFav ? Colors.redAccent.withOpacity(0.2) : Colors.white.withOpacity(0.12),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: isFav ? Colors.redAccent : Colors.white24,
                ),
              ),
              child: Icon(
                isFav ? Icons.favorite_rounded : Icons.favorite_border_rounded,
                color: isFav ? Colors.redAccent : Colors.white,
                size: 22,
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
                  // Animated Cartoon Backdrop
                  Container(
                    decoration: BoxDecoration(
                      gradient: widget.cartoon.gradient,
                    ),
                    child: Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            _currentEpisode.coverEmoji,
                            style: const TextStyle(fontSize: 64),
                          )
                              .animate(
                                onPlay: (c) => c.repeat(reverse: true),
                              )
                              .scale(
                                begin: const Offset(0.9, 0.9),
                                end: const Offset(1.1, 1.1),
                                duration: 1500.ms,
                              ),
                          const SizedBox(height: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
                            decoration: BoxDecoration(
                              color: Colors.black.withOpacity(0.4),
                              borderRadius: BorderRadius.circular(16),
                            ),
                            child: Text(
                              _currentEpisode.title,
                              style: AppFonts.vazirmatn(
                                color: Colors.white,
                                fontSize: 14,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  // Theater Curtains Overlay (Top Header)
                  Positioned(
                    top: 0,
                    left: 0,
                    right: 0,
                    child: Container(
                      height: 24,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [
                            Colors.black.withOpacity(0.6),
                            Colors.transparent,
                          ],
                        ),
                      ),
                    ),
                  ),

                  // Center Play/Pause Overlay indicator
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
                          _isPlaying ? Icons.pause_rounded : Icons.play_arrow_rounded,
                          color: Colors.white,
                          size: 38,
                        ),
                      ),
                    ),
                  ),

                  // HD Badge & Duration
                  Positioned(
                    top: 10,
                    right: 12,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: Colors.black.withOpacity(0.6),
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: Colors.amber.withOpacity(0.7)),
                      ),
                      child: const Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.hd_rounded, color: Colors.amber, size: 16),
                          SizedBox(width: 4),
                          Text('HD 1080', style: TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold)),
                        ],
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
                  // Progress Slider & Timers
                  Row(
                    children: [
                      Text(
                        _formatTime((_progress * 15 * 60).toInt()),
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
                            value: _progress,
                            onChanged: (val) => setState(() => _progress = val),
                          ),
                        ),
                      ),
                      Text(
                        _currentEpisode.duration,
                        style: const TextStyle(color: Colors.white70, fontSize: 11, fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),

                  const SizedBox(height: 6),

                  // Player Buttons
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      // Rewind 10s
                      IconButton(
                        onPressed: () => _seekRelative(-0.05),
                        icon: const Icon(Icons.replay_10_rounded, color: Colors.white, size: 28),
                        tooltip: '۱۰ ثانیه عقب',
                      ),

                      // Play / Pause Main
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

                      // Forward 10s
                      IconButton(
                        onPressed: () => _seekRelative(0.05),
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
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  gradient: widget.cartoon.gradient,
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Center(
                  child: Text(widget.cartoon.coverEmoji, style: const TextStyle(fontSize: 24)),
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
              // Stars
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
          // Learning outcome pill
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
              leading: Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: isCurrent ? widget.cartoon.themeColor : Colors.white.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Center(
                  child: isCurrent
                      ? const Icon(Icons.equalizer_rounded, color: Colors.white, size: 24)
                      : Text(ep.coverEmoji, style: const TextStyle(fontSize: 22)),
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

  String _formatTime(int seconds) {
    final m = (seconds ~/ 60).toString().padLeft(2, '0');
    final s = (seconds % 60).toString().padLeft(2, '0');
    return '$m:$s';
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
