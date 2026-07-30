import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../core/game_data.dart';
import '../core/theme.dart';

class StarDisplay extends StatelessWidget {
  final bool showLabel;
  final double size;
  final Color? color;

  const StarDisplay({
    super.key,
    this.showLabel = true,
    this.size = 18,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(Icons.star_rounded, size: size, color: color ?? Colors.amber)
            .animate(onPlay: (c) => c.repeat(reverse: true))
            .shimmer(duration: 2.seconds, color: Colors.yellow.shade200),
        if (showLabel) ...[
          const SizedBox(width: 4),
          Text(
            '${GameData.stars}',
            style: TextStyle(
              fontSize: size * 0.8,
              fontWeight: FontWeight.bold,
              color: color ?? AppColors.secondary,
            ),
          ),
        ],
      ],
    );
  }
}

class StarBadge extends StatelessWidget {
  final int count;
  final double size;
  final bool animated;

  const StarBadge({
    super.key,
    required this.count,
    this.size = 50,
    this.animated = true,
  });

  @override
  Widget build(BuildContext context) {
    Widget badge = Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: const LinearGradient(
          colors: [Color(0xFFFFD700), Color(0xFFFFA500)],
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.amber.withOpacity(0.4),
            blurRadius: 10,
            spreadRadius: 2,
          ),
        ],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.star_rounded, color: Colors.white, size: 20),
          Text(
            '$count',
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 11,
            ),
          ),
        ],
      ),
    );

    if (animated) {
      badge = badge.animate().scale(
            duration: 500.ms,
            curve: Curves.elasticOut,
          );
    }
    return badge;
  }
}

class StarRewardAnimation extends StatefulWidget {
  final int stars;
  final VoidCallback? onComplete;

  const StarRewardAnimation({
    super.key,
    required this.stars,
    this.onComplete,
  });

  @override
  State<StarRewardAnimation> createState() => _StarRewardAnimationState();
}

class _StarRewardAnimationState extends State<StarRewardAnimation>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..forward();
    Future.delayed(const Duration(milliseconds: 1500), () {
      widget.onComplete?.call();
    });
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.star_rounded, size: 80, color: Colors.amber)
              .animate()
              .scale(
                duration: 600.ms,
                curve: Curves.elasticOut,
              )
              .then()
              .shimmer(color: Colors.yellow),
          const SizedBox(height: 12),
          Text(
            '+${widget.stars} ⭐',
            style: const TextStyle(
              fontSize: 36,
              fontWeight: FontWeight.bold,
              color: Colors.amber,
            ),
          ).animate().fadeIn(delay: 300.ms).slideY(begin: 0.5),
          const SizedBox(height: 8),
          const Text(
            'ستاره گرفتی!',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ).animate().fadeIn(delay: 600.ms),
        ],
      ),
    );
  }
}
