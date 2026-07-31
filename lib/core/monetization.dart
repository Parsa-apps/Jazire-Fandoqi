import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Monetization helper for CafeBazaar & Myket
class Monetization {
  static const String _subscriptionKey = 'is_premium';
  static const String _lastPurchaseDate = 'last_purchase';

  /// Check if user has premium subscription
  static Future<bool> isPremium() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_subscriptionKey) ?? false;
  }

  /// Activate premium (called after successful purchase)
  static Future<void> activatePremium() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_subscriptionKey, true);
    await prefs.setString(_lastPurchaseDate, DateTime.now().toIso8601String());
  }

  /// Show purchase dialog for Bazaar/Myket
  static Future<void> showPurchaseDialog(BuildContext context, {
    required String productId,
    required String productName,
    required int price,
  }) async {
    final isPremiumUser = await isPremium();

    if (isPremiumUser) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('شما قبلاً اشتراک دارید!')),
      );
      return;
    }

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text('خرید $productName'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('$price تومان'),
            const SizedBox(height: 12),
            const Text(
              'با پرداخت از طریق کافه‌بازار یا مایکت، اشتراک فعال می‌شود.',
              textAlign: TextAlign.center,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('انصراف'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
            onPressed: () async {
              Navigator.pop(ctx);
              // TODO: Replace with real Bazaar/Myket billing
              await activatePremium();
              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('$productName با موفقیت خریداری شد!'),
                    backgroundColor: Colors.green,
                  ),
                );
              }
            },
            child: const Text('پرداخت'),
          ),
        ],
      ),
    );
  }

  /// In-app purchase for coins/stars
  static Future<void> purchaseInAppItem(BuildContext context, {
    required String itemId,
    required int coins,
    required int stars,
    required int price,
  }) async {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('خرید داخل برنامه'),
        content: Text('آیا می‌خواهید $coins سکه و $stars ستاره به قیمت $price تومان بخرید؟'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('نه')),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(ctx);
              // Simulate successful purchase
              // In real implementation: call Bazaar billing API
              // GameData.addCoins(coins);
              // GameData.addStars(stars);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('خرید موفق!')),
              );
            },
            child: const Text('خرید'),
          ),
        ],
      ),
    );
  }
}