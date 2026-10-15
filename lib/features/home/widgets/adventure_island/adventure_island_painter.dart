import 'dart:math';
import 'package:flutter/material.dart';
import '../../../../app/island_world_style.dart';

class AdventureIslandPainter extends CustomPainter {
  final double progress;
  final double scrollOffset;

  AdventureIslandPainter({
    required this.progress,
    required this.scrollOffset,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;

    // Background base
    canvas.drawRect(
      Rect.fromLTWH(0, 0, w, h),
      Paint()..color = IslandWorldPalette.skyMist,
    );

    // Draw ocean at the top (Beach Region)
    _drawOcean(canvas, w, h);
    
    // Draw the main island body
    _drawIslandBody(canvas, w, h);

    // Draw winding river through the island
    _drawRiver(canvas, w, h);

    // Draw path connecting regions
    _drawPath(canvas, w, h);
    
    // Draw region-specific decorations (trees, rocks, flowers)
    _drawDecorations(canvas, w, h);
  }

  void _drawOcean(Canvas canvas, double w, double h) {
    final path = Path();
    path.moveTo(0, 0);
    path.lineTo(w, 0);
    path.lineTo(w, h * 0.3);
    
    // Wavy shore
    for (double x = w; x >= 0; x -= 20) {
      final wave = sin(x * 0.05 + progress * 2 * pi) * 15;
      path.lineTo(x, h * 0.28 + wave);
    }
    path.close();

    canvas.drawPath(
      path,
      Paint()
        ..shader = IslandWorldGradients.ocean.createShader(
          Rect.fromLTWH(0, 0, w, h * 0.3),
        ),
    );
    
    // Foam on shore
    final foamPath = Path();
    for (double x = 0; x <= w; x += 15) {
      final wave = sin(x * 0.05 + progress * 2 * pi) * 15;
      foamPath.moveTo(x, h * 0.28 + wave);
      foamPath.lineTo(x + 10, h * 0.28 + wave + 5);
    }
    canvas.drawPath(
      foamPath,
      Paint()
        ..color = Colors.white.withOpacity(0.5)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 4
        ..strokeCap = StrokeCap.round,
    );
  }

  void _drawIslandBody(Canvas canvas, double w, double h) {
    final path = Path();
    path.moveTo(w * 0.1, h * 0.28);
    path.quadraticBezierTo(w * 0.5, h * 0.22, w * 0.9, h * 0.28);
    path.lineTo(w * 0.95, h * 0.5);
    path.quadraticBezierTo(w, h * 0.7, w * 0.85, h * 0.9);
    path.quadraticBezierTo(w * 0.5, h * 0.98, w * 0.15, h * 0.9);
    path.quadraticBezierTo(0, h * 0.7, w * 0.05, h * 0.5);
    path.close();

    canvas.drawPath(
      path,
      Paint()
        ..shader = LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            IslandWorldPalette.honey.withOpacity(0.5), // Sandy transition
            IslandWorldPalette.foliageLight,
            IslandWorldPalette.foliage,
            IslandWorldPalette.foliageDeep,
          ],
          stops: const [0.0, 0.2, 0.6, 1.0],
        ).createShader(Rect.fromLTWH(0, h * 0.25, w, h * 0.7)),
    );
    
    // Draw 3D edge (ground depth)
    final depthPath = Path();
    depthPath.moveTo(w * 0.15, h * 0.9);
    depthPath.quadraticBezierTo(w * 0.5, h * 0.98, w * 0.85, h * 0.9);
    depthPath.lineTo(w * 0.85, h * 0.9 + 40);
    depthPath.quadraticBezierTo(w * 0.5, h * 0.98 + 40, w * 0.15, h * 0.9 + 40);
    depthPath.close();

