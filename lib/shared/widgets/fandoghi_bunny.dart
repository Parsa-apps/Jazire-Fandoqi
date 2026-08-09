import 'package:flutter/material.dart';

import '../../app/app_colors.dart';
import '../../core/fandoghi_models.dart';

/// The visual asset used for فندقی throughout the app.
///
/// Since the rebrand, «فندقی» is a cheerful toddler boy (teal hoodie with a
/// hazelnut badge) instead of the old teacher bunny. The artwork is kept as
/// a transparent, square PNG so it preserves the full character (hair tuft,
/// waving hand and sneakers) in every slot. Several emotional expressions
/// exist (cheer / think / wow); pass [mood] to pick one. Keeping the image
/// inside a normal square frame also means a future mascot asset can be
/// swapped in without changing any of the UI call sites.
class FandoghiBunny extends StatelessWidget {
  /// Logical size of the mascot (width and height of the square frame).
  final double size;
  final BoxFit fit;
  final Alignment alignment;

  /// حالت احساسی — برای حالت‌هایی که تصویر اختصاصی دارند (شادی، جشن،
  /// فکر کردن، تعجب) همان تصویر نشان داده می‌شود وگرنه تصویر پیش‌فرض.
  final FandoghiMood mood;

  const FandoghiBunny({
    super.key,
    this.size = 96,
    this.fit = BoxFit.contain,
    this.alignment = Alignment.center,
    this.mood = FandoghiMood.happy,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: Image.asset(
        mood.portraitAsset ?? 'assets/mascot/fandoghi_baby.png',
        fit: fit,
        alignment: alignment,
        filterQuality: FilterQuality.high,
        // Give a slight fade-in so the bunny does not pop in.
        frameBuilder: (context, child, frame, wasSync) {
          if (wasSync) return child;
          return AnimatedOpacity(
            opacity: frame == null ? 0 : 1,
            duration: const Duration(milliseconds: 220),
            curve: Curves.easeOut,
            child: child,
          );
        },
        errorBuilder: (context, _, __) => _FallbackBunny(size: size),
      ),
    );
  }
}

/// A small fallback so the mascot never disappears if the asset is missing.
class _FallbackBunny extends StatelessWidget {
  final double size;
  const _FallbackBunny({required this.size});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: const Color(0xFFFFF0DB),
        shape: BoxShape.circle,
        border: Border.all(color: AppColors.primary.withOpacity(0.3), width: 2),
      ),
      child: Text('🧒', style: TextStyle(fontSize: size * 0.6)),
    );
  }
}
