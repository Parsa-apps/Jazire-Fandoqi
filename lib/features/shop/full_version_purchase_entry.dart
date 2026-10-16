import 'dart:async';

import 'package:flutter/material.dart';

import '../../app/app_fonts.dart';
import '../../core/monetization.dart';
import '../../shared/widgets/animated_gold_lock.dart';
import 'full_version_paywall.dart';

/// An entry to the existing parent-gated paywall, independent of how far down
/// a paid collection is scrolled. Opening this entry never grants access;
/// purchase/restore and the signed-receipt check still happen in the paywall.
class FullVersionPurchaseEntry extends StatefulWidget {
  const FullVersionPurchaseEntry({super.key, this.compact = false});

  /// The map has room for a small floating entry; parent screens use a card.
  final bool compact;

  @override
  State<FullVersionPurchaseEntry> createState() =>
      _FullVersionPurchaseEntryState();
}

class _FullVersionPurchaseEntryState extends State<FullVersionPurchaseEntry> {
  bool _opening = false;

  @override
  void initState() {
    super.initState();
    // The map used to show only open hub entrances and never checked purchase
    // status. Check once here, then listen for purchase/revocation updates.
    unawaited(Monetization.hasFullVersion());
  }

  Future<void> _openPaywall() async {
    if (_opening) return;
    setState(() => _opening = true);
    try {
      // Recheck ownership before offering another purchase. If the store is
      // unavailable, the paywall remains reachable; it will fail closed.
      final owned = await Monetization.hasFullVersion();
      if (!mounted || owned) return;
      await showFullVersionPaywall(context);
    } finally {
      if (mounted) setState(() => _opening = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<FullVersionAccessStatus>(
      valueListenable: Monetization.accessStatus,
      builder: (context, status, _) {
        final owned = status.isVerified;
        final title = owned ? 'نسخه کامل فعال است' : 'خرید نسخه کامل';
        final subtitle = owned
            ? 'همهٔ محتوای پولی باز است'
            : widget.compact
                ? 'نیمه رایگان • بقیه قفل'
                : 'نیمهٔ اول رایگان است؛ بقیه با یک خرید باز می‌شود.';
        final radius = BorderRadius.circular(widget.compact ? 18 : 16);

        return SizedBox(
          width: widget.compact ? 184 : double.infinity,
          child: Material(
            color: const Color(0xFFFFF8E7),
            elevation: widget.compact ? 4 : 1,
            shadowColor: const Color(0x775D4037),
            shape: RoundedRectangleBorder(
              borderRadius: radius,
              side: const BorderSide(color: Color(0xFFFFB300), width: 1.5),
            ),
            clipBehavior: Clip.antiAlias,
            child: InkWell(
              key: const ValueKey('full_version_purchase_entry'),
              borderRadius: radius,
              onTap: owned || _opening ? null : _openPaywall,
              child: Padding(
                padding: EdgeInsets.symmetric(
                  horizontal: widget.compact ? 8 : 14,
                  vertical: widget.compact ? 9 : 13,
                ),
                child: Row(
                  children: [
                    if (owned)
                      const Icon(Icons.verified_rounded,
                          color: Color(0xFF16803C), size: 28)
                    else
                      const AnimatedGoldLock(size: 28),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            title,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: AppFonts.vazirmatn(
                              fontSize: widget.compact ? 13 : 16,
                              fontWeight: FontWeight.w900,
                              color: const Color(0xFF5D4037),
                            ),
                          ),
                          Text(
                            subtitle,
                            maxLines: widget.compact ? 2 : 3,
                            style: AppFonts.vazirmatn(
                              fontSize: widget.compact ? 10 : 12,
                              color: const Color(0xFF5D4037),
                              height: 1.4,
                            ),
                          ),
                        ],
                      ),
                    ),
                    if (_opening)
                      const SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    else if (!owned && !widget.compact)
                      const Icon(Icons.chevron_left_rounded,
                          color: Color(0xFF5D4037)),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