    canvas.drawPath(
      depthPath,
      Paint()..color = const Color(0xFF5D4037), // Dirt color
    );
  }

  void _drawRiver(Canvas canvas, double w, double h) {
    final path = Path();
    path.moveTo(w * 0.2, h * 0.35); // Springs from somewhere in the top
    path.quadraticBezierTo(w * 0.6, h * 0.45, w * 0.4, h * 0.55);
    path.quadraticBezierTo(w * 0.2, h * 0.65, w * 0.5, h * 0.75);
    path.quadraticBezierTo(w * 0.8, h * 0.85, w * 0.6, h * 0.95);

    // River background
    canvas.drawPath(
      path,
      Paint()
        ..color = IslandWorldPalette.ocean
        ..style = PaintingStyle.stroke
        ..strokeWidth = 35
        ..strokeCap = StrokeCap.round,
    );
    
    // River highlights (water flow)
    final dashPath = Path();
    for(double t = 0; t <= 1; t += 0.05) {
      // Very simple dash approximation on the path
    }
  }

  void _drawPath(Canvas canvas, double w, double h) {
    final path = Path();
    path.moveTo(w * 0.5, h * 0.15); // Start at beach
    path.quadraticBezierTo(w * 0.8, h * 0.3, w * 0.4, h * 0.45);
    path.quadraticBezierTo(w * 0.1, h * 0.6, w * 0.6, h * 0.75);
    path.quadraticBezierTo(w * 0.9, h * 0.9, w * 0.5, h * 0.92);

    // Path shadow
    canvas.drawPath(
      path,
      Paint()
        ..color = Colors.black.withOpacity(0.1)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 24
        ..strokeCap = StrokeCap.round,
    );

    // Path base
    canvas.drawPath(
      path,
      Paint()
        ..color = IslandWorldPalette.paper
        ..style = PaintingStyle.stroke
        ..strokeWidth = 20
        ..strokeCap = StrokeCap.round,
    );
    
    // Dash marks on path
    final dashPaint = Paint()
      ..color = IslandWorldPalette.honey.withOpacity(0.6)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 4
      ..strokeCap = StrokeCap.round;
      
    // A proper path metric dash would be better, but for now we keep it simple.
  }

  void _drawDecorations(Canvas canvas, double w, double h) {
    final rng = Random(42);
    // Draw trees
    for (int i = 0; i < 40; i++) {
      final x = w * rng.nextDouble();
      final y = h * (0.3 + rng.nextDouble() * 0.6);
      
      // Keep away from center path
      if ((x - w/2).abs() > w*0.2) {
        _drawTree(canvas, x, y, 0.6 + rng.nextDouble() * 0.6);
      }
    }
  }
  
  void _drawTree(Canvas canvas, double x, double y, double scale) {
    final s = scale;

    // Trunk
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(x - 4 * s, y - 30 * s, 8 * s, 35 * s),
        Radius.circular(3 * s),
      ),
      Paint()..color = const Color(0xFF6D4C41),
    );

    // Foliage
    final color = IslandWorldPalette.foliageDeep;
    final paint = Paint()..color = color;
    final r = 24 * s;

    canvas.drawCircle(Offset(x, y - 35 * s), r, paint);
    canvas.drawCircle(Offset(x - r * 0.5, y - 35 * s + r * 0.3), r * 0.7, paint);
    canvas.drawCircle(Offset(x + r * 0.5, y - 35 * s + r * 0.2), r * 0.65, paint);
    
    // Highlight
    canvas.drawCircle(
      Offset(x - r * 0.2, y - 35 * s - r * 0.2), 
      r * 0.4, 
      Paint()..color = IslandWorldPalette.foliage,
    );
  }

  @override
  bool shouldRepaint(covariant AdventureIslandPainter oldDelegate) {
    return oldDelegate.progress != progress || oldDelegate.scrollOffset != scrollOffset;
  }
}

class CloudsOverlayPainter extends CustomPainter {
  final double progress;
  CloudsOverlayPainter({required this.progress});

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;
    
    final paint = Paint()..color = Colors.white.withOpacity(0.7);
    
    for (int i = 0; i < 4; i++) {
      final speed = 1.0 + i * 0.5;
      final x = (w * i * 0.3 + progress * w * speed) % (w + 200) - 100;
      final y = 20.0 + i * 30.0;
      
      canvas.drawCircle(Offset(x, y), 25, paint);
      canvas.drawCircle(Offset(x - 20, y + 10), 20, paint);
      canvas.drawCircle(Offset(x + 20, y + 10), 18, paint);
      canvas.drawRect(Rect.fromLTWH(x - 20, y, 40, 30), paint);
    }
  }

  @override
  bool shouldRepaint(covariant CloudsOverlayPainter oldDelegate) => true;
}
