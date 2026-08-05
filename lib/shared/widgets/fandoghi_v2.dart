import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import '../../app/app_colors.dart';

/// ═══════════════════════════════════════════════
/// 🌰 Fandoghi V2 — Professional Animated Mascot
/// A cute hazelnut character with rich animations
/// ═══════════════════════════════════════════════
class FandoghiV2 extends StatefulWidget {
  final double size;
  final bool animate;
  final String? message;
  final VoidCallback? onTap;
  final FandoghiMood mood;

  const FandoghiV2({
    super.key,
    this.size = 80,
    this.animate = true,
    this.message,
    this.onTap,
    this.mood = FandoghiMood.happy,
  });

  @override
  State<FandoghiV2> createState() => _FandoghiState();
}

enum FandoghiMood { happy, excited, thinking, sleeping, wink }

class _FandoghiState extends State<FandoghiV2>
    with TickerProviderStateMixin {
  late AnimationController _floatCtrl;
  late AnimationController _blinkCtrl;
  late AnimationController _bounceCtrl;
  Timer? _blinkTimer;
  bool _isBlinking = false;
  final _rng = Random();

  @override
  void initState() {
    super.initState();
    
    _floatCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2500),
    );
    
    _blinkCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 150),
    );
    
    _bounceCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );

    if (widget.animate) {
      _floatCtrl.repeat(reverse: true);
      _startBlinking();
    }
  }

  void _startBlinking() {
    _blinkTimer = Timer.periodic(
      Duration(milliseconds: 2500 + _rng.nextInt(2000)),
      (_) {
        if (mounted && !_isBlinking) {
          setState(() => _isBlinking = true);
          _blinkCtrl.forward().then((_) {
            if (mounted) {
              _blinkCtrl.reverse().then((_) {
                if (mounted) setState(() => _isBlinking = false);
              });
            }
          });
        }
      },
    );
  }

  @override
  void dispose() {
    _floatCtrl.dispose();
    _blinkCtrl.dispose();
    _bounceCtrl.dispose();
    _blinkTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    Widget body = GestureDetector(
      onTap: () {
        widget.onTap?.call();
        _bounceCtrl.forward(from: 0);
      },
      child: AnimatedBuilder(
        animation: Listenable.merge([_floatCtrl, _bounceCtrl]),
        builder: (_, child) {
          final floatY = widget.animate
              ? sin(_floatCtrl.value * pi) * 6
              : 0.0;
          final bounce = 1.0 + sin(_bounceCtrl.value * pi) * 0.1;
          return Transform.translate(
            offset: Offset(0, -floatY),
            child: Transform.scale(
              scale: bounce,
              child: child,
            ),
          );
        },
        child: _buildCharacter(),
      ),
    );

    if (widget.message != null && widget.message!.isNotEmpty) {
      body = Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          body,
          const SizedBox(height: 8),
          _buildSpeechBubble(),
        ],
      );
    }

    return body;
  }

  Widget _buildCharacter() {
    final s = widget.size;
    
    return SizedBox(
      width: s,
      height: s * 1.3,
      child: Stack(
        clipBehavior: Clip.none,
        alignment: Alignment.center,
        children: [
          // Shadow
          Positioned(
            bottom: -2,
            child: Container(
              width: s * 0.5,
              height: s * 0.08,
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.1),
                borderRadius: BorderRadius.circular(s),
              ),
            ),
          ),
          
          // Body (hazelnut shape)
          Positioned(
            bottom: s * 0.05,
            child: Container(
              width: s * 0.72,
              height: s * 0.85,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    AppColors.fandoghiLight,
                    AppColors.fandoghiBody,
                    AppColors.fandoghiDark,
                  ],
                  stops: const [0.0, 0.5, 1.0],
                ),
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(s * 0.36),
                  topRight: Radius.circular(s * 0.36),
                  bottomLeft: Radius.circular(s * 0.2),
                  bottomRight: Radius.circular(s * 0.2),
                ),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.fandoghiDark.withOpacity(0.3),
                    blurRadius: 12,
                    offset: const Offset(0, 6),
                  ),
                ],
              ),
            ),
          ),
          
          // Body shine
          Positioned(
            bottom: s * 0.35,
            left: s * 0.15,
            child: Container(
              width: s * 0.15,
              height: s * 0.25,
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.15),
                borderRadius: BorderRadius.circular(s),
              ),
            ),
          ),
          
          // Cap
          Positioned(
            top: 0,
            child: Container(
              width: s * 0.52,
              height: s * 0.32,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    const Color(0xFF6D4C41),
                    AppColors.fandoghiDark,
                  ],
                ),
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(s * 0.2),
                  topRight: Radius.circular(s * 0.2),
                  bottomLeft: Radius.circular(s * 0.06),
                  bottomRight: Radius.circular(s * 0.06),
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.2),
                    blurRadius: 6,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
            ),
          ),
          
          // Cap highlight
          Positioned(
            top: s * 0.03,
            left: s * 0.2,
            child: Container(
              width: s * 0.12,
              height: s * 0.06,
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.2),
                borderRadius: BorderRadius.circular(s),
              ),
            ),
          ),
          
          // Eyes
          Positioned(
            top: s * 0.38,
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                _buildEye(s, isLeft: true),
                SizedBox(width: s * 0.14),
                _buildEye(s, isLeft: false),
              ],
            ),
          ),
          
          // Mouth
          Positioned(
            top: s * 0.58,
            child: _buildMouth(s),
          ),
          
          // Cheeks
          Positioned(
            top: s * 0.5,
            left: s * 0.1,
            child: _buildCheek(s),
          ),
          Positioned(
            top: s * 0.5,
            right: s * 0.1,
            child: _buildCheek(s),
          ),
          
          // Arms (little stubs)
          if (widget.mood == FandoghiMood.excited) ...[
            Positioned(
              top: s * 0.45,
              left: -s * 0.08,
              child: _buildArm(s, -0.4),
            ),
            Positioned(
              top: s * 0.45,
              right: -s * 0.08,
              child: _buildArm(s, 0.4),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildEye(double s, {required bool isLeft}) {
    final isWink = widget.mood == FandoghiMood.wink && !isLeft;
    final isSleeping = widget.mood == FandoghiMood.sleeping;
    
    return AnimatedContainer(
      duration: const Duration(milliseconds: 150),
      width: s * 0.11,
      height: (_isBlinking || isSleeping || isWink) ? s * 0.02 : s * 0.11,
      decoration: BoxDecoration(
        color: const Color(0xFF3E2723),
        borderRadius: BorderRadius.circular(s * 0.06),
      ),
      child: (_isBlinking || isSleeping || isWink)
          ? null
          : Center(
              child: Container(
                width: s * 0.04,
                height: s * 0.04,
                decoration: const BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                ),
              ),
            ),
    );
  }

  Widget _buildMouth(double s) {
    switch (widget.mood) {
      case FandoghiMood.happy:
        return Container(
          width: s * 0.18,
          height: s * 0.09,
          decoration: BoxDecoration(
            border: Border(
              bottom: BorderSide(
                color: const Color(0xFF3E2723),
                width: s * 0.025,
              ),
            ),
            borderRadius: BorderRadius.only(
              bottomLeft: Radius.circular(s * 0.1),
              bottomRight: Radius.circular(s * 0.1),
            ),
          ),
        );
      case FandoghiMood.excited:
        return Container(
          width: s * 0.14,
          height: s * 0.1,
          decoration: BoxDecoration(
            color: const Color(0xFF3E2723),
            borderRadius: BorderRadius.circular(s * 0.06),
          ),
          child: Center(
            child: Container(
              width: s * 0.08,
              height: s * 0.04,
              decoration: BoxDecoration(
                color: AppColors.danger,
                borderRadius: BorderRadius.circular(s * 0.02),
              ),
            ),
          ),
        );
      case FandoghiMood.thinking:
        return Container(
          width: s * 0.08,
          height: s * 0.08,
          decoration: BoxDecoration(
            color: const Color(0xFF3E2723),
            shape: BoxShape.circle,
          ),
        );
      case FandoghiMood.sleeping:
        return Text('💤', style: TextStyle(fontSize: s * 0.15));
      case FandoghiMood.wink:
        return Container(
          width: s * 0.15,
          height: s * 0.07,
          decoration: BoxDecoration(
            border: Border(
              bottom: BorderSide(
                color: const Color(0xFF3E2723),
                width: s * 0.02,
              ),
            ),
            borderRadius: BorderRadius.only(
              bottomLeft: Radius.circular(s * 0.08),
              bottomRight: Radius.circular(s * 0.08),
            ),
          ),
        );
    }
  }

  Widget _buildCheek(double s) {
    return Container(
      width: s * 0.1,
      height: s * 0.06,
      decoration: BoxDecoration(
        color: AppColors.fandoghiCheek.withOpacity(0.5),
        shape: BoxShape.circle,
      ),
    );
  }

  Widget _buildArm(double s, double angle) {
    return Transform.rotate(
      angle: angle,
      child: Container(
        width: s * 0.06,
        height: s * 0.2,
        decoration: BoxDecoration(
          color: AppColors.fandoghiBody,
          borderRadius: BorderRadius.circular(s * 0.03),
        ),
      ),
    );
  }

  Widget _buildSpeechBubble() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      constraints: const BoxConstraints(maxWidth: 200),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Text(
        widget.message!,
        textAlign: TextAlign.center,
        style: const TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w600,
          height: 1.5,
        ),
      ),
    );
  }
}
