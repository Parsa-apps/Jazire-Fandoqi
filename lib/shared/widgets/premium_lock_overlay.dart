import 'package:flutter/material.dart';

import '../../app/app_fonts.dart';

/// A consistent, child-friendly premium state for content cards.
class PremiumLockOverlay extends StatelessWidget {
  const PremiumLockOverlay({
    super.key,
    this.label = 'نسخه کامل',
    this.compact = false,
  });

  final String label;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    return Positioned.fill(
      child: IgnorePointer(
        child: ColoredBox(
          color: Colors.black.withOpacity(compact ? 0.28 : 0.42),
          child: Center(
            child: Container(
              padding: compact
                  ? const EdgeInsets.all(5)
                  : const EdgeInsets.symmetric(horizontal: 11, vertical: 7),
              decoration: BoxDecoration(
                color: const Color(0xFF6C43D9).withOpacity(0.94),
                borderRadius: BorderRadius.circular(compact ? 99 : 14),
                border: Border.all(color: Colors.white.withOpacity(0.82)),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.22),
                    blurRadius: 8,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
              child: compact
                  ? const Icon(
                      Icons.lock_rounded,
                      color: Colors.white,
                      size: 16,
                    )
                  : Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(
                          Icons.lock_rounded,
                          color: Colors.white,
                          size: 17,
                        ),
                        const SizedBox(width: 5),
                        Text(
                          label,
                          style: AppFonts.vazirmatn(
                            color: Colors.white,
                            fontSize: 11,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                      ],
                    ),
            ),
          ),
        ),
      ),
    );
  }
}
