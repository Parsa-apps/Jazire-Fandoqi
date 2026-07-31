import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// Common reusable widgets for professional look

class BounceBtn extends StatelessWidget {
  final Widget child;
  final VoidCallback onTap;
  final double scale;

  const BounceBtn({
    super.key,
    required this.child,
    required this.onTap,
    this.scale = 0.95,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        HapticFeedback.lightImpact();
        onTap();
      },
      child: child,
    );
  }
}

class FandoghiMini extends StatelessWidget {
  final double size;
  const FandoghiMini({super.key, this.size = 28});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: const LinearGradient(
          colors: [Color(0xFF8B5E3C), Color(0xFFD4A574)],
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Center(
        child: Text(
          '🌰',
          style: TextStyle(fontSize: size * 0.75),
        ),
      ),
    );
  }
}

class StarDisplay extends StatelessWidget {
  final int count;
  final double size;
  final Color color;

  const StarDisplay({
    super.key,
    this.count = 0,
    this.size = 20,
    this.color = Colors.amber,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(
        5,
        (i) => Icon(
          i < count ? Icons.star_rounded : Icons.star_border_rounded,
          color: color,
          size: size,
        ),
      ),
    );
  }
}

class ProgressBar extends StatelessWidget {
  final double progress;
  final Color color;
  final double height;

  const ProgressBar({
    super.key,
    required this.progress,
    this.color = const Color(0xFF6C63FF),
    this.height = 8,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: height,
      decoration: BoxDecoration(
        color: Colors.grey.shade200,
        borderRadius: BorderRadius.circular(20),
      ),
      child: FractionallySizedBox(
        alignment: Alignment.centerLeft,
        widthFactor: progress.clamp(0.0, 1.0),
        child: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(colors: [color, color.withOpacity(0.7)]),
            borderRadius: BorderRadius.circular(20),
          ),
        ),
      ),
    );
  }
}