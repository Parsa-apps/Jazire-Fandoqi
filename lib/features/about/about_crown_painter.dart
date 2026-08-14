part of 'about_screen.dart';

class _CrownArtwork extends StatelessWidget {
  const _CrownArtwork({required this.width});

  final double width;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: width,
      height: width * 86 / 120,
      child: const CustomPaint(painter: _CrownPainter()),
    );
  }
}

/// Dependency-free vector rendering of the same crown geometry and colors used
/// by assets/crown.svg on the public site.
class _CrownPainter extends CustomPainter {
  const _CrownPainter();

  @override
  void paint(Canvas canvas, Size size) {
    canvas.save();
    canvas.scale(size.width / 120, size.height / 86);

    final crownGradient = const LinearGradient(
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
      colors: [
        Color(0xFFFFF3C4),
        Color(0xFFFBD06F),
        Color(0xFFE9B949),
        Color(0xFFF2D479),
        Color(0xFFB07E1F),
      ],
      stops: [0, 0.26, 0.52, 0.74, 1],
    );
    final crownRect = const Rect.fromLTWH(12, 6, 96, 74);

    final rayPaint = Paint()
      ..shader = const LinearGradient(
        colors: [Color(0x00FFFFFF), Color(0xD9FFFFFF), Color(0x00FFFFFF)],
      ).createShader(const Rect.fromLTWH(0, 0, 10, 20));
    canvas.drawRRect(
      RRect.fromRectAndRadius(const Rect.fromLTWH(56, 0, 8, 20), const Radius.circular(4)),
      rayPaint..color = const Color(0x59FFFFFF),
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(const Rect.fromLTWH(34, 4, 6, 14), const Radius.circular(3)),
      rayPaint,
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(const Rect.fromLTWH(80, 4, 6, 14), const Radius.circular(3)),
      rayPaint,
    );

    final body = Path()
      ..moveTo(14, 66)
      ..lineTo(20, 24)
      ..quadraticBezierTo(26, 34, 32, 22)
      ..lineTo(42, 46)
      ..lineTo(52, 18)
      ..quadraticBezierTo(56, 12, 60, 18)
      ..lineTo(70, 46)
      ..lineTo(80, 22)
      ..quadraticBezierTo(86, 34, 92, 24)
      ..lineTo(98, 66)
      ..quadraticBezierTo(56, 78, 14, 66)
      ..close();

    canvas.save();
    canvas.translate(0, 5);
    canvas.drawPath(
      body,
      Paint()
        ..color = const Color(0x66000000)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 8),
    );
    canvas.restore();

    canvas.drawPath(
      body,
      Paint()..shader = crownGradient.createShader(crownRect),
    );
    canvas.drawPath(
      body,
      Paint()
        ..color = const Color(0xFF8F6217)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2
        ..strokeJoin = StrokeJoin.round,
    );

    final innerShadow = Paint()..color = const Color(0x73B07E1F);
    canvas.drawPath(
      Path()
        ..moveTo(26, 42)
        ..lineTo(30, 30)
        ..quadraticBezierTo(34, 40, 38, 42)
        ..close(),
      innerShadow,
    );
    canvas.drawPath(
      Path()
        ..moveTo(56, 44)
        ..lineTo(60, 32)
        ..quadraticBezierTo(64, 42, 68, 44)
        ..close(),
      innerShadow,
    );
    canvas.drawPath(
      Path()
        ..moveTo(86, 42)
        ..lineTo(90, 30)
        ..quadraticBezierTo(94, 40, 98, 42)
        ..close(),
      innerShadow,
    );

    void drawGoldBall(Offset center, double radius) {
      final rect = Rect.fromCircle(center: center, radius: radius);
      canvas.drawCircle(
        center,
        radius,
        Paint()..shader = crownGradient.createShader(rect),
      );
      canvas.drawCircle(
        center,
        radius,
        Paint()
          ..color = const Color(0xFF8F6217)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 1.5,
      );
    }

    drawGoldBall(const Offset(20, 21), 4.5);
    drawGoldBall(const Offset(60, 13), 5.5);
    drawGoldBall(const Offset(100, 21), 4.5);

    void drawGem(
      Offset center,
      double radius,
      List<Color> colors,
      Color stroke,
    ) {
      final rect = Rect.fromCircle(center: center, radius: radius);
      canvas.drawCircle(
        center,
        radius,
        Paint()
          ..shader = RadialGradient(
            center: const Alignment(0, -0.16),
            colors: colors,
            stops: const [0, 0.55, 1],
          ).createShader(rect),
      );
      canvas.drawCircle(
        center,
        radius,
        Paint()
          ..color = stroke
          ..style = PaintingStyle.stroke
          ..strokeWidth = 1.4,
      );
    }

    drawGem(
      const Offset(60, 27),
      7,
      const [Color(0xFFFF9E9E), Color(0xFFE13A3A), Color(0xFF8F1212)],
      const Color(0xFF7A0E0E),
    );
    drawGem(
      const Offset(32, 34),
      4.2,
      const [Color(0xFFB7F3E6), Color(0xFF2BB3A0), Color(0xFF0E6E60)],
      const Color(0xFF0E6E60),
    );
    drawGem(
      const Offset(88, 34),
      4.2,
      const [Color(0xFFB7F3E6), Color(0xFF2BB3A0), Color(0xFF0E6E60)],
      const Color(0xFF0E6E60),
    );
    canvas.drawOval(
      const Rect.fromLTWH(54.9, 22.7, 5.2, 3.6),
      Paint()..color = const Color(0xCCFFFFFF),
    );

    final bandRect = const Rect.fromLTWH(10, 62, 100, 14);
    canvas.drawRRect(
      RRect.fromRectAndRadius(bandRect, const Radius.circular(7)),
      Paint()
        ..shader = const LinearGradient(
          begin: Alignment.centerRight,
          end: Alignment.centerLeft,
          colors: [Color(0xFFFFE9A8), Color(0xFFE4AC38), Color(0xFF8F6217)],
          stops: [0, 0.4, 1],
        ).createShader(bandRect),
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(bandRect, const Radius.circular(7)),
      Paint()
        ..color = const Color(0xFF8F6217)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2,
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        const Rect.fromLTWH(10, 62, 100, 4),
        const Radius.circular(2),
      ),
      Paint()..color = const Color(0x8CFFF3C4),
    );

    canvas.drawPath(
      Path()
        ..moveTo(18, 40)
        ..lineTo(34, 20)
        ..lineTo(38, 24)
        ..lineTo(22, 44)
        ..close(),
      Paint()..color = const Color(0x80FFFFFF),
    );
    canvas.drawPath(
      Path()
        ..moveTo(62, 26)
        ..lineTo(66, 20)
        ..lineTo(69, 23)
        ..lineTo(65, 29)
        ..close(),
      Paint()..color = const Color(0x8CFFFFFF),
    );

    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant _CrownPainter oldDelegate) => false;
}
