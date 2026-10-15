import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app/app_fonts.dart';
import '../../../app/island_world_style.dart';
import '../../../core/audio_service.dart';
import '../../../core/game_data.dart';
import '../../../core/growth/growth.dart';
import '../../../presentation/providers/game_state_provider.dart';
import '../../growth/certificates_screen.dart';
import '../../growth/weekly_report_screen.dart';

/// ═══════════════════════════════════════════════════════════════
/// 📘 REPORT CARD TAB — تب کارنامه و پیشرفت تحصیلی کودک
/// ═══════════════════════════════════════════════════════════════
class ReportCardTab extends ConsumerWidget {
  const ReportCardTab({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    ref.watch(gameStateProvider);
    final total = GameData.totalCorrect + GameData.totalWrong;
    final rate = total == 0 ? 0 : (GameData.totalCorrect / total * 100).toInt();
    final minutes = GameData.todayPlayMinutes;

    return Scaffold(
      backgroundColor: IslandWorldPalette.paper,
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 30),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // هدر کارنامه
              _buildHeader(context, rate),

              const SizedBox(height: 16),

              // خلاصه آمار عملکرد
              Row(
                children: [
                  Expanded(
                    child: _buildStatCard(
                      emoji: '🎯',
                      title: 'پاسخ‌های درست',
                      value: PersianDigits.toFa(GameData.totalCorrect),
                      color: IslandWorldPalette.success,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _buildStatCard(
                      emoji: '⏱️',
                      title: 'زمان یادگیری امروز',
                      value: '${PersianDigits.toFa(minutes)} دقیقه',
                      color: IslandWorldPalette.deepOcean,
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 16),

              // ── نسخه ۷: سطح جزیره و نوار تجربه ──
              _buildIslandLevelCard(),

              const SizedBox(height: 16),

              // پیشرفت در دروس و مهارت‌ها
              _sectionTitle('📊 وضعیت یادگیری موضوعات'),
              const SizedBox(height: 8),
              _buildSubjectsProgress(),

              const SizedBox(height: 20),

              // گواهینامه‌ها و مدارک پایان دوره
              _sectionTitle(
                '📜 کارنامه‌ها و گواهی‌های افتخار',
              ),
              const SizedBox(height: 8),
              _buildCertificatesTile(context),

              const SizedBox(height: 14),

              // دکمه گزارش تحلیلی کامل والدین
              GestureDetector(
                onTap: () {
                  HapticFeedback.mediumImpact();
                  AudioService.select();
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const WeeklyReportScreen()),
                  );
                },
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: IslandWorldPalette.skyMist,
                    borderRadius: BorderRadius.circular(
                      IslandWorldMetrics.buttonRadius,
                    ),
                    border: Border.all(
                      color: IslandWorldPalette.deepOcean.withOpacity(0.3),
                      width: 1.5,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: IslandWorldPalette.deepOcean.withOpacity(0.1),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(
                        Icons.analytics_rounded,
                        color: IslandWorldPalette.deepOcean,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'مشاهده گزارش تفصیلی والدین',
                        style: AppFonts.vazirmatn(
                          fontSize: 14,
                          fontWeight: FontWeight.w900,
                          color: IslandWorldPalette.deepOcean,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context, int rate) {
    final header = Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        gradient: IslandWorldGradients.sky,
        borderRadius: BorderRadius.circular(IslandWorldMetrics.cardRadius),
        border: Border.all(color: Colors.white.withOpacity(0.84), width: 1.5),
        boxShadow: [
          BoxShadow(
            color: IslandWorldPalette.deepOcean.withOpacity(0.14),
            blurRadius: 14,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 64,
            height: 64,
            decoration: BoxDecoration(
              color: IslandWorldPalette.honey.withOpacity(0.28),
              shape: BoxShape.circle,
            ),
            child: const Center(
              child: Text('📘', style: TextStyle(fontSize: 34)),
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'کارنامه پیشرفت تحصیلی',
                  style: AppFonts.kids(
                    fontSize: 20,
                    fontWeight: FontWeight.w900,
                    color: IslandWorldPalette.ink,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'میزان دقت و تسلط کلی: ${PersianDigits.toFa(rate)}٪ ⭐',
                  style: AppFonts.vazirmatn(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: IslandWorldPalette.deepOcean.withOpacity(0.86),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );

    final animationsDisabled =
        MediaQuery.maybeOf(context)?.disableAnimations ?? false;
    if (animationsDisabled) return header;

    return header
        .animate()
        .fadeIn(duration: IslandWorldMetrics.routeTransition)
        .slideY(
          begin: -0.08,
          duration: IslandWorldMetrics.routeTransition,
          curve: Curves.easeOutCubic,
        );
  }

  Widget _buildStatCard({
    required String emoji,
    required String title,
    required String value,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: IslandWorldPalette.paper,
        borderRadius: BorderRadius.circular(IslandWorldMetrics.buttonRadius),
        border: Border.all(color: color.withOpacity(0.28), width: 1.5),
        boxShadow: [
          BoxShadow(
            color: IslandWorldPalette.ink.withOpacity(0.06),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(emoji, style: const TextStyle(fontSize: 22)),
          const SizedBox(height: 6),
          Text(
            title,
            style: AppFonts.vazirmatn(
              fontSize: 11,
              color: IslandWorldPalette.mutedInk,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            value,
            style: AppFonts.vazirmatn(
              fontSize: 16,
              fontWeight: FontWeight.w900,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  Widget _sectionTitle(String title) {
    return Text(
      title,
      style: AppFonts.vazirmatn(
        fontSize: 15.5,
        fontWeight: FontWeight.w900,
        color: IslandWorldPalette.ink,
      ),
    );
  }

  /// ── نسخه ۷: کارت سطح جزیره — تجربهٔ یادگیری کودک ──
  Widget _buildIslandLevelCard() {
    final level = GameData.islandLevel;
    final progress = GameData.islandLevelProgress;
    final remaining = GameData.xpToNextIslandLevel;
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: IslandWorldGradients.meadow,
        borderRadius: BorderRadius.circular(IslandWorldMetrics.cardRadius),
        border: Border.all(
          color: IslandWorldPalette.foliage.withOpacity(0.38),
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: IslandWorldPalette.foliageDeep.withOpacity(0.12),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Text('🐿️', style: TextStyle(fontSize: 30)),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  'سطح جزیره: ${PersianDigits.toFa(level)} — ${GameData.islandLevelTitle}',
                  style: AppFonts.vazirmatn(
                    color: IslandWorldPalette.ink,
                    fontSize: 16,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),
              Text(
                '${PersianDigits.toFa(GameData.xp)} تجربه',
                style: AppFonts.vazirmatn(
                  color: IslandWorldPalette.deepOcean,
                  fontSize: 14,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          ClipRRect(
            borderRadius: BorderRadius.circular(IslandWorldMetrics.buttonRadius),
            child: LinearProgressIndicator(
              value: progress,
              minHeight: 12,
              backgroundColor: IslandWorldPalette.softOutline,
              valueColor: const AlwaysStoppedAnimation<Color>(
                IslandWorldPalette.foliageDeep,
              ),
            ),
          ),
          const SizedBox(height: 6),
          Text(
            '${PersianDigits.toFa(remaining)} تجربه تا سطح بعد — با بازی و یادگیری جمع می‌شود',
            style: AppFonts.vazirmatn(
              color: IslandWorldPalette.mutedInk,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSubjectsProgress() {
    final subjects = [
      (
        'فارسی و الفبا',
        '🔤',
        (GameData.skills['alphabet'] ?? 0) / 20.0,
        IslandWorldPalette.wood,
      ),
      (
        'ریاضی و شمارش',
        '🔢',
        (GameData.skills['math'] ?? 0) / 20.0,
        IslandWorldPalette.deepOcean,
      ),
      (
        'علوم و حیوانات',
        '🦁',
        (GameData.skills['animals'] ?? 0) / 20.0,
        IslandWorldPalette.foliage,
      ),
      (
        'هنر و نقاشی',
        '🎨',
        (GameData.skills['colors'] ?? 0) / 20.0,
        IslandWorldPalette.coral,
      ),
      (
        'مهارت‌های زندگی',
        '🧭',
        (GameData.skills['concepts'] ?? 0) / 20.0,
        IslandWorldPalette.ocean,
      ),
      (
        'هوش و منطق',
        '🕵️',
        (GameData.skills['logic'] ?? 0) / 20.0,
        IslandWorldPalette.lavender,
      ),
    ];

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: IslandWorldPalette.paper,
        borderRadius: BorderRadius.circular(IslandWorldMetrics.cardRadius),
        border: Border.all(color: IslandWorldPalette.softOutline),
        boxShadow: [
          BoxShadow(
            color: IslandWorldPalette.ink.withOpacity(0.06),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        children: subjects.map((s) {
          final progress = s.$3.clamp(0.0, 1.0).toDouble();
          return Padding(
            padding: const EdgeInsets.symmetric(vertical: 6),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Text(s.$2, style: const TextStyle(fontSize: 16)),
                        const SizedBox(width: 6),
                        Text(
                          s.$1,
                          style: AppFonts.vazirmatn(
                            fontSize: 13,
                            fontWeight: FontWeight.w800,
                            color: IslandWorldPalette.ink,
                          ),
                        ),
                      ],
                    ),
                    Text(
                      '${PersianDigits.toFa((progress * 100).toInt())}٪',
                      style: AppFonts.vazirmatn(
                        fontSize: 12,
                        fontWeight: FontWeight.w900,
                        color: IslandWorldPalette.ink,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                ClipRRect(
                  borderRadius:
                      BorderRadius.circular(IslandWorldMetrics.buttonRadius),
                  child: LinearProgressIndicator(
                    value: progress,
                    minHeight: 8,
                    backgroundColor: s.$4.withOpacity(0.15),
                    valueColor: AlwaysStoppedAnimation<Color>(s.$4),
                  ),
                ),
              ],
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildCertificatesTile(BuildContext context) {
    return GestureDetector(
      onTap: () {
        HapticFeedback.lightImpact();
        AudioService.tap();
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const CertificatesScreen()),
        );
      },
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: IslandWorldPalette.paper,
          borderRadius: BorderRadius.circular(IslandWorldMetrics.buttonRadius),
          border: Border.all(color: IslandWorldPalette.softOutline),
          boxShadow: [
            BoxShadow(
              color: IslandWorldPalette.deepOcean.withOpacity(0.08),
              blurRadius: 8,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: IslandWorldPalette.skyMist,
                borderRadius: BorderRadius.circular(14),
              ),
              child: const Center(
                child: Text('📜', style: TextStyle(fontSize: 26)),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'گواهی‌های افتخار و فارغ‌التحصیلی',
                    style: AppFonts.vazirmatn(
                      fontSize: 14,
                      fontWeight: FontWeight.w900,
                      color: IslandWorldPalette.ink,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    'دریافت مدرک پایان دوره‌های آموزشی با نام کودک',
                    style: AppFonts.vazirmatn(
                      fontSize: 11,
                      color: IslandWorldPalette.mutedInk,
                    ),
                  ),
                ],
              ),
            ),
            const Icon(
              Icons.arrow_back_ios_new_rounded,
              size: 16,
              color: IslandWorldPalette.deepOcean,
            ),
          ],
        ),
      ),
    );
  }
}
