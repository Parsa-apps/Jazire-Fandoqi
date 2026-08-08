import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../core/premium_animations.dart';

/// =======================================================
/// 🐼 PREMIUM ANIMAL CARD — کارت حیوان لوکس جزیره
/// =======================================================
class PremiumAnimalCard extends StatefulWidget {
  final String emoji;
  final String name;
  final String fact;
  final Color color;
  final VoidCallback onTap;

  const PremiumAnimalCard({
    super.key,
    required this.emoji,
    required this.name,
    required this.fact,
    required this.color,
    required this.onTap,
  });

  @override
  State<PremiumAnimalCard> createState() => _PremiumAnimalCardState();
}

class _PremiumAnimalCardState extends State<PremiumAnimalCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _bounceCtrl;

  @override
  void initState() {
    super.initState();
    _bounceCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    );
  }

  @override
  void dispose() {
    _bounceCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        HapticFeedback.lightImpact();
        _bounceCtrl.forward(from: 0);
        widget.onTap();
      },
      child: AnimatedBuilder(
        animation: _bounceCtrl,
        builder: (context, child) {
          final scale = 1.0 + (_bounceCtrl.value * 0.08);
          return Transform.scale(
            scale: scale,
            child: Container(
              width: 150,
              margin: const EdgeInsets.only(right: 16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(26),
                boxShadow: [
                  BoxShadow(
                    color: widget.color.withOpacity(0.25),
                    blurRadius: 20,
                    offset: const Offset(0, 10),
                  ),
                ],
              ),
              child: Column(
                children: [
                  const SizedBox(height: 20),
                  Text(
                    widget.emoji,
                    style: const TextStyle(fontSize: 60),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    widget.name,
                    style: const TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.w900,
                      color: Color(0xFF2D2D2D),
                    ),
                  ),
                  const SizedBox(height: 6),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    child: Text(
                      widget.fact,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontSize: 12,
                        color: Colors.black54,
                        height: 1.4,
                      ),
                    ),
                  ),
                  const SizedBox(height: 18),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}