import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../app/app_colors.dart';
import '../../core/app_legal.dart';
import '../../core/game_data.dart';

/// ═══════════════════════════════════════════════
/// 👨‍👩‍👧 پنل والدین — Parent Panel
/// تنظیمات ساده‌ی کنترل والدین و آمار
/// ═══════════════════════════════════════════════
class ParentPanel extends StatefulWidget {
  const ParentPanel({super.key});
  @override
  State<ParentPanel> createState() => _ParentPanelState();
}

class _ParentPanelState extends State<ParentPanel> {
  late bool _soundEnabled;
  late int _timeLimit;

  @override
  void initState() {
    super.initState();
    _soundEnabled = GameData.soundEnabled;
    _timeLimit = GameData.timeLimitMinutes;
    GameData.changes.addListener(_onDataChanged);
  }

  void _onDataChanged() {
    if (mounted) setState(() {});
  }

  @override
  void dispose() {
    GameData.changes.removeListener(_onDataChanged);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'پنل والدین',
          style: GoogleFonts.vazirmatn(fontWeight: FontWeight.w800),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          // Child stats summary
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: AppGradients.primary,
              borderRadius: BorderRadius.circular(24),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'آمار فرزند شما',
                  style: GoogleFonts.vazirmatn(
                    color: Colors.white,
                    fontWeight: FontWeight.w800,
                    fontSize: 18,
                  ),
                ),
                const SizedBox(height: 12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _stat('⭐', '${GameData.stars} ستاره'),
                    _stat('💰', '${GameData.coins} سکه'),
                    _stat('🎯', '${GameData.totalCorrect} جواب'),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),

          // Sound toggle
          SwitchListTile(
            value: _soundEnabled,
            onChanged: (v) {
              setState(() => _soundEnabled = v);
              GameData.setSoundEnabled(v);
            },
            title: Text('صدا و افکت‌ها',
                style: GoogleFonts.vazirmatn(fontWeight: FontWeight.w600)),
            subtitle: const Text('پخش صدا در بازی‌ها'),
          ),

          // AI is an entitlement, not a setting. The old switch let a child
          // unlock a paid feature by simply toggling it in the parent panel.
          ListTile(
            leading: Icon(
              GameData.aiBuddyUnlocked
                  ? Icons.auto_awesome_rounded
                  : Icons.lock_rounded,
              color: GameData.aiBuddyUnlocked
                  ? AppColors.primary
                  : AppColors.textLight,
            ),
            title: Text(
              'دستیار هوشمند (AI Buddy)',
              style: GoogleFonts.vazirmatn(fontWeight: FontWeight.w600),
            ),
            subtitle: Text(
              GameData.aiBuddyUnlocked
                  ? 'فعال است'
                  : 'با خرید یا باز کردن این قابلیت فعال می‌شود',
            ),
          ),

          // Time limit
          ListTile(
            leading: const Icon(Icons.timer_rounded),
            title: Text('محدودیت زمان بازی',
                style: GoogleFonts.vazirmatn(fontWeight: FontWeight.w600)),
            subtitle: Text(
              '$_timeLimit دقیقه در روز • امروز ${GameData.todayPlaySeconds ~/ 60} دقیقه',
            ),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                IconButton(
                  icon: const Icon(Icons.remove_circle_outline),
                  onPressed: _timeLimit > 15
                      ? () {
                          setState(() => _timeLimit -= 15);
                          GameData.setTimeLimitMinutes(_timeLimit);
                        }
                      : null,
                ),
                IconButton(
                  icon: const Icon(Icons.add_circle_outline),
                  onPressed: _timeLimit < 240
                      ? () {
                          setState(() => _timeLimit =
                              (_timeLimit + 15).clamp(15, 240).toInt());
                          GameData.setTimeLimitMinutes(_timeLimit);
                        }
                      : null,
                ),
              ],
            ),
          ),
          const Divider(height: 28),
          ListTile(
            leading: const Icon(Icons.info_outline_rounded),
            title: Text(
              'درباره و پشتیبانی',
              style: GoogleFonts.vazirmatn(fontWeight: FontWeight.w600),
            ),
            subtitle: const Text(AppLegal.supportEmail),
            trailing: const Icon(Icons.chevron_left_rounded),
            onTap: () => Navigator.pushNamed(context, '/about'),
          ),
        ],
      ),
    );
  }

  Widget _stat(String emoji, String label) {
    return Column(
      children: [
        Text(emoji, style: const TextStyle(fontSize: 26)),
        const SizedBox(height: 4),
        Text(
          label,
          style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w700),
        ),
      ],
    );
  }
}
