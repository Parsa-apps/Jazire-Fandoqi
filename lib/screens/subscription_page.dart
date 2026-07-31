import 'package:flutter/material.dart';
import '../core/game_data.dart';
import '../core/monetization.dart';

class SubPage extends StatelessWidget {
  const SubPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        title: const Text('اشتراک ویژه کودک دانا'),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            const Icon(Icons.workspace_premium, size: 90, color: Color(0xFFFBBF24)),
            const SizedBox(height: 16),
            const Text(
              'کودک دانا پلاس',
              style: TextStyle(fontSize: 28, fontWeight: FontWeight.w900),
            ),
            const SizedBox(height: 8),
            const Text(
              'دسترسی کامل به همه ماژول‌ها + هوش مصنوعی + بدون تبلیغات',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 15, color: Colors.black54),
            ),
            const SizedBox(height: 30),

            // Plans
            _planCard(
              context,
              title: 'ماهانه',
              price: '۴۹,۰۰۰',
              period: 'تومان / ماه',
              color: const Color(0xFF6366F1),
              onBuy: () => _buySubscription(context, 'monthly'),
            ),
            const SizedBox(height: 16),
            _planCard(
              context,
              title: 'سالانه',
              price: '۳۹۹,۰۰۰',
              period: 'تومان / سال',
              color: const Color(0xFF22C55E),
              discount: '۳۰٪ تخفیف',
              onBuy: () => _buySubscription(context, 'yearly'),
              isPopular: true,
            ),

            const SizedBox(height: 30),

            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: Colors.amber.shade200),
              ),
              child: Column(
                children: const [
                  _BenefitRow(icon: Icons.check_circle, text: 'همه بازی‌ها و ماژول‌ها باز'),
                  _BenefitRow(icon: Icons.check_circle, text: 'دوست هوش مصنوعی (AI Buddy)'),
                  _BenefitRow(icon: Icons.check_circle, text: 'بدون هیچ تبلیغی'),
                  _BenefitRow(icon: Icons.check_circle, text: 'گزارش پیشرفت PDF برای والدین'),
                  _BenefitRow(icon: Icons.check_circle, text: 'چرخ شانس نامحدود'),
                  _BenefitRow(icon: Icons.check_circle, text: 'محتوای انحصاری هفتگی'),
                ],
              ),
            ),

            const SizedBox(height: 30),
            const Text(
              'پرداخت امن از طریق کافه‌بازار و مایکت',
              style: TextStyle(color: Colors.grey, fontSize: 13),
            ),
          ],
        ),
      ),
    );
  }

  Widget _planCard(
    BuildContext context, {
    required String title,
    required String price,
    required String period,
    required Color color,
    required VoidCallback onBuy,
    String? discount,
    bool isPopular = false,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: isPopular ? Border.all(color: color, width: 3) : null,
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.08), blurRadius: 15)],
      ),
      child: Stack(
        children: [
          if (isPopular)
            Positioned(
              top: 12,
              right: 16,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
                decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(12)),
                child: const Text('محبوب‌ترین', style: TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.bold)),
              ),
            ),
          Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                const SizedBox(height: 8),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(price, style: TextStyle(fontSize: 32, fontWeight: FontWeight.w900, color: color)),
                    const SizedBox(width: 6),
                    Text(period, style: const TextStyle(fontSize: 14, color: Colors.grey)),
                  ],
                ),
                if (discount != null) ...[
                  const SizedBox(height: 4),
                  Text(discount, style: const TextStyle(color: Colors.green, fontWeight: FontWeight.bold)),
                ],
                const SizedBox(height: 18),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: color,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    ),
                    onPressed: onBuy,
                    child: const Text('خرید از کافه‌بازار', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _buySubscription(BuildContext context, String plan) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('پرداخت'),
        content: Text('در حال اتصال به کافه‌بازار...\n\nپلن: $plan'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('بستن')),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(context);
              // TODO: Replace with real CafeBazaar/Myket billing call before
              // release and only activate premium after billing confirms.
              await Monetization.activatePremium();
              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('اشتراک با موفقیت فعال شد! 🎉')),
                );
              }
            },
            child: const Text('تایید پرداخت'),
          ),
        ],
      ),
    );
  }
}

class _BenefitRow extends StatelessWidget {
  final IconData icon;
  final String text;

  const _BenefitRow({required this.icon, required this.text});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          Icon(icon, color: Colors.green, size: 20),
          const SizedBox(width: 12),
          Text(text, style: const TextStyle(fontSize: 15)),
        ],
      ),
    );
  }
}