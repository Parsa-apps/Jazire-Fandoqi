import 'package:flutter/material.dart';

/// The canonical Parsa Apps brand mark.
///
/// Keep every in-app publisher logo routed through this widget so the artwork,
/// accessibility label and rendering quality remain consistent.
class ParsaAppsLogo extends StatelessWidget {
  const ParsaAppsLogo({
    super.key,
    this.size = 64,
    this.borderRadius = 16,
    this.showShadow = true,
  });

  static const assetPath = 'assets/parsa-apps-gold-1024.png';

  final double size;
  final double borderRadius;
  final bool showShadow;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      image: true,
      label: 'لوگوی پارسا اپس',
      child: ExcludeSemantics(
        child: Container(
          width: size,
          height: size,
          decoration: BoxDecoration(
            color: Colors.black,
            borderRadius: BorderRadius.circular(borderRadius),
            boxShadow: showShadow
                ? [
                    BoxShadow(
                      color: const Color(0xFFFFD700).withOpacity(0.32),
                      blurRadius: size * 0.24,
                      spreadRadius: 1,
                    ),
                  ]
                : null,
          ),
          clipBehavior: Clip.antiAlias,
          child: Image.asset(
            assetPath,
            fit: BoxFit.cover,
            filterQuality: FilterQuality.high,
          ),
        ),
      ),
    );
  }
}
