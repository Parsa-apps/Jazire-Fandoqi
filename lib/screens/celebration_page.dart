import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:confetti/confetti.dart';
import '../widgets/fandoghi.dart';
import '../core/game_data.dart';
import '../core/theme.dart';

class CelebrationPage extends StatefulWidget {
  final String title;
  final String subtitle;
  final String emoji;
  final int starsEarned;
  final int coinsEarned;
  final VoidCallback? onContinue;

  const CelebrationPage({
    super.key,
    required this.title,
    this.subtitle = '',
    this.emoji = '🎉',
    this.starsEarned = 0,
    this.coinsEarned = 0,
    this.onContinue,
  });

  @override
  State<CelebrationPage> createState() => _CelebrationPageState();
}

class _CelebrationPageState extends State<CelebrationPage>
    with TickerProviderStateMixin {
  late ConfettiController _confetti;
  late AnimationController _pulseCtrl;

  @override
  void initState() {
    super.initState();
    _confetti = ConfettiController(duration: const Duration(seconds: 3));
    _pulseCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    )..repeat(reverse: true);
    _confetti.play();
  }

  @override
  void dispose() {
    _confetti.dispose();
    _pulseCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Background gradient
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Color(0xFF6C63FF),
                  Color(0xFF3F3D9E),
                  Color(0xFF1A1A3E),
                ],
              ),
            ),
          ),
          // Floating particles
          ...List.generate(20, (i) {
            return Positioned(
              left: (i * 37.0) % MediaQuery.of(context).size.width,
              top: (i * 53.0) % MediaQuery.of(context).size.height,
              child: Container(
                width: 6 + (i % 4) * 3.0,
                height: 6 + (i % 4) * 3.0,
                decoration: BoxDecoration(
                  color: [
                    Colors.amber,
                    Colors.pink,
                    Colors.cyan,
                    Colors.green,
                    Colors.orange,
                  ][i % 5].withOpacity(0.4),
                  shape: BoxShape.circle,
                ),
              ).animate(onPlay: (c) => c.repeat())
                  .moveY(
                    duration: Duration(seconds: 2 + i % 3),
                    begin: 0,
                    end: -20,
                  )
                  .fadeIn()
                  .fadeOut(),
            );
          }),
          // Confetti
          Align(
            alignment: Alignment.topCenter,
            child: ConfettiWidget(
              confettiController: _confetti,
              blastDirectionality: BlastDirectionality.explosive,
              numberOfParticles: 30,
              colors: const [
                Colors.amber,
                Colors.pink,
                Colors.cyan,
                Colors.green,
                Colors.purple,
                Colors.orange,
              ],
            ),
          ),
          // Content
          SafeArea(
            child: Center(
              child: Padding(
                padding: const EdgeInsets.all(30),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // Fandoghi celebrating
                    const Fandoghi(
                      message: 'آفرین! عالی بود!',
                      size: 80,
                    ),
                    const SizedBox(height: 30),
                    // Big emoji
                    Text(
                      widget.emoji,
                      style: const TextStyle(fontSize: 100),
                    )
                        .animate()
                        .scale(
                          duration: 800.ms,
                          curve: Curves.elasticOut,
                        )
                        .then()
                        .shimmer(color: Colors.white24),
                    const SizedBox(height: 20),
                    // Title
                    Text(
                      widget.title,
                      style: const TextStyle(
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                      textAlign: TextAlign.center,
                    ).animate().fadeIn(delay: 300.ms).slideY(begin: 0.3),
                    if (widget.subtitle.isNotEmpty) ...[
                      const SizedBox(height: 10),
                      Text(
                        widget.subtitle,
                        style: const TextStyle(
                          fontSize: 18,
                          color: Colors.white70,
                        ),
                        textAlign: TextAlign.center,
                      ).animate().fadeIn(delay: 500.ms),
                    ],
                    const SizedBox(height: 30),
                    // Rewards
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        if (widget.starsEarned > 0)
                          _rewardChip(
                            Icons.star_rounded,
                            '+${widget.starsEarned}',
                            Colors.amber,
                          ),
                        if (widget.starsEarned > 0 &&
                            widget.coinsEarned > 0)
                          const SizedBox(width: 16),
                        if (widget.coinsEarned > 0)
                          _rewardChip(
                            Icons.monetization_on_rounded,
                            '+${widget.coinsEarned}',
                            Colors.orange,
                          ),
                      ],
                    ).animate().fadeIn(delay: 700.ms).slideY(begin: 0.3),
                    const SizedBox(height: 40),
                    // Continue button
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.white,
                        foregroundColor: AppColors.primary,
                        minimumSize: const Size(200, 55),
                        padding: const EdgeInsets.symmetric(
                            horizontal: 40, vertical: 16),
                      ),
                      onPressed: () {
                        if (widget.onContinue != null) {
                          widget.onContinue!();
                        } else {
                          Navigator.pop(context);
                        }
                      },
                      child: const Text(
                        'ادامه بدیم! 🚀',
                        style: TextStyle(fontSize: 18),
                      ),
                    ).animate().fadeIn(delay: 900.ms).slideY(begin: 0.3),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _rewardChip(IconData icon, String text, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.2),
        borderRadius: BorderRadius.circular(30),
        border: Border.all(color: color.withOpacity(0.5), width: 2),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: color, size: 24),
          const SizedBox(width: 8),
          Text(
            text,
            style: TextStyle(
              color: color,
              fontSize: 22,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}
