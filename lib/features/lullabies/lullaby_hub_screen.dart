import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../app/app_colors.dart';
import '../../app/app_fonts.dart';
import '../../core/audio_service.dart';
import '../../core/fandoghi_coach.dart';
import '../../core/learning_content/lullabies_data.dart';
import '../../shared/widgets/fandoghi_v2.dart';
import 'lullaby_player_screen.dart';

/// ═══════════════════════════════════════════════════════
/// 🌙 LULLABY HUB — بخش لالایی‌های آرام برای خواب کودکان
/// ۱۰ لالایی شیرین با تصویر اختصاصی و صدای بچگانه
/// ═══════════════════════════════════════════════════════
class LullabyHubScreen extends StatefulWidget {
  const LullabyHubScreen({super.key});

  @override
  State<LullabyHubScreen> createState() => _LullabyHubScreenState();
}

class _LullabyHubScreenState extends State<LullabyHubScreen> {
  @override
  void initState() {
    super.initState();
    // فندقی فقط در بخش بازی/یادگیری حضور دارد.
    FandoghiCoach.disablePersistentPresence();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        FandoghiCoach.say(
          'به بخش لالایی‌های شیرین خوش اومدی 🌙 هر لالایی رو انتخاب کن تا با صدای آروم برات بخونم...',
          mood: FandoghiMood.happy,
          duration: const Duration(seconds: 4),
        );
      }
    });
  }

  void _openLullaby(Lullaby lullaby) {
    HapticFeedback.lightImpact();
    AudioService.sleepChime();
    Navigator.of(context).push(
      MaterialPageRoute(
        settings: RouteSettings(name: '/lullaby/${lullaby.id}'),
        builder: (_) => LullabyPlayerScreen(lullaby: lullaby),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0F0D24),
      body: SafeArea(
        child: Column(
          children: [
            _buildTopBar(),
            Expanded(
              child: CustomScrollView(
                physics: const BouncingScrollPhysics(),
                slivers: [
                  SliverToBoxAdapter(child: _buildWelcomeBanner()),
                  SliverToBoxAdapter(child: _buildInfoCard()),
                  SliverPadding(
                    padding: const EdgeInsets.fromLTRB(16, 12, 16, 90),
                    sliver: _buildGrid(),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      floatingActionButton: _buildBackFab(),
    );
  }

  Widget _buildTopBar() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
      child: Row(
        children: [
          GestureDetector(
            onTap: () => Navigator.of(context).canPop()
                ? Navigator.of(context).pop()
                : Navigator.of(context).pushReplacementNamed('/home'),
            child: Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.1),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.white12),
              ),
              child: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white, size: 20),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Row(
              children: [
                const Text('🌙', style: TextStyle(fontSize: 24)),
                const SizedBox(width: 8),
                Text('لالایی‌های شیرین',
                    style: AppFonts.vazirmatn(fontSize: 19, fontWeight: FontWeight.w900, color: Colors.white)),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(
              color: Colors.indigo.withOpacity(0.18),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: Colors.indigo.withOpacity(0.3)),
            ),
            child: const Row(
              children: [
                Icon(Icons.music_note_rounded, color: Colors.indigoAccent, size: 16),
                SizedBox(width: 4),
                Text('۱۰ لالایی', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 12)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildWelcomeBanner() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 6, 16, 10),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          gradient: const LinearGradient(colors: [Color(0xFF1A237E), Color(0xFF5C6BC0)]),
          borderRadius: BorderRadius.circular(22),
          boxShadow: [BoxShadow(color: Colors.indigo.withOpacity(0.35), blurRadius: 12, offset: const Offset(0, 4))],
        ),
        child: Row(
          children: [
            const FandoghiV2(size: 64, mood: FandoghiMood.happy),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('۱۰ لالایی آرام برای خواب شیرین',
                      style: AppFonts.vazirmatn(color: Colors.white, fontSize: 15, fontWeight: FontWeight.w900)),
                  const SizedBox(height: 4),
                  Text('با تصویر اختصاصی و صدای بچگانه آرامبخش 🌟 هر لالایی با تکرار پخش می‌شود تا خوابت ببرد.',
                      style: TextStyle(color: Colors.white.withOpacity(0.9), fontSize: 12, fontWeight: FontWeight.bold, height: 1.5)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoCard() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.06),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.white12),
        ),
        child: Row(
          children: [
            const Text('💡', style: TextStyle(fontSize: 18)),
            const SizedBox(width: 8),
            Expanded(
              child: Text('روی هر لالایی بزن تا با صدای آروم و تصویر قشنگش پخش شود. می‌تونی روی تکرار بذاری!',
                  style: AppFonts.vazirmatn(color: Colors.white70, fontSize: 11, fontWeight: FontWeight.w700, height: 1.5)),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildGrid() {
    return SliverGrid(
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        mainAxisSpacing: 14,
        crossAxisSpacing: 14,
        childAspectRatio: 0.72,
      ),
      delegate: SliverChildBuilderDelegate(
        (context, index) {
          final lullaby = LullabiesData.all[index];
          return GestureDetector(
            onTap: () => _openLullaby(lullaby),
            child: Container(
              decoration: BoxDecoration(
                color: const Color(0xFF1E1B38),
                borderRadius: BorderRadius.circular(22),
                border: Border.all(color: lullaby.themeColor.withOpacity(0.3), width: 1.5),
                boxShadow: [BoxShadow(color: lullaby.themeColor.withOpacity(0.15), blurRadius: 10, offset: const Offset(0, 4))],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      flex: 3,
                      child: Stack(
                        fit: StackFit.expand,
                        children: [
                          Image.asset(lullaby.coverAsset, fit: BoxFit.cover,
                              errorBuilder: (_, __, ___) => Container(
                                    color: lullaby.themeColor.withOpacity(0.3),
                                    alignment: Alignment.center,
                                    child: Text(lullaby.coverEmoji, style: const TextStyle(fontSize: 54)),
                                  )),
                          Positioned(
                            top: 8,
                            right: 8,
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                              decoration: BoxDecoration(
                                color: Colors.black.withOpacity(0.5),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Row(
                                children: [
                                  const Icon(Icons.access_time_rounded, color: Colors.white70, size: 12),
                                  const SizedBox(width: 4),
                                  Text(lullaby.duration, style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold)),
                                ],
                              ),
                            ),
                          ),
                          Positioned(
                            bottom: 6,
                            left: 8,
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                              decoration: BoxDecoration(color: Colors.black.withOpacity(0.6), borderRadius: BorderRadius.circular(10)),
                              child: const Text('پخش با صدای بچگانه 🌙', style: TextStyle(color: Colors.white, fontSize: 9, fontWeight: FontWeight.bold)),
                            ),
                          ),
                        ],
                      ),
                    ),
                    Expanded(
                      flex: 2,
                      child: Padding(
                        padding: const EdgeInsets.fromLTRB(10, 8, 10, 8),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text('${lullaby.coverEmoji} ${lullaby.title}',
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: AppFonts.vazirmatn(color: Colors.white, fontWeight: FontWeight.w800, fontSize: 13)),
                            Text(lullaby.subtitle,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(color: Colors.white.withOpacity(0.6), fontSize: 11)),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text('🌙 لالایی',
                                    style: TextStyle(color: lullaby.themeColor.withOpacity(0.9), fontSize: 10, fontWeight: FontWeight.bold)),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                  decoration: BoxDecoration(color: lullaby.themeColor.withOpacity(0.35), borderRadius: BorderRadius.circular(10)),
                                  child: const Text('پخش 🎵', style: TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold)),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ).animate(delay: Duration(milliseconds: index * 80)).fadeIn(duration: 400.ms).slideY(begin: 0.2);
        },
        childCount: LullabiesData.all.length,
      ),
    );
  }

  Widget _buildBackFab() {
    return GestureDetector(
      onTap: () => Navigator.of(context).pushReplacementNamed('/gateway'),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
        decoration: BoxDecoration(
          gradient: AppGradients.primary,
          borderRadius: BorderRadius.circular(30),
          boxShadow: [BoxShadow(color: AppColors.primary.withOpacity(0.5), blurRadius: 20, offset: const Offset(0, 6))],
          border: Border.all(color: Colors.white.withOpacity(0.4), width: 1.5),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.home_rounded, color: Colors.white, size: 24),
            const SizedBox(width: 10),
            Text('بازگشت به جزیره 🏝️', style: AppFonts.vazirmatn(fontSize: 15, fontWeight: FontWeight.w900, color: Colors.white)),
          ],
        ),
      ),
    ).animate(onPlay: (c) => c.repeat(reverse: true)).moveY(begin: 0, end: -4, duration: 1500.ms);
  }
}
