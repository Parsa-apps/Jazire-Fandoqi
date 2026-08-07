import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../app/app_colors.dart';
import '../../core/game_data.dart';
import '../../shared/widgets/fandoghi_v2.dart';
import '../../shared/widgets/star_field.dart';

/// ═══════════════════════════════════════════════
/// 🚀 SPLASH SCREEN — Stunning First Impression
/// Animated star field + floating Fandoghi + logo
/// ═══════════════════════════════════════════════
class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashState();
}

class _SplashState extends State<SplashScreen>
    with TickerProviderStateMixin {
  late AnimationController _fadeCtrl;
  late AnimationController _scaleCtrl;
  late AnimationController _slideCtrl;
  late AnimationController _glowCtrl;
  late AnimationController _orbitCtrl;
  Timer? _navigationTimer;

  @override
  void initState() {
    super.initState();
    
    _fadeCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );
    _scaleCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    );
    _slideCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    );
    _glowCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2000),
    );
    _orbitCtrl = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 8),
    );

    // Staggered animation sequence
    _scaleCtrl.forward();
    Future.delayed(const Duration(milliseconds: 300), () {
      if (mounted) _fadeCtrl.forward();
    });
    Future.delayed(const Duration(milliseconds: 600), () {
      if (mounted) _slideCtrl.forward();
    });
    _glowCtrl.repeat(reverse: true);
    _orbitCtrl.repeat();

    // Keep the first impression lively without holding the child on a
    // loading screen for four seconds. First launch continues to onboarding;
    // returning players go straight to the dashboard.
    _navigationTimer = Timer(const Duration(milliseconds: 1400), () {
      if (!mounted) return;
      HapticFeedback.lightImpact();
      final destination = GameData.onboardingSeen ? '/home' : '/onboarding';
      Navigator.pushReplacementNamed(context, destination);
    });
  }

  @override
  void dispose() {
    _fadeCtrl.dispose();
    _scaleCtrl.dispose();
    _slideCtrl.dispose();
    _glowCtrl.dispose();
    _orbitCtrl.dispose();
    _navigationTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: AppGradients.nightSky,
        ),
        child: Stack(
          children: [
            // Animated star field
            const StarFieldBackground(starCount: 80),
            
            // Orbiting particles around center
            _buildOrbitingParticles(),
            
            // Main content
            Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Glowing ring behind Fandoghi
                  _buildGlowRing(),
                  
                  const SizedBox(height: 20),
                  
                  // Fandoghi character
                  ScaleTransition(
                    scale: CurvedAnimation(
                      parent: _scaleCtrl,
                      curve: Curves.elasticOut,
                    ),
                    child: const FandoghiV2(
                      size: 110,
                      animate: true,
                      mood: FandoghiMood.excited,
                    ),
                  ),
                  
                  const SizedBox(height: 30),
                  
                  // App name with shimmer
                  FadeTransition(
                    opacity: _fadeCtrl,
                    child: _buildShimmerText(),
                  ),
                  
                  const SizedBox(height: 12),
                  
                  // Subtitle
                  SlideTransition(
                    position: Tween<Offset>(
                      begin: const Offset(0, 0.5),
                      end: Offset.zero,
                    ).animate(CurvedAnimation(
                      parent: _slideCtrl,
                      curve: Curves.easeOutCubic,
                    )),
                    child: FadeTransition(
                      opacity: _slideCtrl,
                      child: Text(
                        'دنیای یادگیری و بازی',
                        style: GoogleFonts.vazirmatn(
                          fontSize: 18,
                          color: Colors.white70,
                          fontWeight: FontWeight.w500,
                          letterSpacing: 1.5,
                        ),
                      ),
                    ),
                  ),
                  
                  const SizedBox(height: 50),
                  
                  // Loading indicator
                  FadeTransition(
                    opacity: _fadeCtrl,
                    child: _buildLoadingDots(),
                  ),
                ],
              ),
            ),
            
            // Bottom branding
            Positioned(
              bottom: 40,
              left: 0,
              right: 0,
              child: FadeTransition(
                opacity: _fadeCtrl,
                child: Text(
                  'ساخته‌شده توسط فرشاد پارسا',
                  textAlign: TextAlign.center,
                  style: GoogleFonts.exo2(
                    fontSize: 14,
                    color: Colors.white38,
                    fontWeight: FontWeight.w300,
                    letterSpacing: 3,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildGlowRing() {
    return AnimatedBuilder(
      animation: _glowCtrl,
      builder: (_, __) {
        return Container(
          width: 160,
          height: 160,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: RadialGradient(
              colors: [
                AppColors.primary.withOpacity(0.15 + _glowCtrl.value * 0.1),
                AppColors.accent.withOpacity(0.05),
                Colors.transparent,
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildOrbitingParticles() {
    return AnimatedBuilder(
      animation: _orbitCtrl,
      builder: (_, __) {
        return Stack(
          children: List.generate(6, (i) {
            final angle = _orbitCtrl.value * 2 * pi + (i * pi / 3);
            final radius = 120.0 + i * 15;
            return Positioned(
              left: MediaQuery.of(context).size.width / 2 +
                  cos(angle) * radius - 4,
              top: MediaQuery.of(context).size.height / 2 -
                  80 + sin(angle) * radius - 4,
              child: Container(
                width: 8,
                height: 8,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: [
                    AppColors.primary,
                    AppColors.accent,
                    AppColors.warning,
                    AppColors.candy1,
                    AppColors.forest1,
                    AppColors.ocean1,
                  ][i].withOpacity(0.6),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.primary.withOpacity(0.3),
                      blurRadius: 8,
                    ),
                  ],
                ),
              ),
            );
          }),
        );
      },
    );
  }

  Widget _buildShimmerText() {
    return AnimatedBuilder(
      animation: _glowCtrl,
      builder: (_, __) {
        return ShaderMask(
          shaderCallback: (bounds) {
            return LinearGradient(
              colors: const [
                Color(0xFFFFFFFF),
                Color(0xFFFFD700),
                Color(0xFFFFFFFF),
              ],
              stops: [
                (_glowCtrl.value - 0.3).clamp(0.0, 1.0).toDouble(),
                _glowCtrl.value,
                (_glowCtrl.value + 0.3).clamp(0.0, 1.0).toDouble(),
              ],
            ).createShader(bounds);
          },
          child: Text(
            'کودک ایران',
            style: GoogleFonts.vazirmatn(
              fontSize: 48,
              fontWeight: FontWeight.w900,
              color: Colors.white,
              letterSpacing: 2,
            ),
          ),
        );
      },
    );
  }

  Widget _buildLoadingDots() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(3, (i) {
        return AnimatedBuilder(
          animation: _glowCtrl,
          builder: (_, __) {
            final delay = i * 0.3;
            final opacity =
                (sin((_glowCtrl.value * 2 * pi) + delay) + 1) / 2;
            return Container(
              margin: const EdgeInsets.symmetric(horizontal: 6),
              width: 10,
              height: 10,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withOpacity(0.3 + opacity * 0.7),
              ),
            );
          },
        );
      }),
    );
  }
}
