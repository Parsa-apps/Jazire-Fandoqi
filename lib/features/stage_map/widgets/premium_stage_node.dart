import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

enum StageState { locked, current, completed }

/// =======================================================
/// 🗺️ PREMIUM STAGE NODE — نود مرحله لوکس
/// =======================================================
class PremiumStageNode extends StatefulWidget {
  final int stageNumber;
  final String title;
  final String emoji;
  final StageState state;
  final VoidCallback onTap;

  const PremiumStageNode({
    super.key,
    required this.stageNumber,
    required this.title,
    required this.emoji,
    required this.state,
    required this.onTap,
  });

  @override
  State<PremiumStageNode> createState() => _PremiumStageNodeState();
}

class _PremiumStageNodeState extends State<PremiumStageNode>
    with SingleTickerProviderStateMixin {
  late AnimationController _pulseCtrl;

  @override
  void initState() {
    super.initState();
    _pulseCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1400),
    );
    if (widget.state == StageState.current) {
      _pulseCtrl.repeat(reverse: true);
    }
  }

  @override
  void dispose() {
    _pulseCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isLocked = widget.state == StageState.locked;
    final isCurrent = widget.state == StageState.current;
    final isCompleted = widget.state == StageState.completed;

    Color nodeColor;
    if (isCompleted) nodeColor = const Color(0xFF4CAF50);
    else if (isCurrent) nodeColor = const Color(0xFFFFD700);
    else nodeColor = Colors.grey.shade400;

    return GestureDetector(
      onTap: () {
        HapticFeedback.lightImpact();
        widget.onTap();
      },
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Node Circle
          AnimatedBuilder(
            animation: _pulseCtrl,
            builder: (context, child) {
              final scale = isCurrent ? 1.0 + (_pulseCtrl.value * 0.12) : 1.0;
              return Transform.scale(
                scale: scale,
                child: Container(
                  width: 72,
                  height: 72,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: nodeColor,
                    boxShadow: [
                      BoxShadow(
                        color: nodeColor.withOpacity(isCurrent ? 0.5 : 0.3),
                        blurRadius: isCurrent ? 24 : 12,
                        spreadRadius: isCurrent ? 4 : 1,
                      ),
                    ],
                    border: Border.all(
                      color: Colors.white,
                      width: isCurrent ? 4 : 3,
                    ),
                  ),
                  child: Center(
                    child: Text(
                      widget.emoji,
                      style: const TextStyle(fontSize: 32),
                    ),
                  ),
                ),
              );
            },
          ),

          const SizedBox(height: 10),

          // Stage Number Badge
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
            decoration: BoxDecoration(
              color: isLocked ? Colors.grey.shade300 : nodeColor,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              '${widget.stageNumber}',
              style: TextStyle(
                color: isLocked ? Colors.grey.shade700 : Colors.white,
                fontWeight: FontWeight.w900,
                fontSize: 14,
              ),
            ),
          ),

          const SizedBox(height: 6),

          // Title
          SizedBox(
            width: 90,
            child: Text(
              widget.title,
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                color: isLocked ? Colors.grey.shade600 : Colors.white,
                fontSize: 12,
                fontWeight: FontWeight.w700,
                height: 1.2,
              ),
            ),
          ),
        ],
      ),
    );
  }
}