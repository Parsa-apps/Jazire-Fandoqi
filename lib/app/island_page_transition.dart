import 'package:flutter/material.dart';

/// انتقال صفحهٔ «دنیای جزیره»: ورود آرام از پایین با محو و بزرگ‌شدن
/// بسیار خفیف — مثل قدم‌گذاشتن روی سکوی بعدی، نه پرش ناگهانی.
/// کوتاه (۲۸۰ms)، با شتاب طبیعی و بدون چشمک؛ روی گوشی‌های معمولی
/// فقط از شفافیت و تبدیل ارزان استفاده می‌کند.
class IslandPageTransitionsBuilder extends PageTransitionsBuilder {
  const IslandPageTransitionsBuilder();

  @override
  Widget buildTransitions<T>(
    PageRoute<T> route,
    BuildContext context,
    Animation<double> animation,
    Animation<double> secondaryAnimation,
    Widget child,
  ) {
    final curved = CurvedAnimation(
      parent: animation,
      curve: Curves.easeOutCubic,
      reverseCurve: Curves.easeInCubic,
    );
    return FadeTransition(
      opacity: curved,
      child: SlideTransition(
        position: Tween<Offset>(
          begin: const Offset(0, 0.045),
          end: Offset.zero,
        ).animate(curved),
        child: ScaleTransition(
          scale: Tween<double>(begin: 0.985, end: 1).animate(curved),
          child: child,
        ),
      ),
    );
  }
}
