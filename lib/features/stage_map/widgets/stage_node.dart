import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../app/app_colors.dart';

/// ═══════════════════════════════════════════════
/// ⭕ STAGE NODE — Individual Stage on Map
/// Completed, current, or locked state
/// ═══════════════════════════════════════════════
class StageNode extends StatefulWidget {
  final int stageNumber;
  final String title;
  final String emoji;
  final StageState state;
  final String route;
  final VoidCallback? onTap;

  const StageNode({
    super.key,
    required this.stageNumber,
    required this.title,
    required this.emoji,
    required this.state,
    required this.route,
    this.onTap,
  });

  @override
  State<StageNode> createState() => _StageNodeState();
}

enum StageState { completed, current, locked }

class _StageNodeState extends State<StageNode>
    with SingleTickerProviderStateMixin {
  late AnimationController _pulseCtrl;
  bool _isPressed = false;

  @override
  void initState() {
    super.initState();
    _pulseCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    );
    if (widget.state == StageState.current) {
      _pulseCtrl.repeat(reverse: true);
    }
  }

  @override
  void didUpdateWidget(StageNode old) {
    super.didUpdateWidget(old);
    if (widget.state == StageState.current) {
      _pulseCtrl.repeat(reverse: true);
    } else {
      _pulseCtrl.stop();
    }
  }

  @override
  void dispose() {
    _pulseCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => setState(() => _isPressed = true),
      onTapUp: (_) {
        setState(() => _isPressed = false);
        if (widget.state != StageState.locked) {
          HapticFeedback.mediumImpact();
          widget.onTap?.call();
        }
      },
      onTapCancel: () => setState(() => _isPressed = false),
      child: AnimatedBuilder(
        animation: _pulseCtrl,
        builder: (_, child) {
          final pulseScale = widget.state == StageState.current
              ? 1.0 + sin(_pulseCtrl.value * pi) * 0.08
              : 1.0;
          final pulseGlow = widget.state == StageState.current
              ? 0.3 + sin(_pulseCtrl.value * pi) * 0.2
              : 0.0;

          return Transform.scale(
            scale: (_isPressed ? 0.9 : 1.0) * pulseScale,
            child: child,
          );
        },
        child: SizedBox(
          width: 72,
          height: 90,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Main node
              _buildNode(),
              const SizedBox(height: 6),
              // Title
              Text(
                widget.title,
                textAlign: TextAlign.center,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: GoogleFonts.vazirmatn(
                  fontSize: 10,
                  fontWeight: FontWeight.w700,
                  color: widget.state == StageState.locked
                      ? AppColors.textLight
                      : AppColors.textPrimary,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNode() {
    switch (widget.state) {
      case StageState.completed:
        return _completedNode();
      case StageState.current:
        return _currentNode();
      case StageState.locked:
        return _lockedNode();
    }
  }

  // ✅ COMPLETED NODE
  Widget _completedNode() {
    return Container(
      width: 56,
      height: 56,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFFFFD700), Color(0xFFFFA000)],
        ),
        border: Border.all(color: const Color(0xFFFFE082), width: 3),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFFFFD700).withOpacity(0.4),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Emoji
          Text(widget.emoji, style: const TextStyle(fontSize: 22)),
          // Check mark
          Positioned(
            bottom: 0,
            right: 0,
            child: Container(
              width: 20,
              height: 20,
              decoration: BoxDecoration(
                color: const Color(0xFF4CAF50),
                shape: BoxShape.circle,
                border: Border.all(color: Colors.white, width: 2),
              ),
              child: const Icon(Icons.check, color: Colors.white, size: 12),
            ),
          ),
        ],
      ),
    );
  }

  // 🔵 CURRENT NODE (pulsing)
  Widget _currentNode() {
    return AnimatedBuilder(
      animation: _pulseCtrl,
      builder: (_, __) {
        final glow = 0.3 + sin(_pulseCtrl.value * pi) * 0.2;
        return Container(
          width: 60,
          height: 60,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: const LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [Color(0xFF6C5CE7), Color(0xFFA29BFE)],
            ),
            border: Border.all(color: Colors.white, width: 3),
            boxShadow: [
              BoxShadow(
                color: AppColors.primary.withOpacity(glow),
                blurRadius: 20,
                spreadRadius: 5,
              ),
              BoxShadow(
                color: Colors.black.withOpacity(0.15),
                blurRadius: 8,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Stack(
            alignment: Alignment.center,
            children: [
              Text(widget.emoji, style: const TextStyle(fontSize: 24)),
              // Arrow indicator
              Positioned(
                top: -16,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: AppColors.primary,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Text(
                    '▶',
                    style: TextStyle(color: Colors.white, fontSize: 8),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  // 🔒 LOCKED NODE
  Widget _lockedNode() {
    return Container(
      width: 50,
      height: 50,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Colors.grey.shade300,
            Colors.grey.shade400,
          ],
        ),
        border: Border.all(color: Colors.grey.shade200, width: 2),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 6,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Icon(
        Icons.lock_rounded,
        color: Colors.grey.shade500,
        size: 22,
      ),
    );
  }
}
