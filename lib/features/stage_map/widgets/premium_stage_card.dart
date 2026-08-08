import 'package:flutter/material.dart';
import '../../../core/premium_animations.dart';

/// =======================================================
/// 🗺️ PREMIUM STAGE CARD — کارت مرحله لوکس
/// =======================================================
class PremiumStageCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final bool isLocked;
  final int stars;
  final VoidCallback onTap;
  final Gradient gradient;

  const PremiumStageCard({
    super.key,
    required this.title,
    required this.subtitle,
    required this.isLocked,
    required this.stars,
    required this.onTap,
    required this.gradient,
  });

  @override
  Widget build(BuildContext context) {
    return PremiumAnimations.premiumCard(
      onTap: onTap,
      child: Container(
        height: 110,
        decoration: BoxDecoration(
          gradient: isLocked ? null : gradient,
          color: isLocked ? Colors.grey.shade200 : null,
          borderRadius: BorderRadius.circular(26),
        ),
        child: Stack(
          children: [
            if (!isLocked)
              Positioned(
                right: 20,
                top: 18,
                child: Row(
                  children: List.generate(
                    3,
                    (i) => Icon(
                      i < stars ? Icons.star_rounded : Icons.star_border_rounded,
                      color: Colors.amber,
                      size: 22,
                    ),
                  ),
                ),
              ),
            Padding(
              padding: const EdgeInsets.all(22),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w900,
                      color: isLocked ? Colors.grey : Colors.white,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: TextStyle(
                      fontSize: 14,
                      color: isLocked ? Colors.grey : Colors.white70,
                    ),
                  ),
                ],
              ),
            ),
            if (isLocked)
              const Positioned(
                right: 20,
                top: 20,
                child: Icon(Icons.lock_rounded, color: Colors.grey, size: 28),
              ),
          ],
        ),
      ),
    );
  }
}