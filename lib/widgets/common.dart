import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// Common reusable widgets for professional look

class BounceBtn extends StatelessWidget {
  final Widget child;
  final VoidCallback onTap;
  final double scale;

  const BounceBtn({
    super.key,
    required this.child,
    required this.onTap,
    this.scale = 0.95,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        HapticFeedback.lightImpact();
        onTap();
      },
      child: child,
    );
  }
}

// NOTE: StarDisplay lives in widgets/star_display.dart and FandoghiMini in
// widgets/fandoghi.dart. They used to be duplicated here, which caused
// "ambiguous import" compile errors in every file importing both libraries.

class ProgressBar extends StatelessWidget {
  final double progress;
  final Color color;
  final double height;

  const ProgressBar({
    super.key,
    required this.progress,
    this.color = const Color(0xFF6C63FF),
    this.height = 8,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: height,
      decoration: BoxDecoration(
        color: Colors.grey.shade200,
        borderRadius: BorderRadius.circular(20),
      ),
      child: FractionallySizedBox(
        alignment: Alignment.centerLeft,
        widthFactor: progress.clamp(0.0, 1.0).toDouble(),
        child: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(colors: [color, color.withOpacity(0.7)]),
            borderRadius: BorderRadius.circular(20),
          ),
        ),
      ),
    );
  }
}
class ChildFeedback {
  static void correct(BuildContext context) {
    ScaffoldMessenger.of(context).clearSnackBars();
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Row(
          children: [
            Icon(Icons.check_circle, color: Colors.white),
            SizedBox(width: 8),
            Text('آفرین! درست بود! 🎉', style: TextStyle(fontSize: 16)),
          ],
        ),
        backgroundColor: Colors.green,
        duration: Duration(milliseconds: 800),
      ),
    );
  }

  static void tryAgain(BuildContext context) {
    ScaffoldMessenger.of(context).clearSnackBars();
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Row(
          children: [
            Icon(Icons.error, color: Colors.white),
            SizedBox(width: 8),
            Text('دوباره تلاش کن! 💪', style: TextStyle(fontSize: 16)),
          ],
        ),
        backgroundColor: Colors.redAccent,
        duration: Duration(milliseconds: 800),
      ),
    );
  }
}
