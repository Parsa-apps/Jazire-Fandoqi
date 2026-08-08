import 'package:flutter/material.dart';
import '../../../core/premium_animations.dart';

/// =======================================================
/// 👤 PREMIUM PROFILE HEADER — هدر پروفایل لوکس
/// =======================================================
class PremiumProfileHeader extends StatelessWidget {
  final String name;
  final int level;
  final int stars;
  final int coins;

  const PremiumProfileHeader({
    super.key,
    required this.name,
    required this.level,
    required this.stars,
    required this.coins,
  });

  @override
  Widget build(BuildContext context) {
    return PremiumAnimations.slideUp(
      visible: true,
      child: Container(
        margin: const EdgeInsets.all(20),
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [Color(0xFF6C5CE7), Color(0xFF4834D4)],
          ),
          borderRadius: BorderRadius.circular(32),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF6C5CE7).withOpacity(0.4),
              blurRadius: 24,
              offset: const Offset(0, 12),
            ),
          ],
        ),
        child: Column(
          children: [
            Text(
              name.isNotEmpty ? name : 'دوست کوچولو',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 26,
                fontWeight: FontWeight.w900,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'لول $level • قهرمان یادگیری',
              style: const TextStyle(color: Colors.white70, fontSize: 15),
            ),
            const SizedBox(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _stat('⭐', stars.toString(), 'ستاره'),
                _stat('💰', coins.toString(), 'سکه'),
                _stat('🏆', level.toString(), 'لول'),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _stat(String emoji, String value, String label) {
    return Column(
      children: [
        Text(emoji, style: const TextStyle(fontSize: 28)),
        const SizedBox(height: 4),
        Text(
          value,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 22,
            fontWeight: FontWeight.w900,
          ),
        ),
        Text(label, style: const TextStyle(color: Colors.white70, fontSize: 12)),
      ],
    );
  }
}