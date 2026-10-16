import 'dart:async';

import 'package:flutter/material.dart';

import '../../app/app_fonts.dart';
import '../../app/island_world_style.dart';
import '../../core/monetization.dart';
import '../../shared/widgets/animated_gold_lock.dart';
import 'full_version_paywall.dart';

/// ═══════════════════════════════════════════════════════════════
/// 🛒 HUB PURCHASE CHIP — دکمهٔ خرید همیشه‌نویدبارِ هاب‌ها
///
/// والد نباید برای پیدا کردنِ راهِ خرید، تا انتهای نقشه اسکرول کند یا
/// سراغِ آیتمِ قفل برود. این چیپِ طلایی همیشه بالای صفحه، کنارِ عنوانِ
/// هاب (کارتون‌کده، قصه‌خانه، لالایی‌کده) دیده می‌شود و همان پی‌والِ
/// رسمیِ والد را باز می‌کند — نه بیشتر، نه کمتر.
///
/// قراردادِ fail-closed با بقیهٔ فروشگاه یکی است:
///  • تا وقتی `Monetization` مالکیت را تأیید نکرده، دکمه «خرید» است.
///  • لمسِ دکمه خودش هرگز دسترسی نمی‌سازد؛ فقط پی‌وال را باز می‌کند.
///  • بعد از خرید تأییدشده، بدونِ بازکردنِ صفحه، به «فعال» سبز تبدیل
///    می‌شود و لمسِ دوباره کاری نمی‌کند.
/// ═══════════════════════════════════════════════════════════════
class HubPurchaseChip extends StatefulWidget {
  const HubPurchaseChip({super.key});

  @override
  State<HubPurchaseChip> createState() => _HubPurchaseChipState();
}

class _HubPurchaseChipState extends State<HubPurchaseChip> {
  bool _opening = false;

  @override
  void initState() {
    super.initState();
    // هماهنگ با FullVersionPurchaseEntry: یک‌بار وضعیت را بپرس (کوئری‌ها
    // در Monetization یکی می‌شوند) و بعد از آن به گوش دادن بسنده کن.
    unawaited(Monetization.hasFullVersion());
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
        return Semantics(
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
        );
      },
    );
  }
}
