import 'package:flutter/material.dart';
import '../core/game_data.dart';
import '../core/monetization.dart';
import '../widgets/common.dart';

class Shop extends StatefulWidget {
  const Shop({super.key});
  @override
  State<Shop> createState() => _ShopState();
}

class _ShopState extends State<Shop> {
  final List<_ShopItem> items = [
    _ShopItem(id: 's1', emoji: '⭐', name: 'بسته ستاره کوچک', price: 50, type: 'stars', amount: 10),
    _ShopItem(id: 's2', emoji: '🌟', name: 'بسته ستاره بزرگ', price: 120, type: 'stars', amount: 30),
    _ShopItem(id: 'c1', emoji: '💰', name: 'بسته سکه کوچک', price: 80, type: 'coins', amount: 200),
    _ShopItem(id: 'c2', emoji: '💎', name: 'بسته سکه بزرگ', price: 180, type: 'coins', amount: 500),
    _ShopItem(id: 'p1', emoji: '👑', name: 'تاج طلایی', price: 250, type: 'sticker', amount: 0),
    _ShopItem(id: 'p2', emoji: '🦸', name: 'لباس قهرمان', price: 300, type: 'sticker', amount: 0),
    _ShopItem(id: 'p3', emoji: '🚀', name: 'موشک جادویی', price: 220, type: 'sticker', amount: 0),
    _ShopItem(id: 'ai', emoji: '🤖', name: 'دوست AI (نامحدود)', price: 450, type: 'premium', amount: 0),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('فروشگاه کودک دانا'),
        backgroundColor: const Color(0xFF6366F1),
        foregroundColor: Colors.white,
      ),
      body: Column(
        children: [
          // Balance header
          Container(
            padding: const EdgeInsets.all(16),
            color: const Color(0xFF6366F1).withOpacity(0.08),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _balanceChip('⭐ ${GameData.stars}', Colors.amber),
                const SizedBox(width: 16),
                _balanceChip('💰 ${GameData.coins}', Colors.orange),
              ],
            ),
          ),

          Expanded(
            child: GridView.builder(
              padding: const EdgeInsets.all(16),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 14,
                mainAxisSpacing: 14,
                childAspectRatio: 0.85,
              ),
              itemCount: items.length,
              itemBuilder: (context, i) {
                final item = items[i];
                final owned = GameData.stickers.contains(item.id) || (item.type == 'premium' && GameData.aiBuddyUnlocked);

                return BounceBtn(
                  onTap: () {
                    if (owned) return;
                    _buyItem(item);
                  },
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(22),
                      boxShadow: [
                        BoxShadow(color: Colors.black.withOpacity(0.08), blurRadius: 12, offset: const Offset(0, 4)),
                      ],
                      border: owned ? Border.all(color: Colors.green, width: 3) : null,
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(item.emoji, style: const TextStyle(fontSize: 48)),
                        const SizedBox(height: 8),
                        Text(
                          item.name,
                          textAlign: TextAlign.center,
                          style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 12),
                        if (owned)
                          const Chip(
                            label: Text('خریداری شده', style: TextStyle(color: Colors.white)),
                            backgroundColor: Colors.green,
                          )
                        else
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 6),
                            decoration: BoxDecoration(
                              color: const Color(0xFF6366F1),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Text(
                              item.type == 'premium' ? '۱۰۰ ستاره' : '${item.price} سکه',
                              style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                            ),
                          ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _balanceChip(String text, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(30),
        boxShadow: [BoxShadow(color: color.withOpacity(0.2), blurRadius: 8)],
      ),
      child: Text(text, style: TextStyle(fontWeight: FontWeight.bold, color: color)),
    );
  }

  void _buyItem(_ShopItem item) {
    if (GameData.coins < item.price && item.type != 'premium') {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('سکه کافی نیست!')),
      );
      return;
    }

    if (item.type == 'premium') {
      if (GameData.aiBuddyUnlocked) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('این قابلیت قبلاً خریداری شده!')),
        );
        return;
      }
      if (GameData.stars < 100) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('برای AI نامحدود حداقل ۱۰۰ ستاره نیاز است')),
        );
        return;
      }
      GameData.stars -= 100;
      GameData.aiBuddyUnlocked = true;
      Monetization.activatePremium();
    } else {
      GameData.coins -= item.price;
    }

    if (item.type == 'stars') {
      GameData.addStars(item.amount);
    } else if (item.type == 'coins') {
      GameData.addCoins(item.amount);
    } else if (item.type == 'sticker') {
      GameData.stickers.add(item.id);
    }

    GameData.save();
    setState(() {});

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('${item.name} با موفقیت خریداری شد! 🎉')),
    );
  }
}

class _ShopItem {
  final String id;
  final String emoji;
  final String name;
  final int price;
  final String type; // stars, coins, sticker, premium
  final int amount;

  _ShopItem({
    required this.id,
    required this.emoji,
    required this.name,
    required this.price,
    required this.type,
    required this.amount,
  });
}