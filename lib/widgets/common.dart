import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class ChildFeedback {
  static final _praise = [
    'آفرین! عالی بود! 🌟',
    'باریکلا قهرمان! 🥳',
    'درست گفتی! ادامه بده! 🚀',
  ];
  static final _tryAgain = [
    'نزدیک بودی! یک‌بار دیگه امتحان کن 🌈',
    'اشکال نداره عزیزم، با دقت نگاه کن 💛',
    'تو می‌تونی! دوباره تلاش کن ✨',
  ];

  static void correct(BuildContext context) =>
      _show(context, _praise[DateTime.now().millisecond % _praise.length],
          const Color(0xFF2EAF63));
  static void tryAgain(BuildContext context) =>
      _show(context, _tryAgain[DateTime.now().millisecond % _tryAgain.length],
          const Color(0xFFFF8A4C));

  static void _show(BuildContext context, String message, Color color) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(
        behavior: SnackBarBehavior.floating,
        backgroundColor: color,
        duration: const Duration(milliseconds: 1150),
        margin: const EdgeInsets.fromLTRB(24, 0, 24, 24),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
        content: Text(message,
            textAlign: TextAlign.center,
            style: const TextStyle(
                fontSize: 16, fontWeight: FontWeight.bold)),
      ));
  }
}

class BounceBtn extends StatefulWidget {
  final Widget child;
  final VoidCallback onTap;
  const BounceBtn({super.key, required this.child, required this.onTap});
  @override
  State<BounceBtn> createState() => _BounceBtnState();
}

class _BounceBtnState extends State<BounceBtn>
    with SingleTickerProviderStateMixin {
  late AnimationController _c;
  @override
  void initState() {
    super.initState();
    _c = AnimationController(
        vsync: this,
        duration: const Duration(milliseconds: 150),
        lowerBound: 0.9,
        upperBound: 1.0)
      ..value = 1.0;
  }

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext c) => GestureDetector(
        onTapDown: (_) => _c.reverse(),
        onTapUp: (_) {
          _c.forward();
          HapticFeedback.lightImpact();
          widget.onTap();
        },
        onTapCancel: () => _c.forward(),
        child: ScaleTransition(scale: _c, child: widget.child),
      );
}
