import 'package:flutter/material.dart';

import '../../core/monetization.dart';

/// A safe support diagnostic: why access is free/full, never receipt contents,
/// order IDs, tokens, signatures, PINs or other private purchase information.
class PurchaseAccessStatus extends StatelessWidget {
  const PurchaseAccessStatus({super.key});

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<FullVersionAccessStatus>(
      valueListenable: Monetization.accessStatus,
      builder: (context, status, _) {
        final message = switch (status) {
          FullVersionAccessStatus.checking => 'وضعیت خرید هنوز بررسی نشده است.',
          FullVersionAccessStatus.free =>
            'نسخهٔ رایگان؛ خرید تأییدشده‌ای در فروشگاه پیدا نشد.',
          FullVersionAccessStatus.untrustedBuild =>
            'فعال‌سازی فقط در نسخهٔ رسمی انتشار مایکت امکان‌پذیر است.',
          FullVersionAccessStatus.needsRestore =>
            'مجوز قبلی قابل تأیید نیست. اگر خریده‌اید، «بازیابی خرید نسخهٔ کامل» را بزنید.',
          FullVersionAccessStatus.storeVerified =>
            'نسخهٔ کامل؛ رسید امضاشدهٔ مایکت تأیید شد.',
          FullVersionAccessStatus.offlineVerified =>
            'نسخهٔ کامل آفلاین؛ امضای رسید مایکت ذخیره‌شده تأیید شد.',
        };
        return Semantics(
          liveRegion: true,
          child: Text(
            message,
            key: const ValueKey('purchase_access_status'),
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  height: 1.7,
                  color: status.isVerified
                      ? const Color(0xFF16803C) : const Color(0xFF5D4037),
                ),
          ),
        );
      },
    );
  }
}
