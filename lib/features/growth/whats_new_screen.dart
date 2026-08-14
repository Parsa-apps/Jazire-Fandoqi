import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

import '../../app/app_colors.dart';
import '../../app/app_fonts.dart';
import '../../app/design_tokens.dart';
import '../../core/growth/growth.dart';
import '../../core/growth/whats_new.dart';

/// ═══════════════════════════════════════════════════════════════
/// 🎁 صفحه تازه‌های نسخه — طراحی پرمیوم، کارتی، انیمیشندار
/// ═══════════════════════════════════════════════════════════════
class WhatsNewScreen extends StatelessWidget {
  const WhatsNewScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // ── پس‌زمینه گرادینت
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Color(0xFF6C5CE7),
                  Color(0xFF00B894),
                  Color(0xFF00CEC9),
                ],
                stops: [0.0, 0.55, 1.0],
              ),
            ),
          ),

          // ── دایره‌های تزئینی محو
          Positioned(
            top: -80, right: -60,
            child: _blob(220, Colors.white.withOpacity(0.08)),
          ),
          Positioned(
            bottom: -100, left: -80,
            child: _blob(280, Colors.white.withOpacity(0.07)),
          ),

          SafeArea(
            child: Column(
              children: [
                const SizedBox(height: 8),
                // ── دکمه بستن
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  child: Row(
                    children: [
                      IconButton(
                        onPressed: () {
                          GrowthStore.markWhatsNewSeen();
                          Navigator.pop(context);
                        },
                        icon: const Icon(Icons.close_rounded,
                            color: Colors.white, size: 26),
                        style: IconButton.styleFrom(
                          backgroundColor: Colors.white.withOpacity(0.15),
                          shape: const CircleBorder(),
                        ),
                      ),
                    ],
                  ),
                ),

                // ── هدر
                _buildHeader(),

                // ── لیست تغییرات
                Expanded(
                  child: ListView(
                    padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
                    children: [
                      for (int i = 0; i < WhatsNew.sections.length; i++)
                        _SectionCard(section: WhatsNew.sections[i], index: i),

                      const SizedBox(height: 20),

                      // ── پیام پایانی
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.12),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(color: Colors.white24),
                        ),
                        child: Row(
                          children: [
                            const Text('💌', style: TextStyle(fontSize: 32)),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                'نظرات شما چراغ راه ماست. اگر پیشنهاد یا انتقادی دارید، از پنل والدین با ما در میان بگذارید.',
                                style: AppFonts.vazirmatn(
                                  color: Colors.white.withOpacity(0.95),
                                  fontSize: 12,
                                  height: 1.7,
                                ),
                                textAlign: TextAlign.justify,
                              ),
                            ),
                          ],
                        ),
                      ).animate().fadeIn(delay: 400.ms, duration: 600.ms).slideY(begin: 0.2),

                      const SizedBox(height: 20),

                      // ── دکمه شروع
                      SizedBox(
                        width: double.infinity,
                        height: 58,
                        child: ElevatedButton(
                          onPressed: () {
                            GrowthStore.markWhatsNewSeen();
                            Navigator.pop(context);
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.white,
                            foregroundColor: const Color(0xFF6C5CE7),
                            elevation: 8,
                            shadowColor: Colors.black26,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(20),
                            ),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Icon(Icons.rocket_launch_rounded, size: 22),
                              const SizedBox(width: 10),
                              Text(
                                'بزن بریم بازی کنیم 🎮',
                                style: AppFonts.vazirmatn(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w900,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ).animate().fadeIn(delay: 500.ms).slideY(begin: 0.3),

                      const SizedBox(height: 8),
                      Center(
                        child: Text(
                          'نسخه ${WhatsNew.version} ${WhatsNew.buildNumber}',
                          style: AppFonts.vazirmatn(
                            color: Colors.white54,
                            fontSize: 11,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 4, 20, 16),
      child: Column(
        children: [
          // آیکون بزرگ فندقی
          Container(
            width: 110, height: 110,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: const LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [Color(0xFFFFEAA2), Color(0xFFFFD166)],
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.2),
                  blurRadius: 25,
                  offset: const Offset(0, 10),
                ),
              ],
            ),
            child: const Center(
              child: Text('🌴🥥🌴',
                  style: TextStyle(fontSize: 44, height: 1)),
            ),
          )
              .animate(onPlay: (c) => c.repeat(reverse: true))
              .scale(begin: const Offset(1, 1), end: const Offset(1.06, 1.06), duration: 1500.ms, curve: Curves.easeInOut),

          const SizedBox(height: 14),

          ShaderMask(
            shaderCallback: (b) => const LinearGradient(
              colors: [Colors.yellowAccent, Colors.white],
            ).createShader(b),
            child: Text(
              '✨ تازه چه‌خبر؟',
              style: AppFonts.vazirmatn(
                fontSize: 30,
                fontWeight: FontWeight.w900,
                color: Colors.white,
              ),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'نسخه ${WhatsNew.version} — ${WhatsNew.versionName}',
            style: AppFonts.vazirmatn(
              color: Colors.white.withOpacity(0.85),
              fontSize: 13,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.15),
              borderRadius: BorderRadius.circular(30),
              border: Border.all(color: Colors.white24),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text('🎁', style: TextStyle(fontSize: 16)),
                const SizedBox(width: 8),
                Text(
                  'کلی بهبود، امنیت و تازگی برای بچه‌ها',
                  style: AppFonts.vazirmatn(
                    color: Colors.white,
                    fontSize: 11.5,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    ).animate().fadeIn(duration: 500.ms).slideY(begin: -0.15);
  }

  Widget _blob(double size, Color color) {
    return Container(
      width: size, height: size,
      decoration: BoxDecoration(shape: BoxShape.circle, color: color),
    );
  }
}

class _SectionCard extends StatelessWidget {
  final WhatsNewSection section;
  final int index;
  const _SectionCard({required this.section, required this.index});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.08),
              blurRadius: 18,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── هدر دسته‌بندی (نوار رنگی)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
              decoration: BoxDecoration(
                color: section.color,
                borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.25),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(section.emoji,
                        style: const TextStyle(fontSize: 22)),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      section.title,
                      style: AppFonts.vazirmatn(
                        color: Colors.white,
                        fontSize: 15,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.25),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      '${section.items.length} مورد',
                      style: AppFonts.vazirmatn(
                        color: Colors.white,
                        fontSize: 10,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // ── آیتم‌ها
            Padding(
              padding: const EdgeInsets.fromLTRB(6, 8, 6, 8),
              child: Column(
                children: [
                  for (int j = 0; j < section.items.length; j++)
                    _ItemTile(
                      item: section.items[j],
                      color: section.color,
                      delay: Duration(milliseconds: 150 + index * 80 + j * 100),
                    ),
                ],
              ),
            ),
          ],
        ),
      ).animate().fadeIn(delay: Duration(milliseconds: 120 + index * 100), duration: 500.ms)
       .slideX(begin: 0.08, end: 0, delay: Duration(milliseconds: 120 + index * 100), duration: 500.ms, curve: Curves.easeOutCubic),
    );
  }
}

class _ItemTile extends StatelessWidget {
  final WhatsNewItem item;
  final Color color;
  final Duration delay;
  const _ItemTile({required this.item, required this.color, required this.delay});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // آیکون
          Container(
            width: 44, height: 44,
            decoration: BoxDecoration(
              color: color.withOpacity(0.12),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Center(
              child: Text(item.emoji, style: const TextStyle(fontSize: 24)),
            ),
          ),
          const SizedBox(width: 12),

          // متن‌ها
          Expanded(
            child: Padding(
              padding: const EdgeInsets.only(top: 2),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          item.title,
                          style: AppFonts.vazirmatn(
                            fontSize: 13.5,
                            fontWeight: FontWeight.w900,
                            color: const Color(0xFF2D3436),
                          ),
                        ),
                      ),
                      Icon(Icons.check_circle_rounded,
                          color: color, size: 18),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    item.body,
                    style: AppFonts.vazirmatn(
                      fontSize: 11.5,
                      height: 1.7,
                      color: Colors.black54,
                      fontWeight: FontWeight.w500,
                    ),
                    textAlign: TextAlign.justify,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    ).animate().fadeIn(delay: delay, duration: 400.ms).slideX(begin: 0.1);
  }
}
