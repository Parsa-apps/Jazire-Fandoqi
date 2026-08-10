import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../app/design_tokens.dart';

/// 🎨 ProfessionalSkeleton Premium — پیشنهاد ۱۶
/// جایگزین اسپینر با شیمر پریمیوم + Design Tokens + 3 شکل
class ProfessionalSkeleton extends StatelessWidget {
  final bool isLoading;
  final Widget child;
  final int itemCount;
  final SkeletonType type;

  const ProfessionalSkeleton({
    super.key,
    this.isLoading = true,
    required this.child,
    this.itemCount = 3,
    this.type = SkeletonType.card,
  });

  @override
  Widget build(BuildContext context) {
    if (!isLoading) return child;
    return Column(
      children: List.generate(itemCount, (index) {
        return Container(
          margin: const EdgeInsets.symmetric(vertical: 6, horizontal: 12),
          height: type == SkeletonType.card ? 72 : type == SkeletonType.circle ? 56 : 20,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(type == SkeletonType.circle ? AppRadii.pill : AppRadii.lg),
            gradient: const LinearGradient(
              colors: [Color(0xFFE8E8E8), Color(0xFFF8F8F8), Color(0xFFE8E8E8)],
              stops: [0.0, 0.5, 1.0],
              begin: Alignment.centerLeft,
              end: Alignment.centerRight,
            ),
          ),
          child: type == SkeletonType.circle
              ? Row(children: [Container(width: 48, height: 48, decoration: const BoxDecoration(shape: BoxShape.circle, color: Color(0xFFE0E0E0))), const SizedBox(width: 12), Expanded(child: Container(height: 16, decoration: BoxDecoration(color: const Color(0xFFE0E0E0), borderRadius: BorderRadius.circular(AppRadii.pill))))])
              : null,
        )
            .animate(onPlay: (c) => c.repeat(), delay: (index * 120).ms)
            .shimmer(duration: 1400.ms, color: Colors.white.withOpacity(0.4));
      }),
    );
  }
}

enum SkeletonType { card, circle, text }
