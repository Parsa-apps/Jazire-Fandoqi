import 'dart:async';

import 'package:flutter/material.dart';

import '../../app/app_fonts.dart';
import '../../app/island_world_style.dart';
import '../../core/monetization.dart';
import '../../shared/widgets/animated_gold_lock.dart';
import 'full_version_paywall.dart';

/// ═══════════════════════════════════════════════════════════════
/// 🛒 HUB PURCHASE CHIP — دکمهٔ خرید همیشه‌نویدبارِ هاب‌ها و صفحهٔ اصلی
///
/// والد نباید برای پیدا کردنِ راهِ خرید، تا انتهای نقشه اسکرول کند یا
/// سراغِ آیتمِ قفل برود. این چیپِ طلایی بالای هاب‌ها (کارتون‌کده،
/// قصه‌خانه، لالایی‌کده) و روی خودِ نقشهٔ اصلی می‌نشیند و همان پی‌والِ
/// رسمیِ والد را باز می‌کند — نه بیشتر، نه کمتر.
///
/// دورِ دکمه تا وقتی نسخه کامل فعال نشده، یک هالهٔ نئونی طلایی با
/// تنفّس آرام می‌درخشد تا راهِ خرید از هر جای صفحه دیده شود.
///
/// قراردادِ fail-closed با بقیهٔ فروشگاه یکی است:
///  • تا وقتی `Monetization` مالکیت را تأیید نکرده، دکمه «خرید» است.
///  • لمسِ دکمه خودش هرگز دسترسی نمی‌سازد؛ فقط پی‌وال را باز می‌کند.
///  • بعد از خرید تأییدشده، هاله خاموش و دکمه به «فعال» سبزِ آرام
///    تبدیل می‌شود و لمسِ دوباره کاری نمی‌کند.
/// ═══════════════════════════════════════════════════════════════
class HubPurchaseChip extends StatefulWidget {
  const HubPurchaseChip({super.key});

  @override
  State<HubPurchaseChip> createState() => _HubPurchaseChipState();
}

class _HubPurchaseChipState extends State<HubPurchaseChip>
    with SingleTickerProviderStateMixin {
  bool _opening = false;
  late final AnimationController _glow;

  @override
  void initState() {
    super.initState();
    // هالهٔ نئونی: تنفّس آرامِ ۰→۱→۰ (۱٫۷ ثانیه) که فقط لایهٔ درخشش را
    // هر فریم رنگ می‌کند؛ خودِ دکمه و متنش بازسازی نمی‌شوند.
    _glow = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1700),
    );
    // هماهنگ با FullVersionPurchaseEntry: یک‌بار وضعیت را بپرس (کوئری‌ها
    // در Monetization یکی می‌شوند) و بعد از آن به گوش دادن بسنده کن.
    unawaited(Monetization.hasFullVersion());
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // با «کاهش حرکت» سیستم، هاله ثابت می‌ماند (چشمک نمی‌زند) ولی حضورش
    // محفوظ است. تیکر این ویجت با TickerMode تب‌های IndexedStack هم
    // خودبه‌خود خاموش می‌شود، پس تبِ پنهان هزینهٔ انیمیشن ندارد.
    final reduceMotion =
        MediaQuery.maybeOf(context)?.disableAnimations ?? false;
    if (reduceMotion) {
      if (_glow.isAnimating) _glow.stop();
      _glow.value = 0.4;
    } else if (!_glow.isAnimating) {
      _glow.repeat(reverse: true);
    }
  }

  @override
  void dispose() {
    _glow.dispose();
    super.dispose();
  }

  /// هالهٔ نئونی دور دکمه — فقط وقتی نسخه کامل هنوز فعال نیست.
  /// بعد از خرید، دکمه آرام و سبز می‌شود و درخشش دیگر معنا ندارد.
  Widget _withNeonHalo(bool owned, Widget button) {
    if (owned) return button;
    return AnimatedBuilder(
      animation: _glow,
      child: button,
      builder: (context, button) {
        final t = Curves.easeInOut.transform(_glow.value);
        return DecoratedBox(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(999),
            boxShadow: [
              // هالهٔ نزدیک: طلاییِ گرم که با تنفّس نزدیک و دور می‌شود
              BoxShadow(
                color: const Color(0xFFFFC94D).withOpacity(0.32 + 0.30 * t),
                blurRadius: 9 + 9 * t,
                spreadRadius: -1 + 2 * t,
              ),
              // هالهٔ دور: کهرباییِ پخش که دکمه را از پس‌زمینه جدا می‌کند
              BoxShadow(
                color: const Color(0xFFFF9E2C).withOpacity(0.14 + 0.20 * t),
                blurRadius: 18 + 14 * t,
                spreadRadius: 1 + 1.5 * t,
              ),
            ],
          ),
          child: button,
        );
      },
    );
  }

  Future<void> _openPaywall() async {
    if (_opening) return;
    setState(() => _opening = true);
    try {
      // پیش از هر پیشنهادِ خرید، مالکیت را دوباره از فروشگاه بپرس.
      // بازشدنِ این دکمه هرگز خودش دسترسی نمی‌سازد.
      final owned = await Monetization.hasFullVersion();
      if (!mounted || owned) return;
      await showFullVersionPaywall(context);
    } finally {
      if (mounted) {
        setState(() => _opening = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<FullVersionAccessStatus>(
      valueListenable: Monetization.accessStatus,
      builder: (context, status, _) {
        final owned = status.isVerified;
        return _withNeonHalo(
          owned,
          Semantics(
            container: true,
            label: owned
                ? 'نسخهٔ کامل فعال است'
                : 'خرید نسخهٔ کامل؛ نیمهٔ اول هر مجموعه رایگان است',
            button: !owned,
            child: Tooltip(
              message: owned ? 'نسخهٔ کامل فعال است' : 'خرید نسخهٔ کامل',
              child: Material(
                color: owned ? const Color(0xFFE3F6E8) : Colors.transparent,
                elevation: owned ? 0 : 2,
                shadowColor: const Color(0x66B8860B),
                shape: StadiumBorder(
                  side: BorderSide(
                    color: owned
                        ? const Color(0xFF16803C)
                        : const Color(0xFFD99415),
                    width: 1.5,
                  ),
                ),
                clipBehavior: Clip.antiAlias,
                child: InkWell(
                  key: const ValueKey('hub_purchase_button'),
                  onTap: owned || _opening ? null : _openPaywall,
                  child: Container(
                    height: 38,
                    padding: const EdgeInsets.symmetric(horizontal: 11),
                    decoration: owned
                        ? null
                        : const BoxDecoration(
                            gradient: IslandWorldGradients.honeyButton,
                          ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        if (_opening)
                          const SizedBox(
                            width: 17,
                            height: 17,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        else if (owned)
                          const Icon(
                            Icons.verified_rounded,
                            color: Color(0xFF16803C),
                            size: 19,
                          )
                        else
                          const AnimatedGoldLock(size: 19),
                        const SizedBox(width: 5),
                        Text(
                          owned ? 'فعال' : 'خرید',
                          maxLines: 1,
                          style: AppFonts.vazirmatn(
                            fontSize: 13.5,
                            fontWeight: FontWeight.w900,
                            color: owned
                                ? const Color(0xFF16803C)
                                : IslandWorldPalette.ink,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
