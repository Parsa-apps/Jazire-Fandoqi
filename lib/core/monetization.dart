import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'billing_service.dart';
import 'game_data.dart';

/// Monetization helper for CafeBazaar & Myket
///
/// تمام خریدها از طریق [BillingService] انجام می‌شوند و اشتراک فقط
/// زمانی فعال می‌شود که استور خرید را تایید کرده باشد.
class Monetization {
  static const String _subscriptionKey = 'is_premium';
  static const String _lastPurchaseDate = 'last_purchase';

  /// شناسه محصولات اشتراک در پنل کافه‌بازار/مایکت
  static const String productIdMonthly = 'sub_monthly';
  static const String productIdYearly = 'sub_yearly';

  /// Check if user has premium subscription
  static Future<bool> isPremium() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_subscriptionKey) ?? false;
  }

  /// Activate premium — ONLY call after [BillingResult.success]
  static Future<void> activatePremium() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_subscriptionKey, true);
    await prefs.setString(_lastPurchaseDate, DateTime.now().toIso8601String());
  }

  /// خرید اشتراک از استور و فعال‌سازی فقط در صورت تایید پرداخت.
  /// مقدار برگشتی: آیا کاربر حالا اشتراک فعال دارد یا نه.
  static Future<bool> buySubscription(BuildContext context, {required String plan}) async {
    if (await isPremium()) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('شما قبلاً اشتراک دارید!')),
        );
      }
      return true;
    }

    final productId = plan == 'yearly' ? productIdYearly : productIdMonthly;
    final result = await BillingService.purchaseSubscription(productId);
    if (!context.mounted) return result.success;

    if (result.success) {
      await activatePremium();
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('اشتراک با موفقیت فعال شد! 🎉'),
            backgroundColor: Colors.green,
          ),
        );
      }
      return true;
    }

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(result.message),
        backgroundColor: Colors.red,
      ),
    );
    return false;
  }

  /// Show purchase dialog for Bazaar/Myket
  static Future<void> showPurchaseDialog(BuildContext context, {
    required String productId,
    required String productName,
    required int price,
  }) async {
    final isPremiumUser = await isPremium();

    if (isPremiumUser) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('شما قبلاً اشتراک دارید!')),
        );
      }
      return;
    }

    if (!context.mounted) return;
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
              final result = await BillingService.purchaseSubscription(productId);
              if (!context.mounted) return;
              if (result.success) {
                await activatePremium();
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('$productName با موفقیت خریداری شد!'),
                      backgroundColor: Colors.green,
                    ),
                  );
                }
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(result.message),
                    backgroundColor: Colors.red,
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

  /// In-app purchase for coins/stars (consumable, real-money)
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
              final result = await BillingService.purchaseConsumable(itemId);
              if (!context.mounted) return;
              if (result.success) {
                if (coins > 0) GameData.addCoins(coins);
                if (stars > 0) GameData.addStars(stars);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('خرید موفق!'),
                    backgroundColor: Colors.green,
                  ),
                );
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(result.message),
                    backgroundColor: Colors.red,
                  ),
                );
              }
            },
            child: const Text('خرید'),
          ),
        ],
      ),
    );
  }
}
