import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'billing_service.dart';
import 'game_data.dart';

/// Monetization helper for CafeBazaar & Myket.
///
/// A local boolean is useful for debug sandbox UX but is never trusted by a
/// release build. Release entitlement requires a non-empty receipt token
/// returned by the native store bridge. The real native SDK should additionally
/// validate the receipt according to the store's official protocol.
class Monetization {
  static const String _subscriptionKey = 'is_premium';
  static const String _receiptTokenKey = 'premium_receipt_token';
  static const String _lastPurchaseDate = 'last_purchase';

  static const String productIdMonthly = 'sub_monthly';
  static const String productIdYearly = 'sub_yearly';

  static Future<bool> isPremium() async {
    final prefs = await SharedPreferences.getInstance();
    if (!kReleaseMode) {
      return prefs.getBool(_subscriptionKey) ?? false;
    }

    // Do not trust a cached flag/token in release: a subscription can expire
    // or be refunded. Ask the store bridge for the current entitlement.
    final restored = await BillingService.restorePurchases();
    if (!restored.success ||
        restored.purchaseToken == null ||
        restored.purchaseToken!.isEmpty) {
      return false;
    }
    await prefs.setString(_receiptTokenKey, restored.purchaseToken!);
    return true;
  }

  /// Activates access only after a successful store result.
  static Future<bool> activatePremium(BillingResult result) async {
    if (!result.success) return false;
    if (kReleaseMode &&
        (result.purchaseToken == null || result.purchaseToken!.isEmpty)) {
      return false;
    }

    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_subscriptionKey, true);
    if (result.purchaseToken != null && result.purchaseToken!.isNotEmpty) {
      await prefs.setString(_receiptTokenKey, result.purchaseToken!);
    }
    await prefs.setString(_lastPurchaseDate, DateTime.now().toIso8601String());
    return true;
  }

  /// Restores an entitlement after reinstall/device change. The native bridge
  /// must return a currently valid subscription receipt.
  static Future<bool> restorePremium() async {
    final result = await BillingService.restorePurchases();
    return activatePremium(result);
  }

  static Future<bool> buySubscription(
    BuildContext context, {
    required String plan,
  }) async {
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
    final activated = await activatePremium(result);
    if (!context.mounted) return activated;

    if (activated) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('اشتراک با موفقیت فعال شد! 🎉'),
          backgroundColor: Colors.green,
        ),
      );
      return true;
    }

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          result.message.isEmpty ? 'پرداخت تأیید نشد' : result.message,
        ),
        backgroundColor: Colors.red,
      ),
    );
    return false;
  }

  /// Shows a store purchase confirmation. The child-facing UI never receives
  /// a success message until the native bridge has returned a valid result.
  static Future<void> showPurchaseDialog(
    BuildContext context, {
    required String productId,
    required String productName,
    required int price,
  }) async {
    if (await isPremium()) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('شما قبلاً اشتراک دارید!')),
        );
      }
      return;
    }

    if (!context.mounted) return;
    await showDialog<void>(
      context: context,
      builder: (dialogContext) => AlertDialog(
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
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('انصراف'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
            onPressed: () async {
              Navigator.pop(dialogContext);
              final result = await BillingService.purchaseSubscription(productId);
              final activated = await activatePremium(result);
              if (!context.mounted) return;
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                    activated
                        ? '$productName با موفقیت خریداری شد!'
                        : (result.message.isEmpty
                            ? 'پرداخت تأیید نشد'
                            : result.message),
                  ),
                  backgroundColor: activated ? Colors.green : Colors.red,
                ),
              );
            },
            child: const Text('پرداخت'),
          ),
        ],
      ),
    );
  }

  /// In-app purchase for coins/stars (consumable, real-money).
  static Future<void> purchaseInAppItem(
    BuildContext context, {
    required String itemId,
    required int coins,
    required int stars,
    required int price,
  }) async {
    await showDialog<void>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('خرید داخل برنامه'),
        content: Text(
          'آیا می‌خواهید $coins سکه و $stars ستاره به قیمت $price تومان بخرید؟',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('نه'),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(dialogContext);
              var result = await BillingService.purchaseConsumable(itemId);
              if (result.success && result.purchaseToken != null) {
                final consumed = await BillingService.consumePurchase(
                  result.purchaseToken!,
                );
                if (!consumed.success) result = consumed;
              }
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
