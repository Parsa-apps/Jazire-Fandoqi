import 'package:flutter/material.dart';

import '../../core/asset_manager.dart';

/// =======================================================
/// ✨ PREMIUM LOADING SCREEN
/// =======================================================
class PremiumLoading extends StatelessWidget {
  final String message;

  const PremiumLoading({super.key, this.message = 'در حال آماده‌سازی...'});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: const Color(0xFF4834D4),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // فاز ۵: تصویر از کش AssetManager لود می‌شود
            const FandoghiImage(
              'assets/premium/loading_fandoghi.png',
              width: 160,
              height: 160,
            ),
            const SizedBox(height: 30),
            Text(
              message,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 20),
            const SizedBox(
              width: 60,
              height: 4,
              child: LinearProgressIndicator(
                backgroundColor: Colors.white24,
                color: Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }
}