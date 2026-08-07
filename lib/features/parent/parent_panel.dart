import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../app/app_colors.dart';
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
  late bool _aiEnabled;
  late int _timeLimit;

  @override
  void initState() {
    super.initState();
    _soundEnabled = GameData.soundEnabled;
    _aiEnabled = GameData.aiBuddyUnlocked;
    _timeLimit = GameData.timeLimitMinutes;
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
              GameData.soundEnabled = v;
              GameData.save();
            },
            title: Text('صدا و افکت‌ها',
                style: GoogleFonts.vazirmatn(fontWeight: FontWeight.w600)),
            subtitle: const Text('پخش صدا در بازی‌ها'),
          ),

          // AI buddy toggle
          SwitchListTile(
            value: _aiEnabled,
            onChanged: (v) {
              setState(() => _aiEnabled = v);
              GameData.aiBuddyUnlocked = v;
              GameData.save();
            },
            title: Text('دستیار هوشمند (AI Buddy)',
                style: GoogleFonts.vazirmatn(fontWeight: FontWeight.w600)),
            subtitle: const Text('کمک‌رسان هوشمند در بازی‌ها'),
          ),

          // Time limit
          ListTile(
            leading: const Icon(Icons.timer_rounded),
            title: Text('محدودیت زمان بازی',
                style: GoogleFonts.vazirmatn(fontWeight: FontWeight.w600)),
            subtitle: Text('$_timeLimit دقیقه در روز'),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                IconButton(
                  icon: const Icon(Icons.remove_circle_outline),
                  onPressed: _timeLimit > 15
                      ? () {
                          setState(() => _timeLimit -= 15);
                          GameData.timeLimitMinutes = _timeLimit;
                          GameData.save();
                        }
                      : null,
                ),
                IconButton(
                  icon: const Icon(Icons.add_circle_outline),
                  onPressed: () {
                    setState(() => _timeLimit += 15);
                    GameData.timeLimitMinutes = _timeLimit;
                    GameData.save();
                  },
                ),
              ],
            ),
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
