import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

/// 🌈 حرفه‌ای — انیمیشن بارگذاری برای اپ با هاله‌ی رنگی
class ProfessionalSplash extends StatelessWidget {
  const ProfessionalSplash({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFF2D3436), Color(0xFF4834D4), Color(0xFF6C5CE7)],
          ),
        ),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // هاله‌ی رنگی حرفه‌ای
              Container(
                width: 120,
                height: 120,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: const LinearGradient(
                    colors: [Color(0xFFFFA726), Color(0xFFF06292), Color(0xFFBA68C8), Color(0xFF4FC3F7)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  boxShadow: [
                    BoxShadow(color: const Color(0xFFFFA726).withOpacity(0.6), blurRadius: 30, spreadRadius: 10),
                    BoxShadow(color: const Color(0xFFF06292).withOpacity(0.5), blurRadius: 40, spreadRadius: 15),
                  ],
                ),
                child: const Icon(Icons.auto_awesome, color: Colors.white, size: 56),
              )
                  .animate(onPlay: (c) => c.repeat(reverse: true))
                  .scale(begin: const Offset(0.9, 0.9), end: const Offset(1.1, 1.1), duration: 2000.ms, curve: Curves.easeInOut)
                  .shimmer(duration: 1500.ms, color: Colors.white.withOpacity(0.4)),
              const SizedBox(height: 24),
              const Text(
                'جزیره فندقی',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 28,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 2,
                  shadows: [Shadow(color: Color(0xFF6C5CE7), blurRadius: 20, offset: Offset(0, 4))],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
