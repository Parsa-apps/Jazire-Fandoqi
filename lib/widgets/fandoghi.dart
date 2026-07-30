import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../core/theme.dart';

/// فندقی - شخصیت راهنمای کودک ایران
/// یک فندق بامزه که به بچه‌ها کمک می‌کنه
class Fandoghi extends StatefulWidget {
  final String message;
  final double size;
  final bool animate;
  final VoidCallback? onTap;
  final bool showBubble;

  const Fandoghi({
    super.key,
    this.message = '',
    this.size = 60,
    this.animate = true,
    this.onTap,
    this.showBubble = true,
  });

  @override
  State<Fandoghi> createState() => _FandoghiState();
}

class _FandoghiState extends State<Fandoghi>
    with SingleTickerProviderStateMixin {
  late AnimationController _blinkCtrl;
  bool _isBlinking = false;
  Timer? _blinkTimer;

  @override
  void initState() {
    super.initState();
    _blinkCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 150),
    );
    _blinkTimer = Timer.periodic(const Duration(seconds: 3), (_) {
      if (mounted) {
        setState(() => _isBlinking = true);
        Future.delayed(const Duration(milliseconds: 200), () {
          if (mounted) setState(() => _isBlinking = false);
        });
      }
    });
  }

  @override
  void dispose() {
    _blinkTimer?.cancel();
    _blinkCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: widget.onTap,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          _buildBody(),
          if (widget.showBubble && widget.message.isNotEmpty) ...[
            const SizedBox(width: 8),
            Flexible(child: _buildBubble()),
          ],
        ],
      ),
    );
  }

  Widget _buildBody() {
    final s = widget.size;
    Widget body = SizedBox(
      width: s,
      height: s * 1.15,
      child: Stack(
        clipBehavior: Clip.none,
        alignment: Alignment.center,
        children: [
          // Body (hazelnut shape)
          Positioned(
            bottom: 0,
            child: Container(
              width: s * 0.75,
              height: s * 0.85,
              decoration: BoxDecoration(
                color: AppColors.fandoghiBrown,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(s * 0.4),
                  topRight: Radius.circular(s * 0.4),
                  bottomLeft: Radius.circular(s * 0.25),
                  bottomRight: Radius.circular(s * 0.25),
                ),
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    AppColors.fandoghiLight,
                    AppColors.fandoghiBrown,
                  ],
                ),
              ),
            ),
          ),
          // Cap (top part)
          Positioned(
            top: 0,
            child: Container(
              width: s * 0.55,
              height: s * 0.3,
              decoration: BoxDecoration(
                color: const Color(0xFF5D4037),
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(s * 0.2),
                  topRight: Radius.circular(s * 0.2),
                  bottomLeft: Radius.circular(s * 0.08),
                  bottomRight: Radius.circular(s * 0.08),
                ),
                border: Border(
                  bottom: BorderSide(
                    color: const Color(0xFF3E2723),
                    width: s * 0.02,
                  ),
                ),
              ),
            ),
          ),
          // Eyes
          Positioned(
            top: s * 0.38,
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                _buildEye(s * 0.1),
                SizedBox(width: s * 0.12),
                _buildEye(s * 0.1),
              ],
            ),
          ),
          // Mouth (smile)
          Positioned(
            top: s * 0.56,
            child: Container(
              width: s * 0.2,
              height: s * 0.08,
              decoration: BoxDecoration(
                border: Border(
                  bottom: BorderSide(
                    color: const Color(0xFF3E2723),
                    width: s * 0.025,
                  ),
                ),
                borderRadius: BorderRadius.circular(s * 0.1),
              ),
            ),
          ),
          // Blush cheeks
          Positioned(
            top: s * 0.5,
            left: s * 0.12,
            child: Container(
              width: s * 0.12,
              height: s * 0.08,
              decoration: BoxDecoration(
                color: Colors.pink.withOpacity(0.3),
                shape: BoxShape.circle,
              ),
            ),
          ),
          Positioned(
            top: s * 0.5,
            right: s * 0.12,
            child: Container(
              width: s * 0.12,
              height: s * 0.08,
              decoration: BoxDecoration(
                color: Colors.pink.withOpacity(0.3),
                shape: BoxShape.circle,
              ),
            ),
          ),
        ],
      ),
    );

    if (widget.animate) {
      body = body
          .animate(onPlay: (c) => c.repeat(reverse: true))
          .float(duration: 2000.ms, begin: -3, end: 3);
    }
    return body;
  }

  Widget _buildEye(double size) {
    return Container(
      width: size,
      height: _isBlinking ? size * 0.2 : size,
      decoration: BoxDecoration(
        color: const Color(0xFF3E2723),
        borderRadius: BorderRadius.circular(size / 2),
      ),
      child: _isBlinking
          ? null
          : Center(
              child: Container(
                width: size * 0.35,
                height: size * 0.35,
                decoration: const BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                ),
              ),
            ),
    );
  }

  Widget _buildBubble() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Text(
        widget.message,
        style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
      ),
    ).animate().fadeIn(duration: 300.ms).slideX(begin: 0.2);
  }
}

/// Mini Fandoghi for inline use (e.g. in app bars, buttons)
class FandoghiMini extends StatelessWidget {
  final double size;
  const FandoghiMini({super.key, this.size = 28});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size * 1.15,
      child: Stack(
        alignment: Alignment.center,
        children: [
          Positioned(
            bottom: 0,
            child: Container(
              width: size * 0.75,
              height: size * 0.85,
              decoration: BoxDecoration(
                color: AppColors.fandoghiBrown,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(size * 0.4),
                  topRight: Radius.circular(size * 0.4),
                  bottomLeft: Radius.circular(size * 0.25),
                  bottomRight: Radius.circular(size * 0.25),
                ),
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [AppColors.fandoghiLight, AppColors.fandoghiBrown],
                ),
              ),
            ),
          ),
          Positioned(
            top: 0,
            child: Container(
              width: size * 0.55,
              height: size * 0.3,
              decoration: BoxDecoration(
                color: const Color(0xFF5D4037),
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(size * 0.2),
                  topRight: Radius.circular(size * 0.2),
                  bottomLeft: Radius.circular(size * 0.08),
                  bottomRight: Radius.circular(size * 0.08),
                ),
              ),
            ),
          ),
          Positioned(
            top: size * 0.42,
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: size * 0.08,
                  height: size * 0.08,
                  decoration: const BoxDecoration(
                    color: Color(0xFF3E2723),
                    shape: BoxShape.circle,
                  ),
                ),
                SizedBox(width: size * 0.1),
                Container(
                  width: size * 0.08,
                  height: size * 0.08,
                  decoration: const BoxDecoration(
                    color: Color(0xFF3E2723),
                    shape: BoxShape.circle,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
