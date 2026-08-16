import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app/app_colors.dart';
import '../../../app/app_fonts.dart';
import '../../../core/audio_service.dart';
import '../../../core/fandoghi_coach.dart';
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
      backgroundColor: const Color(0xFFF4F7F9),
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 30),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // هدر کارنامه
              _buildHeader(rate),

              const SizedBox(height: 16),

              // خلاصه آمار عملکرد
              Row(
                children: [
                  Expanded(
                    child: _buildStatCard(
                      emoji: '🎯',
                      title: 'پاسخ‌های درست',
                      value: PersianDigits.toFa(GameData.totalCorrect),
                      color: const Color(0xFF2E7D32),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _buildStatCard(
                      emoji: '⏱️',
                      title: 'زمان یادگیری امروز',
                      value: '${PersianDigits.toFa(minutes)} دقیقه',
                      color: const Color(0xFF0277BD),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 16),

              // پیشرفت در دروس و مهارت‌ها
              _sectionTitle('📊 وضعیت یادگیری موضوعات'),
              const SizedBox(height: 8),
              _buildSubjectsProgress(),

              const SizedBox(height: 20),

              // گواهینامه‌ها و مدارک پایان دوره
              _sectionTitle('📜 کارنامه‌ها و گواهی‌های افتخار'),
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
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: const Color(0xFF00ACC1), width: 1.5),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFF00ACC1).withOpacity(0.15),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.analytics_rounded, color: Color(0xFF00838F)),
                      const SizedBox(width: 8),
                      Text(
                        'مشاهده گزارش تفصیلی والدین',
                        style: AppFonts.vazirmatn(
                          fontSize: 14,
                          fontWeight: FontWeight.w900,
                          color: const Color(0xFF00838F),
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

  Widget _buildHeader(int rate) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF00838F), Color(0xFF00ACC1)],
        ),
        borderRadius: BorderRadius.circular(28),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF00ACC1).withOpacity(0.35),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 64,
            height: 64,
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.25),
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
                  style: AppFonts.vazirmatn(
                    fontSize: 20,
                    fontWeight: FontWeight.w900,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'میزان دقت و تسلط کلی: ${PersianDigits.toFa(rate)}٪ ⭐',
                  style: AppFonts.vazirmatn(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: Colors.white.withOpacity(0.92),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    ).animate().fadeIn(duration: 400.ms).slideY(begin: -0.1);
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
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withOpacity(0.3), width: 1.5),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
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
            style: TextStyle(fontSize: 11, color: Colors.grey.shade600, fontWeight: FontWeight.bold),
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
        color: const Color(0xFF2C3E50),
      ),
    );
  }

  Widget _buildSubjectsProgress() {
    final subjects = [
      ('فارسی و الفبا', '🔤', (GameData.skills['alphabet'] ?? 0) / 20.0, const Color(0xFFD35400)),
      ('ریاضی و شمارش', '🔢', (GameData.skills['math'] ?? 0) / 20.0, const Color(0xFF8E44AD)),
      ('علوم و حیوانات', '🦁', (GameData.skills['animals'] ?? 0) / 20.0, const Color(0xFF27AE60)),
      ('هنر و نقاشی', '🎨', (GameData.skills['colors'] ?? 0) / 20.0, const Color(0xFFE74C3C)),
      ('مهارت‌های زندگی', '🧭', (GameData.skills['concepts'] ?? 0) / 20.0, const Color(0xFF00897B)),
    ];

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        children: subjects.map((s) {
          final progress = s.$3.clamp(0.0, 1.0);
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
                            color: const Color(0xFF2C3E50),
                          ),
                        ),
                      ],
                    ),
                    Text(
                      '${(progress * 100).toInt()}٪',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w900,
                        color: s.$4,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                ClipRRect(
                  borderRadius: BorderRadius.circular(8),
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
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: const Color(0xFFFFB300), width: 1.5),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.04),
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
                color: const Color(0xFFFFF8E1),
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
                      color: const Color(0xFF2C3E50),
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    'دریافت مدرک پایان دوره‌های آموزشی با نام کودک',
                    style: TextStyle(fontSize: 11, color: Colors.grey.shade600),
                  ),
                ],
              ),
            ),
            const Icon(Icons.arrow_back_ios_new_rounded, size: 16, color: Color(0xFFFFB300)),
          ],
        ),
      ),
    );
  }
}
