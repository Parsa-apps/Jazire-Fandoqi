import 'package:flutter/material.dart';

/// 🎨 حرفه‌ای — ویجت بارگذاری حرفه‌ای با اسکلتون (Skeleton Loading)
/// جایگزین حرفه‌ای برای CircularProgressIndicator ساده
class ProfessionalSkeleton extends StatelessWidget {
  final bool isLoading;
  final Widget child;
  final int itemCount;

  const ProfessionalSkeleton({
    super.key,
    this.isLoading = true,
    required this.child,
    this.itemCount = 3,
  });

  @override
  Widget build(BuildContext context) {
    if (!isLoading) return child;

    return Column(
      children: List.generate(itemCount, (index) {
        return Container(
          margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
          height: 60,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            gradient: const LinearGradient(
              colors: [
                Color(0xFFE8E8E8),
                Color(0xFFF8F8F8),
                Color(0xFFE8E8E8),
              ],
              stops: [0.0, 0.5, 1.0],
              begin: Alignment.centerLeft,
              end: Alignment.centerRight,
            ),
          ),
        ).animate(
          onPlay: (controller) => controller.repeat(),
        ).shimmer(
          duration: 1500.ms,
          color: const Color(0xFFFFFFFF).withOpacity(0.3),
        );
      }),
    );
  }
}
