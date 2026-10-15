import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../../core/audio_service.dart';
import '../../../../core/fandoghi_coach.dart';

class AdventureIslandHero extends StatefulWidget {
  final double progress;
  const AdventureIslandHero({super.key, required this.progress});

  @override
  State<AdventureIslandHero> createState() => _AdventureIslandHeroState();
}

class _AdventureIslandHeroState extends State<AdventureIslandHero> with SingleTickerProviderStateMixin {
  late AnimationController _breatheCtrl;
  bool _isWaving = false;

  @override
  void initState() {
    super.initState();
    _breatheCtrl = AnimationController(vsync: this, duration: const Duration(seconds: 2))..repeat(reverse: true);
  }

  @override
  void dispose() {
    _breatheCtrl.dispose();
    super.dispose();
  }

  void _pokeFandoqi() {
    HapticFeedback.lightImpact();
    AudioService.select();
    setState(() => _isWaving = true);
    
    // Select a random phrase
    final phrases = [
      'سلام دوست من! بریم بگردیم؟ 🗺️',
      'روی هر ساختمون بزنی یه بازی جدید داریم! 🎪',
      'دیدی جزیره چقدر بزرگ شده؟ ✨',
      'من اینجام تا راهنماییت کنم! 🌰',
    ];
    final msg = phrases[Random().nextInt(phrases.length)];
    FandoghiCoach.instruction(msg);
    
    Future.delayed(const Duration(seconds: 2), () {
      if (mounted) setState(() => _isWaving = false);
    });
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: _pokeFandoqi,
      child: AnimatedBuilder(
        animation: _breatheCtrl,
        builder: (context, child) {
          final jump = _isWaving ? sin(_breatheCtrl.value * pi * 4) * 10 : 0.0;
          final scaleY = 1.0 - (_breatheCtrl.value * 0.05);
          
          return Transform.translate(
            offset: Offset(0, jump),
            child: Transform(
              alignment: Alignment.bottomCenter,
              transform: Matrix4.identity()..scale(1.0, scaleY),
              child: child,
            ),
          );
        },
        child: Container(
          width: 140,
          height: 160,
          decoration: const BoxDecoration(
            image: DecorationImage(
              // Using existing asset or a fallback shape if not available
              image: AssetImage('assets/mascot/fandoghi_baby.webp'),
              fit: BoxFit.contain,
            ),
          ),
          // Fallback if image doesn't exist
          child: const Center(
            child: Text('🌰', style: TextStyle(fontSize: 80)),
          ),
        ),
      ),
    );
  }
}
