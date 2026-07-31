import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:confetti/confetti.dart';
import '../core/game_data.dart';
import '../core/theme.dart';
import '../widgets/fandoghi.dart';
import '../widgets/common.dart';

/// صندوق جایزه - جایزه‌های روزانه و هفتگی
class PrizeBoxScreen extends StatefulWidget {
  const PrizeBoxScreen({super.key});
  @override
  State<PrizeBoxScreen> createState() => _PrizeBoxScreenState();
}

class _PrizeBoxScreenState extends State<PrizeBoxScreen>
    with TickerProviderStateMixin {
  late ConfettiController _confetti;
  String? _openedPrize;
  int? _prizeAmount;

  final List<_PrizeItem> _dailyPrizes = [
    _PrizeItem(id: 'daily_1', emoji: '🎁', label: 'جعبه کوچک',
        minReward: 10, maxReward: 30, type: 'coins'),
    _PrizeItem(id: 'daily_2', emoji: '⭐', label: 'ستاره',
        minReward: 1, maxReward: 3, type: 'stars'),
    _PrizeItem(id: 'daily_3', emoji: '🎪', label: 'جعبه بزرگ',
        minReward: 30, maxReward: 80, type: 'coins'),
    _PrizeItem(id: 'daily_4', emoji: '🌟', label: 'سوپر ستاره',
        minReward: 3, maxReward: 5, type: 'stars'),
  ];

  final List<_PrizeItem> _weeklyPrizes = [
    _PrizeItem(id: 'weekly_1', emoji: '👑', label: 'تاج طلایی',
        minReward: 100, maxReward: 200, type: 'coins'),
    _PrizeItem(id: 'weekly_2', emoji: '💎', label: 'الماس',
        minReward: 5, maxReward: 10, type: 'stars'),
    _PrizeItem(id: 'weekly_3', emoji: '🏆', label: 'جام قهرمانی',
        minReward: 150, maxReward: 300, type: 'coins'),
  ];

  @override
  void initState() {
    super.initState();
    _confetti = ConfettiController(duration: const Duration(seconds: 2));
  }

  @override
  void dispose() {
    _confetti.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Color(0xFFFFD700),
                  Color(0xFFFFA500),
                  Color(0xFFFF8C00),
                ],
              ),
            ),
          ),
          SafeArea(
            child: Column(
              children: [
                _buildHeader(),
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      children: [
                        _buildFandoghiTip(),
                        const SizedBox(height: 16),
                        _buildTokenDisplay(),
                        const SizedBox(height: 20),
                        _buildSectionTitle('🎁 جایزه‌های روزانه'),
                        const SizedBox(height: 12),
                        _buildPrizeGrid(_dailyPrizes),
                        const SizedBox(height: 24),
                        _buildSectionTitle('🏆 جایزه‌های هفتگی'),
                        const SizedBox(height: 12),
                        _buildPrizeGrid(_weeklyPrizes),
                        const SizedBox(height: 24),
                        _buildTreasureChest(),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
          Align(
            alignment: Alignment.topCenter,
            child: ConfettiWidget(
              confettiController: _confetti,
              blastDirectionality: BlastDirectionality.explosive,
              numberOfParticles: 25,
              colors: const [
                Colors.amber, Colors.orange, Colors.yellow,
                Colors.pink, Colors.purple,
              ],
            ),
          ),
          // Prize reveal overlay
          if (_openedPrize != null) _buildPrizeReveal(),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          const Text(
            '🎁 صندوق جایزه',
            style: TextStyle(
              color: Colors.white,
              fontSize: 22,
              fontWeight: FontWeight.bold,
            ),
          ),
          const Spacer(),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.star_rounded,
                    color: Colors.white, size: 18),
                const SizedBox(width: 4),
                Text(
                  '${GameData.stars}',
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFandoghiTip() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.9),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        children: [
          const Fandoghi(size: 45, animate: true),
          const SizedBox(width: 12),
          const Expanded(
            child: Text(
              'هر روز بیا و جایزه‌هات رو بگیر!\nهرچی بیشتر بازی کنی، جایزه بیشتری داری.',
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: Color(0xFF5D4037),
                height: 1.5,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTokenDisplay() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.9),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: Colors.amber.withOpacity(0.2),
              shape: BoxShape.circle,
            ),
            child: const Text('🎟️', style: TextStyle(fontSize: 24)),
          ),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'توکن جایزه',
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey,
                ),
              ),
              Text(
                '${GameData.prizeBoxTokens}',
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.amber,
                ),
              ),
            ],
          ),
          const Spacer(),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: Colors.green.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              '🔥 ${GameData.streak} روز',
              style: const TextStyle(
                color: Colors.green,
                fontWeight: FontWeight.bold,
                fontSize: 13,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: const TextStyle(
        color: Colors.white,
        fontSize: 18,
        fontWeight: FontWeight.bold,
        shadows: [
          Shadow(color: Colors.black26, blurRadius: 4),
        ],
      ),
    );
  }

  Widget _buildPrizeGrid(List<_PrizeItem> prizes) {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
        childAspectRatio: 1.0,
      ),
      itemCount: prizes.length,
      itemBuilder: (context, i) {
        final prize = prizes[i];
        final isClaimed = GameData.openedPrizes.contains(prize.id);
        return BounceBtn(
          onTap: isClaimed ? () {} : () => _claimPrize(prize),
          child: Container(
            decoration: BoxDecoration(
              color: isClaimed
                  ? Colors.grey.withOpacity(0.3)
                  : Colors.white.withOpacity(0.95),
              borderRadius: BorderRadius.circular(20),
              boxShadow: isClaimed
                  ? []
                  : [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  isClaimed ? '✅' : prize.emoji,
                  style: const TextStyle(fontSize: 40),
                ).animate(onPlay: isClaimed
                    ? (c) {}
                    : (c) => c.repeat(reverse: true)).moveY(
                  duration: Duration(seconds: 2 + i % 2),
                  begin: -3,
                  end: 3,
                ),
                const SizedBox(height: 8),
                Text(
                  prize.label,
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                    color: isClaimed ? Colors.grey : Colors.black87,
                  ),
                ),
                if (isClaimed)
                  const Text(
                    'دریافت شد',
                    style: TextStyle(
                      fontSize: 10,
                      color: Colors.green,
                    ),
                  ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildTreasureChest() {
    final canOpen = GameData.canOpenTreasure();
    return BounceBtn(
      onTap: canOpen
          ? () {
              GameData.addCoins(100);
              GameData.treasureOpened = true;
              GameData.addStars(5);
              GameData.save();
              _confetti.play();
              setState(() {
                _openedPrize = '🎪';
                _prizeAmount = 100;
              });
            }
          : () {},
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          gradient: canOpen
              ? const LinearGradient(
                  colors: [Color(0xFFFFD700), Color(0xFFFF8C00)],
                )
              : LinearGradient(
                  colors: [
                    Colors.grey.shade300,
                    Colors.grey.shade400,
                  ],
                ),
          borderRadius: BorderRadius.circular(24),
          boxShadow: canOpen
              ? [
                  BoxShadow(
                    color: Colors.amber.withOpacity(0.5),
                    blurRadius: 20,
                    spreadRadius: 2,
                  ),
                ]
              : [],
        ),
        child: Column(
          children: [
            Text(
              canOpen ? '🎪' : '🔒',
              style: const TextStyle(fontSize: 50),
            ).animate(onPlay: canOpen
                ? (c) => c.repeat(reverse: true)
                : (c) {}).scale(
              duration: 800.ms,
              begin: const Offset(0.9, 0.9),
              end: const Offset(1.1, 1.1),
            ),
            const SizedBox(height: 8),
            Text(
              canOpen ? 'صندوق گنج آماده‌ست!' : 'ماموریت‌ها رو کامل کن',
              style: TextStyle(
                color: canOpen ? Colors.white : Colors.grey.shade600,
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            if (!canOpen)
              Text(
                '${GameData.dailyMissions}/3 ماموریت انجام شده',
                style: TextStyle(
                  color: Colors.grey.shade500,
                  fontSize: 12,
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildPrizeReveal() {
    return GestureDetector(
      onTap: () => setState(() => _openedPrize = null),
      child: Container(
        color: Colors.black.withOpacity(0.7),
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                _openedPrize ?? '',
                style: const TextStyle(fontSize: 100),
              ).animate().scale(
                    duration: 600.ms,
                    curve: Curves.elasticOut,
                  ),
              const SizedBox(height: 20),
              Text(
                'تبریک! 🎉',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                ),
              ).animate().fadeIn(delay: 300.ms),
              const SizedBox(height: 10),
              Text(
                '+$_prizeAmount جایزه گرفتی!',
                style: const TextStyle(
                  color: Colors.amber,
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                ),
              ).animate().fadeIn(delay: 500.ms),
              const SizedBox(height: 30),
              const Text(
                'برای ادامه کلیک کن',
                style: TextStyle(color: Colors.white54),
              ).animate().fadeIn(delay: 800.ms),
            ],
          ),
        ),
      ),
    );
  }

  void _claimPrize(_PrizeItem prize) {
    HapticFeedback.mediumImpact();
    final rng = Random();
    final amount =
        rng.nextInt(prize.maxReward - prize.minReward + 1) + prize.minReward;

    if (prize.type == 'stars') {
      GameData.addStars(amount);
    } else {
      GameData.addCoins(amount);
    }

    GameData.openedPrizes.add(prize.id);
    GameData.save();

    _confetti.play();
    setState(() {
      _openedPrize = prize.emoji;
      _prizeAmount = amount;
    });
  }
}

class _PrizeItem {
  final String id;
  final String emoji;
  final String label;
  final int minReward;
  final int maxReward;
  final String type;

  _PrizeItem({
    required this.id,
    required this.emoji,
    required this.label,
    required this.minReward,
    required this.maxReward,
    required this.type,
  });
}
