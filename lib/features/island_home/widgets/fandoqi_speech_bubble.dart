import 'package:flutter/material.dart';

import '../../../app/app_fonts.dart';
import '../../../app/island_cinema_style.dart';

/// 💬 حبابِ گفتگویِ داستانیِ فندقی در بالایِ سرِ کاراکتر.
///
/// همراه با دنبالهٔ اشاره‌گرِ پایینی که مستقیماً به سرِ فندقی اشاره می‌کند.
class FandoqiSpeechBubble extends StatelessWidget {
  const FandoqiSpeechBubble({
    super.key,
    required this.message,
    this.onTap,
    this.compact = false,
    this.reduceMotion = false,
    this.tailAlignmentX = 0.0,
  });

  final String message;
  final VoidCallback? onTap;
  final bool compact;
  final bool reduceMotion;

  /// ترازِ افقیِ نوکِ فلشِ حباب در بازهٔ `[-0.65, 0.65]` (در مختصاتِ صفحهٔ چپ‌به‌راست:
  /// منفی = چپ‌تر، مثبت = راست‌تر، صفر = دقیقاً وسطِ حباب).
  final double tailAlignmentX;

  static const double tailHeight = 8.0;

  @override
  Widget build(BuildContext context) {
    final bubbleBody = Container(
      padding: EdgeInsets.symmetric(
        horizontal: compact ? 12 : 15,
        vertical: compact ? 6 : 8,
      ),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: <Color>[
            Color(0xFFFFFDF7),
            Color(0xFFFFF3D4),
          ],
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: IslandCinemaPalette.gold,
          width: 2.0,
        ),
        boxShadow: <BoxShadow>[
          BoxShadow(
            color: IslandCinemaPalette.shade.withOpacity(0.24),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Flexible(
            child: AnimatedSwitcher(
              duration: reduceMotion
                  ? Duration.zero
                  : const Duration(milliseconds: 220),
              child: Text(
                message,
                key: ValueKey<String>(message),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                textAlign: TextAlign.center,
                textDirection: TextDirection.rtl,
                style: AppFonts.kids(
                  fontSize: compact ? 12.5 : 14.0,
                  fontWeight: FontWeight.w800,
                  color: IslandCinemaPalette.woodDeep,
                  height: 1.2,
                ),
              ),
            ),
          ),
        ],
      ),
    );

    return Semantics(
      button: onTap != null,
      label: 'پیام فندقی: $message',
      onTap: onTap,
      child: ExcludeSemantics(
        child: GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: onTap,
          child: Column(
            key: const ValueKey<String>('living_island_speech_bubble'),
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              bubbleBody,
              SizedBox(
                width: 140,
                height: tailHeight,
                child: CustomPaint(
                  painter: _BubbleTailPainter(
                    fillColor: const Color(0xFFFFF3D4),
                    borderColor: IslandCinemaPalette.gold,
                    alignmentX: tailAlignmentX.clamp(-0.65, 0.65),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _BubbleTailPainter extends CustomPainter {
  const _BubbleTailPainter({
    required this.fillColor,
    required this.borderColor,
    required this.alignmentX,
  });

  final Color fillColor;
  final Color borderColor;
  final double alignmentX;

  @override
  void paint(Canvas canvas, Size size) {
    final centerX = size.width * (0.5 + alignmentX * 0.5);
    const halfBase = 7.5;

    final fillPath = Path()
      ..moveTo(centerX - halfBase, -1.5)
      ..lineTo(centerX, size.height)
      ..lineTo(centerX + halfBase, -1.5)
      ..close();

    canvas.drawPath(
      fillPath,
      Paint()
        ..color = fillColor
        ..style = PaintingStyle.fill,
    );

    final borderPath = Path()
      ..moveTo(centerX - halfBase, 0)
      ..lineTo(centerX, size.height)
      ..lineTo(centerX + halfBase, 0);

    canvas.drawPath(
      borderPath,
      Paint()
        ..color = borderColor
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2.0
        ..strokeJoin = StrokeJoin.round,
    );
  }

  @override
  bool shouldRepaint(covariant _BubbleTailPainter oldDelegate) {
    return oldDelegate.alignmentX != alignmentX ||
        oldDelegate.fillColor != fillColor ||
        oldDelegate.borderColor != borderColor;
  }
}
